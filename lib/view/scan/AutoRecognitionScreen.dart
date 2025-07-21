import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';

import '../../ML/AntiSpoofingDetector.dart';
import '../../ML/Recognition.dart';
import '../../ML/Recognizer.dart';
import '../../main.dart';
import '../../utils/Util.dart';
import '../../repository/attendancerepository.dart';
import '../../data/local/preferences.dart';

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
  late AntiSpoofingDetector antiSpoofingDetector;

  bool isInitialized = false;
  bool isRecognizing = false;
  CameraImage? frame;

  // Recognition results
  List<Recognition> recognitions = [];
  Recognition? lastRecognition;

  // Anti-spoofing variables
  bool isRealFace = true;
  double spoofingConfidence = 0.0;

  // Performance optimization
  int frameSkipCounter = 0;
  static const int frameSkipInterval = 3; // Process every 4th frame

  // Recognition confidence threshold
  static const double recognitionThreshold = 0.6;

  // Cooldown to prevent repeated dialogs
  DateTime? lastDialogTime;
  static const int dialogCooldownSeconds = 5;

  @override
  void initState() {
    super.initState();
    initializeComponents();
  }

  void initializeComponents() async {
    // Initialize face detector
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
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
      enableAudio: false,
    );

    await controller.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        isInitialized = true;
        isRecognizing = true; // Auto-start recognition
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

    if (faces.isNotEmpty) {
      await performFaceRecognition(faces);
    } else {
      setState(() {
        recognitions.clear();
      });
    }

    setState(() {
      isBusy = false;
    });
  }

  performFaceRecognition(List<Face> faces) async {
    recognitions.clear();

    // Convert camera image to img.Image
    img.Image? image = Platform.isIOS
        ? Util.convertBGRA8888ToImage(frame!)
        : Util.convertNV21(frame!);

    if (image == null) return;

    image = img.copyRotate(image, angle: camDirec == CameraLensDirection.front ? 270 : 90);

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;

      // Crop face with bounds checking
      int left = faceRect.left.toInt().clamp(0, image.width - 1);
      int top = faceRect.top.toInt().clamp(0, image.height - 1);
      int width = faceRect.width.toInt().clamp(1, image.width - left);
      int height = faceRect.height.toInt().clamp(1, image.height - top);

      img.Image croppedFace = img.copyCrop(image,
          x: left,
          y: top,
          width: width,
          height: height);

      // Perform anti-spoofing check
      await checkAntiSpoofing(croppedFace);

      // Only proceed with recognition if face is real
      if (isRealFace) {
        Recognition recognition = recognizer.recognize(croppedFace, faceRect);

        // Check if recognition confidence is above threshold
        // Note: distance is actually cosine similarity (higher = better match)
        if (recognition.distance > recognitionThreshold) {
          recognitions.add(recognition);

          // Auto-submit attendance if this is a good match and cooldown has passed
          if (shouldShowDialog(recognition)) {
            await _autoSubmitAttendance(recognition, croppedFace);
          }
        }
      }
    }
  }

  Future<void> checkAntiSpoofing(img.Image croppedFace) async {
    try {
      AntiSpoofingResult result = await antiSpoofingDetector.detectSpoofing(croppedFace);

      setState(() {
        isRealFace = result.isReal;
        spoofingConfidence = result.confidence;
      });
    } catch (e) {
      print('Anti-spoofing detection error: $e');
      // Default to real face if detection fails
      setState(() {
        isRealFace = true;
        spoofingConfidence = 0.5;
      });
    }
  }

  bool shouldShowDialog(Recognition recognition) {
    // Check cooldown period
    if (lastDialogTime != null) {
      Duration timeSinceLastDialog = DateTime.now().difference(lastDialogTime!);
      if (timeSinceLastDialog.inSeconds < dialogCooldownSeconds) {
        return false;
      }
    }

    // Check if this is a different person or significantly better match
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

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Get stored face image if available
    Uint8List? storedImage = await recognizer.getStoredFaceImage(recognition.name);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(40)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success icon
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withAlpha(80),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),

                    SizedBox(height: 20),

                    // Recognition title
                    Text(
                      "Face Recognized!",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16),

                    // User name
                    Text(
                      "Welcome back,",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 8),

                    Text(
                      recognition.name,
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 16),

                    // Attendance type
                    Text(
                      _getAttendanceTypeText(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 24),

                    // Face images row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Current face
                        Column(
                          children: [
                            Text(
                              "Current",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.memory(
                                Uint8List.fromList(img.encodeBmp(faceImage)),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),

                        // Arrow
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),

                        // Stored face
                        Column(
                          children: [
                            Text(
                              "Stored",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: storedImage != null
                                  ? Image.memory(
                                storedImage,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withAlpha(100),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Confidence score
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Confidence: ${(recognition.distance * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel button
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Confirm button
                        ElevatedButton(
                          onPressed: () => _submitAttendance(recognition),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
        );
      },
    );
  }

  String _getAttendanceTypeText() {
    switch (widget.attendanceType) {
      case 'clock_in':
        return 'Ready to Clock In';
      case 'clock_out':
        return 'Ready to Clock Out';
      case 'break_start':
        return 'Ready to Start Break';
      case 'break_end':
        return 'Ready to End Break';
      default:
        return 'Ready to Record Attendance';
    }
  }

  String _getAppBarTitle() {
    switch (widget.attendanceType) {
      case 'clock_in':
        return 'Clock In';
      case 'clock_out':
        return 'Clock Out';
      case 'break_start':
        return 'Break Start';
      case 'break_end':
        return 'Break End';
      default:
        return 'Face Recognition';
    }
  }

  Future<void> _autoSubmitAttendance(Recognition recognition, img.Image faceImage) async {
    lastDialogTime = DateTime.now();
    lastRecognition = recognition;
    
    // Stop recognition during submission
    setState(() {
      isRecognizing = false;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Show brief recognition success message
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
                    'Face Recognized!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Welcome ${recognition.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Processing ${_getAttendanceTypeText()}...',
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

      // Get user data
      final preferences = Preferences();
      final userData = await preferences.getUserData();
      
      if (userData == null) {
        throw Exception('User data not found');
      }

      // Submit attendance
      final attendanceRepo = AttendanceRepository();
      
      // Get location data from widget or use defaults
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
        
        // Build address from location data
        String street = widget.locationData!['street'] ?? '';
        String city = widget.locationData!['city'] ?? '';
        String state = widget.locationData!['state'] ?? '';
        String country = widget.locationData!['country'] ?? '';
        address = '$street, $city, $state, $country'.replaceAll(RegExp(r'^,\s*|,\s*$'), '').trim();
        if (address.isEmpty) address = 'Location not available';
      } else {
        // Fallback values if no location data provided
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
        '', // No image file path needed for face recognition
        latitude: latitude,
        longitude: longitude,
        wifiSSID: wifiSSID,
        wifiBSSID: wifiBSSID,
        address: address,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }

      if (result != null) {
        // Check if there's an error in the response
        if (result.error) {
          // Show error dialog
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
                        'Error',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        result.message.isNotEmpty ? result.message : 'An error occurred',
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
          
          // Auto-close after 3 seconds and go back to previous screen
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              Navigator.of(context).pop(); // Close error dialog
              Navigator.of(context).pop({
                'success': false,
                'error': true,
                'message': result.message,
              }); // Go back to previous screen with error info
            }
          });
        } else {
          // Check for validation messages (warnings)
          if (result.validationMessage.isNotEmpty) {
            // Show warning dialog
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
                          'Notice',
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
            
            // Auto-close after 3 seconds and go back to previous screen
            Future.delayed(Duration(seconds: 3), () {
              if (mounted) {
                Navigator.of(context).pop(); // Close warning dialog
                Navigator.of(context).pop({
                  'success': false,
                  'warning': true,
                  'message': result.validationMessage,
                }); // Go back to previous screen with warning info
              }
            });
          } else {
            // Success - show success message
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
                          'Success!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          result.message.isNotEmpty ? result.message : '${_getAttendanceTypeText()} recorded successfully!',
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

            // Auto-close after 2 seconds and return to main screen with data
            Future.delayed(Duration(seconds: 2), () {
              if (mounted) {
                Navigator.of(context).pop(); // Close success dialog
                
                // Prepare return data with actual server timestamps
                String timestamp = DateTime.now().toIso8601String();
                if (result.data != null) {
                  // Use the actual timestamp from server response based on attendance type
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
                    case 'break_start':
                      if (result.data!.breakIn != null) {
                        timestamp = result.data!.breakIn!;
                      }
                      break;
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
                }); // Return to calling screen with data
              }
            });
          }
        }
      } else {
        throw Exception('Failed to submit attendance');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if open
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to submit attendance: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close error dialog
                  Navigator.of(context).pop({
                    'success': false,
                    'error': true,
                    'message': 'Failed to submit attendance: ${e.toString()}',
                  }); // Go back to previous screen with error info
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _submitAttendance(Recognition recognition) async {
    Navigator.of(context).pop(); // Close dialog
    
    // Stop recognition during submission
    setState(() {
      isRecognizing = false;
    });

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );

      // Get user data
      final preferences = Preferences();
      final userData = await preferences.getUserData();
      
      if (userData == null) {
        throw Exception('User data not found');
      }

      // Submit attendance
      final attendanceRepo = AttendanceRepository();
      
      // Get location data from widget or use defaults
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
        
        // Build address from location data
        String street = widget.locationData!['street'] ?? '';
        String city = widget.locationData!['city'] ?? '';
        String state = widget.locationData!['state'] ?? '';
        String country = widget.locationData!['country'] ?? '';
        address = '$street, $city, $state, $country'.replaceAll(RegExp(r'^,\s*|,\s*$'), '').trim();
        if (address.isEmpty) address = 'Location not available';
      } else {
        // Fallback values if no location data provided
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
        '', // No image file path needed for face recognition
        latitude: latitude,
        longitude: longitude,
        wifiSSID: wifiSSID,
        wifiBSSID: wifiBSSID,
        address: address,
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (result != null) {
        // Check if there's an error in the response
        if (result.error) {
          // Show error dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text(result.message.isNotEmpty ? result.message : 'An error occurred'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close error dialog
                    Navigator.of(context).pop({
                      'success': false,
                      'error': true,
                      'message': result.message,
                    }); // Go back to previous screen with error info
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else if (result.validationMessage.isNotEmpty) {
          // Show validation message dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Notice'),
              content: Text(result.validationMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop({
                      'success': false,
                      'warning': true,
                      'message': result.validationMessage,
                    }); // Go back to previous screen with warning info
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Success - show success dialog and return result
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Success!'),
              content: Text(result.message.isNotEmpty ? result.message : '${_getAttendanceTypeText()} recorded successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close success dialog
                    
                    // Prepare return data with actual server timestamps
                    String timestamp = DateTime.now().toIso8601String();
                    if (result.data != null) {
                      // Use the actual timestamp from server response based on attendance type
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
                        case 'break_start':
                          if (result.data!.breakIn != null) {
                            timestamp = result.data!.breakIn!;
                          }
                          break;
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
                    }); // Return to calling screen with data
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception('Failed to submit attendance');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if open
      
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to submit attendance: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close error dialog
                Navigator.of(context).pop({
                  'success': false,
                  'error': true,
                  'message': 'Failed to submit attendance: ${e.toString()}',
                }); // Go back to previous screen with error info
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
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
          _getAppBarTitle(),
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: !isInitialized
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
        children: [
          // Camera preview
          Expanded(
            child: Stack(
              children: [
                // Camera preview
                Positioned.fill(
                  child: controller.value.isInitialized
                      ? CameraPreview(controller)
                      : Container(color: Colors.grey[800]),
                ),

                // Face detection overlay
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

                // Anti-spoofing warning
                if (isRecognizing && !isRealFace)
                  Positioned(
                    top: 60,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "⚠️ Spoofing detected! Use your real face",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // Status indicator
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isRecognizing
                          ? Colors.green.withAlpha(200)
                          : Colors.grey.withAlpha(200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isRecognizing
                          ? (recognitions.isEmpty
                          ? "Looking for faces..."
                          : "Recognizing ${recognitions.length} face(s)")
                          : "Recognition paused",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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

      // Draw face box
      canvas.drawRRect(rRect, boxPaint);

      // Draw label background
      const double labelHeight = 30;
      final labelRect = Rect.fromLTRB(
        left,
        top - labelHeight,
        right,
        top,
      );
      final labelRRect = RRect.fromRectAndRadius(labelRect, const Radius.circular(4));
      canvas.drawRRect(labelRRect, labelBgPaint);

      // Draw label text
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${recognition.name} (${(recognition.distance * 100).toStringAsFixed(0)}%)',
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