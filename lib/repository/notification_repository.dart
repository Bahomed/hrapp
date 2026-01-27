import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/app_notification_model.dart';
import 'package:dio/dio.dart';

import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

class NotificationRepository {
  final Preferences preferences = Preferences();
  final dioClient = DioClient();

  Future<List<AppNotification>> getNotifications() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      
      final response = await dioClient.get(
        '$workspaceUrl$notificationsUrl',
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage()},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => AppNotification.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (error) {
      if (error is DioException) {
        throw exceptionHandler(error);
      }
      throw Exception('Network error occurred');
    }
  }

  Future<AppNotification> getNotification(String id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      
      final response = await dioClient.get(
        '$workspaceUrl$notificationsUrl/$id',
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage()},
      );

      if (response.statusCode == 200) {
        return AppNotification.fromJson(response.data);
      } else {
        throw Exception('Failed to load notification');
      }
    } catch (error) {
      if (error is DioException) {
        throw exceptionHandler(error);
      }
      throw Exception('Network error occurred');
    }
  }

  Future<bool> markNotificationAsRead(String id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      
      final response = await dioClient.post(
        '$workspaceUrl$notificationsUrl/$id/mark-read',
        {},
        {'locale': getCurrentLanguage()},
        {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (error) {
      if (error is DioException) {
        throw exceptionHandler(error);
      }
      return false;
    }
  }
}