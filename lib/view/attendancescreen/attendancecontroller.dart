import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:injazat_hr_app/repository/attendancerepository.dart';
import 'package:injazat_hr_app/utils/alertbox.dart';
import 'package:injazat_hr_app/utils/list_extensions.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
// import 'package:tflite_flutter/tflite_flutter.dart';

class AttendanceController extends GetxController {
  final repository = AttendanceRepository();

  var status = 0.obs;
  var person = "".obs;
  var debugMessage = "".obs; // Add this missing property

  var mode = 0;

  @override
  Future<void> onInit() async {
    mode = Get.arguments["mode"];
    debugMessage.value = "Initializing camera...";
    await getImageFromCamera();
    super.onInit();
  }

  Future<void> getImageFromCamera() async {
    try {
      debugMessage.value = "Starting liveness detection...";


      customLoader();

      
      Get.back();
      

    } catch (e) {
      status.value = 2;
      person.value = "Something went wrong. Please scan face again";
      debugMessage.value = "Error: ${e.toString()}";
    }
  }

  void _searchResult(List predictedData, File imageFile) async {
    try {
      double currDist = 0.0;


        return;


    } catch (e) {
      debugMessage.value = "Error in search: ${e.toString()}";
      person.value = "Unknown User";
      status.value = 2;
      showLottieDialog("Unknown User", "Search failed", AlertType.error,
          "assets/raw/error.json");
    }
  }

  double euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }

    return sqrt(sum);
  }

  // You'll need to implement this method or import it from your utils
  Float32List imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    
    for (int i = 0; i < 112; i++) {
      for (int j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        // Updated for image package v4.x
        buffer[pixelIndex++] = (pixel.r - 127.5) / 127.5;
        buffer[pixelIndex++] = (pixel.g - 127.5) / 127.5;
        buffer[pixelIndex++] = (pixel.b - 127.5) / 127.5;
      }
    }
    return convertedBytes;
  }
}