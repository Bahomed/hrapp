import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/data/remote/dio_client/dio_client.dart';
import 'package:injazat_hr_app/data/remote/network_url/network_url.dart';
import '../data/remote/response/schedule_models.dart';
import '../utils/exceptionhandler.dart';

class ScheduleRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  // Get all schedule templates
  Future<List<ScheduleTemplate>> getScheduleTemplates() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/schedule-templates';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
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

}