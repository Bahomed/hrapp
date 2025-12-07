import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

import '../../ML/Recognition.dart';
import '../../ML/Recognizer.dart';
import '../../data/local/preferences.dart';
import '../../repository/face_registration_repository.dart';
import '../../main.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
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
    // Use saveLayer + clear blend mode for broader device compatibility
    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final clearPaint = Paint()..blendMode = BlendMode.clear;

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final circleRect =
        Rect.fromCircle(center: circleCenter, radius: circleRadius);

    canvas.saveLayer(fullRect, overlayPaint);
    canvas.drawRect(fullRect, overlayPaint);
    canvas.drawOval(circleRect, clearPaint);
    canvas.restore();
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
  CameraDescription? description;
  CameraLensDirection camDirec = CameraLensDirection.front;
  bool hasCameraError = false;
  String cameraErrorMessage = '';

  CameraDescription? _getFrontCamera() {
    if (cameras.isEmpty) return null;

    for (var camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        return camera;
      }
    }
    return cameras.first;
  }

  late FaceDetector faceDetector;
  late Recognizer recognizer;

  int currentStep = 0;
  bool isInitialized = false;
  bool isCapturing = false;
  List<img.Image> capturedFaces = [];
  List<Recognition> faceEmbeddings = [];
  CameraImage? frame;

  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  bool isAngleCorrect = false;
  String angleStatus = "";
  int correctAngleCount = 0;
  static const int requiredStableFrames = 5; // Reduced from 8 to 5

  bool isFaceQualityGood = false;
  double faceConfidence = 0.0;

  bool showCountdown = false;
  int countdownValue = 3;

  Face? detectedFace; // Store detected face for drawing landmarks

  int frameSkipCounter = 0;
  static const int frameSkipInterval = 2;

  static const double circleSize = 280;
  static const double circleRadius = circleSize / 2;

  List<String> get instructions => [
        tr('look_straight_ahead'),
        tr('look_up'),
        tr('look_down'),
        tr('look_to_your_left'),
        tr('look_to_your_right')
      ];

  List<String> get subInstructions => [
        tr('hold_phone_still_look_camera'),
        tr('tilt_head_up_slightly'),
        tr('tilt_head_down_slightly'),
        tr('turn_head_to_left'),
        tr('turn_head_to_right')
      ];

  // Debug logging toggle
  bool enableCaptureDebug = true;

  void _debug(String message) {
    if (!enableCaptureDebug) return;
    debugPrint('AutoRegisterDebug: $message');
  }

  @override
  void initState() {
    super.initState();

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

    _arrowAnimationController.repeat(reverse: true);

    initializeComponents();
  }

  void initializeComponents() async {
    try {
      description = _getFrontCamera();

      if (description == null) {
        setState(() {
          hasCameraError = true;
          cameraErrorMessage = tr('no_cameras_available');
          isInitialized = true;
        });
        return;
      }

      faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: false,
          enableLandmarks: true, // ✅ Detect eyes, nose, mouth for better validation
          enableContours: true,
          enableTracking: true,
          minFaceSize: 0.15, // ✅ Minimum face size (15% of image)
          performanceMode: FaceDetectorMode.accurate, // ✅ Use accurate mode for better boundaries
        ),
      );

      recognizer = Recognizer();

      await initializeCamera();
    } catch (e) {
      setState(() {
        hasCameraError = true;
        cameraErrorMessage = 'Failed to initialize camera: ${e.toString()}';
        isInitialized = true;
      });
    }
  }

  initializeCamera() async {
    if (description == null) {
      setState(() {
        hasCameraError = true;
        cameraErrorMessage = tr('no_camera_available_initialization');
        isInitialized = true;
      });
      return;
    }

    controller = CameraController(
      description!,
      ResolutionPreset.medium,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup
              .nv21 // ML Kit officially supports NV21 for Android
          : ImageFormatGroup.bgra8888,
      enableAudio: false,
    );

    await controller.initialize().then((_) {
      if (!mounted) return;

      print(
          '📷 Camera initialized - Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
      print('📷 Camera direction: $camDirec');
      print('📷 Sensor orientation: ${description!.sensorOrientation}');

      setState(() {
        isInitialized = true;
      });

      controller.startImageStream((image) {
        // Always keep the latest frame so capture uses current data
        frame = image;

        if (!isBusy && isCapturing) {
          // Debug: Print image format info on first frame
          if (frameSkipCounter == 0) {
            print('📷 Image format: ${image.format.group}');
            print('📷 Image size: ${image.width}x${image.height}');
            print('📷 Planes: ${image.planes.length}');
          }
          isBusy = true;
          doFaceDetectionOnFrame();
        }
      });
    });
  }

  doFaceDetectionOnFrame() async {
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
      Face face = faces.first;

      // Store face for drawing landmarks
      setState(() {
        detectedFace = face;
      });

      bool faceWellPositioned = isFaceWellPositioned(face);
      bool faceCentered = _isFaceCentered(face);
      bool angleCorrect = isCorrectAngleForStep(face);
      bool qualityGood = assessFaceQuality(face);

      if (faceWellPositioned &&
          faceCentered &&
          angleCorrect &&
          qualityGood) {
        correctAngleCount++;

        if (correctAngleCount >= requiredStableFrames) {
          HapticFeedback.mediumImpact();
          await captureFaceForCurrentStep(face);
          correctAngleCount = 0;
        } else {
          setState(() {
            isAngleCorrect = true;
            isFaceQualityGood = true;
            angleStatus = tr('hold_steady_count')
                .replaceAll('{current}', correctAngleCount.toString())
                .replaceAll(
                    '{total}', requiredStableFrames.toString());
          });
        }
      } else {
        correctAngleCount = 0;
        setState(() {
          isAngleCorrect = false;
          if (!faceCentered) {
            angleStatus = tr('position_face_in_circle');
          } else if (isFaceQualityGood || !qualityGood) {
            if (qualityGood) {
              angleStatus = getAngleGuidanceMessage();
            }
          }
        });
      }
    } else {
      correctAngleCount = 0;
      setState(() {
        detectedFace = null; // Clear face when not detected
        isAngleCorrect = false;
        isFaceQualityGood = false;
        angleStatus =
            faces.isEmpty ? tr('no_face_detected') : tr('multiple_faces_detected');
      });
    }

    setState(() {
      isBusy = false;
    });
  }

  bool isFaceWellPositioned(Face face) {
    double faceWidth = face.boundingBox.width;
    double faceHeight = face.boundingBox.height;

    return faceWidth > 80 &&
        faceHeight > 80 &&
        faceWidth < 500 &&
        faceHeight < 500;
  }

  bool isCorrectAngleForStep(Face face) {
    double? headEulerAngleX = face.headEulerAngleX;
    double? headEulerAngleY = face.headEulerAngleY;
    double? headEulerAngleZ = face.headEulerAngleZ;

    if (headEulerAngleX == null ||
        headEulerAngleY == null ||
        headEulerAngleZ == null) {
      return false;
    }

    if (Platform.isAndroid && camDirec == CameraLensDirection.front) {
      headEulerAngleY = -headEulerAngleY;
    }

    const double tolerance = 20.0; // Relaxed from 15.0
    const double rollTolerance = 30.0; // Relaxed from 25.0

    switch (currentStep) {
      case 0:
        return headEulerAngleX.abs() < tolerance &&
            headEulerAngleY.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 1:
        return headEulerAngleX > 8 &&
            headEulerAngleX < 50 &&
            headEulerAngleY.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 2:
        return headEulerAngleX < -8 &&
            headEulerAngleX > -50 &&
            headEulerAngleY.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 3:
        return headEulerAngleY < -8 &&
            headEulerAngleY > -50 &&
            headEulerAngleX.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 4:
        return headEulerAngleY > 8 &&
            headEulerAngleY < 50 &&
            headEulerAngleX.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      default:
        return false;
    }
  }

  bool assessFaceQuality(Face face) {
    double frameWidth = frame?.width.toDouble() ?? 640;
    double frameHeight = frame?.height.toDouble() ?? 480;

    double faceWidth = face.boundingBox.width;
    double faceHeight = face.boundingBox.height;
    double faceSize = faceWidth * faceHeight;

    double minFaceSize = 2000; // Reduced from 2500 to allow smaller faces
    double maxFaceSize =
        frameWidth * frameHeight * 0.85; // Increased from 0.8

    if (faceSize < minFaceSize) {
      setState(() {
        isFaceQualityGood = false;
        angleStatus = tr('move_closer_to_camera');
      });
      return false;
    }

    if (faceSize > maxFaceSize) {
      setState(() {
        isFaceQualityGood = false;
        angleStatus = tr('move_away_from_camera');
      });
      return false;
    }

    setState(() {
      isFaceQualityGood = true;
    });

    return true;
  }

  /// Align face by rotating based on eye positions to ensure horizontal alignment
  img.Image _alignFaceByEyes(
      img.Image face,
      FaceLandmark leftEye,
      FaceLandmark rightEye,
      double centerX,
      double centerY,
      int cropLeft,
      int cropTop) {
    try {
      // Calculate angle between eyes (global coords – translation doesn’t matter)
      double dx =
          (rightEye.position.x - leftEye.position.x).toDouble();
      double dy =
          (rightEye.position.y - leftEye.position.y).toDouble();
      double angle = -atan2(dy, dx) * 180 / pi;

      // Only apply small corrections (within ±15 degrees)
      if (angle.abs() > 15) {
        angle = angle.sign * 15;
      }

      // Rotate the face to align eyes horizontally
      if (angle.abs() > 2) {
        return img.copyRotate(face, angle: angle);
      }
      return face;
    } catch (e) {
      return face;
    }
  }

  /// ✅ NEW: Validates that a cropped image actually contains a face (basic checks)
  Future<bool> _validateCroppedFaceContainsFace(img.Image croppedFace) async {
    try {
      // Simple validation - just check minimum size
      if (croppedFace.width < 50 || croppedFace.height < 50) {
        return false;
      }

      // Fast heuristic: reject nearly-uniform images (likely empty background)
      final bool hasVariance = _hasLuminanceVariance(croppedFace);
      if (!hasVariance) return false;

      // Always return true if basic checks pass
      return true;
    } catch (e) {
      return true; // Don't block on validation errors
    }
  }

  bool _hasLuminanceVariance(img.Image image) {
    // Sample every Nth pixel to keep it fast
    const int step = 12;
    double mean = 0;
    double meanSq = 0;
    int count = 0;

    for (int y = 0; y < image.height; y += step) {
      for (int x = 0; x < image.width; x += step) {
        final img.Pixel pixel = image.getPixel(x, y);
        final int r = pixel.r.toInt();
        final int g = pixel.g.toInt();
        final int b = pixel.b.toInt();
        final double luma =
            0.299 * r + 0.587 * g + 0.114 * b;
        mean += luma;
        meanSq += luma * luma;
        count++;
      }
    }

    if (count == 0) return false;
    mean /= count;
    meanSq /= count;
    final double variance = meanSq - (mean * mean);

    // Require some variance to avoid flat red/black frames
    final bool pass = variance > 100; // was 1200
    _debug('luma variance=$variance pass=$pass');
    return pass;
  }

  /// Re-run face detection on the latest frame before saving to avoid capturing empty space
  Future<Face?> _refreshFaceBeforeCapture() async {
    final InputImage? latestInput = getInputImage();
    if (latestInput == null) return null;

    try {
      final List<Face> faces =
          await faceDetector.processImage(latestInput);
      _debug('refreshFace: faces detected=${faces.length}');
      if (faces.length != 1) return null;

      final Face refreshed = faces.first;
      _debug('refreshFace: box=${refreshed.boundingBox}');

      // Enforce basic positioning/quality again right before capture
      final bool positioned = isFaceWellPositioned(refreshed);
      final bool quality = assessFaceQuality(refreshed);
      final bool centered = _isFaceCentered(refreshed);
      _debug(
          'refreshFace checks -> positioned=$positioned quality=$quality centered=$centered angleOk=${isCorrectAngleForStep(refreshed)}');
      if (!positioned || !quality || !centered) return null;

      return refreshed;
    } catch (e) {
      _debug('refreshFace error: $e');
    }
    return null;
  }

  bool _isFaceCentered(Face face) {
    final double frameWidth = frame?.width.toDouble() ?? 640;
    final double frameHeight = frame?.height.toDouble() ?? 480;

    final double cx = face.boundingBox.center.dx;
    final double cy = face.boundingBox.center.dy;

    final double marginX = frameWidth * 0.15; // middle 70% horizontally
    final double marginY =
        frameHeight * 0.15; // middle 70% vertically

    return cx > marginX &&
        cx < (frameWidth - marginX) &&
        cy > marginY &&
        cy < (frameHeight - marginY);
  }

  // Anti-spoofing is now handled through liveness challenges (head movements)
  // No need for a separate ML model

  String getAngleGuidanceMessage() {
    switch (currentStep) {
      case 0:
        return tr('look_straight_at_camera');
      case 1:
        return tr('tilt_head_up');
      case 2:
        return tr('tilt_head_down');
      case 3:
        return tr('turn_head_left');
      case 4:
        return tr('turn_head_right');
      default:
        return tr('position_face_in_circle');
    }
  }

  Future<void> captureFaceForCurrentStep(Face face) async {
    if (capturedFaces.length <= currentStep) {
      await _showCountdownAndCapture(face);
    }
  }

  Future<void> _showCountdownAndCapture(Face face) async {
    setState(() {
      showCountdown = true;
      countdownValue = 3;
    });

    for (int i = 3; i > 0; i--) {
      setState(() {
        countdownValue = i;
      });
      await Future.delayed(Duration(milliseconds: 700));
    }

    // Hand off to capture; it will re-validate on the latest frame
    await _performFaceCapture(face);

    setState(() {
      showCountdown = false;
    });
  }

  Future<void> _performFaceCapture(Face face) async {
    setState(() {
      isBusy = true;
    });

    // Try to refresh face from latest frame
    final Face? latest = await _refreshFaceBeforeCapture();
    face = latest ?? face;

    if (face.boundingBox.width < 40 || face.boundingBox.height < 40) {
      setState(() {
        angleStatus = tr('face_not_captured_properly_retrying');
      });
      correctAngleCount = 0;
      isBusy = false;
      HapticFeedback.lightImpact();
      return;
    }

    // ✅ iOS: Use stream frame for consistent quality with recognition
    // ✅ Android: Use takePicture for high quality
    img.Image? capturedImage;

    if (Platform.isIOS) {
      // Use stream frame directly (same as recognition)
      if (frame == null) {
        setState(() {
          angleStatus = tr('face_not_captured_properly_retrying');
        });
        correctAngleCount = 0;
        isBusy = false;
        HapticFeedback.lightImpact();
        return;
      }

      // Import Util for convertBGRA8888ToImage
      capturedImage = Util.convertBGRA8888ToImage(frame!);
      if (capturedImage == null) {
        isBusy = false;
        return;
      }
    } else {
      // Android: Take picture for high quality
      final XFile? picture = await controller.takePicture();
      if (picture == null) {
        setState(() {
          angleStatus = tr('face_not_captured_properly_retrying');
        });
        correctAngleCount = 0;
        isBusy = false;
        HapticFeedback.lightImpact();
        return;
      }

      final Uint8List imageBytes = await picture.readAsBytes();
      capturedImage = img.decodeImage(imageBytes);
      if (capturedImage == null) {
        isBusy = false;
        return;
      }
    }

    // -----------------------------
    // ✅ CROP FACE WITH MINIMAL PADDING — IMPORTANT
    // Add minimal padding to include just the face without extra background
    // -----------------------------
    final Rect box = face.boundingBox;

    // Calculate minimal padding (5% of face size on each side)
    // This gives us 10% extra width and 10% extra height total
    final double paddingX = box.width * 0.05;
    final double paddingY = box.height * 0.05;

    // Apply padding while staying within image bounds
    int x = (box.left - paddingX).toInt().clamp(0, capturedImage.width - 1);
    int y = (box.top - paddingY).toInt().clamp(0, capturedImage.height - 1);
    int right = (box.right + paddingX).toInt().clamp(0, capturedImage.width);
    int bottom = (box.bottom + paddingY).toInt().clamp(0, capturedImage.height);

    int w = (right - x).clamp(1, capturedImage.width - x);
    int h = (bottom - y).clamp(1, capturedImage.height - y);

    // Crop face with minimal padding (recognizer will resize & preprocess internally)
    img.Image croppedFace = img.copyCrop(capturedImage, x: x, y: y, width: w, height: h);

    // -----------------------------
    // ✅ GENERATE EMBEDDING FROM CROPPED FACE
    // Pass the cropped face directly - recognizer will resize & preprocess it
    // -----------------------------
    final Rect dummyRect = Rect.fromLTWH(0, 0, croppedFace.width.toDouble(), croppedFace.height.toDouble());
    Recognition recognition = recognizer.recognize(croppedFace, dummyRect);

    // Store embeddings
    faceEmbeddings.add(recognition);

    // Create a resized version for preview display
    img.Image displayFace = img.copyResize(croppedFace, width: 160, height: 160);
    capturedFaces.add(displayFace);

    HapticFeedback.heavyImpact();
    await Future.delayed(Duration(milliseconds: 800));
    _nextStep();

    setState(() {
      isBusy = false;
    });
  }

  void _nextStep() {
    if (currentStep < instructions.length - 1) {
      setState(() {
        currentStep++;
        isCapturing = false;
        isAngleCorrect = false;
        isFaceQualityGood = false;
        angleStatus = tr('position_your_face');
        correctAngleCount = 0;
      });

      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            isCapturing = true;
          });
        }
      });
    } else {
      // For production: go directly to registration
      _completeRegistration();

      // For debugging: show preview dialog
    //  _showCapturedFacesPreview();
    }
  }

  /// Show preview dialog with all captured faces
  Future<void> _showCapturedFacesPreview() async {
    setState(() {
      isCapturing = false;
    });

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final themeService = Get.find<ThemeService>();
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            tr('verify_captured_faces'),
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('review_faces_before_saving'),
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: capturedFaces.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.green, width: 2),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                child: Image.memory(
                                  Uint8List.fromList(
                                      img.encodePng(
                                          capturedFaces[index])),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Container(
                              padding:
                                  EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green
                                    .withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.vertical(
                                        bottom:
                                            Radius.circular(10)),
                              ),
                              child: Text(
                                instructions[index],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Retry
              },
              child: Text(
                tr('retry'),
                style: TextStyle(
                    color:
                        themeService.getErrorColor(),
                    fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    themeService.getSuccessColor(),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
              child: Text(
                tr('confirm_and_save'),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // User confirmed, proceed with saving
      _completeRegistration();
    } else {
      // User wants to retry
      _resetRegistration();
    }
  }

  /// Reset registration to start over
  void _resetRegistration() {
    setState(() {
      currentStep = 0;
      capturedFaces.clear();
      faceEmbeddings.clear();
      isCapturing = false;
      isAngleCorrect = false;
      isFaceQualityGood = false;
      angleStatus = '';
      correctAngleCount = 0;
    });
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
        Recognition primaryRecognition = faceEmbeddings.first;
        img.Image primaryFace = capturedFaces.first;

        // Extract all embeddings from captured faces
        List<List<double>> allEmbeddings =
            faceEmbeddings.map((rec) => rec.embeddings).toList();

        final preferences = Preferences();
        final userId = await preferences.getUserId();

        if (userId != null) {
          final faceRepository = FaceRegistrationRepository();

          // Register with API using primary embedding
          final result = await faceRepository.registerFaceApi(
            userId: userId.toString(),
            name: name,
            embeddings: primaryRecognition.embeddings,
            faceImage:
                Uint8List.fromList(img.encodeBmp(primaryFace)),
          );

          // Register multiple embeddings for better accuracy
          recognizer.registerMultipleFaces(
            name,
            allEmbeddings, // Pass all 5 embeddings
            Uint8List.fromList(img.encodeBmp(primaryFace)),
          );

          recognizer.refreshRegisteredFaces();

          Get.snackbar(
            tr('success'),
            result?.message ??
                tr('face_registered_successfully')
                    .replaceAll('{name}', name)
                    .replaceAll('{count}',
                        capturedFaces.length.toString()),
            backgroundColor:
                Get.find<ThemeService>().getSuccessColor(),
            colorText: Colors.white,
          );

          Future.delayed(Duration(milliseconds: 1500), () {
            Get.back();
          });
        }
      } catch (e) {
        Get.snackbar(
          tr('error'),
          '${tr('failed_to_register_face')}: ${e.toString()}',
          backgroundColor:
              Get.find<ThemeService>().getErrorColor(),
          colorText: Colors.white,
        );
      } finally {
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
        double opacity = 0.4 + (_arrowAnimation.value * 0.6);
        double offset = _arrowAnimation.value * 20;

        Widget arrowIcon;
        Offset arrowOffset = Offset.zero;

        switch (currentStep) {
          case 1:
            arrowIcon = Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 60,
              color:
                  Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(0, -offset);
            break;

          case 2:
            arrowIcon = Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 60,
              color:
                  Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(0, offset);
            break;

          case 3:
            arrowIcon = Icon(
              Icons.keyboard_arrow_left_rounded,
              size: 60,
              color:
                  Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(-offset, 0);
            break;

          case 4:
            arrowIcon = Icon(
              Icons.keyboard_arrow_right_rounded,
              size: 60,
              color:
                  Colors.white.withValues(alpha: opacity),
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
    if (description == null || frame == null) return null;

    final camera = description!;
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation =
          InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      const orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };
      var rotationCompensation =
          orientations[controller!.value.deviceOrientation];

      if (rotationCompensation == null) return null;
      if (camera.lensDirection ==
          CameraLensDirection.front) {
        rotationCompensation =
            (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) %
                360;
      }
      rotation =
          InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format =
        InputImageFormatValue.fromRawValue(frame!.format.raw);
    if (format == null) return null;

    // Validate format based on platform
    if (Platform.isIOS &&
        format != InputImageFormat.bgra8888) return null;
    if (Platform.isAndroid &&
        format != InputImageFormat.nv21 &&
        format != InputImageFormat.yuv_420_888) {
      return null;
    }
    if (frame!.planes.isEmpty) return null;

    // Normalize Android input to NV21 bytes
    Uint8List? bytes;
    InputImageFormat targetFormat = format;

    if (Platform.isAndroid) {
      if (frame!.planes.length == 1 &&
          format == InputImageFormat.nv21) {
        bytes = frame!.planes.first.bytes;
        targetFormat = InputImageFormat.nv21;
      } else {
        // Convert YUV_420_888 (3-plane) to NV21
        bytes = _convertYUV420ToNV21(frame!);
        targetFormat = InputImageFormat.nv21;
      }
    } else {
      bytes = frame!.planes.first.bytes;
    }

    // ✅ CRITICAL: For Android NV21, bytesPerRow should be width, not stride
    // For iOS BGRA8888, use the actual bytesPerRow from the plane
    final int bytesPerRow = Platform.isIOS
        ? frame!.planes.first.bytesPerRow
        : frame!.width;  // NV21 format uses width as bytesPerRow

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(frame!.width.toDouble(), frame!.height.toDouble()),
        rotation: rotation,
        format: targetFormat,
        bytesPerRow: bytesPerRow,
      ),
    );
  }

  /// Convert YUV_420_888 to NV21 so ML Kit can process it on Android
  Uint8List _convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride =
        image.planes[1].bytesPerPixel ?? 1;

    final Uint8List out =
        Uint8List(ySize + (width * height ~/ 2));
    int offset = 0;

    // Copy Y plane
    for (int row = 0; row < height; row++) {
      final int rowStart =
          row * image.planes[0].bytesPerRow;
      out.setRange(
        offset,
        offset + width,
        image.planes[0].bytes.sublist(
            rowStart, rowStart + width),
      );
      offset += width;
    }

    // Interleave VU data
    final bytesU = image.planes[1].bytes;
    final bytesV = image.planes[2].bytes;
    final int chromaHeight = height ~/ 2;
    final int chromaWidth = width ~/ 2;

    for (int row = 0; row < chromaHeight; row++) {
      for (int col = 0; col < chromaWidth; col++) {
        final int uvIndex =
            row * uvRowStride + col * uvPixelStride;
        out[offset++] = bytesV[uvIndex];
        out[offset++] = bytesU[uvIndex];
      }
    }

    return out;
  }

  void _startCapture() {
    setState(() {
      isCapturing = true;
      isAngleCorrect = false;
      isFaceQualityGood = false;
      angleStatus = tr('position_face_in_circle');
      correctAngleCount = 0;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    _arrowAnimationController.dispose();

    if (!hasCameraError) {
      try {
        faceDetector.close();
        recognizer.close();
      } catch (e) {
        // Ignore disposal errors
      }
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    final themeService = Get.find<ThemeService>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('auto_face_registration'),
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: !isInitialized
          ? Center(
              child: CircularProgressIndicator(
                  color: themeService.getSuccessColor()),
            )
          : hasCameraError
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 80,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 24),
                        Text(
                          tr('camera_error'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          cameraErrorMessage,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                themeService.getErrorColor(),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            tr('go_back'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: controller.value.isInitialized
                                ? CameraPreview(controller)
                                : Container(
                                    color: Colors.grey[800],
                                  ),
                          ),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: CircleOverlayPainter(
                                circleCenter: Offset(
                                  MediaQuery.of(context)
                                          .size
                                          .width /
                                      2,
                                  (MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              MediaQuery.of(
                                                      context)
                                                  .padding
                                                  .top -
                                              kToolbarHeight -
                                              300) /
                                          2 +
                                      MediaQuery.of(context)
                                          .padding
                                          .top +
                                      kToolbarHeight,
                                ),
                                circleRadius:
                                    circleRadius,
                                overlayColor: Colors.black
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                          Positioned(
                            left: (MediaQuery.of(context)
                                        .size
                                        .width -
                                    circleSize) /
                                2,
                            top: (MediaQuery.of(context)
                                            .size
                                            .height -
                                        MediaQuery.of(
                                                context)
                                            .padding
                                            .top -
                                        kToolbarHeight -
                                        300) /
                                    2 +
                                MediaQuery.of(context)
                                    .padding
                                    .top +
                                kToolbarHeight -
                                circleRadius,
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isCapturing
                                      ? (isAngleCorrect &&
                                              isFaceQualityGood
                                          ? themeService
                                              .getSuccessColor()
                                          : themeService
                                              .getWarningColor())
                                      : Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: isCapturing
                                  ? Container(
                                      decoration:
                                          BoxDecoration(
                                        shape:
                                            BoxShape.circle,
                                      ),
                                      child:
                                          _buildAnimatedArrow(),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            left: MediaQuery.of(context)
                                    .size
                                    .width /
                                2 -
                                4,
                            top: (MediaQuery.of(context)
                                            .size
                                            .height -
                                        MediaQuery.of(
                                                context)
                                            .padding
                                            .top -
                                        kToolbarHeight -
                                        300) /
                                    2 +
                                MediaQuery.of(context)
                                    .padding
                                    .top +
                                kToolbarHeight -
                                4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          if (showCountdown)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black
                                    .withValues(alpha: 0.7),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: (MediaQuery.of(
                                                      context)
                                                  .size
                                                  .width -
                                              120) /
                                          2,
                                      top: (MediaQuery.of(
                                                      context)
                                                  .size
                                                  .height -
                                              MediaQuery.of(
                                                      context)
                                                  .padding
                                                  .top -
                                              kToolbarHeight -
                                              300) /
                                              2 +
                                          MediaQuery.of(
                                                  context)
                                              .padding
                                              .top +
                                          kToolbarHeight -
                                          60,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration:
                                            BoxDecoration(
                                          shape:
                                              BoxShape.circle,
                                          color: Colors.green,
                                          border: Border.all(
                                              color:
                                                  Colors.white,
                                              width: 4),
                                        ),
                                        child: Center(
                                          child: Text(
                                            countdownValue
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 48,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (isCapturing && !showCountdown)
                            Positioned(
                              top: MediaQuery.of(context)
                                      .padding
                                      .top +
                                  kToolbarHeight +
                                  20,
                              left: 0,
                              right: 0,
                              child: Container(
                                alignment:
                                    Alignment.center,
                                child: Container(
                                  padding: EdgeInsets
                                      .symmetric(
                                          horizontal: 16,
                                          vertical: 8),
                                  decoration:
                                      BoxDecoration(
                                    color: (isAngleCorrect &&
                                            isFaceQualityGood)
                                        ? Colors.green
                                        : Colors.orange,
                                    borderRadius:
                                        BorderRadius
                                            .circular(20),
                                  ),
                                  child: Text(
                                    angleStatus,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            instructions[currentStep],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.w600,
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
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: List.generate(
                              instructions.length,
                              (index) =>
                                  AnimatedContainer(
                                duration: Duration(
                                    milliseconds: 300),
                                margin: EdgeInsets
                                    .symmetric(
                                        horizontal: 4),
                                width: index ==
                                        currentStep
                                    ? 16
                                    : 12,
                                height: index ==
                                        currentStep
                                    ? 16
                                    : 12,
                                decoration:
                                    BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index <
                                          currentStep
                                      ? Colors.green
                                      : index ==
                                              currentStep
                                          ? ((isAngleCorrect &&
                                                  isFaceQualityGood)
                                              ? Colors.green
                                              : Colors.orange)
                                          : Colors
                                              .white30,
                                  border: index ==
                                          currentStep
                                      ? Border.all(
                                          color:
                                              Colors.white,
                                          width: 2)
                                      : null,
                                ),
                                child: index ==
                                            currentStep &&
                                        isCapturing
                                    ? Container(
                                        decoration:
                                            BoxDecoration(
                                          shape: BoxShape
                                              .circle,
                                          color: Colors
                                              .white
                                              .withValues(
                                                  alpha:
                                                      0.3),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                          if (currentStep == 0 &&
                              !isCapturing)
                            ElevatedButton(
                              onPressed:
                                  _startCapture,
                              style:
                                  ElevatedButton
                                      .styleFrom(
                                backgroundColor:
                                    Colors.green,
                                foregroundColor:
                                    Colors.white,
                                padding: EdgeInsets
                                    .symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(8),
                                ),
                              ),
                              child: Text(
                                tr('start_auto_registration'),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          if (isCapturing)
                            Text(
                              (isAngleCorrect &&
                                      isFaceQualityGood)
                                  ? tr('perfect_hold_position')
                                  : angleStatus,
                              style: TextStyle(
                                color: (isAngleCorrect &&
                                        isFaceQualityGood)
                                    ? Colors.green
                                    : Colors.orange,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                              textAlign:
                                  TextAlign.center,
                            ),
                          if (capturedFaces
                              .isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets
                                      .only(top: 16),
                              child: Text(
                                tr('captured_angles_count')
                                    .replaceAll(
                                        '{current}',
                                        capturedFaces
                                            .length
                                            .toString())
                                    .replaceAll(
                                        '{total}',
                                        instructions
                                            .length
                                            .toString()),
                                style: TextStyle(
                                  color:
                                      Colors.white70,
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
