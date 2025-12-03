import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../data/local/preferences.dart';
import '../data/remote/response/login_response.dart';
import 'Recognition.dart';

class Recognizer {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;

  // ✅ Increased resolution for better feature extraction
  static const int WIDTH = 160;  // Keep at 160x160 as the model expects this
  static const int HEIGHT = 160;
  static const int OUTPUT = 512;

  final prefsHelper = Preferences();
  Map<String, Recognition> registered = Map();

  // ✅ Store multiple embeddings per person for more robust matching
  Map<String, List<List<double>>> multipleEmbeddings = Map();
  @override
  String get modelName => 'assets/facenet.tflite';

  Recognizer({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
    loadRegisteredFaces();
  }

  void loadRegisteredFaces() async {
    final userData = await prefsHelper.getFaceUser();
    print('🔍 Loading registered faces...');
    if (userData != null) {
      String name = userData['name'];
      String embeddingStr = userData['embedding'];
      print('✅ Found user data for: $name');
      print('📊 Embedding length: ${embeddingStr.length} characters');
      if (embeddingStr.isNotEmpty) {
        List<double> embd;

        try {
          // If it's stored as JSON array
          if (embeddingStr.startsWith('[') && embeddingStr.endsWith(']')) {
            // Remove brackets and split
            String cleanStr = embeddingStr.substring(1, embeddingStr.length - 1);
            embd = cleanStr.split(',').map((e) => double.parse(e.trim())).toList();
          } else {
            // If it's comma-separated without brackets
            embd = embeddingStr.split(',').map((e) => double.parse(e.trim())).toList();
          }

          print('📦 Loaded embedding with ${embd.length} dimensions');

          // ✅ IMPORTANT: The stored embedding is ALREADY normalized during registration
          // DO NOT normalize again or it will be double-normalized!
          // embd = _normalizeEmbedding(embd);

          Recognition recognition = Recognition(name, Rect.zero, embd, 0);
          registered.putIfAbsent(name, () => recognition);

          // ✅ Store in multiple embeddings map as well
          multipleEmbeddings.putIfAbsent(name, () => [embd]);

          print('✅ Successfully loaded registered face for: $name');
          print('📊 Total registered faces: ${registered.length}');
        } catch (e) {
          print('❌ Error loading face embedding: $e');
        }
      } else {
        print('⚠️ Embedding string is empty for user: $name');
      }
    } else {
      print('⚠️ No user data found in preferences');
    }
  }
  // void loadRegisteredFaces() async {
  //   final userData = await prefsHelper.getFaceUser();
  //   if (userData != null) {
  //     String name = userData['name'];
  //     String embeddingStr = userData['embedding'];
  //     if (embeddingStr.isNotEmpty) {
  //       List<double> embd = embeddingStr.split(',').map((e) => double.parse(e.trim())).toList().cast<double>();
  //       Recognition recognition = Recognition(name, Rect.zero, embd, 0);
  //       registered.putIfAbsent(name, () => recognition);
  //       print('Loaded registered face: $name');
  //     } else {
  //       print('Face embedding is empty for user: $name');
  //     }
  //   } else {
  //     print('No registered face found in shared preferences');
  //   }
  // }

  // Method to refresh face data after registration
  void refreshRegisteredFaces() {
    registered.clear();
    loadRegisteredFaces();
  }

  Future<Uint8List> compressImage(Uint8List imageData,
      {int maxSizeInKB = 500}) async {
    img.Image? image = img.decodeImage(imageData);
    if (image == null) throw Exception('Image decoding failed');

    // Resize to smaller dimensions if necessary
    img.Image resized = img.copyResize(image, width: 300); // ~300px width

    int quality = 85; // Start with high quality
    Uint8List jpg;

    do {
      jpg = Uint8List.fromList(img.encodeJpg(resized, quality: quality));
      quality -= 5;
    } while (jpg.lengthInBytes > maxSizeInKB * 1024 && quality > 20);

    return jpg;
  }

  /// ✅ Enhanced registration with embedding normalization
  void registerFaceInDB(String name, List<double> embedding, Uint8List faceImage) async {
    // ✅ Normalize embedding before storing
    embedding = _normalizeEmbedding(embedding);

    // Update face data in user preferences
    final userData = await prefsHelper.getUserData();
    if (userData != null) {
      // Update the face data in the user data structure
      userData.faceData = FaceData(
        id: userData.faceData?.id,
        userId: userData.id.toString(),
        name: name,
        embeddings: embedding.join(","),
        faceImageBase64: base64Encode(faceImage),
        createdAt: userData.faceData?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Save updated user data
      await prefsHelper.saveUserData(userData);
    }

    // Also add to in-memory registered map
    Recognition recognition = Recognition(name, Rect.zero, embedding, 0);
    registered.putIfAbsent(name, () => recognition);

    // ✅ Store in multiple embeddings map
    multipleEmbeddings.putIfAbsent(name, () => []);
    multipleEmbeddings[name]!.add(embedding);
  }

  /// ✅ Register multiple embeddings for the same person (better accuracy)
  void registerMultipleFaces(String name, List<List<double>> embeddings, Uint8List primaryFaceImage) async {
    if (embeddings.isEmpty) return;

    // Normalize all embeddings
    List<List<double>> normalizedEmbeddings = embeddings.map((emb) => _normalizeEmbedding(emb)).toList();

    // Use the first embedding as the primary one for storage
    List<double> primaryEmbedding = normalizedEmbeddings.first;

    // Update face data in user preferences
    final userData = await prefsHelper.getUserData();
    if (userData != null) {
      userData.faceData = FaceData(
        id: userData.faceData?.id,
        userId: userData.id.toString(),
        name: name,
        embeddings: primaryEmbedding.join(","),
        faceImageBase64: base64Encode(primaryFaceImage),
        createdAt: userData.faceData?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await prefsHelper.saveUserData(userData);
    }

    // Store primary in registered map
    Recognition recognition = Recognition(name, Rect.zero, primaryEmbedding, 0);
    registered[name] = recognition;

    // ✅ Store all embeddings for improved matching
    multipleEmbeddings[name] = normalizedEmbeddings;

    print('Registered $name with ${embeddings.length} embeddings for improved accuracy');
  }

  Future<Uint8List?> getStoredFaceImage(String name) async {
    try {
      final userData = await prefsHelper.getFaceUser();
      if (userData != null && userData['name'] == name) {
        return userData['image'] as Uint8List?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }


  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName);
    } catch (e) {
    }
  }

  /// ✅ Enhanced preprocessing with better normalization
  img.Image _preprocessImage(img.Image inputImage) {
    // Apply histogram equalization for better contrast
    inputImage = img.adjustColor(inputImage,
      contrast: 1.1,
      brightness: 1.0,
    );

    // Apply slight sharpening to enhance features (3x3 kernel)
    inputImage = img.convolution(inputImage,
      filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0
      ],
      div: 1,
      offset: 0,
    );

    return inputImage;
  }

  List<dynamic> imageToArray(img.Image inputImage) {
    // ✅ DISABLED preprocessing - it was causing inconsistent embeddings
    // inputImage = _preprocessImage(inputImage);

    img.Image resizedImage = img.copyResize(inputImage, width: WIDTH, height: HEIGHT);
    List<double> flattenedList = resizedImage.data!.expand((channel) => [channel.r, channel.g, channel.b]).map((value) => value.toDouble()).toList();
    Float32List float32Array = Float32List.fromList(flattenedList);
    int channels = 3;
    int height = HEIGHT;
    int width = WIDTH;
    Float32List reshapedArray = Float32List(1 * height * width * channels);
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int index = c * height * width + h * width + w;
          // ✅ Improved normalization to [-1, 1] range
          reshapedArray[index] = (float32Array[c * height * width + h * width + w] - 127.5) / 127.5;
        }
      }
    }
    return reshapedArray.reshape([1, WIDTH, HEIGHT, 3]);
  }

  Recognition recognize(img.Image image, Rect location) {
    // Crop face from image, resize it and convert it to float array
    var input = imageToArray(image);

    // Output array
    List output = List.filled(1 * OUTPUT, 0).reshape([1, OUTPUT]);

    // Performs inference
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(input, output);
    final run = DateTime.now().millisecondsSinceEpoch - runs;

    // Convert dynamic list to double list
    List<double> outputArray = output.first.cast<double>();

    // ✅ Normalize the embedding before comparison
    outputArray = _normalizeEmbedding(outputArray);

    // ✅ Find nearest embedding with improved matching
    Pair pair = findNearestImproved(outputArray);

    return Recognition(pair.name, location, outputArray, pair.distance);
  }

  /// ✅ L2 normalization for consistent embedding comparison
  List<double> _normalizeEmbedding(List<double> embedding) {
    double sum = 0;
    for (double val in embedding) {
      sum += val * val;
    }
    double norm = sqrt(sum);
    if (norm == 0) return embedding;

    return embedding.map((val) => val / norm).toList();
  }


  /// ✅ Improved matching with multiple embeddings averaging
  Pair findNearestImproved(List<double> emb) {
    Pair pair = Pair("Unknown", -1);

    print('🔎 Searching for match in ${registered.length} registered faces');
    print('🔎 MultipleEmbeddings contains: ${multipleEmbeddings.keys.toList()}');

    for (MapEntry<String, Recognition> item in registered.entries) {
      final String name = item.key;

      // If multiple embeddings exist, average the similarity scores
      double maxSimilarity = -1;

      if (multipleEmbeddings.containsKey(name) && multipleEmbeddings[name]!.isNotEmpty) {
        print('📊 Comparing with ${multipleEmbeddings[name]!.length} embeddings for $name');
        for (List<double> knownEmb in multipleEmbeddings[name]!) {
          double similarity = _cosineSimilarity(emb, knownEmb);
          if (similarity > maxSimilarity) {
            maxSimilarity = similarity;
          }
        }
      } else {
        // Fallback to single embedding
        print('📊 Using single embedding for $name');
        List<double> knownEmb = item.value.embeddings;
        maxSimilarity = _cosineSimilarity(emb, knownEmb);
      }

      print('📈 Similarity for $name: $maxSimilarity (threshold: 0.75)');

      // Cosine similarity is between -1 and 1, where 1 means most similar
      if (pair.distance == -1 || maxSimilarity > pair.distance) {
        pair.distance = maxSimilarity;
        pair.name = name;
      }
    }

    print('🎯 Best match: ${pair.name} with similarity: ${pair.distance}');
    return pair;
  }

  /// ✅ Optimized cosine similarity calculation (assumes normalized embeddings)
  double _cosineSimilarity(List<double> emb1, List<double> emb2) {
    if (emb1.length != emb2.length) return -1;

    double dot = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < emb1.length; i++) {
      dot += emb1[i] * emb2[i];
      normA += emb1[i] * emb1[i];
      normB += emb2[i] * emb2[i];
    }

    double norm = sqrt(normA) * sqrt(normB);
    if (norm == 0) return -1;

    return dot / norm;
  }

  /// ✅ Legacy method for backward compatibility
  Pair findNearest(List<double> emb) {
    return findNearestImproved(emb);
  }


  void close() {
    interpreter.close();
  }

}
class Pair{
  String name;
  double distance;
  Pair(this.name,this.distance);
}


