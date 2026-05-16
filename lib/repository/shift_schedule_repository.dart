import 'package:dio/dio.dart';

import '../data/local/preferences.dart';
import '../data/remote/dio_client/dio_client.dart';
import '../data/remote/response/weekly_shift_schedule_response.dart';
import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

class ShiftScheduleRepository {
  final DioClient _dioClient = DioClient();
  final Preferences _preferences = Preferences();

  Future<WeeklyShiftScheduleResponse> getSchedule({
    required String view,   // 'today' | 'weekly' | 'monthly'
    String? weekStart,      // 'YYYY-MM-DD' — required for view=weekly
    String? month,          // 'YYYY-MM'    — required for view=monthly
  }) async {
    final token = await _preferences.getToken();
    final workspaceUrl = await _preferences.getWorkspaceUrl();

    final Map<String, dynamic> query = {
      'view': view,
      'locale': getCurrentLanguage(),
    };
    if (weekStart != null) query['week_start'] = weekStart;
    if (month != null) query['month'] = month;

    try {
      final response = await _dioClient.get(
        '$workspaceUrl/api/weekly-shift-schedule',
        {'Authorization': 'Bearer $token'},
        query,
      );
      final data = response.data;
      if (data == null) {
        return WeeklyShiftScheduleResponse(
          success: false,
          view: view,
          rangeStart: '',
          rangeEnd: '',
          days: [],
        );
      }
      return WeeklyShiftScheduleResponse.fromJson(
          data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<ManagerWeeklyShiftScheduleResponse> getManagerSchedule({
    required String view,
    String? weekStart,
    String? month,
  }) async {
    final token = await _preferences.getToken();
    final workspaceUrl = await _preferences.getWorkspaceUrl();

    final Map<String, dynamic> query = {
      'view': view,
      'locale': getCurrentLanguage(),
    };
    if (weekStart != null) query['week_start'] = weekStart;
    if (month != null) query['month'] = month;

    try {
      final response = await _dioClient.get(
        '$workspaceUrl/api/manager/weekly-shift-schedule',
        {'Authorization': 'Bearer $token'},
        query,
      );
      final data = response.data;
      if (data == null) {
        return ManagerWeeklyShiftScheduleResponse(
          success: false,
          view: view,
          rangeStart: '',
          rangeEnd: '',
          employees: [],
        );
      }
      return ManagerWeeklyShiftScheduleResponse.fromJson(
          data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }
}
