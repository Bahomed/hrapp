import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/data/remote/response/app_notification_model.dart';
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/utils/app_theme.dart';
import 'package:co.injazathr.injazathr/view/payroll/payroll_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/request_home_screen.dart';
import 'package:co.injazathr.injazathr/view/notifications_screen/notification_screen.dart';

import '../view/approval/approval_screen.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final Preferences _preferences = Preferences();
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final RxList<AppNotification> _notifications = <AppNotification>[].obs;
  static List<AppNotification> get notifications => _notifications.value;
  static RxList<AppNotification> get notificationsObs => _notifications;

  static Future<void> initialize() async {
    // Initialize local notifications with click handler
    await _initializeLocalNotifications();
    
    // Initialize Firebase messaging handlers only for message taps
    await _initializeFirebaseMessaging();
    
    // Load saved notifications
    await _loadSavedNotifications();
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // Handle initial message when app is opened from terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessageTap(initialMessage);
    }
  }


  static Future<void> _handleBackgroundMessageTap(RemoteMessage message) async {
    // Debug logging removed

    final appNotification = _createAppNotificationFromFCM(message);
    await _navigateToNotificationScreen(appNotification);
  }

  static AppNotification _createAppNotificationFromFCM(RemoteMessage message) {
    final notificationType = NotificationType.values.firstWhere(
      (type) => type.name == (message.data['type'] ?? 'general'),
      orElse: () => NotificationType.general,
    );

    return AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? message.data['title'] ?? '',
      body: message.notification?.body ?? message.data['body'] ?? '',
      type: notificationType,
      data: message.data,
      timestamp: DateTime.now(),
      imageUrl: message.notification?.android?.imageUrl ?? message.data['image_url'],
      actionUrl: message.data['action_url'],
    );
  }





  static Future<void> _navigateToNotificationScreen(AppNotification notification) async {
    // Mark as read when opened
    await markAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.payroll:
        // Check if payroll_id is provided for direct detail navigation
        final payrollId = notification.data?['payroll_id'];
        if (payrollId != null) {
          Get.to(() => PayrollScreen(payrollId: payrollId));
        } else {
          Get.to(() => const PayrollScreen());
        }
        break;

      case NotificationType.requestStatus:
        // Navigate to requests screen - we can extend this later for specific request details
        Get.to(() => const RequestHomeScreen());
        break;
      case NotificationType.message:
        // For now navigate to notifications screen, can be extended for chat later
        Get.to(() => const NotificationScreen());
        break;
      case NotificationType.approval:
      // For now navigate to notifications screen, can be extended for chat later
        Get.to(() => const ApprovalScreen());
        break;
      case NotificationType.general:
      default:
        Get.to(() => const NotificationScreen());
        break;
    }
  }

  static Future<void> _addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    await _saveNotifications();
  }

  static Future<void> _saveNotifications() async {
    final notificationsJson = _notifications.map((n) => n.toJson()).toList();
    await _preferences.saveNotifications(notificationsJson);
  }

  static Future<void> _loadSavedNotifications() async {
    try {
      final savedNotifications = await _preferences.getNotifications();
      _notifications.clear();
      _notifications.addAll(savedNotifications.map((json) => AppNotification.fromJson(json)));
    } catch (e) {
      // Debug logging removed
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  static Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveNotifications();
  }

  static Future<void> clearNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  static Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
  }

  static List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  static int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  static int getUnreadCountByType(NotificationType type) {
    return _notifications.where((n) => n.type == type && !n.isRead).length;
  }

  // Method to handle foreground messages from FCMService
  static Future<void> handleForegroundMessage(RemoteMessage message) async {
    final appNotification = _createAppNotificationFromFCM(message);
    await _addNotification(appNotification);
    
    // Show local notification for foreground messages only
    await _createLocalNotification(message);
  }

  // Method to add background notifications from FCMService
  static Future<void> addBackgroundNotification(RemoteMessage message) async {
    final appNotification = _createAppNotificationFromFCM(message);
    await _addNotification(appNotification);
  }

  // Create local notification (similar to awesome_notifications pattern)
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'basic_channel',
      'Basic Notifications',
      description: 'This channel is used for basic notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    // Debug logging removed
    
    // Handle local notification tap by navigating based on payload
    if (response.payload != null) {
      try {
        // Parse the payload as JSON to extract both type and data
        final Map<String, dynamic> payloadData = jsonDecode(response.payload!);
        final String typeString = payloadData['type'] ?? 'general';
        final Map<String, dynamic>? data = payloadData['data'];
        
        
        final notificationType = NotificationType.values.firstWhere(
          (type) => type.name == typeString,
          orElse: () => NotificationType.general,
        );
        
        final dummyNotification = AppNotification(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          title: payloadData['title'] ?? '',
          body: payloadData['body'] ?? '',
          type: notificationType,
          data: data,
          timestamp: DateTime.now(),
        );
        
        _navigateToNotificationScreen(dummyNotification);
      } catch (e) {
        // Fallback to old method if JSON parsing fails
        final notificationType = NotificationType.values.firstWhere(
          (type) => type.name == response.payload,
          orElse: () => NotificationType.general,
        );
        
        final dummyNotification = AppNotification(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          title: '',
          body: '',
          type: notificationType,
          timestamp: DateTime.now(),
        );
        
        _navigateToNotificationScreen(dummyNotification);
      }
    }
  }

  // Create local notification (similar to awesome_notifications pattern)
  static Future<void> _createLocalNotification(RemoteMessage message) async {
    final String title = message.notification?.title ?? message.data['title'] ?? '';
    final String body = message.notification?.body ?? message.data['body'] ?? '';
    final String imageUrl = message.data['image'] ?? '';

    // Debug logging removed

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'basic_channel',
      'Basic Notifications',
      channelDescription: 'This channel is used for basic notifications.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      showWhen: true,
      autoCancel: true,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    try {
      // Create JSON payload containing both type and all FCM data
      final Map<String, dynamic> payloadJson = {
        'type': message.data['type'] ?? 'general',
        'title': title,
        'body': body,
        'data': message.data,
      };
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(payloadJson),
      );
      
      // Debug logging removed
    } catch (e) {
      // Debug logging removed
    }
  }
}