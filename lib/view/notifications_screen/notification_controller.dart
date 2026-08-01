import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/data/remote/response/app_notification_model.dart';
import 'package:co.injazathr.injazathr/repository/notification_repository.dart';
import 'package:co.injazathr.injazathr/view/payroll/payroll_screen.dart';
import 'package:flutter/material.dart';

import '../approval/approval_screen.dart';
import '../attendance/attendance_detail_screen.dart';
import '../profile/employee_profile_screen.dart';
import '../request_leave/request_home_screen.dart';
import '../request_detail/request_detail_screen.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();
  
  var notifications = <AppNotification>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  var filteredNotifications = <AppNotification>[].obs;
  var selectedFilter = Rxn<NotificationType>();
  var selectedRequestType = RxnString();
  var showOnlyUnread = false.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Ensure "All" filter is selected by default
    selectedFilter.value = null;
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final typeParam = selectedFilter.value != null
          ? _notificationTypeToParam(selectedFilter.value!)
          : null;

      final data = await _repository.getNotifications(
        type: typeParam,
        requestType: selectedRequestType.value,
      );
      notifications.value = data;

      applyFilters();
    } catch (error) {
      hasError.value = true;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  String _notificationTypeToParam(NotificationType type) {
    switch (type) {
      case NotificationType.general:
        return 'general';
      case NotificationType.payroll:
        return 'payroll';
      case NotificationType.requestStatus:
        return 'requestStatus';
      case NotificationType.message:
        return 'message';
      case NotificationType.approval:
        return 'approval';
      case NotificationType.attendance:
        return 'attendance';
    }
  }

  void applyFilters() {
    var filtered = notifications.where((notification) {
      bool typeMatch = true;
      bool readMatch = true;

      if (selectedFilter.value != null) {
        typeMatch = notification.type == selectedFilter.value;
      }

      if (showOnlyUnread.value) {
        readMatch = !notification.isRead;
      }

      return typeMatch && readMatch;
    }).toList();

    filteredNotifications.value = filtered;
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  void filterByType(NotificationType? type) {
    selectedFilter.value = type;
    // Clear request type when switching top-level type away from requestStatus
    if (type != NotificationType.requestStatus) {
      selectedRequestType.value = null;
    }
    loadNotifications();
  }

  void filterByRequestType(String? requestType) {
    selectedRequestType.value = requestType;
    // Ensure type filter is on requestStatus when a request subtype is chosen
    if (requestType != null) {
      selectedFilter.value = NotificationType.requestStatus;
    }
    loadNotifications();
  }

  void toggleUnreadFilter() {
    showOnlyUnread.value = !showOnlyUnread.value;
    applyFilters();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || notifications[index].isRead) return;

    // Update locally immediately so badge reflects at once
    notifications[index] = notifications[index].copyWith(isRead: true);
    applyFilters();

    // Sync to server in background — local state already updated
    _repository.markNotificationAsRead(notificationId).catchError((_) {});
  }

  void onNotificationTap(AppNotification notification) {
    // Always mark as read when tapped
    if (!notification.isRead) {
      markAsRead(notification.id);
    }
    
    // Always handle the action - like FCM notifications
    handleNotificationAction(notification);
  }

  void handleNotificationAction(AppNotification notification) {
    switch (notification.type) {
      case NotificationType.payroll:
        // Navigate to payroll screen - like FCM notification
        _navigateToPayrollScreen(notification);
        break;

      case NotificationType.requestStatus:
        // Navigate to request details screen
        _navigateToRequestScreen(notification);
        break;
      case NotificationType.approval:
        // Navigate to approval screen
        _navigateToApprovalScreen(notification);
        break;
      case NotificationType.message:
        // Navigate to messages/chat screen
        _navigateToMessageScreen(notification);
        break;
      case NotificationType.attendance:
        _navigateToAttendanceScreen(notification);
        break;
      case NotificationType.general:
        _navigateToGeneralScreen(notification);
        break;
    }
  }

  void _navigateToPayrollScreen(AppNotification notification) {
    // Navigate to payroll screen with payroll_id from data - same as FCM
    final payrollId = notification.data?['payroll_id'];
    if (payrollId != null) {
      Get.to(() => PayrollScreen(payrollId: payrollId));
    } else {
      Get.to(() => const PayrollScreen());
    }
  }

  void _navigateToRequestScreen(AppNotification notification) {
    final requestId = notification.data?['request_id'];
    final requestType = notification.data?['request_type']?.toString();
    if (requestId != null) {
      final id = int.tryParse(requestId.toString());
      if (id != null) {
        Get.to(() => RequestDetailScreen(requestId: id, requestType: requestType));
        return;
      }
    }
    Get.to(() => const RequestHomeScreen());
  }

  void _navigateToApprovalScreen(AppNotification notification) {
    final requestIdRaw = notification.data?['request_id'];
    final requestId = requestIdRaw != null ? int.tryParse(requestIdRaw.toString()) : null;
    Get.to(() => ApprovalScreen(requestId: requestId));
  }

  void _navigateToMessageScreen(AppNotification notification) {
    final employeeId = notification.data?['employee_id'];
    if (employeeId != null) {
      final id = int.tryParse(employeeId.toString());
      if (id != null) {
        Get.to(() => EmployeeProfileScreen(employeeId: id));
        return;
      }
    }
    // Fallback: show notification info if no employee_id
    Get.snackbar(
      notification.title,
      notification.body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }

  void _navigateToAttendanceScreen(AppNotification notification) {
    Get.to(() => const AttendanceDetailScreen());
  }

  void _navigateToGeneralScreen(AppNotification notification) {
    // For general notifications, maybe show a detailed view or go to home
    final info = notification.data?['info'];
    if (info != null) {
      Get.snackbar(
        notification.title,
        notification.body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  List<NotificationType> get availableTypes => [
    NotificationType.general,
    ...notifications.map((n) => n.type).toSet().toList()
  ];
}