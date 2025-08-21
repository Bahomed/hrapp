import 'package:get/get.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/response/app_notification_model.dart';
import 'package:com.injazatsoftware.injazathr/repository/notification_repository.dart';
import 'package:com.injazatsoftware.injazathr/view/payroll/payroll_screen.dart';
import 'package:flutter/material.dart';

import '../approval/approval_screen.dart';
import '../request_leave/request_home_screen.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();
  
  var notifications = <AppNotification>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  var filteredNotifications = <AppNotification>[].obs;
  var selectedFilter = Rxn<NotificationType>();
  var showOnlyUnread = false.obs;

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
      
      final data = await _repository.getNotifications();
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

  void applyFilters() {
    var filtered = notifications.where((notification) {
      bool typeMatch = true;
      bool readMatch = true;
      
      // If a specific type is selected, filter by that type
      // If null (All), show all types
      if (selectedFilter.value != null) {
        typeMatch = notification.type == selectedFilter.value;
      }
      
      if (showOnlyUnread.value) {
        readMatch = !notification.isRead;
      }
      
      return typeMatch && readMatch;
    }).toList();
    
    filteredNotifications.value = filtered;
  }

  void filterByType(NotificationType? type) {
    selectedFilter.value = type;
    applyFilters();
  }

  void toggleUnreadFilter() {
    showOnlyUnread.value = !showOnlyUnread.value;
    applyFilters();
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _repository.markNotificationAsRead(notificationId);
      if (success) {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          applyFilters();
        }
      }
    } catch (error) {
      Get.snackbar(
        'Error',
        'Failed to mark notification as read',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
      case NotificationType.general:
        // Handle general notifications - maybe show details or home screen
        _navigateToGeneralScreen(notification);
        break;
    }
  }

  void _navigateToPayrollScreen(AppNotification notification) {
    // Navigate to payroll screen with payroll_id from data - same as FCM
    final payrollId = notification.data?['payroll_id'];
    print('NotificationController: Navigating to payroll with ID: $payrollId');
    if (payrollId != null) {
      print('NotificationController: Opening PayrollScreen with payrollId: $payrollId');
      Get.to(() => PayrollScreen(payrollId: payrollId));
    } else {
      print('NotificationController: Opening PayrollScreen without specific ID');
      Get.to(() => const PayrollScreen());
    }
  }

  void _navigateToRequestScreen(AppNotification notification) {
    // Navigate to request details with request_id
    final requestId = notification.data?['request_id'];
    // print('NotificationController: Navigating to request with ID: $requestId');
    // if (requestId != null) {
    //   // Navigate to specific request details - you may need to import the screen
    //   print('NotificationController: Opening request details for ID: $requestId');
    //   // Get.to(() => RequestDetailsScreen(requestId: requestId));
    // } else {
    //   // Navigate to general requests screen
      print('NotificationController: Opening general requests screen');
     Get.to(() => const RequestHomeScreen());
    //}
  }

  void _navigateToApprovalScreen(AppNotification notification) {
    // Navigate to approval screen - same pattern as other screens
    print('NotificationController: Opening ApprovalScreen');
     Get.to(() => const ApprovalScreen());
  }

  void _navigateToMessageScreen(AppNotification notification) {
    // Navigate to message/chat screen with message details
    final messageId = notification.data?['message_id'];
    final senderId = notification.data?['sender_id'];
    print('NotificationController: Opening messages with messageId: $messageId, senderId: $senderId');
    // Get.to(() => MessagesScreen(messageId: messageId, senderId: senderId));
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

  int get unreadCount => notifications.where((n) => !n.isRead).length;
  
  List<NotificationType> get availableTypes => [
    NotificationType.general,
    ...notifications.map((n) => n.type).toSet().toList()
  ];
}