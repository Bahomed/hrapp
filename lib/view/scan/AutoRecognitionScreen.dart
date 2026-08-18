import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../ML/Recognition.dart';
import '../../ML/Recognizer.dart';
import '../../main.dart';
import '../../repository/attendancerepository.dart';
import '../../data/local/preferences.dart';
import '../../services/theme_service.dart';
import '../../utils/Util.dart';
import '../../utils/translation_helper.dart';

/// Convert cosine similarity (-1..1) into a 0..100 confidence percentage.
double similarityToConfidencePercent(double similarity) {
  final normalized = ((similarity + 1) / 2).clamp(0.0, 1.0);
  return normalized * 100;
}

class AutoRecognitionScreen extends StatefulWidget {
  final String attendanceType; // 'clock_in', 'clock_out', 'break_start', 'break_end'
  final Map<String, dynamic>? locationData;

  const AutoRecognitionScreen({
    super.key,
    required this.attendanceType,
    this.locationData,
  });

  @override
  State<AutoRecognitionScreen> createState() => _AutoRecognitionScreenState();
}

class _AutoRecognitionScreenState extends State<AutoRecognitionScreen> {
  dynamic controller;
  bool isBusy = false;
  late Size size;
  late CameraDescription description = cameras[1];
  CameraLensDirection camDirec = CameraLensDirection.front;

  late FaceDetector faceDetector;
  late Recognizer recognizer;

  bool isInitialized = false;
  bool isRecognizing = false;
  CameraImage? frame;

  // Recognition results
  List<Recognition> recognitions = [];
  Recognition? lastRecognition;

  // Passive liveness: detects natural face movement across frames (no user action needed)
  bool _livenessVerified = false;
  final List<Offset> _facePositions = [];
  static const int _kLivenessFrames = 12;      // collect over ~12 processed frames
  static const double _kMinMovementPixels = 3.0; // minimum variance to confirm live face

  // Performance optimization
  int frameSkipCounter = 0;
  static const int frameSkipInterval = 3;

  // ✅ Recognition confidence threshold adjusted for improved preprocessing
  // With L2 normalization and better preprocessing, we can use a higher threshold
  // ~88% confidence => similarity ~0.75 (increased from 0.70)
  static const double recognitionThreshold = 0.75;

  // Cooldown to prevent repeated dialogs
  DateTime? lastDialogTime;
  static const int dialogCooldownSeconds = 5;

  @override
  void initState() {
    super.initState();
    initializeComponents();
  }

