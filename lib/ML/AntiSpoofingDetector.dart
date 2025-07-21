import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AntiSpoofingDetector {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;
  
  // Model input/output dimensions for anti-spoofing
  static const int WIDTH = 224;
  static const int HEIGHT = 224;
  static const int OUTPUT_SIZE = 2; // [fake, real] probabilities
  
  // Threshold for determining if face is real or fake
  static const double REAL_THRESHOLD = 0.5;
  
  @override
  String get modelName => 'assets/FaceAntiSpoofing.tflite';

  AntiSpoofingDetector({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();
    
    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName);
      print('Anti-spoofing model loaded successfully');
    } catch (e) {
      print('Unable to load anti-spoofing model: ${e.toString()}');
    }
  }

  List<dynamic> imageToArray(img.Image inputImage) {
    // Resize image to model input size
    img.Image resizedImage = img.copyResize(inputImage, width: WIDTH, height: HEIGHT);
    
    // Convert to float array normalized between 0-1
    List<double> flattenedList = resizedImage.data!
        .expand((channel) => [channel.r, channel.g, channel.b])
        .map((value) => value.toDouble() / 255.0)
        .toList();
    
    Float32List float32Array = Float32List.fromList(flattenedList);
    
    // Reshape to [1, HEIGHT, WIDTH, 3]
    return float32Array.reshape([1, HEIGHT, WIDTH, 3]);
  }

  Future<AntiSpoofingResult> detectSpoofing(img.Image faceImage) async {
    try {
      // Convert image to input array
      var input = imageToArray(faceImage);
      
      // Prepare output array
      List output = List.filled(1 * OUTPUT_SIZE, 0.0).reshape([1, OUTPUT_SIZE]);
      
      // Run inference
      final startTime = DateTime.now().millisecondsSinceEpoch;
      interpreter.run(input, output);
      final inferenceTime = DateTime.now().millisecondsSinceEpoch - startTime;
      
      // Extract probabilities
      List<double> probabilities = output.first.cast<double>();
      double fakeProb = probabilities[0];
      double realProb = probabilities[1];
      
      // Determine if face is real or fake
      bool isReal = realProb > REAL_THRESHOLD;
      double confidence = isReal ? realProb : fakeProb;
      
      print('Anti-spoofing result: Real=${realProb.toStringAsFixed(3)}, Fake=${fakeProb.toStringAsFixed(3)}, IsReal=$isReal');
      
      return AntiSpoofingResult(
        isReal: isReal,
        confidence: confidence,
        realProbability: realProb,
        fakeProbability: fakeProb,
        inferenceTime: inferenceTime,
      );
    } catch (e) {
      print('Error in anti-spoofing detection: ${e.toString()}');
      // Return default "real" result if model fails
      return AntiSpoofingResult(
        isReal: true,
        confidence: 0.5,
        realProbability: 0.5,
        fakeProbability: 0.5,
        inferenceTime: 0,
      );
    }
  }

  void close() {
    interpreter.close();
  }
}

class AntiSpoofingResult {
  final bool isReal;
  final double confidence;
  final double realProbability;
  final double fakeProbability;
  final int inferenceTime;

  AntiSpoofingResult({
    required this.isReal,
    required this.confidence,
    required this.realProbability,
    required this.fakeProbability,
    required this.inferenceTime,
  });

  @override
  String toString() {
    return 'AntiSpoofingResult(isReal: $isReal, confidence: ${confidence.toStringAsFixed(3)}, realProb: ${realProbability.toStringAsFixed(3)}, fakeProb: ${fakeProbability.toStringAsFixed(3)})';
  }
}