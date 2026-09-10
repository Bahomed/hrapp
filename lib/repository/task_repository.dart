import 'dart:io';

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/task_models.dart';
import 'package:dio/dio.dart';

import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

/// Mobile Task Management API client. Mirrors App\Http\Controllers\Api\
/// TaskController method-for-method, following the same conventions as
/// ChatRepository (token + workspace URL from Preferences, DioException
/// funnelled through exceptionHandler).
class TaskRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  Future<Map<String, String>> _authHeader() async {
    final token = await preferences.getToken();
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, dynamic> _localeQuery([Map<String, dynamic>? extra]) => {
        'locale': getCurrentLanguage(),
        ...?extra,
      };

  Never _rethrow(Object e) {
    if (e is DioException) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    }
    throw e.toString();
  }

  String _boardUrl(TaskBoardType board) {
    switch (board) {
      case TaskBoardType.my:
        return tasksMyBoardUrl;
      case TaskBoardType.all:
        return tasksAllBoardUrl;
      case TaskBoardType.team:
        return tasksTeamBoardUrl;
    }
  }

  // ── Boards ───────────────────────────────────────────────────────────────

  /// GET /api/tasks/{my|all|team}-board — optionally filtered by a type code.
  /// `page` / `perPage` paginate every column at once (default 20/page, max 100).
  Future<TaskBoard> getBoard(
    TaskBoardType board, {
    String? taskType,
    int? page,
    int? perPage,
  }) async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}${_boardUrl(board)}',
        await _authHeader(),
        _localeQuery({
          if (taskType != null && taskType.isNotEmpty) 'task_type': taskType,
          if (page != null) 'page': page,
          if (perPage != null) 'per_page': perPage,
        }),
      );
      final env = TaskEnvelope.fromJson(
          res.data, (d) => TaskBoard.fromJson(Map<String, dynamic>.from(d)));
      return env.data ?? TaskBoard(columns: const []);
    } catch (e) {
      _rethrow(e);
    }
  }

  // ── Lookups ──────────────────────────────────────────────────────────────

  /// GET /api/tasks/statuses — every status, for the "move to" buttons.
  Future<List<TaskStatus>> getStatuses() async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}$taskStatusesUrl',
        await _authHeader(),
        _localeQuery(),
      );
      final env = TaskEnvelope.fromJson(res.data, (d) {
        final list = d is List ? d : (d as Map)['statuses'] as List? ?? [];
        return list
            .map((e) => TaskStatus.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
      return env.data ?? <TaskStatus>[];
    } catch (e) {
      _rethrow(e);
    }
  }

  /// GET /api/tasks/types — active task types for the create-task picker.
  Future<List<TaskType>> getTypes() async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}$taskTypesUrl',
        await _authHeader(),
        _localeQuery(),
      );
      final env = TaskEnvelope.fromJson(res.data, (d) {
        final list = d is List ? d : (d as Map)['types'] as List? ?? [];
        return list
            .map((e) => TaskType.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
      return env.data ?? <TaskType>[];
    } catch (e) {
      _rethrow(e);
    }
  }

  /// GET /api/tasks/employees/search — server-side searchable employee picker.
  /// Never load the full list client-side; always go through this.
  Future<List<TaskEmployee>> searchEmployees(
    String search, {
    int? selectedId,
    int limit = 50,
  }) async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}$taskEmployeesSearchUrl',
        await _authHeader(),
        _localeQuery({
          'search': search,
          'limit': limit,
          if (selectedId != null) 'selected_id': selectedId,
        }),
      );
      final env = TaskEnvelope.fromJson(res.data, (d) {
        final list = d is List ? d : (d as Map)['employees'] as List? ?? [];
        return list
            .map((e) => TaskEmployee.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
      return env.data ?? <TaskEmployee>[];
    } catch (e) {
      _rethrow(e);
    }
  }

  /// GET /api/tasks/count — open-task count for the badge (pool-scoped).
  Future<int> getCount() async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}$taskCountUrl',
        await _authHeader(),
        _localeQuery(),
      );
      final env = TaskEnvelope.fromJson(
          res.data, (d) => _asCount(d));
      return env.data ?? 0;
    } catch (e) {
      _rethrow(e);
    }
  }

  int _asCount(dynamic d) {
    if (d is int) return d;
    if (d is Map) {
      final v = d['count'];
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
    }
    return 0;
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  /// POST /api/tasks/{id}/status — move a task to another status.
  Future<void> updateStatus(int taskId, String status, {String? notes}) async {
    try {
      await dioClient.post(
        '${await preferences.getWorkspaceUrl()}${taskStatusUpdateUrl(taskId)}',
        {
          'status': status,
          if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        },
        _localeQuery(),
        await _authHeader(),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  /// POST /api/tasks — create a manual task. Returns the created task on
  /// success; a 422 surfaces the first validation error as a thrown String.
  Future<TaskItem?> createTask({
    required String taskType,
    required int employeeId,
    String? title,
    String? description,
  }) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}$createTaskUrl',
        {
          'task_type': taskType,
          'employee_id': employeeId,
          if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
        },
        _localeQuery(),
        await _authHeader(),
      );
      final data = res.data is Map ? res.data['data'] : null;
      if (data is Map) {
        return TaskItem.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      _rethrow(e);
    }
  }
}
