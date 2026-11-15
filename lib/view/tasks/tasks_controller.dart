import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/preferences.dart';
import '../../data/remote/dio_client/dio_client.dart';
import '../../data/remote/network_url/network_url.dart';
import '../../data/remote/response/task_models.dart';
import '../../utils/api_result.dart';
import '../../repository/task_repository.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';

/// Drives the three task boards (My / All / Team). Statuses and types are
/// shared across boards and fetched once; each board keeps its own cached
/// data, loading/error state and optional type filter so switching tabs is
/// instant and a refresh only re-hits the visible board.
///
/// Per-board state is held as concrete `Rx` objects (not an `RxMap`) so that
/// every `.value` read inside an `Obx` is tracked — `RxMap` does not report a
/// reactive read on `operator []`, which silently breaks `Obx`.
class TasksController extends GetxController {
  final TaskRepository _repo = TaskRepository();
  final ThemeService _theme = ThemeService.instance;

  static const boards = <TaskBoardType>[
    TaskBoardType.my,
    TaskBoardType.all,
    TaskBoardType.team,
  ];

  final Map<TaskBoardType, Rxn<TaskBoard>> _data = {
    for (final b in boards) b: Rxn<TaskBoard>(),
  };
  final Map<TaskBoardType, RxBool> _loading = {
    for (final b in boards) b: false.obs,
  };
  final Map<TaskBoardType, RxnString> _error = {
    for (final b in boards) b: RxnString(),
  };
  final Map<TaskBoardType, RxnString> _filter = {
    for (final b in boards) b: RxnString(),
  };
  final Map<TaskBoardType, bool> _fetched = {};

  // "load more" spinner state, one lazily-created RxBool per "board:columnCode".
  final Map<String, RxBool> _loadingMore = {};
  RxBool _loadingMoreRx(String key) =>
      _loadingMore.putIfAbsent(key, () => false.obs);

  // Shared lookups.
  final RxList<TaskStatus> statuses = <TaskStatus>[].obs;
  final RxList<TaskType> types = <TaskType>[].obs;

  // Which task's action row is currently expanded on a card (id, or null).
  final RxnInt expandedTaskId = RxnInt();

  final RxInt openCount = 0.obs;

  /// Boards this user may open (Settings › Permissions › Tasks):
  /// My always; Team (`tasks.t_team`) / All (`tasks.t_all`) only when their
  /// board answers 200.
  final RxList<TaskBoardType> availableBoards =
      <TaskBoardType>[TaskBoardType.my].obs;

  @override
  void onInit() {
    super.onInit();
    _loadLookups();
    loadBoard(TaskBoardType.my);
    refreshCount();
    _probeBoards();
  }

  Future<void> _probeBoards() async {
    final base = await Preferences().getWorkspaceUrl();
    Future<bool> ok(String path) async {
      final r = await ApiResult.guard(() => DioClient().dio.get('$base$path',
          queryParameters: {'locale': getCurrentLanguage(), 'per_page': 1}));
      return r.statusCode == 200;
    }

    final results = await Future.wait([ok(tasksAllBoardUrl), ok(tasksTeamBoardUrl)]);
    availableBoards.assignAll([
      TaskBoardType.my,
      if (results[0]) TaskBoardType.all,
      if (results[1]) TaskBoardType.team,
    ]);
  }

  Future<void> _loadLookups() async {
    // Non-fatal: cards still render without move buttons / the type filter.
    try {
      statuses.value = await _repo.getStatuses();
    } catch (_) {}
    try {
      types.value = await _repo.getTypes();
    } catch (_) {}
  }

  bool isLoading(TaskBoardType b) => _loading[b]!.value;
  String? errorFor(TaskBoardType b) => _error[b]!.value;
  TaskBoard? dataFor(TaskBoardType b) => _data[b]!.value;
  String? filterFor(TaskBoardType b) => _filter[b]!.value;

  Future<void> loadBoard(TaskBoardType board, {bool force = false}) async {
    if (_loading[board]!.value) return;
    if (!force && (_fetched[board] ?? false)) return;
    _loading[board]!.value = true;
    _error[board]!.value = null;
    try {
      _data[board]!.value =
          await _repo.getBoard(board, taskType: _filter[board]!.value);
      _fetched[board] = true;
    } catch (e) {
      _error[board]!.value = e.toString();
    } finally {
      _loading[board]!.value = false;
    }
  }

  Future<void> refreshBoard(TaskBoardType board) =>
      loadBoard(board, force: true);

  bool isLoadingMore(TaskBoardType board, String columnCode) =>
      _loadingMoreRx('${board.name}:$columnCode').value;

  /// Fetch the next page for one column and append it. `page` on the board
  /// request paginates every column, so we only merge the requested one and
  /// leave the others untouched.
  Future<void> loadMoreColumn(TaskBoardType board, String columnCode) async {
    final current = _data[board]!.value;
    if (current == null) return;
    final idx = current.columns.indexWhere((c) => c.code == columnCode);
    if (idx == -1) return;
    final col = current.columns[idx];
    final pg = col.pagination;
    if (pg == null || !pg.hasMore) return;

    final key = '${board.name}:$columnCode';
    final busy = _loadingMoreRx(key);
    if (busy.value) return;
    busy.value = true;
    try {
      final next = await _repo.getBoard(
        board,
        taskType: _filter[board]!.value,
        page: pg.currentPage + 1,
      );
      final freshIdx =
          next.columns.indexWhere((c) => c.code == columnCode);
      if (freshIdx == -1) return;
      final fresh = next.columns[freshIdx];

      final seen = col.tasks.map((t) => t.id).toSet();
      final merged = <TaskItem>[
        ...col.tasks,
        ...fresh.tasks.where((t) => !seen.contains(t.id)),
      ];
      final columns = [...current.columns];
      columns[idx] =
          col.copyWith(tasks: merged, pagination: fresh.pagination);
      _data[board]!.value = TaskBoard(columns: columns);
    } catch (e) {
      _snack(tr('error'), e.toString());
    } finally {
      busy.value = false;
    }
  }

  void setTypeFilter(TaskBoardType board, String? code) {
    _filter[board]!.value = (code == null || code.isEmpty) ? null : code;
    loadBoard(board, force: true);
  }

  void toggleExpanded(int taskId) {
    expandedTaskId.value = expandedTaskId.value == taskId ? null : taskId;
  }

  /// Statuses a task can be moved to — everything except its current column.
  List<TaskStatus> moveTargetsFor(String currentColumnCode) =>
      statuses.where((s) => s.code != currentColumnCode).toList();

  Future<void> updateStatus(
    TaskBoardType board,
    TaskItem task,
    TaskStatus target, {
    String? notes,
  }) async {
    try {
      await _repo.updateStatus(task.id, target.code, notes: notes);
      expandedTaskId.value = null;
      _snack(tr('success'), tr('task_updated'), error: false);
      await refreshBoard(board);
      refreshCount();
    } catch (e) {
      _snack(tr('error'), e.toString());
    }
  }

  Future<void> refreshCount() async {
    try {
      openCount.value = await _repo.getCount();
    } catch (_) {}
  }

  /// Called by the create-task flow after a successful POST so every board that
  /// has already been opened — and the badge — reflect the new task.
  Future<void> onTaskCreated() async {
    for (final b in boards) {
      if (_fetched[b] ?? false) await loadBoard(b, force: true);
    }
    refreshCount();
  }

  void _snack(String title, String msg, {bool error = true}) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          error ? _theme.getErrorColor() : _theme.getSuccessColor(),
      colorText: Colors.white,
    );
  }
}
