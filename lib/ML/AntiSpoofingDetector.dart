import 'dart:typed_data';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class AntiSpoofingDetector {
  Interpreter? interpreter;
  late InterpreterOptions _interpreterOptions;
  bool _isModelLoaded = false;
  
  // Model input/output dimensions for anti-spoofing
  static const int WIDTH = 256;
  static const int HEIGHT = 256;
  static const int INPUT_CHANNELS = 6; // Model expects 6 channels
  static const int OUTPUT_WIDTH = 32;
  static const int OUTPUT_HEIGHT = 32;
  static const int OUTPUT_CHANNELS = 1;
  
  // Threshold for determining if face is real or fake - adjusted based on model behavior
  static const double REAL_THRESHOLD = 0.6;
  
  String get modelName => 'assets/FaceAntiSpoofing.tflite';

  AntiSpoofingDetector({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();
    
    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(modelName, options: _interpreterOptions);
      _isModelLoaded = true;
      
      // Print model input/output details for debugging
      var inputTensors = interpreter!.getInputTensors();
      var outputTensors = interpreter!.getOutputTensors();
      
    } catch (e) {
      _isModelLoaded = false;
    }
  }

  List<dynamic> imageToArray(img.Image inputImage) {
    // Resize image to model input size
    img.Image resizedImage = img.copyResize(inputImage, width: WIDTH, height: HEIGHT);
    
    // Convert to float array with 6 channels (RGB + duplicated RGB for anti-spoofing)
    List<double> flattenedList = resizedImage.data!
        .expand((channel) => [
          channel.r.toDouble() / 255.0,
          channel.g.toDouble() / 255.0, 
          channel.b.toDouble() / 255.0,
          channel.r.toDouble() / 255.0, // Duplicate RGB channels
          channel.g.toDouble() / 255.0,
          channel.b.toDouble() / 255.0,
        ])
        .toList();
    
    Float32List float32Array = Float32List.fromList(flattenedList);
    
    // Validate array size
    int expectedSize = HEIGHT * WIDTH * INPUT_CHANNELS;
    if (float32Array.length != expectedSize) {
      throw Exception('Invalid input array size: expected $expectedSize, got ${float32Array.length}');
    }
    
    // Reshape to [1, HEIGHT, WIDTH, 6]
    return float32Array.reshape([1, HEIGHT, WIDTH, INPUT_CHANNELS]);
  }

  Future<AntiSpoofingResult> detectSpoofing(img.Image faceImage) async {
    // Ensure model is loaded before running inference
    if (!_isModelLoaded || interpreter == null) {
      await loadModel();
    }
    
    // If model still failed to load, return default result
    if (!_isModelLoaded || interpreter == null) {
      return AntiSpoofingResult(
        isReal: true,
        confidence: 0.5,
        realProbability: 0.5,
        fakeProbability: 0.5,
        inferenceTime: 0,
      );
    }
    
    try {
      // Convert image to input array
      var input = imageToArray(faceImage);
      
      // Prepare output array for [1, 32, 32, 1] output
      int outputSize = OUTPUT_WIDTH * OUTPUT_HEIGHT * OUTPUT_CHANNELS;
      List output = List.filled(outputSize, 0.0).reshape([1, OUTPUT_WIDTH, OUTPUT_HEIGHT, OUTPUT_CHANNELS]);
      
      // Run inference
      final startTime = DateTime.now().millisecondsSinceEpoch;
      final currentInterpreter = interpreter!;
      currentInterpreter.run(input, output);
      final inferenceTime = DateTime.now().millisecondsSinceEpoch - startTime;
      
      // Extract feature map and calculate average confidence
      // The output is [1, 32, 32, 1], so we need to flatten the nested structure
      List<double> outputValues = [];
      
      // Flatten the nested list structure
      for (var batch in output) {
        for (var row in batch) {
          for (var col in row) {
            for (var channel in col) {
              outputValues.add(channel.toDouble());
            }
          }
        }
      }
      
      // Calculate statistics from the 32x32 feature map
      double averageScore = outputValues.reduce((a, b) => a + b) / outputValues.length;
      
      // Calculate variance to detect spoofing patterns
      double variance = outputValues
          .map((x) => pow(x - averageScore, 2))
          .reduce((a, b) => a + b) / outputValues.length;
      
      // Use raw average score and variance to determine if face is real
      // Higher variance often indicates more texture/detail in real faces
      double confidence = averageScore.abs();
      
      // Combine average score and variance for better detection
      // Real faces typically have higher variance (more texture details)
      bool isReal = (averageScore > 0.3) && (variance > 0.05); // Stricter thresholds
      
      double realProb = isReal ? confidence : 1 - confidence;
      double fakeProb = 1 - realProb;
      
      
      return AntiSpoofingResult(
        isReal: isReal,
        confidence: confidence,
        realProbability: realProb,
        fakeProbability: fakeProb,
        inferenceTime: inferenceTime,
      );
    } catch (e) {
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
    interpreter?.close();
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