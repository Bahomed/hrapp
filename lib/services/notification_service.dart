import 'dart:convert';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/data/remote/response/app_notification_model.dart';
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/view/payroll/payroll_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/request_home_screen.dart';
import 'package:co.injazathr.injazathr/view/notifications_screen/notification_screen.dart';

import '../view/approval/approval_screen.dart';
import '../view/request_detail/request_detail_screen.dart';
import '../view/attendance/attendance_detail_screen.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final Preferences _preferences = Preferences();
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final RxList<AppNotification> _notifications = <AppNotification>[].obs;
  static List<AppNotification> get notifications => _notifications.value;
  static RxList<AppNotification> get notificationsObs => _notifications;

  // Holds a tap that arrived before the navigator was ready
  static AppNotification? _pendingNavigation;

  static Future<void> initialize() async {
    // Initialize local notifications with click handler
    await _initializeLocalNotifications();

    // Initialize Firebase messaging handlers only for message taps
    await _initializeFirebaseMessaging();

    // Load saved notifications and restore badge
    await _loadSavedNotifications();
  }

  /// Call this after the user grants notification permission (iOS).
  /// Must be called to enable badge on iPhone.
  static Future<void> requestBadgePermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _initializeFirebaseMessaging() async {
    // Background tap (app was suspended): navigator is ready, navigate directly
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final notification = _createAppNotificationFromFCM(message);
      _storePending(notification);
      // Attempt immediate navigation; if the navigator isn't ready yet the
      // pending flag above ensures handlePendingNavigation() picks it up.
      _tryNavigate(notification);
    });

    // Terminated state tap: navigator does NOT exist yet — store for later
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      final notification = _createAppNotificationFromFCM(initialMessage);
      final exists = _notifications.any((n) => n.id == notification.id);
      if (!exists) await _addNotification(notification);
      _storePending(notification);
      // Do NOT call Get.to() here — no navigator exists yet
    }
  }

  static void _storePending(AppNotification notification) {
    _pendingNavigation = notification;
  }

  /// Call this from HomeScreenController.onInit() so terminated/background
  /// taps that arrived before the navigator was ready are handled.
  static Future<void> handlePendingNavigation() async {
    final pending = _pendingNavigation;
    print('[NAV] handlePendingNavigation pending=$pending');
    if (pending == null) return;
    _pendingNavigation = null;
    await _navigateToNotificationScreen(pending);
  }

  static Future<void> _tryNavigate(AppNotification notification) async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('[NAV] _tryNavigate context=${Get.context != null} type=${notification.type}');
    if (Get.context != null) {
      _pendingNavigation = null;
      await _navigateToNotificationScreen(notification);
    }
  }

  static AppNotification _createAppNotificationFromFCM(RemoteMessage message) {
    print('[FCM] messageId=${message.messageId} data=${message.data} notification=${message.notification?.title}');
    return AppNotification.fromJson({
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? message.data['title'] ?? '',
      'body': message.notification?.body ?? message.data['body'] ?? '',
      'type': message.data['type'] ?? 'general',
      'data': message.data,
      'timestamp': DateTime.now().toIso8601String(),
      'is_read': false,
      'image_url': message.notification?.android?.imageUrl ?? message.data['image_url'],
      'action_url': message.data['action_url'],
    });
  }





  static Future<void> _navigateToNotificationScreen(AppNotification notification) async {
    // Mark as read when opened
    await markAsRead(notification.id);

    print('[NAV] type=${notification.type} data=${notification.data}');

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
        final requestIdRaw = notification.data?['request_id'];
        final requestType = notification.data?['request_type']?.toString();
        if (requestIdRaw != null) {
          final id = int.tryParse(requestIdRaw.toString());
          if (id != null) {
            Get.to(() => RequestDetailScreen(requestId: id, requestType: requestType));
            break;
          }
        }
        Get.to(() => const RequestHomeScreen());
        break;
      case NotificationType.message:
        // For now navigate to notifications screen, can be extended for chat later
        Get.to(() => const NotificationScreen());
        break;
      case NotificationType.approval:
        final requestIdRaw = notification.data?['request_id'];
        final requestId = requestIdRaw != null ? int.tryParse(requestIdRaw.toString()) : null;
        Get.to(() => ApprovalScreen(requestId: requestId));
        break;
      case NotificationType.attendance:
        Get.to(() => const AttendanceDetailScreen());
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
    await _updateBadge();
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
      print('[Badge] loaded ${_notifications.length} notifications, unread=$unreadCount');
      await _updateBadge();
    } catch (e) {
      print('[Badge] load error: $e');
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      await _updateBadge();
    }
  }

  static Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveNotifications();
    await _updateBadge();
  }

  static Future<void> clearNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    await _updateBadge();
  }

  static Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    await _updateBadge();
  }

  static List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  static int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  static Future<void> _updateBadge() async {
    final count = unreadCount;
    print('[Badge] unreadCount=$count');
    try {
      final supported = await FlutterAppBadger.isAppBadgeSupported();
      print('[Badge] isSupported=$supported');
      if (count > 0) {
        await FlutterAppBadger.updateBadgeCount(count);
        print('[Badge] set to $count');
      } else {
        await FlutterAppBadger.removeBadge();
        print('[Badge] removed');
      }
    } catch (e) {
      print('[Badge] error: $e');
    }
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
    // ignore: unused_local_variable — will be used for rich notifications
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

    final DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: unreadCount,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
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
        DateTime.now().millisecondsSinceEpoch % 2147483647, // unique per ms, within int32 range
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