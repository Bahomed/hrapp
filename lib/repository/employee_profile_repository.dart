import 'dart:io';
import 'package:dio/dio.dart';
import '../data/local/preferences.dart';
import '../data/remote/dio_client/dio_client.dart';
import '../data/remote/network_url/network_url.dart';
import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

class EmployeeProfileRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  // Get employee profile by ID
  Future<Map<String, dynamic>> getEmployeeProfile(int employeeId) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$getEmployeeProfileUrl$employeeId';

      final queryParams = {
        'locale': getCurrentLanguage(),
      };

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        queryParams,
      );

      if (response.data['success'] == true || response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load employee profile');
      }
    } on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }
}