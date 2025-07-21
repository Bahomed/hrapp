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
  static const int WIDTH = 160;
  static const int HEIGHT = 160;
  static const int OUTPUT = 512;
  final prefsHelper = Preferences();
  Map<String,Recognition> registered = Map();
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
    if (userData != null) {
      String name = userData['name'];
      String embeddingStr = userData['embedding'];
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

          Recognition recognition = Recognition(name, Rect.zero, embd, 0);
          registered.putIfAbsent(name, () => recognition);
          print('Loaded registered face: $name');
        } catch (e) {
          print('Error parsing embedding for user $name: $e');
        }
      } else {
        print('Face embedding is empty for user: $name');
      }
    } else {
      print('No registered face found in shared preferences');
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

  void registerFaceInDB(String name, List<double> embedding, Uint8List faceImage) async {
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
    print('Registered face in memory and updated preferences: $name');
  }

  Future<Uint8List?> getStoredFaceImage(String name) async {
    try {
      final userData = await prefsHelper.getFaceUser();
      if (userData != null && userData['name'] == name) {
        return userData['image'] as Uint8List?;
      }
      return null;
    } catch (e) {
      print('Error getting stored face image: $e');
      return null;
    }
  }


  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName);
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  List<dynamic> imageToArray(img.Image inputImage){
    img.Image resizedImage = img.copyResize(inputImage!, width: WIDTH, height: HEIGHT);
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
          reshapedArray[index] = (float32Array[c * height * width + h * width + w]-127.5)/127.5;
        }
      }
    }
    return reshapedArray.reshape([1,WIDTH,HEIGHT,3]);
  }

  Recognition recognize(img.Image image,Rect location) {

    //TODO crop face from image resize it and convert it to float array
    var input = imageToArray(image);
    print(input.shape.toString());

    //TODO output array
    List output = List.filled(1*OUTPUT, 0).reshape([1,OUTPUT]);

    //TODO performs inference
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(input, output);
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms$output');

    //TODO convert dynamic list to double list
    List<double> outputArray = output.first.cast<double>();

    //TODO looks for the nearest embeeding in the database and returns the pair
    Pair pair = findNearest(outputArray);
    print("distance= ${pair.distance}");

    return Recognition(pair.name,location,outputArray,pair.distance);
  }


  //TODO  looks for the nearest embeeding in the database and returns the pair which contain information of registered face with which face is most similar
  Pair findNearest(List<double> emb) {
    Pair pair = Pair("Unknown", -1);
    for (MapEntry<String, Recognition> item in registered.entries) {
      final String name = item.key;
      List<double> knownEmb = item.value.embeddings;

      double dot = 0;
      double normA = 0;
      double normB = 0;
      for (int i = 0; i < emb.length; i++) {
        dot += emb[i] * knownEmb[i];
        normA += emb[i] * emb[i];
        normB += knownEmb[i] * knownEmb[i];
      }

      double similarity = dot / (sqrt(normA) * sqrt(normB));

      // Cosine similarity is between -1 and 1, where 1 means most similar
      if (pair.distance == -1 || similarity > pair.distance) {
        pair.distance = similarity;
        pair.name = name;
      }
    }

    return pair;
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