  void initializeComponents() async {
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
        enableContours: false,
        enableTracking: true,
      ),
    );

    recognizer = Recognizer();

    await initializeCamera();
  }

  initializeCamera() async {
    controller = CameraController(
      description,
      ResolutionPreset.medium,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
      enableAudio: false,
    );

    await controller.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        isInitialized = true;
        isRecognizing = true;
      });

      controller.startImageStream((image) => {
        if (!isBusy && isRecognizing) {
          isBusy = true,
          frame = image,
          doFaceRecognitionOnFrame()
        }
      });
    });
  }

  doFaceRecognitionOnFrame() async {
    frameSkipCounter++;
    if (frameSkipCounter % frameSkipInterval != 0) {
      setState(() {
        isBusy = false;
      });
      return;
    }

    // ✅ Create InputImage with proper error handling using frame and description
    final inputImage = _createInputImageRobust(frame!, description);
    if (inputImage == null) {
      setState(() {
        isBusy = false;
      });
      return;
    }

    List<Face> faces = await faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      final face = faces.first;

      // Liveness gate: require a blink before allowing face matching
      if (!_livenessVerified) {
        _checkLiveness(face);
        setState(() { isBusy = false; });
        return;
      }

      // ✅ Call appropriate method based on platform
      if (Platform.isIOS) {
        await iosPerformFaceRecognition(faces);
      } else {
        await androidPerformFaceRecognition(faces);
      }
    } else {
      setState(() {
        recognitions.clear();
      });
    }

    setState(() {
      isBusy = false;
    });
  }

  iosPerformFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    // Convert camera image to img.Image
    img.Image? image = Util.convertBGRA8888ToImage(frame!);

    if (image == null) return;

   
    for (Face face in faces) {
      Rect faceRect = face.boundingBox;

      // ✅ Use same 5% padding as registration
      final double paddingX = faceRect.width * 0.05;
      final double paddingY = faceRect.height * 0.05;

      int left = (faceRect.left - paddingX).toInt().clamp(0, image.width - 1);
      int top = (faceRect.top - paddingY).toInt().clamp(0, image.height - 1);
      int right = (faceRect.right + paddingX).toInt().clamp(0, image.width);
      int bottom = (faceRect.bottom + paddingY).toInt().clamp(0, image.height);

      int width = (right - left).clamp(1, image.width - left);
      int height = (bottom - top).clamp(1, image.height - top);

      img.Image croppedFace = img.copyCrop(image,
          x: left,
          y: top,
          width: width,
          height: height);

      // 🐛 DEBUG: Log crop details for iOS
      print('📱 iOS DEBUG: Stream frame: ${image.width}x${image.height}');
      print('📦 iOS DEBUG: Face rect: ${faceRect.left.toInt()}, ${faceRect.top.toInt()}, ${faceRect.width.toInt()}, ${faceRect.height.toInt()}');
      print('📐 iOS DEBUG: Padding: $paddingX x $paddingY');
      print('✂️ iOS DEBUG: Crop coords: left=$left, top=$top, right=$right, bottom=$bottom');
      print('🖼️ iOS DEBUG: Cropped face: ${croppedFace.width}x${croppedFace.height}');

      Recognition recognition = recognizer.recognize(croppedFace, faceRect);

      if (recognition.distance > recognitionThreshold) {
        recognitions.add(recognition);

        if (shouldShowDialog(recognition)) {
          await controller.stopImageStream();
          await showRecognitionDialog(recognition, croppedFace);
          if (isRecognizing && mounted) {
            controller.startImageStream((image) => {
              if (!isBusy && isRecognizing) {
                isBusy = true,
                frame = image,
                doFaceRecognitionOnFrame()
              }
            });
          }
        }
      }
    }
  }

  androidPerformFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    // ✅ Check cooldown first to avoid unnecessary picture taking
    if (lastDialogTime != null) {
      Duration timeSinceLastDialog = DateTime.now().difference(lastDialogTime!);
      if (timeSinceLastDialog.inSeconds < dialogCooldownSeconds) {
        return; // Skip processing during cooldown
      }
    }

    // Use stream frame directly so bounding box coordinates match face detection
    try {
      final img.Image rawFrame = Util.convertNV21(frame!);
      // Rotate to match the orientation ML Kit uses for face bounding boxes
      final int sensorRot = description.sensorOrientation;
      img.Image? image = sensorRot == 0 ? rawFrame : img.copyRotate(rawFrame, angle: sensorRot);

      if (image == null) {
        setState(() {
          isBusy = false;
        });
        return;
      }

      for (Face face in faces) {
        Rect faceRect = face.boundingBox;

        // ✅ Use original bounding box without rotation adjustment
        // ✅ Add 5% padding to avoid cutting off facial features
        final double paddingX = faceRect.width * 0.05;
        final double paddingY = faceRect.height * 0.05;

        int left = (faceRect.left - paddingX).toInt().clamp(0, image.width - 1);
        int top = (faceRect.top - paddingY).toInt().clamp(0, image.height - 1);
        int right = (faceRect.right + paddingX).toInt().clamp(0, image.width);
        int bottom = (faceRect.bottom + paddingY).toInt().clamp(0, image.height);

        int width = (right - left).clamp(1, image.width - left);
        int height = (bottom - top).clamp(1, image.height - top);

        img.Image croppedFace = img.copyCrop(image,
            x: left,
            y: top,
            width: width,
            height: height);

        Recognition recognition = recognizer.recognize(croppedFace, faceRect);

        if (recognition.distance > recognitionThreshold) {
          recognitions.add(recognition);

          if (shouldShowDialog(recognition)) {
            await controller.stopImageStream();
            await showRecognitionDialog(recognition, croppedFace);
            if (isRecognizing && mounted) {
              controller.startImageStream((image) => {
                if (!isBusy && isRecognizing) {
                  isBusy = true,
                  frame = image,
                  doFaceRecognitionOnFrame()
                }
              });
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error during face recognition: $e');
    }
  }

  /// Passive liveness: tracks face center across frames.
  /// A live person naturally shifts slightly; a held photo stays nearly perfectly still.
  /// No user action required — completely silent.
  void _checkLiveness(Face face) {
    final Rect box = face.boundingBox;
    final Offset center = Offset(box.left + box.width / 2, box.top + box.height / 2);

    _facePositions.add(center);
    if (_facePositions.length > _kLivenessFrames) {
      _facePositions.removeAt(0);
    }

    if (_facePositions.length < _kLivenessFrames) return; // still collecting

    // Compute variance of x and y positions
    final double meanX = _facePositions.map((p) => p.dx).reduce((a, b) => a + b) / _facePositions.length;
    final double meanY = _facePositions.map((p) => p.dy).reduce((a, b) => a + b) / _facePositions.length;

    double varX = 0, varY = 0;
    for (final p in _facePositions) {
      varX += (p.dx - meanX) * (p.dx - meanX);
      varY += (p.dy - meanY) * (p.dy - meanY);
    }
    varX /= _facePositions.length;
    varY /= _facePositions.length;

    final double movement = varX + varY; // combined movement score

    if (movement >= _kMinMovementPixels) {
      setState(() { _livenessVerified = true; });
      HapticFeedback.mediumImpact();
    }
  }

  bool shouldShowDialog(Recognition recognition) {
    if (lastDialogTime != null) {
      Duration timeSinceLastDialog = DateTime.now().difference(lastDialogTime!);
      if (timeSinceLastDialog.inSeconds < dialogCooldownSeconds) {
        return false;
      }
    }

    if (lastRecognition == null ||
        lastRecognition!.name != recognition.name ||
        recognition.distance > lastRecognition!.distance + 0.1) {
      return true;
    }

    return false;
  }

  Future<void> showRecognitionDialog(Recognition recognition, img.Image faceImage) async {
    lastDialogTime = DateTime.now();
    lastRecognition = recognition;

    HapticFeedback.mediumImpact();

    // Get stored face image if available
    Uint8List? storedImage = await recognizer.getStoredFaceImage(recognition.name);

    if (!mounted) return;

    // ✅ For production: Skip dialog and auto-submit
    await _autoSubmitAttendance(recognition, faceImage);
    // return;

    // ✅ For debugging: Uncomment below to show preview dialog

   /* showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  constraints: BoxConstraints(
                    maxWidth: 500,
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ Close button at top right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                isRecognizing = true;
                              });
                            },
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withAlpha(80),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),

                      SizedBox(height: 16),

                      Text(
                        tr('face_recognized'),
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 12),

                      Text(
                        tr('welcome_back'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 6),

                      Text(
                        recognition.name,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 12),

                      Text(
                        _getAttendanceTypeText(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20),

                      // Face images row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  tr('current_face'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.memory(
                                    Uint8List.fromList(img.encodePng(faceImage)),
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  tr('stored_face'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: storedImage != null
                                      ? Image.memory(
                                    storedImage,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withAlpha(100),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white70,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${tr('confidence')}: ${similarityToConfidencePercent(recognition.distance).toStringAsFixed(1)}%",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  isRecognizing = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                tr('cancel'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _submitAttendance(recognition),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                tr('confirm'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    */
  }

  String _getAttendanceTypeText() {
    switch (widget.attendanceType) {
      case 'clock_in':
        return tr('ready_to_clock_in');
      case 'clock_out':
        return tr('ready_to_clock_out');
      case 'break_in':
      case 'break_start':
        return tr('ready_to_start_break');
      case 'break_out':
      case 'break_end':
        return tr('ready_to_end_break');
      default:
        return tr('ready_to_record_attendance');
    }
  }

  String _getAppBarTitle() {
    switch (widget.attendanceType) {
      case 'clock_in':
        return tr('clock_in');
      case 'clock_out':
        return tr('clock_out');
      case 'break_in':
      case 'break_start':
        return tr('break_start');
      case 'break_out':
      case 'break_end':
        return tr('break_end');
      default:
        return tr('face_recognition');
    }
  }

  /// Save face image to temporary file and return the file path
  Future<String> _saveFaceImageToFile(img.Image faceImage) async {
    try {
      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();

      // Create unique filename with timestamp
      final String fileName = 'face_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(tempDir.path, fileName);

      // Encode image to JPEG format
      final List<int> imageBytes = img.encodeJpg(faceImage, quality: 85);

      // Write to file
      final File imageFile = File(filePath);
      await imageFile.writeAsBytes(imageBytes);

      print('✅ Face image saved to: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Error saving face image: $e');
      return '';
    }
  }

  Future<void> _autoSubmitAttendance(Recognition recognition, img.Image faceImage) async {
    lastDialogTime = DateTime.now();
    lastRecognition = recognition;

    setState(() {
      isRecognizing = false;
    });

    HapticFeedback.mediumImpact();

    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(200),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    tr('face_recognized'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    trParams('welcome_user', {'name': recognition.name}),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    trParams('processing_attendance_type', {'type': _getAttendanceTypeText()}),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      final preferences = Preferences();
      final userData = await preferences.getUserData();

      if (userData == null) {
        throw Exception('User data not found');
      }

      final attendanceRepo = AttendanceRepository();

      // 🔐 Save face image to file for server verification
      final String imagePath = await _saveFaceImageToFile(faceImage);
      if (imagePath.isEmpty) {
        throw Exception('Failed to save face image');
      }

      double? latitude;
      double? longitude;
      String? wifiSSID;
      String? wifiBSSID;
      String? address;

      if (widget.locationData != null) {
        latitude = widget.locationData!['latitude'];
        longitude = widget.locationData!['longitude'];
        wifiSSID = widget.locationData!['wifiSSID'];
        wifiBSSID = widget.locationData!['wifiBSSID'];

        String street = widget.locationData!['street'] ?? '';
        String city = widget.locationData!['city'] ?? '';
        String state = widget.locationData!['state'] ?? '';
        String country = widget.locationData!['country'] ?? '';
        address = '$street, $city, $state, $country'.replaceAll(RegExp(r'^,\s*|,\s*$'), '').trim();
        if (address.isEmpty) address = 'Location not available';
      } else {
        latitude = 0.0;
        longitude = 0.0;
        wifiSSID = 'Unknown';
        wifiBSSID = 'Unknown';
        address = 'Location not available';
      }

      // ✅ Send attendance with face image proof
      final result = await attendanceRepo.saveEmployeeAttendanceWithLocation(
        userData.id!,
        widget.attendanceType,
        'Face verification attendance',
        imagePath,  // 🔐 Now sending actual face image!
        latitude: latitude,
        longitude: longitude,
        wifiSSID: wifiSSID,
        wifiBSSID: wifiBSSID,
        address: address,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (result != null) {
        if (result.error) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(200),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 48),
                      SizedBox(height: 16),
                      Text(
                        tr('error'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        result.message.isNotEmpty ? result.message : tr('an_error_occurred'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop({
                'success': false,
                'error': true,
                'message': result.message,
              });
            }
          });
        } else if (result.validationMessage.isNotEmpty) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(200),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.white, size: 48),
                      SizedBox(height: 16),
                      Text(
                        tr('notice'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        result.validationMessage,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop({
                'success': false,
                'warning': true,
                'message': result.validationMessage,
              });
            }
          });
        } else {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(200),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 48),
                      SizedBox(height: 16),
                      Text(
                        tr('success_title'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        result.message.isNotEmpty ? result.message : trParams('attendance_recorded_successfully', {'type': _getAttendanceTypeText()}),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();

              String timestamp = DateTime.now().toIso8601String();
              if (result.data != null) {
                switch (widget.attendanceType) {
                  case 'clock_in':
                    if (result.data!.clockIn != null) {
                      timestamp = result.data!.clockIn!;
                    }
                    break;
                  case 'clock_out':
                    if (result.data!.clockOut != null) {
                      timestamp = result.data!.clockOut!;
                    }
                    break;
                  case 'break_in':
                  case 'break_start':
                    if (result.data!.breakIn != null) {
                      timestamp = result.data!.breakIn!;
                    }
                    break;
                  case 'break_out':
                  case 'break_end':
                    if (result.data!.breakOut != null) {
                      timestamp = result.data!.breakOut!;
                    }
                    break;
                }
              }

              Navigator.of(context).pop({
                'success': true,
                'attendanceType': widget.attendanceType,
                'time': timestamp,
                'userName': recognition.name,
                'message': result.message,
              });
            }
          });
        }
      } else {
        throw Exception('Failed to submit attendance');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(tr('error')),
            content: Text('${tr('failed_to_submit_attendance')}: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop({
                    'success': false,
                    'error': true,
                    'message': '${tr('failed_to_submit_attendance')}: ${e.toString()}',
                  });
                },
                child: Text(tr('ok')),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _submitAttendance(Recognition recognition) async {
    Navigator.of(context).pop();

    setState(() {
      isRecognizing = false;
    });

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );

      final preferences = Preferences();
      final userData = await preferences.getUserData();

      if (userData == null) {
        throw Exception('User data not found');
      }

      final attendanceRepo = AttendanceRepository();

      double? latitude;
      double? longitude;
      String? wifiSSID;
      String? wifiBSSID;
      String? address;

      if (widget.locationData != null) {
        latitude = widget.locationData!['latitude'];
        longitude = widget.locationData!['longitude'];
        wifiSSID = widget.locationData!['wifiSSID'];
        wifiBSSID = widget.locationData!['wifiBSSID'];

        String street = widget.locationData!['street'] ?? '';
        String city = widget.locationData!['city'] ?? '';
        String state = widget.locationData!['state'] ?? '';
        String country = widget.locationData!['country'] ?? '';
        address = '$street, $city, $state, $country'.replaceAll(RegExp(r'^,\s*|,\s*$'), '').trim();
        if (address.isEmpty) address = 'Location not available';
      } else {
        latitude = 0.0;
        longitude = 0.0;
        wifiSSID = 'Unknown';
        wifiBSSID = 'Unknown';
        address = 'Location not available';
      }

      final result = await attendanceRepo.saveEmployeeAttendanceWithLocation(
        userData.id!,
        widget.attendanceType,
        'Face verification attendance',
        '',
        latitude: latitude,
        longitude: longitude,
        wifiSSID: wifiSSID,
        wifiBSSID: wifiBSSID,
        address: address,
      );

      Navigator.of(context).pop();

      if (result != null) {
        if (result.error) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(tr('error')),
              content: Text(result.message.isNotEmpty ? result.message : tr('an_error_occurred')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop({
                      'success': false,
                      'error': true,
                      'message': result.message,
                    });
                  },
                  child: Text(tr('ok')),
                ),
              ],
            ),
          );
        } else if (result.validationMessage.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(tr('notice')),
              content: Text(result.validationMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop({
                      'success': false,
                      'warning': true,
                      'message': result.validationMessage,
                    });
                  },
                  child: Text(tr('ok')),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(tr('success_title')),
              content: Text(result.message.isNotEmpty ? result.message : trParams('attendance_recorded_successfully', {'type': _getAttendanceTypeText()})),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    String timestamp = DateTime.now().toIso8601String();
                    if (result.data != null) {
                      switch (widget.attendanceType) {
                        case 'clock_in':
                          if (result.data!.clockIn != null) {
                            timestamp = result.data!.clockIn!;
                          }
                          break;
                        case 'clock_out':
                          if (result.data!.clockOut != null) {
                            timestamp = result.data!.clockOut!;
                          }
                          break;
                        case 'break_in':
                        case 'break_start':
                          if (result.data!.breakIn != null) {
                            timestamp = result.data!.breakIn!;
                          }
                          break;
                        case 'break_out':
                        case 'break_end':
                          if (result.data!.breakOut != null) {
                            timestamp = result.data!.breakOut!;
                          }
                          break;
                      }
                    }

                    Navigator.of(context).pop({
                      'success': true,
                      'attendanceType': widget.attendanceType,
                      'time': timestamp,
                      'userName': recognition.name,
                      'message': result.message,
                    });
                  },
                  child: Text(tr('ok')),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception('Failed to submit attendance');
      }
    } catch (e) {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr('error')),
          content: Text('${tr('failed_to_submit_attendance')}: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop({
                  'success': false,
                  'error': true,
                  'message': '${tr('failed_to_submit_attendance')}: ${e.toString()}',
                });
              },
              child: Text(tr('ok')),
            ),
          ],
        ),
      );
    }
  }

  /// Convert YUV_420_888 (3-plane) to NV21 byte layout for ML Kit
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

  void _toggleCameraDirection() async {
    if (camDirec == CameraLensDirection.back) {
      camDirec = CameraLensDirection.front;
      description = cameras[1];
    } else {
      camDirec = CameraLensDirection.back;
      description = cameras[0];
    }
    await controller.stopImageStream();
    setState(() {
      controller;
    });
    initializeCamera();
  }

  void _toggleRecognition() {
    setState(() {
      isRecognizing = !isRecognizing;
      if (!isRecognizing) {
        recognitions.clear();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    faceDetector.close();
    recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // Allow back navigation and stop recognition
        setState(() {
          isRecognizing = false;
        });
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // Stop recognition before going back
              setState(() {
                isRecognizing = false;
              });
              Navigator.pop(context);
            },
          ),
          title: Text(
            _getAppBarTitle(),
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
                  Positioned.fill(
                    child: controller.value.isInitialized
                        ? CameraPreview(controller)
                        : Container(color: Colors.grey[800]),
                  ),

                  if (recognitions.isNotEmpty)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: FaceRecognitionPainter(
                          Size(
                            controller.value.previewSize!.height,
                            controller.value.previewSize!.width,
                          ),
                          recognitions,
                          camDirec,
                        ),
                      ),
                    ),

                  // Liveness instruction banner
                  if (isRecognizing)
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _livenessVerified
                              ? Colors.green.withAlpha(220)
                              : Colors.orange.withAlpha(220),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _livenessVerified
                                  ? Icons.check_circle_outline
                                  : Icons.face_retouching_natural,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _livenessVerified
                                  ? tr('liveness_verified')
                                  : tr('liveness_look_camera'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create InputImage with maximum robustness
  InputImage? _createInputImageRobust(CameraImage image, CameraDescription camera) {
    // Try multiple approaches in order of preference

    // Approach 0: Convert YUV420 to NV21 for Android if needed
    if(Platform.isAndroid && _getSafeInputImageFormat(image.format) == InputImageFormat.yuv420) {
      try {
        return _createInputImageWithYUV420ToNV21Conversion(image, camera);
      } catch (e) {
        debugPrint('(Conversion yuv420 to nv21) InputImage creation failed: $e');
      }
    }

    // Approach 1: Force nv21 (Android) / bgra8888 (iOS) format (most common)
    try {
      return _createInputImageForced(image, camera);
    } catch (e) {
      debugPrint('Forced nv21 (Android) / bgra8888 (iOS) InputImage creation failed: $e');
    }

    // Approach 2: Minimal metadata approach
    try {
      return _createInputImageMinimal(image, camera);
    } catch (e) {
      debugPrint('Minimal InputImage creation failed: $e');
    }

    return null;
  }

  /// InputImage creation converting yuv420 to nv21 format
  InputImage? _createInputImageWithYUV420ToNV21Conversion(CameraImage image, CameraDescription camera) {
    try {
      if (image.format.group != ImageFormatGroup.yuv420) {
        throw ArgumentError('CameraImage must be in YUV420 format');
      }

      if (image.planes.length < 3) {
        throw ArgumentError('YUV420 image should have at least 3 planes');
      }

      final width = image.width;
      final height = image.height;

      // Calculate plane sizes - YUV420 has 4:2:0 subsampling
      final ySize = width * height;
      final uvSize = (width * height) ~/ 4; // 1/4 of Y size

      // Final buffer for NV21: Y + interleaved VU
      final nv21Buffer = Uint8List(ySize + uvSize * 2);

      // Access YUV planes
      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      // 1. Copy Y plane (luminance)
      int dstIndex = 0;
      int srcIndex = 0;

      // Copy Y considering possible padding
      for (int y = 0; y < height; y++) {
        final bytesToCopy = width < yPlane.bytesPerRow ? width : yPlane.bytesPerRow;
        final endIndex = srcIndex + bytesToCopy;

        if (endIndex <= yPlane.bytes.length && dstIndex + bytesToCopy <= nv21Buffer.length) {
          nv21Buffer.setRange(dstIndex, dstIndex + bytesToCopy, yPlane.bytes, srcIndex);
        }

        dstIndex += width;
        srcIndex += yPlane.bytesPerRow;
      }

      // 2. Interleave U and V planes into VU format (NV21)
      final uvWidth = width ~/ 2;
      final uvHeight = height ~/ 2;

      // Reset indices for UV section
      dstIndex = ySize;

      for (int y = 0; y < uvHeight; y++) {
        for (int x = 0; x < uvWidth; x++) {
          final uvIndex = y * uPlane.bytesPerRow ~/ 2 + x;

          // Copy V first, then U (NV21 format: Y + interleaved VU)
          if (uvIndex < vPlane.bytes.length && dstIndex < nv21Buffer.length - 1) {
            nv21Buffer[dstIndex++] = vPlane.bytes[uvIndex]; // V
          } else {
            nv21Buffer[dstIndex++] = 128; // Default value if out of range
          }

          if (uvIndex < uPlane.bytes.length && dstIndex < nv21Buffer.length) {
            nv21Buffer[dstIndex++] = uPlane.bytes[uvIndex]; // U
          } else {
            nv21Buffer[dstIndex++] = 128; // Default value if out of range
          }
        }
      }

      return InputImage.fromBytes(
        bytes: nv21Buffer,
        metadata: InputImageMetadata(
          size: Size(width.toDouble(), height.toDouble()),
          rotation: _getInputImageRotation(camera),
          format: InputImageFormat.nv21,
          bytesPerRow: yPlane.bytesPerRow,
        ),
      );
    } catch (e) {
      throw Exception('Failed to convert YUV420 to NV21: $e');
    }
  }

  /// Forced nv21 format for Android and bgra8888 for iOS InputImage creation
  InputImage? _createInputImageForced(CameraImage image, CameraDescription camera) {
    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);

    debugPrint("_createInputImageForced called. Format [${inputImageFormat?.name}], It will be forced to ${Platform.isAndroid ? InputImageFormat.nv21.name : InputImageFormat.bgra8888.name}");

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: _getInputImageRotation(camera),
        format: Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  /// Minimal InputImage creation with fixed values
  InputImage? _createInputImageMinimal(CameraImage image, CameraDescription camera) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg, // Fixed rotation
        format: Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888,
        bytesPerRow: image.planes.isNotEmpty ? image.planes.first.bytesPerRow : image.width,
      ),
    );
  }

  /// Get safe InputImageFormat (only use formats that definitely exist)
  InputImageFormat _getSafeInputImageFormat(ImageFormat format) {
    switch (format.group) {
      case ImageFormatGroup.yuv420:
        return InputImageFormat.yuv420;
      case ImageFormatGroup.bgra8888:
        return InputImageFormat.bgra8888;
      case ImageFormatGroup.nv21:
        return InputImageFormat.nv21;
      case ImageFormatGroup.jpeg:
      case ImageFormatGroup.unknown:
      default:
        if(Platform.isAndroid) {
          debugPrint('Using nv21 (Android) fallback for format: ${format.group}');
          return InputImageFormat.nv21;
        } else {
          debugPrint('Using bgra8888 (iOS) fallback for format: ${format.group}');
          return InputImageFormat.bgra8888;
        }
    }
  }

  /// Get InputImageRotation based on camera sensor orientation
  InputImageRotation _getInputImageRotation(CameraDescription camera) {
    try {
      final sensorOrientation = camera.sensorOrientation;
      switch (sensorOrientation) {
        case 0:
          return InputImageRotation.rotation0deg;
        case 90:
          return InputImageRotation.rotation90deg;
        case 180:
          return InputImageRotation.rotation180deg;
        case 270:
          return InputImageRotation.rotation270deg;
        default:
          debugPrint('Unknown sensor orientation: $sensorOrientation, using 0 degrees');
          return InputImageRotation.rotation0deg;
      }
    } catch (e) {
      debugPrint('Error getting rotation: $e');
      return InputImageRotation.rotation0deg;
    }
  }
}

