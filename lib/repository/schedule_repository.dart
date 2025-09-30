import 'dart:io';
import 'package:dio/dio.dart';
import 'package:com.injazatsoftware.injazathr/data/local/preferences.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/network_url/network_url.dart';
import '../data/remote/response/schedule_models.dart';
import '../utils/exceptionhandler.dart';
import 'package:com.injazatsoftware.injazathr/utils/translation_helper.dart';

class ScheduleRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  // Get all schedule templates (optionally for specific employee)
  Future<List<ScheduleTemplate>> getScheduleTemplates([int? employeeId]) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/schedule-templates';

      final queryParams = {'locale': getCurrentLanguage()};
      if (employeeId != null) {
        queryParams['emp_id'] = employeeId.toString();
      }

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        queryParams,
      );

      final data = response.data['data'] as List;
      return data.map((e) => ScheduleTemplate.fromJson(e)).toList();
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

  // Get a single schedule template by ID
  Future<ScheduleTemplate> getScheduleTemplate(String id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/schedule-templates/$id';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );

      return ScheduleTemplate.fromJson(response.data['data']);
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

  // Get schedule templates for specific employee
  Future<List<ScheduleTemplate>> getScheduleTemplatesForEmployee(int employeeId) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/schedule-templates';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage(), 'emp_id': employeeId},
      );

      final data = response.data['data'] as List;
      return data.map((e) => ScheduleTemplate.fromJson(e)).toList();
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