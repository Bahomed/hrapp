import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:injazat_hr_app/repository/attendancerepository.dart';
import 'package:injazat_hr_app/utils/alertbox.dart';
import 'package:injazat_hr_app/utils/list_extensions.dart';
import 'package:injazat_hr_app/utils/location_service.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

enum VerificationState { scanning, processing, success, failed }

class FaceVerifyController extends GetxController {

  final attendanceRepository = AttendanceRepository();

  int userId = 0;
  String userName = "";
  String attendanceType = "clock_in"; // default to clock-in

  var verificationState = VerificationState.scanning.obs;
  var statusMessage = "".obs;

  @override
  Future<void> onInit() async {
    userId = Get.arguments["userId"] ?? 0;
    userName = Get.arguments["username"] ?? "";
    attendanceType = Get.arguments["attendanceType"] ?? "clock_in";
    
    statusMessage.value = "Position your face in the camera";
    await getImageFromCamera();
    super.onInit();
  }

  Future<void> getImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front);

      if (photo == null) {
        Get.back(result: false);
        return;
      }



    } catch (e) {
      verificationState.value = VerificationState.failed;
      statusMessage.value = "Something went wrong";
      showLottieDialog(
          "Verification Failed",
          "Something went wrong. Please try again.",
          AlertType.error,
          "assets/raw/error.json");
      
      await Future.delayed(const Duration(seconds: 2));
      Get.back(result: false);
    }
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int i = 0; i < 112; i++) {
      for (int j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - 128) / 128;
        buffer[pixelIndex++] = (pixel.g - 128) / 128;
        buffer[pixelIndex++] = (pixel.b - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  Future<bool> isValidFaceQuality(Face face, XFile photo) async {
    try {
      // Check face size (should be reasonable portion of image)
      final imageBytes = await photo.readAsBytes();
      final image = imglib.decodeImage(imageBytes);
      if (image == null) return false;

      double faceArea = face.boundingBox.width * face.boundingBox.height;
      double imageArea = image.width.toDouble() * image.height.toDouble();
      double faceRatio = faceArea / imageArea;

      // Face should be at least 8% but not more than 85% of image
      if (faceRatio < 0.08 || faceRatio > 0.85) return false;

      // Check if face landmarks are detected (indicates good quality)
      if (face.landmarks.isEmpty) return false;

      // Check face confidence if available
      if (face.trackingId != null && face.trackingId! < 0) return false;

      return true;
    } catch (e) {
      return false;
    }
  }
}
