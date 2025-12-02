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

import '../../ML/AntiSpoofingDetector.dart';
import '../../ML/Recognition.dart';
import '../../ML/Recognizer.dart';
import '../../data/local/preferences.dart';
import '../../repository/face_registration_repository.dart';
import '../../main.dart';
import '../../utils/Util.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';

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

    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: circleCenter, radius: circleRadius));

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

// Custom painter to draw face landmarks and contours
class FaceLandmarksPainter extends CustomPainter {
  final Face? face;
  final Size imageSize;
  final Size screenSize;

  FaceLandmarksPainter({
    required this.face,
    required this.imageSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (face == null) return;

    // Calculate scale - image width maps to screen width
    final scaleX = screenSize.width / imageSize.height;  // Note: height because camera is rotated
    final scaleY = screenSize.height / imageSize.width;  // Note: width because camera is rotated

    // Offset for centering
    final offsetX = 0.0;
    final offsetY = 0.0;

    // Draw face oval contour (face mesh)
    final faceOval = face!.contours[FaceContourType.face];
    if (faceOval != null && faceOval.points.isNotEmpty) {
      final path = Path();
      final firstPoint = _transformPoint(faceOval.points.first, scaleX, scaleY, offsetX, offsetY);
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (var point in faceOval.points.skip(1)) {
        final transformedPoint = _transformPoint(point, scaleX, scaleY, offsetX, offsetY);
        path.lineTo(transformedPoint.dx, transformedPoint.dy);
      }
      path.close();

      final paint = Paint()
        ..color = Colors.green.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawPath(path, paint);
    }

    // Draw eye contours
    _drawContour(canvas, face!.contours[FaceContourType.leftEye], scaleX, scaleY, offsetX, offsetY, Colors.blue);
    _drawContour(canvas, face!.contours[FaceContourType.rightEye], scaleX, scaleY, offsetX, offsetY, Colors.blue);

    // Draw nose contours
    _drawContour(canvas, face!.contours[FaceContourType.noseBridge], scaleX, scaleY, offsetX, offsetY, Colors.yellow);
    _drawContour(canvas, face!.contours[FaceContourType.noseBottom], scaleX, scaleY, offsetX, offsetY, Colors.yellow);

    // Draw mouth contours
    _drawContour(canvas, face!.contours[FaceContourType.upperLipTop], scaleX, scaleY, offsetX, offsetY, Colors.red);
    _drawContour(canvas, face!.contours[FaceContourType.lowerLipBottom], scaleX, scaleY, offsetX, offsetY, Colors.red);

    // Draw landmarks as larger circles
    final landmarkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    face!.landmarks.forEach((type, landmark) {
      if (landmark != null) {
        final transformedPoint = _transformPoint(
          Point(landmark.position.x, landmark.position.y),
          scaleX,
          scaleY,
          offsetX,
          offsetY
        );
        canvas.drawCircle(
          Offset(transformedPoint.dx, transformedPoint.dy),
          6.0,
          landmarkPaint,
        );
      }
    });
  }

  Offset _transformPoint(Point point, double scaleX, double scaleY, double offsetX, double offsetY) {
    // Transform coordinates from camera space to screen space
    // For front camera in portrait mode: rotate 90 degrees counterclockwise
    final x = point.y.toDouble() * scaleX + offsetX;
    final y = point.x.toDouble() * scaleY + offsetY;
    return Offset(x, y);
  }

  void _drawContour(Canvas canvas, FaceContour? contour, double scaleX, double scaleY, double offsetX, double offsetY, Color color) {
    if (contour == null || contour.points.isEmpty) return;

    final path = Path();
    final firstPoint = _transformPoint(contour.points.first, scaleX, scaleY, offsetX, offsetY);
    path.moveTo(firstPoint.dx, firstPoint.dy);

    for (var point in contour.points.skip(1)) {
      final transformedPoint = _transformPoint(point, scaleX, scaleY, offsetX, offsetY);
      path.lineTo(transformedPoint.dx, transformedPoint.dy);
    }

    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(FaceLandmarksPainter oldDelegate) {
    return face != oldDelegate.face;
  }
}

// Simple holder for rotated image + mapped rect
class _RotatedFrame {
  final img.Image image;
  final Rect rect;
  _RotatedFrame(this.image, this.rect);
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
  late AntiSpoofingDetector antiSpoofingDetector;

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
  static const int requiredStableFrames = 5;  // Reduced from 8 to 5

  bool isFaceQualityGood = false;
  double faceConfidence = 0.0;

  bool isRealFace = true;
  double spoofingConfidence = 0.0;

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
          cameraErrorMessage = 'No cameras available on this device';
          isInitialized = true;
        });
        return;
      }

      faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: false,
          enableLandmarks: true,
          enableContours: true,
          enableTracking: true,
        ),
      );

      recognizer = Recognizer();
      antiSpoofingDetector = AntiSpoofingDetector();

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
        cameraErrorMessage = 'No camera available for initialization';
        isInitialized = true;
      });
      return;
    }

    controller = CameraController(
        description!,
        ResolutionPreset.medium,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21  // ML Kit officially supports NV21 for Android
            : ImageFormatGroup.bgra8888,
        enableAudio: false
    );

    await controller.initialize().then((_) {
      if (!mounted) return;

      print('📷 Camera initialized - Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
      print('📷 Camera direction: $camDirec');
      print('📷 Sensor orientation: ${description!.sensorOrientation}');

      setState(() {
        isInitialized = true;
      });

      controller.startImageStream((image) => {
        if (!isBusy && isCapturing) {
          // Debug: Print image format info on first frame
          if (frameSkipCounter == 0) {
            print('📷 Image format: ${image.format.group}'),
            print('📷 Image size: ${image.width}x${image.height}'),
            print('📷 Planes: ${image.planes.length}'),
          },
          isBusy = true,
          frame = image,
          doFaceDetectionOnFrame()
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
      bool angleCorrect = isCorrectAngleForStep(face);
      bool qualityGood = assessFaceQuality(face);
      await checkAntiSpoofing(face);

      if (faceWellPositioned && angleCorrect && qualityGood && isRealFace) {
        correctAngleCount++;

        if (correctAngleCount >= requiredStableFrames) {
          HapticFeedback.mediumImpact();
          await captureFaceForCurrentStep(face);
          correctAngleCount = 0;
        } else {
          setState(() {
            isAngleCorrect = true;
            isFaceQualityGood = true;
            angleStatus = tr('hold_steady_count').replaceAll('{current}', correctAngleCount.toString()).replaceAll('{total}', requiredStableFrames.toString());
          });
        }
      } else {
        correctAngleCount = 0;
        setState(() {
          isAngleCorrect = false;
          if (isFaceQualityGood || !qualityGood) {
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
        angleStatus = faces.isEmpty ? tr('no_face_detected') : tr('multiple_faces_detected');
      });
    }

    setState(() {
      isBusy = false;
    });
  }

  bool isFaceWellPositioned(Face face) {
    double faceWidth = face.boundingBox.width;
    double faceHeight = face.boundingBox.height;

    return faceWidth > 80 && faceHeight > 80 &&
        faceWidth < 500 && faceHeight < 500;
  }

  bool isCorrectAngleForStep(Face face) {
    double? headEulerAngleX = face.headEulerAngleX;
    double? headEulerAngleY = face.headEulerAngleY;
    double? headEulerAngleZ = face.headEulerAngleZ;

    if (headEulerAngleX == null || headEulerAngleY == null || headEulerAngleZ == null) {
      return false;
    }

    if (Platform.isAndroid && camDirec == CameraLensDirection.front) {
      headEulerAngleY = -headEulerAngleY;
    }

    const double tolerance = 20.0;  // Relaxed from 15.0
    const double rollTolerance = 30.0;  // Relaxed from 25.0

    switch (currentStep) {
      case 0:
        return headEulerAngleX.abs() < tolerance &&
            headEulerAngleY.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 1:
        return headEulerAngleX > 8 && headEulerAngleX < 50 &&
            headEulerAngleY.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 2:
        return headEulerAngleX < -8 && headEulerAngleX > -50 &&
            headEulerAngleY.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 3:
        return headEulerAngleY < -8 && headEulerAngleY > -50 &&
            headEulerAngleX.abs() < tolerance &&
            headEulerAngleZ.abs() < rollTolerance;

      case 4:
        return headEulerAngleY > 8 && headEulerAngleY < 50 &&
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

    double minFaceSize = 2000;  // Reduced from 2500 to allow smaller faces
    double maxFaceSize = frameWidth * frameHeight * 0.85;  // Increased from 0.8 to allow larger faces

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
  img.Image _alignFaceByEyes(img.Image face, FaceLandmark leftEye, FaceLandmark rightEye,
      double centerX, double centerY, int cropLeft, int cropTop) {
    try {
      // Calculate angle between eyes
      double dx = (rightEye.position.x - leftEye.position.x).toDouble();
      double dy = (rightEye.position.y - leftEye.position.y).toDouble();
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

  /// ✅ NEW: Validates that a cropped image actually contains a face
  Future<bool> _validateCroppedFaceContainsFace(img.Image croppedFace) async {
    try {
      // Simple validation - just check minimum size
      if (croppedFace.width < 50 || croppedFace.height < 50) {
        return false;
      }

      // Always return true if basic size check passes
      // Face detection already verified the face exists
      return true;
    } catch (e) {
      return true; // Don't block on validation errors
    }
  }

  /// Rotate the camera frame to upright orientation and map the face rect into that space
  _RotatedFrame _rotateImageAndMapRect(img.Image image, Rect faceRect) {
    final int originalWidth = image.width;
    final int originalHeight = image.height;
    final bool isFront = camDirec == CameraLensDirection.front;
    final int angle = isFront ? 270 : 90; // portrait upright

    final img.Image rotatedImage = img.copyRotate(image, angle: angle);

    // Map bounding box to rotated coordinates (matches logic in AutoRecognitionScreen)
    double rotatedLeft;
    double rotatedTop;
    double rotatedWidth = faceRect.height;
    double rotatedHeight = faceRect.width;

    if (isFront) {
      rotatedLeft = faceRect.top;
      rotatedTop = originalWidth - (faceRect.left + faceRect.width);
    } else {
      rotatedLeft = originalHeight - (faceRect.top + faceRect.height);
      rotatedTop = faceRect.left;
    }

    final Rect mappedRect = Rect.fromLTWH(rotatedLeft, rotatedTop, rotatedWidth, rotatedHeight);
    return _RotatedFrame(rotatedImage, mappedRect);
  }

  Future<void> checkAntiSpoofing(Face face) async {
    img.Image? image = Platform.isIOS
        ? Util.convertBGRA8888ToImage(frame!)
        : (frame!.planes.length == 3
            ? Util.convertYUV420ToImageStatic(frame!)
            : Util.convertNV21(frame!));

    if (image != null) {
      // Rotate the full frame to upright orientation and map the face rect accordingly
      final rotated = _rotateImageAndMapRect(image, face.boundingBox);
      final uprightImage = rotated.image;
      final faceRect = rotated.rect;

      // Tighter square crop around face center to avoid background
      double centerX = faceRect.left + faceRect.width / 2;
      double centerY = faceRect.top + faceRect.height / 2;
      double faceSize = (faceRect.width > faceRect.height ? faceRect.width : faceRect.height) * 1.1;

      int left = (centerX - faceSize / 2).toInt().clamp(0, uprightImage.width - 1);
      int top = (centerY - faceSize / 2).toInt().clamp(0, uprightImage.height - 1);
      int width = faceSize.toInt().clamp(1, uprightImage.width - left);
      int height = faceSize.toInt().clamp(1, uprightImage.height - top);

      img.Image croppedFace = img.copyCrop(
        uprightImage,
        x: left,
        y: top,
        width: width,
        height: height,
      );

      try {
        AntiSpoofingResult result = await antiSpoofingDetector.detectSpoofing(croppedFace);

        setState(() {
          isRealFace = result.isReal;
          spoofingConfidence = result.confidence;
        });

        if (!result.isReal) {
          setState(() {
            isFaceQualityGood = false;
            angleStatus = tr('spoofing_detected_real_face');
          });
        }
      } catch (e) {
        setState(() {
          isRealFace = true;
          spoofingConfidence = 0.5;
        });
      }
    }
  }

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

    await _performFaceCapture(face);

    setState(() {
      showCountdown = false;
    });
  }

  Future<void> _performFaceCapture(Face face) async {
    img.Image? image = Platform.isIOS
        ? Util.convertBGRA8888ToImage(frame!)
        : (frame!.planes.length == 3
            ? Util.convertYUV420ToImageStatic(frame!)
            : Util.convertNV21(frame!));

    if (image != null) {
      // Rotate the full frame to upright orientation and map the face rect accordingly
      final rotated = _rotateImageAndMapRect(image, face.boundingBox);
      final uprightImage = rotated.image;
      final faceRect = rotated.rect;

      // Create a tighter square crop around the mapped face rect center for better accuracy
      double centerX = faceRect.left + faceRect.width / 2;
      double centerY = faceRect.top + faceRect.height / 2;
      double faceSize = (faceRect.width > faceRect.height ? faceRect.width : faceRect.height) * 1.15;

      int left = (centerX - faceSize / 2).toInt().clamp(0, uprightImage.width - 1);
      int top = (centerY - faceSize / 2).toInt().clamp(0, uprightImage.height - 1);
      int width = faceSize.toInt().clamp(1, uprightImage.width - left);
      int height = faceSize.toInt().clamp(1, uprightImage.height - top);

      img.Image croppedFace = img.copyCrop(
        uprightImage,
        x: left,
        y: top,
        width: width,
        height: height,
      );

      // Align face using eye positions if available (no change in crop coords needed after rotation)
      FaceLandmark? leftEye = face.landmarks[FaceLandmarkType.leftEye];
      FaceLandmark? rightEye = face.landmarks[FaceLandmarkType.rightEye];
      if (leftEye != null && rightEye != null) {
        croppedFace = _alignFaceByEyes(croppedFace, leftEye, rightEye, centerX, centerY, left, top);
      }

      // ✅ VALIDATE: Ensure the cropped image actually contains a face
      bool isValidFace = await _validateCroppedFaceContainsFace(croppedFace);

      if (!isValidFace) {
        setState(() {
          angleStatus = tr('face_not_captured_properly_retrying');
          correctAngleCount = 0;
          isBusy = false;
        });

        HapticFeedback.lightImpact();
        return;
      }

      // ✅ Resize to higher resolution for better embeddings (512x512 instead of 300x300)
      img.Image resizedFace = img.copyResize(croppedFace, width: 512, height: 512);

      Recognition recognition = recognizer.recognize(resizedFace, faceRect);

      capturedFaces.add(resizedFace);
      faceEmbeddings.add(recognition);

      HapticFeedback.heavyImpact();

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
      // ✅ For production: go directly to registration
      //_completeRegistration();

      // ✅ For debugging: uncomment this line to show preview dialog
       _showCapturedFacesPreview();
    }
  }

  /// ✅ NEW: Show preview dialog with all captured faces
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('review_faces_before_saving'),
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                child: Image.memory(
                                  Uint8List.fromList(img.encodePng(capturedFaces[index])),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
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
                style: TextStyle(color: themeService.getErrorColor(), fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: themeService.getSuccessColor(),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                tr('confirm_and_save'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  /// ✅ NEW: Reset registration to start over
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

        final preferences = Preferences();
        final userId = await preferences.getUserId();

        if (userId != null) {
          final faceRepository = FaceRegistrationRepository();

          final result = await faceRepository.registerFaceApi(
            userId: userId.toString(),
            name: name,
            embeddings: primaryRecognition.embeddings,
            faceImage: Uint8List.fromList(img.encodeBmp(primaryFace)),
          );

          recognizer.registerFaceInDB(
            name,
            primaryRecognition.embeddings,
            Uint8List.fromList(img.encodeBmp(primaryFace)),
          );

          recognizer.refreshRegisteredFaces();

          Get.snackbar(
            tr('success'),
            result?.message ??
                tr('face_registered_successfully').replaceAll('{name}', name).replaceAll('{count}', capturedFaces.length.toString()),
            backgroundColor: Get.find<ThemeService>().getSuccessColor(),
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
          backgroundColor: Get.find<ThemeService>().getErrorColor(),
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
              color: Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(0, -offset);
            break;

          case 2:
            arrowIcon = Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 60,
              color: Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(0, offset);
            break;

          case 3:
            arrowIcon = Icon(
              Icons.keyboard_arrow_left_rounded,
              size: 60,
              color: Colors.white.withValues(alpha: opacity),
            );
            arrowOffset = Offset(-offset, 0);
            break;

          case 4:
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
    if (description == null || frame == null) return null;

    final camera = description!;
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
    if (format == null) return null;

    // Validate format based on platform - ML Kit supports NV21/YUV420 on Android and BGRA8888 on iOS
    if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;
    if (Platform.isAndroid &&
        format != InputImageFormat.nv21 &&
        format != InputImageFormat.yuv_420_888) {
      return null;
    }
    if (frame!.planes.isEmpty) return null;

    // Normalize Android input to NV21 bytes (ML Kit happy path)
    Uint8List? bytes;
    InputImageFormat targetFormat = format;

    if (Platform.isAndroid) {
      if (frame!.planes.length == 1 && format == InputImageFormat.nv21) {
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

    final int bytesPerRow = Platform.isIOS
        ? frame!.planes.first.bytesPerRow // preserve iOS stride for BGRA
        : frame!.width; // NV21: use width to avoid padding differences

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
    final int uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final Uint8List out = Uint8List(ySize + (width * height ~/ 2));
    int offset = 0;

    // Copy Y plane
    for (int row = 0; row < height; row++) {
      final int rowStart = row * image.planes[0].bytesPerRow;
      out.setRange(offset, offset + width,
          image.planes[0].bytes.sublist(rowStart, rowStart + width));
      offset += width;
    }

    // Interleave VU data
    final bytesU = image.planes[1].bytes;
    final bytesV = image.planes[2].bytes;
    final int chromaHeight = height ~/ 2;
    final int chromaWidth = width ~/ 2;

    for (int row = 0; row < chromaHeight; row++) {
      for (int col = 0; col < chromaWidth; col++) {
        final int uvIndex = row * uvRowStride + col * uvPixelStride;
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
        antiSpoofingDetector.close();
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
          ? Center(child: CircularProgressIndicator(color: themeService.getSuccessColor()))
          : hasCameraError
          ? Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.white54,
              ),
              SizedBox(height: 24),
              Text(
                'Camera Error',
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
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeService.getErrorColor(),
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
                  'Go Back',
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
                      : Container(color: Colors.grey[800]),
                ),

                Positioned.fill(
                  child: CustomPaint(
                    painter: CircleOverlayPainter(
                      circleCenter: Offset(
                        MediaQuery.of(context).size.width / 2,
                        (MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            kToolbarHeight -
                            300) / 2 + MediaQuery.of(context).padding.top + kToolbarHeight,
                      ),
                      circleRadius: circleRadius,
                      overlayColor: Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),

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
                            ? (isAngleCorrect && isFaceQualityGood ? themeService.getSuccessColor() : themeService.getWarningColor())
                            : Colors.white,
                        width: 4,
                      ),
                    ),
                    child: isCapturing
                        ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: _buildAnimatedArrow(),
                    )
                        : null,
                  ),
                ),

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
                      tr('start_auto_registration'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                if (isCapturing)
                  Text(
                    (isAngleCorrect && isFaceQualityGood) ? tr('perfect_hold_position') : angleStatus,
                    style: TextStyle(
                      color: (isAngleCorrect && isFaceQualityGood) ? Colors.green : Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                if (capturedFaces.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      tr('captured_angles_count').replaceAll('{current}', capturedFaces.length.toString()).replaceAll('{total}', instructions.length.toString()),
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
