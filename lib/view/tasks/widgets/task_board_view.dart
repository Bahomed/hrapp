import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/remote/response/task_models.dart';
import '../../../services/theme_service.dart';
import '../../../utils/translation_helper.dart';
import '../task_ui_helpers.dart';
import '../tasks_controller.dart';
import 'task_card.dart';

/// One board rendered as a horizontal-scroll Kanban — one column per entry in
/// the API's `columns` (never a hardcoded set of statuses). A type-filter chip
/// row sits above it when the API exposes task types.
class TaskBoardView extends StatelessWidget {
  final TaskBoardType boardType;
  const TaskBoardView({super.key, required this.boardType});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final c = Get.find<TasksController>();

    // Lazily fetch this board the first time its tab is built.
    WidgetsBinding.instance.addPostFrameCallback((_) => c.loadBoard(boardType));

    return Obx(() {
      final loading = c.isLoading(boardType);
      final error = c.errorFor(boardType);
      final board = c.dataFor(boardType);

      if (loading && board == null) {
        return const Center(child: CircularProgressIndicator());
      }
      if (error != null && board == null) {
        return _ErrorState(
          message: error,
          onRetry: () => c.refreshBoard(boardType),
        );
      }

      final columns = board?.columns ?? const <TaskColumn>[];

      return Column(
        children: [
          if (c.types.isNotEmpty) _FilterChips(boardType: boardType, controller: c),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => c.refreshBoard(boardType),
              child: columns.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Text(
                            tr('no_tasks'),
                            style: TextStyle(
                                color: theme.getTextSecondaryColor()),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                      children: [
                        for (final col in columns)
                          _BoardColumn(
                            column: col,
                            boardType: boardType,
                            controller: c,
                          ),
                      ],
                    ),
            ),
          ),
        ],
      );
    });
  }
}

class _FilterChips extends StatelessWidget {
  final TaskBoardType boardType;
  final TasksController controller;
  const _FilterChips({required this.boardType, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Obx(() {
      final active = controller.filterFor(boardType);
      return SizedBox(
        height: 46,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          children: [
            _chip(
              label: tr('all_types'),
              selected: active == null,
              onTap: () => controller.setTypeFilter(boardType, null),
              theme: theme,
            ),
            for (final t in controller.types)
              _chip(
                label: t.name,
                selected: active == t.code,
                onTap: () => controller.setTypeFilter(boardType, t.code),
                theme: theme,
              ),
          ],
        ),
      );
    });
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required ThemeService theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? theme.getPrimaryColor()
                : theme.getCardColor(),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? theme.getPrimaryColor()
                  : theme.getDividerColor(),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : theme.getTextPrimaryColor(),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardColumn extends StatelessWidget {
  final TaskColumn column;
  final TaskBoardType boardType;
  final TasksController controller;

  const _BoardColumn({
    required this.column,
    required this.boardType,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final headerColor = taskHexColor(column.color, theme.getPrimaryColor());
    final width = MediaQuery.of(context).size.width * 0.82;

    return Container(
      width: width.clamp(260.0, 340.0),
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: theme.getPageBackgroundColor(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.getDividerColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.14),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                bottom: BorderSide(color: headerColor.withValues(alpha: 0.4)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: headerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    column.name,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: theme.getTextPrimaryColor(),
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.getCardColor(),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.getDividerColor()),
                  ),
                  child: Text(
                    '${column.tasks.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.getTextSecondaryColor(),
                    ),
                  ),
                ),
                if (column.isTerminal) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.lock_outline,
                      size: 13, color: theme.getTextSecondaryColor()),
                ],
              ],
            ),
          ),
          Expanded(
            child: column.tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        tr('no_tasks_in_column'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.getTextSecondaryColor(),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(10),
                    children: [
                      for (final task in column.tasks)
                        TaskCard(
                          task: task,
                          column: column,
                          boardType: boardType,
                          controller: controller,
                        ),
                      if (column.hasMore)
                        _LoadMore(
                          boardType: boardType,
                          column: column,
                          controller: controller,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _LoadMore extends StatelessWidget {
  final TaskBoardType boardType;
  final TaskColumn column;
  final TasksController controller;

  const _LoadMore({
    required this.boardType,
    required this.column,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Obx(() {
        final busy = controller.isLoadingMore(boardType, column.code);
        return OutlinedButton(
          onPressed: busy
              ? null
              : () => controller.loadMoreColumn(boardType, column.code),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.getPrimaryColor(),
            side: BorderSide(color: theme.getDividerColor()),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          child: busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  '${tr('load_more')}'
                  '${column.pagination != null ? ' (${column.tasks.length}/${column.pagination!.total})' : ''}',
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
        );
      }),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(tr('retry'))),
          ],
        ),
      ),
    );
  }
}
