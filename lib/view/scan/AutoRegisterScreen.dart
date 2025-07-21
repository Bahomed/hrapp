import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../ML/AntiSpoofingDetector.dart';
import '../../ML/Recognition.dart';
import '../../ML/Recognizer.dart';
import '../../data/local/preferences.dart';
import '../../repository/face_registration_repository.dart';
import '../../main.dart';
import '../../utils/Util.dart';
// Custom painter to create overlay with transparent circle
class CircleOverlayPainter extends CustomPainter {
  final Offset circleCenter;
  final double circleRadius;
  final Color overlayColor;

  CircleOverlayPainter({
    required this.circleCenter,
    required this.circleRadius,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // Create a path for the entire screen
    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path for the circle (hole)
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: circleCenter, radius: circleRadius));

    // Subtract the circle from the full screen to create a hole
    final overlayPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      circlePath,
    );

    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AutoRegisterScreen extends StatefulWidget {
  const AutoRegisterScreen({super.key});

  @override
  State<AutoRegisterScreen> createState() => _AutoRegisterScreenState();
}

class _AutoRegisterScreenState extends State<AutoRegisterScreen>
    with TickerProviderStateMixin {
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;

  late FaceDetector faceDetector;
  late Recognizer recognizer;
  late AntiSpoofingDetector antiSpoofingDetector;

  int currentStep = 0;
  bool isInitialized = false;
  bool isCapturing = false;
  List<img.Image> capturedFaces = [];
  List<Recognition> faceEmbeddings = [];
  CameraImage? frame;

  // Animation controllers
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  // Angle verification variables
  bool isAngleCorrect = false;
  String angleStatus = "Position your face";
  int correctAngleCount = 0;
  static const int requiredStableFrames = 8; // Reduced for faster response

  // Quality assessment variables
  bool isFaceQualityGood = false;
  double faceConfidence = 0.0;

  // Anti-spoofing variables
  bool isRealFace = true;
  double spoofingConfidence = 0.0;

  // UI enhancement variables
  bool showCountdown = false;
  int countdownValue = 3;

  // Performance optimization
  int frameSkipCounter = 0;
  static const int frameSkipInterval = 2; // Process every 3rd frame

  // Circle overlay dimensions
  static const double circleSize = 280;
  static const double circleRadius = circleSize / 2;

  final List<String> instructions = [
    "Look straight ahead",
    "Look up",
    "Look down",
    "Look to your left",
    "Look to your right"
  ];

  final List<String> subInstructions = [
    "Hold your phone still and look directly at the camera",
    "Tilt your head up slightly",
    "Tilt your head down slightly",
    "Turn your head to the left",
    "Turn your head to the right"
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _arrowAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _arrowAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start repeating animation
    _arrowAnimationController.repeat(reverse: true);

    initializeComponents();
  }

  void initializeComponents() async {
    // Initialize face detector with landmarks for angle detection
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: true,
        enableContours: false,
        enableTracking: true,
      ),
    );

    // Initialize face recognizer
    recognizer = Recognizer();

    // Initialize anti-spoofing detector
    antiSpoofingDetector = AntiSpoofingDetector();

    // Initialize camera
    await initializeCamera();
  }

  initializeCamera() async {
    controller = CameraController(
        description,
        ResolutionPreset.medium,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
        enableAudio: false
    );

    await controller.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        isInitialized = true;
      });

      controller.startImageStream((image) => {
        if (!isBusy && isCapturing) {
          isBusy = true,
          frame = image,
          doFaceDetectionOnFrame()
        }
      });
    });
  }

  doFaceDetectionOnFrame() async {
    // Performance optimization - skip frames
    frameSkipCounter++;
    if (frameSkipCounter % frameSkipInterval != 0) {
      setState(() {
        isBusy = false;
      });
      return;
    }

    InputImage? inputImage = getInputImage();
    if (inputImage == null) {
      setState(() {
        isBusy = false;
      });
      return;
    }

    List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isNotEmpty && faces.length == 1) {
      // Only proceed if exactly one face is detected
      Face face = faces.first;

      // Check if face is well-positioned, angle is correct, quality is good, and is real
      bool faceWellPositioned = isFaceWellPositioned(face);
      bool angleCorrect = isCorrectAngleForStep(face);
      bool qualityGood = assessFaceQuality(face);
      await checkAntiSpoofing(face);

      if (faceWellPositioned && angleCorrect && qualityGood && isRealFace) {
        correctAngleCount++;

        // Require stable detection for multiple frames
        if (correctAngleCount >= requiredStableFrames) {
          // Haptic feedback for successful capture
          HapticFeedback.mediumImpact();
          await captureFaceForCurrentStep(face);
          correctAngleCount = 0;
        } else {
          setState(() {
            isAngleCorrect = true;
            isFaceQualityGood = true;
            angleStatus = "Hold steady... ${correctAngleCount}/${requiredStableFrames}";
          });
        }
      } else {
        correctAngleCount = 0;
        setState(() {
          isAngleCorrect = false;
          // Only update angleStatus if it wasn't already set by quality assessment
          if (isFaceQualityGood || !qualityGood) {
            // Quality assessment sets its own status, so only override if quality is good
            if (qualityGood) {
              angleStatus = getAngleGuidanceMessage();
            }
          }
        });
      }
    } else {
      correctAngleCount = 0;
      setState(() {
        isAngleCorrect = false;
        isFaceQualityGood = false;
        angleStatus = faces.isEmpty ? "No face detected" : "Multiple faces detected";
      });
    }

    setState(() {
      isBusy = false;
    });
  }

  bool isFaceWellPositioned(Face face) {
    // Check if face is within reasonable bounds and size
    double faceWidth = face.boundingBox.width;
    double faceHeight = face.boundingBox.height;

    // Face should be reasonably sized (not too small or too large)
    return faceWidth > 80 && faceHeight > 80 &&
        faceWidth < 500 && faceHeight < 500;
  }

  bool isCorrectAngleForStep(Face face) {
    // Get head pose angles
    double? headEulerAngleX = face.headEulerAngleX; // Up/Down (pitch)
    double? headEulerAngleY = face.headEulerAngleY; // Left/Right (yaw)
    double? headEulerAngleZ = face.headEulerAngleZ; // Tilt (roll)

    if (headEulerAngleX == null || headEulerAngleY == null || headEulerAngleZ == null) {
      return false;
    }

    // For front camera, we need to adjust the angles because the image is mirrored
    if (camDirec == CameraLensDirection.front) {
      headEulerAngleY = -headEulerAngleY;
    }

    // More lenient angle thresholds
    const double tolerance = 15.0;
    const double rollTolerance = 25.0;

    switch (currentStep) {
      case 0: // Straight ahead
        return headEulerAngleX.abs() < tolerance &&
            headEulerAngleY.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 1: // Look up - SWAPPED: Try positive X values
        return headEulerAngleX > 8 && headEulerAngleX < 50 &&
            headEulerAngleY.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 2: // Look down - SWAPPED: Try negative X values
        return headEulerAngleX < -8 && headEulerAngleX > -50 &&
            headEulerAngleY.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 3: // Look left
        return headEulerAngleY < -8 && headEulerAngleY > -50 &&
            headEulerAngleX.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 4: // Look right
        return headEulerAngleY > 8 && headEulerAngleY < 50 &&
            headEulerAngleX.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      default:
        return false;
    }
  }

  bool assessFaceQuality(Face face) {
    // Get frame dimensions
    double frameWidth = frame?.width.toDouble() ?? 640;
    double frameHeight = frame?.height.toDouble() ?? 480;

    // Assess face quality based on multiple factors
    double faceWidth = face.boundingBox.width;
    double faceHeight = face.boundingBox.height;
    double faceSize = faceWidth * faceHeight;

    // More reasonable face size thresholds
    double minFaceSize = 2500; // Very lenient minimum
    double maxFaceSize = frameWidth * frameHeight * 0.8; // 80% of frame max

    // Check face size - only reject if REALLY too small or too large
    if (faceSize < minFaceSize) {
      setState(() {
        isFaceQualityGood = false;
        angleStatus = "Move closer to camera";
      });
      return false;
    }

    if (faceSize > maxFaceSize) {
      setState(() {
        isFaceQualityGood = false;
        angleStatus = "Move away from camera";
      });
      return false;
    }

    // Face quality is good - no other checks needed
    // The visual circle guide is sufficient for user positioning
    setState(() {
      isFaceQualityGood = true;
    });

    return true;
  }

  Future<void> checkAntiSpoofing(Face face) async {
    // Convert camera image to img.Image for anti-spoofing detection
    img.Image? image = Platform.isIOS
        ? Util.convertBGRA8888ToImage(frame!)
        : Util.convertNV21(frame!);

    if (image != null) {
      image = img.copyRotate(image, angle: camDirec == CameraLensDirection.front ? 270 : 90);

      // Crop face with bounds checking
      Rect faceRect = face.boundingBox;
      int left = faceRect.left.toInt().clamp(0, image.width - 1);
      int top = faceRect.top.toInt().clamp(0, image.height - 1);
      int width = faceRect.width.toInt().clamp(1, image.width - left);
      int height = faceRect.height.toInt().clamp(1, image.height - top);

      img.Image croppedFace = img.copyCrop(image,
          x: left,
          y: top,
          width: width,
          height: height);

      // Perform anti-spoofing detection
      try {
        AntiSpoofingResult result = await antiSpoofingDetector.detectSpoofing(croppedFace);

        setState(() {
          isRealFace = result.isReal;
          spoofingConfidence = result.confidence;
        });

        // Update UI status if face is detected as fake
        if (!result.isReal) {
          setState(() {
            isFaceQualityGood = false;
            angleStatus = "Spoofing detected! Use your real face";
          });
        }
      } catch (e) {
        print('Anti-spoofing detection error: $e');
        // Default to real face if detection fails
        setState(() {
          isRealFace = true;
          spoofingConfidence = 0.5;
        });
      }
    }
  }

  String getAngleGuidanceMessage() {
    // Return specific guidance based on current step
    switch (currentStep) {
      case 0:
        return "Look straight at the camera";
      case 1:
        return "Tilt your head up";
      case 2:
        return "Tilt your head down";
      case 3:
        return "Turn your head left";
      case 4:
        return "Turn your head right";
      default:
        return "Position your face in the circle";
    }
  }

  Future<void> captureFaceForCurrentStep(Face face) async {
    if (capturedFaces.length <= currentStep) {
      // Show countdown before capture
      await _showCountdownAndCapture(face);
    }
  }

  Future<void> _showCountdownAndCapture(Face face) async {
    // Show countdown
    setState(() {
      showCountdown = true;
      countdownValue = 3;
    });

    // Countdown animation
    for (int i = 3; i > 0; i--) {
      setState(() {
        countdownValue = i;
      });
      await Future.delayed(Duration(milliseconds: 700));
    }

    // Capture the face
    await _performFaceCapture(face);

    // Hide countdown
    setState(() {
      showCountdown = false;
    });
  }

  Future<void> _performFaceCapture(Face face) async {
    // Convert camera image to img.Image
    img.Image? image = Platform.isIOS
        ? Util.convertBGRA8888ToImage(frame!)
        : Util.convertNV21(frame!);

    if (image != null) {
      image = img.copyRotate(image, angle: camDirec == CameraLensDirection.front ? 270 : 90);

      // Crop face with bounds checking
      Rect faceRect = face.boundingBox;
      int left = faceRect.left.toInt().clamp(0, image.width - 1);
      int top = faceRect.top.toInt().clamp(0, image.height - 1);
      int width = faceRect.width.toInt().clamp(1, image.width - left);
      int height = faceRect.height.toInt().clamp(1, image.height - top);

      img.Image croppedFace = img.copyCrop(image,
          x: left,
          y: top,
          width: width,
          height: height);

      // Get face embedding
      Recognition recognition = recognizer.recognize(croppedFace, faceRect);

      // Store the captured face and embedding
      capturedFaces.add(croppedFace);
      faceEmbeddings.add(recognition);

      // Success haptic feedback
      HapticFeedback.heavyImpact();

      // Auto-advance to next step
      await Future.delayed(Duration(milliseconds: 800));
      _nextStep();
    }
  }

  void _nextStep() {
    if (currentStep < instructions.length - 1) {
      setState(() {
        currentStep++;
        isCapturing = false;
        isAngleCorrect = false;
        isFaceQualityGood = false;
        angleStatus = "Position your face";
        correctAngleCount = 0;
      });

      // Start capturing after a short delay
      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            isCapturing = true;
          });
        }
      });
    } else {
      // Complete registration
      _completeRegistration();
    }
  }

  void _completeRegistration() async {
    setState(() {
      isCapturing = false;
    });
    final Preferences preferences = Preferences();

    final userName = await preferences.getUserDisplayName();
    await _saveFaceRegistration(userName);
    Get.back();
  }




  Future<void> _saveFaceRegistration(String name) async {
    if (faceEmbeddings.isNotEmpty) {
      try {
        // Use the first face embedding as the primary one
        Recognition primaryRecognition = faceEmbeddings.first;
        img.Image primaryFace = capturedFaces.first;
        
        // Get user ID from preferences
        final preferences = Preferences();
        final userId = await preferences.getUserId();
        
        if (userId != null) {
          // Create repository instance
          final faceRepository = FaceRegistrationRepository();

          // Register or update face on server (prevents duplicates)
          final result = await faceRepository.registerFaceApi(
            userId: userId.toString(),
            name: name,
            embeddings: primaryRecognition.embeddings,
            faceImage: Uint8List.fromList(img.encodeBmp(primaryFace)),
          );
          // Register face in local database
          recognizer.registerFaceInDB(
            name,
            primaryRecognition.embeddings,
            Uint8List.fromList(img.encodeBmp(primaryFace)),
          );

          // Refresh face data from storage
          recognizer.refreshRegisteredFaces();
          print('OKkkkkkkkkkkkkkkkkkkkkkkkkkkkk');
          // Show success message first
          Get.snackbar(
            'Success',
            result?.message ??
                'Face registered successfully as $name with ${capturedFaces
                    .length} angles!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );



          // Go back after a short delay to show the success message
          Future.delayed(Duration(milliseconds: 1500), () {
            Get.back();
          });
        }
      } catch (e) {
        // Show error message

        Get.snackbar(
          'Error',
          'Failed to register face: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        // Reset for next registration
        setState(() {
          currentStep = 0;
          capturedFaces.clear();
          faceEmbeddings.clear();
        });
      }
    }
  }

  Widget _buildAnimatedArrow() {
    if (currentStep == 0 || !isCapturing) {
      // No arrow for straight ahead or when not capturing
      return Center(
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _arrowAnimation,
      builder: (context, child) {
        double opacity = 0.4 + (_arrowAnimation.value * 0.6); // Fade between 0.4 and 1.0
        double offset = _arrowAnimation.value * 20; // Move up to 20 pixels

        Widget arrowIcon;
        Offset arrowOffset = Offset.zero;

        switch (currentStep) {
          case 1: // Look up
            arrowIcon = Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 60,
              color: Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(0, -offset);
            break;

          case 2: // Look down
            arrowIcon = Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 60,
              color: Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(0, offset);
            break;

          case 3: // Look left
            arrowIcon = Icon(
              Icons.keyboard_arrow_left_rounded,
              size: 60,
              color: Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(-offset, 0);
            break;

          case 4: // Look right
            arrowIcon = Icon(
              Icons.keyboard_arrow_right_rounded,
              size: 60,
              color: Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(offset, 0);
            break;

          default:
            arrowIcon = SizedBox.shrink();
        }

        return Center(
          child: Transform.translate(
            offset: arrowOffset,
            child: arrowIcon,
          ),
        );
      },
    );
  }

  InputImage? getInputImage() {
    final camera = camDirec == CameraLensDirection.front ? cameras[1] : cameras[0];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      const orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };
      var rotationCompensation = orientations[controller!.value.deviceOrientation];

      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(frame!.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (frame!.planes.length != 1) return null;
    final plane = frame!.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(frame!.width.toDouble(), frame!.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  void _startCapture() {
    setState(() {
      isCapturing = true;
      isAngleCorrect = false;
      isFaceQualityGood = false;
      angleStatus = "Position your face";
      correctAngleCount = 0;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _arrowAnimationController.dispose();
    faceDetector.close();
    recognizer.close();
    antiSpoofingDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Auto Face Registration',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: !isInitialized
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Camera preview
                Positioned.fill(
                  child: controller.value.isInitialized
                      ? CameraPreview(controller)
                      : Container(color: Colors.grey[800]),
                ),

                // Overlay to darken surrounding area with transparent circle
                Positioned.fill(
                  child: CustomPaint(
                    painter: CircleOverlayPainter(
                      circleCenter: Offset(
                        MediaQuery.of(context).size.width / 2,
                        (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            kToolbarHeight -
                            300) / 2 + MediaQuery.of(context).padding.top + kToolbarHeight, // Center in available camera area
                      ),
                      circleRadius: circleRadius,
                      overlayColor: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),

                // Face detection overlay circle - positioned to match the transparent hole
                Positioned(
                  left: (MediaQuery.of(context).size.width - circleSize) / 2,
                  top: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight -
                      300) / 2 + MediaQuery.of(context).padding.top + kToolbarHeight - circleRadius,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCapturing
                            ? (isAngleCorrect && isFaceQualityGood ? Colors.green : Colors.orange)
                            : Colors.white,
                        width: 4,
                      ),
                    ),
                    child: isCapturing
                        ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Remove any background color to keep it transparent
                      ),
                      // Add animated arrow inside the circle
                      child: _buildAnimatedArrow(),
                    )
                        : null,
                  ),
                ),

                // Center dot for guidance - positioned to match circle center
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 4,
                  top: (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      kToolbarHeight -
                      300) / 2 + MediaQuery.of(context).padding.top + kToolbarHeight - 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                // Countdown overlay
                if (showCountdown)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: Stack(
                        children: [
                          Positioned(
                            left: (MediaQuery.of(context).size.width - 120) / 2,
                            top: (MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top -
                                kToolbarHeight -
                                300) / 2 + MediaQuery.of(context).padding.top + kToolbarHeight - 60,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              child: Center(
                                child: Text(
                                  countdownValue.toString(),
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Angle status indicator
                if (isCapturing && !showCountdown)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: (isAngleCorrect && isFaceQualityGood) ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          angleStatus,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Instructions section
          Container(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  instructions[currentStep],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  subInstructions[currentStep],
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Enhanced progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    instructions.length,
                        (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: index == currentStep ? 16 : 12,
                      height: index == currentStep ? 16 : 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < currentStep
                            ? Colors.green
                            : index == currentStep
                            ? ((isAngleCorrect && isFaceQualityGood) ? Colors.green : Colors.orange)
                            : Colors.white30,
                        border: index == currentStep
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: index == currentStep && isCapturing
                          ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      )
                          : null,
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Start/Status button
                if (currentStep == 0 && !isCapturing)
                  ElevatedButton(
                    onPressed: _startCapture,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Start Auto Registration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                // Status text
                if (isCapturing)
                  Text(
                    (isAngleCorrect && isFaceQualityGood) ? 'Perfect! Hold that position...' : angleStatus,
                    style: TextStyle(
                      color: (isAngleCorrect && isFaceQualityGood) ? Colors.green : Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                // Captured faces count
                if (capturedFaces.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'Captured: ${capturedFaces.length}/${instructions.length} angles',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}