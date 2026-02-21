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
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      body: Column(
        children: [
          _buildFilterSection(context, controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hasError.value) {
                return _buildErrorState(context, controller);
              }

              if (controller.filteredNotifications.isEmpty) {
                return _buildEmptyState(context, controller);
              }

              return _buildNotificationsList(context, controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, NotificationController controller) {
    final themeService = ThemeService.instance;
    
    return Container(
      padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 16, tablet: 20, desktop: 24)
          .add(ResponsiveUtils.responsiveVerticalPadding(context, mobile: 12, tablet: 14, desktop: 16)),
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
              children: [
                // All filter
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tr('all')),
                    selected: controller.selectedFilter.value == null,
                    onSelected: (_) => controller.filterByType(null),
                    backgroundColor: themeService.getSurfaceColor(),
                    selectedColor: Colors.blue.withOpacity(0.2),
                    checkmarkColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: controller.selectedFilter.value == null ? Colors.blue : themeService.getTextSecondaryColor(),
                      fontWeight: controller.selectedFilter.value == null ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: controller.selectedFilter.value == null ? Colors.blue : themeService.getTextSecondaryColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                // Type filters
                ...NotificationType.values.map((type) {
                  final isSelected = controller.selectedFilter.value == type;
                  final color = _getTypeColor(type);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppNotification(
                            id: '',
                            title: '',
                            body: '',
                            type: type,
                            timestamp: DateTime.now(),
                          ).typeIcon),
                          const SizedBox(width: 4),
                          Text(AppNotification(
                            id: '',
                            title: '',
                            body: '',
                            type: type,
                            timestamp: DateTime.now(),
                          ).typeDisplayName),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) => controller.filterByType(type),
                      backgroundColor: themeService.getSurfaceColor(),
                      selectedColor: color.withOpacity(0.2),
                      checkmarkColor: color,
                      labelStyle: TextStyle(
                        color: isSelected ? color : themeService.getTextSecondaryColor(),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? color : themeService.getTextSecondaryColor().withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  );
                }).toList(),
              ],
            )),
          ),
          const SizedBox(height: 12),
          // Unread filter and refresh button
          Row(
            children: [
              Obx(() => FilterChip(
                label: Text(tr('unread_only')),
                selected: controller.showOnlyUnread.value,
                onSelected: (_) => controller.toggleUnreadFilter(),
                backgroundColor: themeService.getSurfaceColor(),
                selectedColor: Colors.orange.withOpacity(0.2),
                checkmarkColor: Colors.orange,
                labelStyle: TextStyle(
                  color: controller.showOnlyUnread.value ? Colors.orange : themeService.getTextSecondaryColor(),
                  fontWeight: controller.showOnlyUnread.value ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: controller.showOnlyUnread.value ? Colors.orange : themeService.getTextSecondaryColor().withOpacity(0.3),
                  width: 1,
                ),
              )),
              const Spacer(),
              // Refresh button
              Obx(() => ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : controller.refreshNotifications,
                icon: controller.isLoading.value
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: themeService.getTextPrimaryColor(),
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(tr('refresh')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeService.getActionColor('primary'),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(BuildContext context, NotificationController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: ListView.builder(
        padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 16, tablet: 20, desktop: 24),
        itemCount: controller.filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = controller.filteredNotifications[index];
          return _buildNotificationCard(context, notification, controller);
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification notification, NotificationController controller) {
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.onNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 16, tablet: 20, desktop: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead ? null : Theme.of(context).primaryColor.withOpacity(0.05),
            border: notification.isRead ? null : Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getTypeColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: notification.type == NotificationType.message &&
                              notification.data?['employee_id'] != null
                          ? const Icon(Icons.person, size: 22, color: Colors.purple)
                          : Text(
                              notification.typeIcon,
                              style: const TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.typeDisplayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getTypeColor(notification.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTimestamp(notification.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, NotificationController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            tr('no_notifications'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('no_notifications_description'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, NotificationController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            tr('error_loading_notifications'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.refreshNotifications,
            child: Text(tr('retry')),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(NotificationType type) {
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return trParams('days_ago', {'days': difference.inDays.toString()});
    } else if (difference.inHours > 0) {
      return trParams('hours_ago', {'hours': difference.inHours.toString()});
    } else if (difference.inMinutes > 0) {
      return trParams('minutes_ago', {'minutes': difference.inMinutes.toString()});
    } else {
      return tr('just_now');
    }
  }


}