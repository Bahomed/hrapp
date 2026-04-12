import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/data/remote/response/app_notification_model.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final theme = Theme.of(context);
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      body: Column(
        children: [
          _buildFilterBar(context, controller, theme, themeService),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.hasError.value) {
                return _buildErrorState(context, controller, theme);
              }
              if (controller.filteredNotifications.isEmpty) {
                return _buildEmptyState(context, theme);
              }
              return _buildList(context, controller, theme, themeService);
            }),
          ),
        ],
      ),
    );
  }

  // ── Filter bar ────────────────────────────────────────────────────────────

  Widget _buildFilterBar(
    BuildContext context,
    NotificationController controller,
    ThemeData theme,
    ThemeService themeService,
  ) {
    return Container(
      color: themeService.getSurfaceColor(),
      child: Column(
        children: [
          // Type chips row
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Obx(() => _chip(
                      label: tr('all'),
                      icon: Icons.all_inbox_rounded,
                      color: theme.primaryColor,
                      selected: controller.selectedFilter.value == null,
                      onTap: () => controller.filterByType(null),
                      theme: theme,
                    )),
                const SizedBox(width: 8),
                ...NotificationType.values.map((type) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Obx(() => _chip(
                            label: _typeName(type),
                            icon: _typeIconData(type),
                            color: _typeColor(type),
                            selected: controller.selectedFilter.value == type,
                            onTap: () => controller.filterByType(type),
                            theme: theme,
                          )),
                    )),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.4)),
          // Unread toggle + refresh
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Obx(() => _unreadToggle(controller, theme)),
                const Spacer(),
                Obx(() => _refreshButton(controller, theme, themeService)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : theme.dividerColor.withOpacity(0.5),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? color : theme.hintColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? color : theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unreadToggle(NotificationController controller, ThemeData theme) {
    final active = controller.showOnlyUnread.value;
    return GestureDetector(
      onTap: controller.toggleUnreadFilter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.orange.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.orange : theme.dividerColor.withOpacity(0.5),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mark_email_unread_outlined,
                size: 14,
                color: active ? Colors.orange : theme.hintColor),
            const SizedBox(width: 5),
            Text(
              tr('unread_only'),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? Colors.orange : theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _refreshButton(
    NotificationController controller,
    ThemeData theme,
    ThemeService themeService,
  ) {
    final loading = controller.isLoading.value;
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: loading ? null : controller.refreshNotifications,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeService.getActionColor('primary'),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: loading
            ? const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.refresh_rounded, size: 15),
        label: Text(tr('refresh'),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
      ),
    );
  }

  // ── List ──────────────────────────────────────────────────────────────────

  Widget _buildList(
    BuildContext context,
    NotificationController controller,
    ThemeData theme,
    ThemeService themeService,
  ) {
    final hPad = ResponsiveUtils.responsiveHorizontalPadding(
        context, mobile: 16, tablet: 20, desktop: 24);

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: ListView.builder(
        padding: hPad.copyWith(top: 12, bottom: 24),
        itemCount: controller.filteredNotifications.length,
        itemBuilder: (context, index) {
          final n = controller.filteredNotifications[index];
          return _NotificationCard(
            notification: n,
            onTap: () => controller.onNotificationTap(n),
            typeColor: _typeColor(n.type),
            typeIcon: _typeIconData(n.type),
            typeName: _typeName(n.type),
            timestamp: _formatTimestamp(n.timestamp),
            theme: theme,
            themeService: themeService,
          );
        },
      ),
    );
  }

  // ── Empty / Error states ──────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_rounded,
              size: 56, color: theme.hintColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(tr('no_notifications'),
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.hintColor.withOpacity(0.8))),
          const SizedBox(height: 6),
          Text(tr('no_notifications_description'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor.withOpacity(0.55))),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    NotificationController controller,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(tr('error_loading_notifications'),
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor.withOpacity(0.7))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.refreshNotifications,
              child: Text(tr('retry')),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Colors.blue;
      case NotificationType.payroll:
        return Colors.green;
      case NotificationType.requestStatus:
        return Colors.orange;
      case NotificationType.message:
        return Colors.purple;
      case NotificationType.approval:
        return Colors.red;
    }
  }

  IconData _typeIconData(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return Icons.info_outline_rounded;
      case NotificationType.payroll:
        return Icons.payments_outlined;
      case NotificationType.requestStatus:
        return Icons.assignment_turned_in_outlined;
      case NotificationType.message:
        return Icons.chat_bubble_outline_rounded;
      case NotificationType.approval:
        return Icons.how_to_reg_outlined;
    }
  }

  String _typeName(NotificationType type) {
    return AppNotification(
      id: '',
      title: '',
      body: '',
      type: type,
      timestamp: DateTime.now(),
    ).typeDisplayName;
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) {
      return trParams('days_ago', {'days': diff.inDays.toString()});
    } else if (diff.inHours > 0) {
      return trParams('hours_ago', {'hours': diff.inHours.toString()});
    } else if (diff.inMinutes > 0) {
      return trParams('minutes_ago', {'minutes': diff.inMinutes.toString()});
    } else {
      return tr('just_now');
    }
  }
}

// ── Notification card (extracted widget for clean rebuilds) ────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.typeColor,
    required this.typeIcon,
    required this.typeName,
    required this.timestamp,
    required this.theme,
    required this.themeService,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final Color typeColor;
  final IconData typeIcon;
  final String typeName;
  final String timestamp;
  final ThemeData theme;
  final ThemeService themeService;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(14),
        border: isUnread
            ? Border.all(color: typeColor.withOpacity(0.35), width: 1)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isUnread ? 0.07 : 0.04),
            blurRadius: isUnread ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored icon badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(typeIcon, size: 20, color: typeColor),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          typeName,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        notification.body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.45,
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(isUnread ? 0.85 : 0.65),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 11, color: theme.hintColor),
                          const SizedBox(width: 4),
                          Text(
                            timestamp,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.hintColor,
                            ),
                          ),
                          if (notification.actionUrl != null &&
                              notification.actionUrl!.isNotEmpty) ...[
                            const Spacer(),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 11, color: typeColor),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
