import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/remote/response/task_models.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'create_task_screen.dart';
import 'tasks_controller.dart';
import 'widgets/task_board_view.dart';

/// The three task boards behind a tab bar. Deep-linked from a `task`
/// notification, which lands on the first tab (My Tasks).
class TasksScreen extends StatelessWidget {
  /// Which board to open on. Notifications deep-link to My Tasks.
  final TaskBoardType initialBoard;

  const TasksScreen({super.key, this.initialBoard = TaskBoardType.my});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final c = Get.isRegistered<TasksController>()
        ? Get.find<TasksController>()
        : Get.put(TasksController());

    final tabs = <TaskBoardType, String>{
      TaskBoardType.my: tr('my_tasks'),
      TaskBoardType.all: tr('all_tasks'),
      TaskBoardType.team: tr('team_tasks'),
    };
    final initialIndex = TasksController.boards.indexOf(initialBoard);

    return DefaultTabController(
      length: TasksController.boards.length,
      initialIndex: initialIndex < 0 ? 0 : initialIndex,
      child: Scaffold(
        backgroundColor: theme.getPageBackgroundColor(),
        appBar: AppBar(
          backgroundColor: theme.getSurfaceColor(),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.getTextPrimaryColor()),
            onPressed: () => Get.back(),
          ),
          title: Text(
            tr('tasks'),
            style: TextStyle(
              color: theme.getTextPrimaryColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.refresh, color: theme.getTextPrimaryColor()),
                onPressed: () => c.refreshBoard(
                  TasksController.boards[DefaultTabController.of(context).index],
                ),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: false,
            labelColor: theme.getPrimaryColor(),
            unselectedLabelColor: theme.getTextSecondaryColor(),
            indicatorColor: theme.getPrimaryColor(),
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            tabs: [
              for (final b in TasksController.boards) Tab(text: tabs[b]),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: theme.getPrimaryColor(),
          onPressed: () async {
            final created = await Get.to(() => const CreateTaskScreen());
            if (created == true) c.onTaskCreated();
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: TabBarView(
          children: [
            for (final b in TasksController.boards) TaskBoardView(boardType: b),
          ],
        ),
      ),
    );
  }
}
