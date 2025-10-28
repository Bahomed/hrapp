import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:co.injazathr.injazathr/repository/loginrepository.dart';
import 'package:co.injazathr.injazathr/services/notification_service.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Only add to notification service for when app opens
  // Server already shows the notification automatically
  await FCMService._addToNotificationService(message);
}

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final LoginRepository _loginRepository = LoginRepository();
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Initialize local notifications
    await _initializeLocalNotifications();

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Debug logging removed

    // Check if permission was denied
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // Debug logging removed
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Debug logging removed
    }

    // Handle foreground messages - delegate to NotificationService
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Debug logging removed

      // Let NotificationService handle foreground messages
      NotificationService.handleForegroundMessage(message);
    });

    // Handle background message opening (when user taps notification)
    // Navigation is now handled by NotificationService

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      // Debug logging removed
      // Update the token on the server
      _loginRepository.updateFCMToken();
    });
  }

  static Future<String?> getFCMToken() async {
    try {
      // Debug logging removed

      // For iOS, ensure APNS token is available first
      if (Platform.isIOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          // Debug logging removed
          // Wait a bit and try again
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken == null) {
            // Debug logging removed
            // Try to get FCM token anyway
          }
        }
        if (kDebugMode && apnsToken != null) {
        }
      }

      String? token = await _firebaseMessaging.getToken();
      // Debug logging removed
      return token;
    } catch (e) {
      // Debug logging removed
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      // Debug logging removed
    } catch (e) {
      // Debug logging removed
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      // Debug logging removed
    } catch (e) {
      // Debug logging removed
    }
  }

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

    await _localNotifications.initialize(initializationSettings);

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

  static Future<void> _showLocalNotification(RemoteMessage message) async {
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

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? message.data['title'] ?? '',
      message.notification?.body ?? message.data['body'] ?? '',
      notificationDetails,
    );
  }

  static Future<void> _addToNotificationService(RemoteMessage message) async {
    try {
      await NotificationService.addBackgroundNotification(message);
    } catch (e) {
      // Debug logging removed
    }
  }
}