class FaceRecognitionPainter extends CustomPainter {
  final Size absoluteImageSize;
  final List<Recognition> recognitions;
  final CameraLensDirection camDirection;

  FaceRecognitionPainter(this.absoluteImageSize, this.recognitions, this.camDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    final Paint labelBgPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green.withAlpha(180);

    for (final recognition in recognitions) {
      final double left = camDirection == CameraLensDirection.front
          ? (absoluteImageSize.width - recognition.location.right) * scaleX
          : recognition.location.left * scaleX;
      final double top = recognition.location.top * scaleY;
      final double right = camDirection == CameraLensDirection.front
          ? (absoluteImageSize.width - recognition.location.left) * scaleX
          : recognition.location.right * scaleX;
      final double bottom = recognition.location.bottom * scaleY;

      final rect = Rect.fromLTRB(left, top, right, bottom);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

      canvas.drawRRect(rRect, boxPaint);

      const double labelHeight = 30;
      final labelRect = Rect.fromLTRB(
        left,
        top - labelHeight,
        right,
        top,
      );
      final labelRRect = RRect.fromRectAndRadius(labelRect, const Radius.circular(4));
      canvas.drawRRect(labelRRect, labelBgPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${recognition.name} (${similarityToConfidencePercent(recognition.distance).toStringAsFixed(0)}%)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(left + 4, top - labelHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(FaceRecognitionPainter oldDelegate) => true;
}