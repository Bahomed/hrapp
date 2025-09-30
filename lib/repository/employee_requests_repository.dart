import 'dart:io';
import 'package:dio/dio.dart';
import '../data/local/preferences.dart';
import '../data/remote/dio_client/dio_client.dart';
import '../data/remote/network_url/network_url.dart';
import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

class EmployeeRequestsRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  // Get employee requests by ID with filtering options
  Future<Map<String, dynamic>> getEmployeeRequests(
    int employeeId, {
    String? selectedFilterType,
    String? search,
    String? status,
    int page = 1,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$getEmployeeRequestsUrl$employeeId';

      final queryParams = <String, dynamic>{
        'locale': getCurrentLanguage(),
        'page': page.toString(),
      };

      // Add optional filters
      if (selectedFilterType != null && selectedFilterType.isNotEmpty) {
        queryParams['selectedFilterType'] = selectedFilterType;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['selectedFilterStatus'] = status;
      }

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        queryParams,
      );

      if (response.data['error'] == false || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load employee requests');
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