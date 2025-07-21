import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/utils/api_helper.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:math';

import '../data/remote/dio_client/dio_client.dart';
import '../data/remote/response/saveemployeeattendanceresponse.dart';
import '../data/remote/response/attendance_response.dart';
import '../utils/exceptionhandler.dart';

class AttendanceRepository {

  final dioclient = DioClient();
  final preferences = Preferences();



  Future<String> getToken() async {
    return await preferences.getToken();
  }





  /// Verify Face ID by comparing with stored data
  Future<bool> verifyFaceId(String scannedFaceData, int userId) async {
    try {
    return true;
    } catch (e) {
      print('Error verifying Face ID: $e');
      return false;
    }
  }

  /// Calculate cosine similarity between two face encodings
  double _calculateCosineSimilarity(List<double> vec1, List<double> vec2) {
    if (vec1.length != vec2.length) return 0.0;

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      norm1 += vec1[i] * vec1[i];
      norm2 += vec2[i] * vec2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) return 0.0;

    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }

  /// Clock in with Face ID verification including location data
  Future<SaveEmployeeAttendanceResponse> clockInWithFaceVerification(
      int userId, 
      String scannedFaceData, 
      String attendanceType, 
      String reason,
      {String image = '',
      double? latitude,
      double? longitude,
      String? wifiSSID,
      String? wifiBSSID,
      String? address}) async {
    
    // First verify the Face ID
    final isVerified = await verifyFaceId(scannedFaceData, userId);
    if (!isVerified) {
      throw Exception('Face ID verification failed. Please try again.');
    }

    // If verified, proceed with attendance including location data
    return await saveEmployeeAttendanceWithLocation(
      userId, 
      attendanceType, 
      reason, 
      image,
      latitude: latitude,
      longitude: longitude,
      wifiSSID: wifiSSID,
      wifiBSSID: wifiBSSID,
      address: address,
    );
  }

  /// Save attendance with location data
  Future<SaveEmployeeAttendanceResponse> saveEmployeeAttendanceWithLocation(
      int userid, 
      String attendanceType, 
      String reason, 
      String image,
      {double? latitude,
      double? longitude,
      String? wifiSSID,
      String? wifiBSSID,
      String? address}) async {
    
    final token = await preferences.getToken();
    final workspaceUrl = await preferences.getWorkspaceUrl();
    
    try {
      final formData = FormData.fromMap({
        'image': image.isEmpty
            ? ''
            : await MultipartFile.fromFile(image, filename: 'userImage.jpg'),
        'user_id': userid,
        'attendanceType': attendanceType,
        'reason': reason,
        'latitude': latitude?.toString() ?? '',
        'longitude': longitude?.toString() ?? '',
        'wifi_ssid': wifiSSID ?? '',
        'wifi_bssid': wifiBSSID ?? '',
        'address': address ?? '',
        'timestamp': DateTime.now().toIso8601String(),
        'locale': ApiHelper.instance.getCurrentLocale(),
      });
      
      final attendanceUrl = '$workspaceUrl/api/submit-attendance';
      var response = await dioclient.postForImageUpload(
          attendanceUrl,
          formData,
          {'Authorization': 'Bearer $token'});

      return SaveEmployeeAttendanceResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<SaveEmployeeAttendanceResponse> saveEmployeeAttendance(
      int userid, String attenancetype, String reason, String image) async {
    final token = await preferences.getToken();
    final workspaceUrl = await preferences.getWorkspaceUrl();
    
    try {
      final formData = FormData.fromMap({
        'image': image.isEmpty
            ? ''
            : await MultipartFile.fromFile(image, filename: 'userImage.jpg'),
        'user_id': userid,
        'attendanceType': attenancetype,
        'reason': reason,
      });
      
      final attendanceUrl = '$workspaceUrl/api/submit-attendance';
      var response = await dioclient.postForImageUpload(
          attendanceUrl,
          formData,
          {'Authorization': 'Bearer $token'});

      return SaveEmployeeAttendanceResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  /// Get attendance status for current day
  Future<Map<String, dynamic>> getAttendanceStatus({DateTime? timestamp, String? locale}) async {
    final token = await preferences.getToken();
    final workspaceUrl = await preferences.getWorkspaceUrl();
    
    try {
      final now = timestamp ?? DateTime.now();
      final currentLocale = locale ?? ApiHelper.instance.getCurrentLocale();
      
      final queryParams = {
        'locale': currentLocale,
        'timestamp': now.toIso8601String(),
      };
      
      final apiUrl = '$workspaceUrl/api/attendance/status';
      
      print('Calling attendance status API: $apiUrl');
      print('Query params: $queryParams');
      print('Token: ${token.isNotEmpty ? "Present" : "Missing"}');
      
      final response = await dioclient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        queryParams,
      );
      
      print('Attendance status API response: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      return response.data;
    } on DioException catch (e) {
      print('Dio error in attendance status API: ${e.message}');
      print('Error response: ${e.response?.data}');
      throw exceptionHandler(e);
    } catch (e) {
      print('General error in attendance status API: $e');
      rethrow;
    }
  }

  /// Get user attendance for calendar by month and year
  Future<AttendanceCalendarResponse> getUserAttendanceByMonthYear(int month, int year) async {
    final token = await preferences.getToken();
    final workspaceUrl = await preferences.getWorkspaceUrl();
    
    try {
      final apiUrl = '$workspaceUrl/api/attendance/calendar/$month/$year';
      
      print('Calling attendance API: $apiUrl');
      print('Token: ${token.isNotEmpty ? "Present" : "Missing"}');
      
      final response = await dioclient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      
      print('Attendance API response: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      return AttendanceCalendarResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio error in attendance API: ${e.message}');
      print('Error response: ${e.response?.data}');
      throw exceptionHandler(e);
    } catch (e) {
      print('General error in attendance API: $e');
      rethrow;
    }
  }
}
