import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/remote/response/task_models.dart';
import '../../../services/theme_service.dart';
import '../../../utils/translation_helper.dart';
import '../task_ui_helpers.dart';
import '../tasks_controller.dart';

/// One task card. In an actionable column it can expand to reveal a notes
/// field and one "Mark as {status}" button per other status. In a terminal
/// column it is read-only and shows completion details.
class TaskCard extends StatelessWidget {
  final TaskItem task;
  final TaskColumn column;
  final TaskBoardType boardType;
  final TasksController controller;

  const TaskCard({
    super.key,
    required this.task,
    required this.column,
    required this.boardType,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final typeColor = taskHexColor(column.color, theme.getPrimaryColor());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.getDividerColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TypeBadge(label: task.taskTypeName, color: typeColor),
                const SizedBox(height: 8),
                if (task.title.isNotEmpty)
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.getTextPrimaryColor(),
                    ),
                  ),
                if ((task.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: theme.getTextSecondaryColor(),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                if ((task.employeeName ?? '').isNotEmpty)
                  _MetaLine(
                    icon: Icons.person_outline,
                    label: tr('employee'),
                    value: task.employeeName!,
                  ),
                if ((task.responsibleNames ?? '').isNotEmpty)
                  _MetaLine(
                    icon: Icons.assignment_ind_outlined,
                    label: tr('responsible'),
                    value: task.responsibleNames!,
                  ),
                if ((task.createdAt ?? '').isNotEmpty)
                  _MetaLine(
                    icon: Icons.schedule,
                    label: '',
                    value: task.createdAt!,
                  ),
                if (column.isTerminal) _terminalDetails(theme),
                if (!column.isTerminal) _actions(context, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _terminalDetails(ThemeService theme) {
    final hasBy = (task.completedByName ?? '').isNotEmpty;
    final hasNotes = (task.completionNotes ?? '').isNotEmpty;
    if (!hasBy && !hasNotes && (task.completedAt ?? '').isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.getSurfaceColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasBy)
            _MetaLine(
              icon: Icons.verified_outlined,
              label: tr('completed_by'),
              value: task.completedByName!,
            ),
          if ((task.completedAt ?? '').isNotEmpty)
            _MetaLine(
              icon: Icons.event_available_outlined,
              label: '',
              value: task.completedAt!,
            ),
          if (hasNotes) ...[
            const SizedBox(height: 4),
            Text(
              tr('completion_notes'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: theme.getTextSecondaryColor(),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              task.completionNotes!,
              style: TextStyle(
                fontSize: 12.5,
                color: theme.getTextPrimaryColor(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, ThemeService theme) {
    // Server-enforced, no bypass (admins included): only a member of this
    // task type's responsibility pool may move it, so don't even offer the
    // controls to anyone else.
    if (!task.canChangeStatus) {
      return _NotResponsibleNote(theme: theme);
    }
    return Obx(() {
      // Touch both observables up front so Obx always registers a dependency,
      // even on the early-return paths below.
      final expanded = controller.expandedTaskId.value == task.id;
      final targets = controller.statuses.isEmpty
          ? const <TaskStatus>[]
          : controller.moveTargetsFor(column.code);
      if (targets.isEmpty) return const SizedBox.shrink();

      if (!expanded) {
        return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: () => controller.toggleExpanded(task.id),
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: Text(tr('move_task')),
            style: TextButton.styleFrom(
              foregroundColor: theme.getPrimaryColor(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      }

      return _ExpandedActions(
        task: task,
        column: column,
        boardType: boardType,
        controller: controller,
        targets: targets,
      );
    });
  }
}

class _NotResponsibleNote extends StatelessWidget {
  final ThemeService theme;
  const _NotResponsibleNote({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.getSurfaceColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline,
              size: 14, color: theme.getTextSecondaryColor()),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tr('task_not_responsible'),
              style: TextStyle(
                fontSize: 11.5,
                color: theme.getTextSecondaryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandedActions extends StatefulWidget {
  final TaskItem task;
  final TaskColumn column;
  final TaskBoardType boardType;
  final TasksController controller;
  final List<TaskStatus> targets;

  const _ExpandedActions({
    required this.task,
    required this.column,
    required this.boardType,
    required this.controller,
    required this.targets,
  });

  @override
  State<_ExpandedActions> createState() => _ExpandedActionsState();
}

class _ExpandedActionsState extends State<_ExpandedActions> {
  final TextEditingController _notes = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _move(TaskStatus target) async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.controller.updateStatus(
      widget.boardType,
      widget.task,
      target,
      notes: _notes.text,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _notes,
            minLines: 1,
            maxLines: 3,
            style: TextStyle(fontSize: 13, color: theme.getTextPrimaryColor()),
            decoration: InputDecoration(
              hintText: tr('add_a_note_optional'),
              hintStyle: TextStyle(
                  fontSize: 12.5, color: theme.getTextSecondaryColor()),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.getDividerColor()),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.getDividerColor()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in widget.targets)
                _StatusButton(
                  status: s,
                  busy: _busy,
                  onTap: () => _move(s),
                ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => widget.controller.toggleExpanded(widget.task.id),
                style: TextButton.styleFrom(
                  foregroundColor: theme.getTextSecondaryColor(),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(tr('cancel')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final TaskStatus status;
  final bool busy;
  final VoidCallback onTap;

  const _StatusButton({
    required this.status,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final color = taskHexColor(status.color, theme.getPrimaryColor());
    return ElevatedButton(
      onPressed: busy ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: taskOnColor(color),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        visualDensity: VisualDensity.compact,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        trParams('mark_as_status', {'status': status.name}),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TypeBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: theme.getTextSecondaryColor()),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 11.5,
                  color: theme.getTextSecondaryColor(),
                ),
                children: [
                  if (label.isNotEmpty)
                    TextSpan(
                      text: '$label: ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
