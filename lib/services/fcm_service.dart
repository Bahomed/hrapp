import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:com.injazatsoftware.injazathr/repository/loginrepository.dart';
import 'package:com.injazatsoftware.injazathr/services/notification_service.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
    print('Message data: ${message.data}');
    print('Message notification: ${message.notification?.title}');
  }

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

    if (kDebugMode) {
      print('=== NOTIFICATION PERMISSION STATUS ===');
      print('Authorization Status: ${settings.authorizationStatus}');
      print('Alert Setting: ${settings.alert}');
      print('Badge Setting: ${settings.badge}');
      print('Sound Setting: ${settings.sound}');
      print('=====================================');
    }

    // Check if permission was denied
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) {
        print('❌ NOTIFICATION PERMISSION DENIED - Notifications will not work!');
        print('Please enable notifications in iOS Settings > [App Name] > Notifications');
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('✅ NOTIFICATION PERMISSION GRANTED - Notifications should work');
      }
    }

    // Handle foreground messages - delegate to NotificationService
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('🔥 FOREGROUND MESSAGE RECEIVED!');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
        print('Message ID: ${message.messageId}');
      }

      // Let NotificationService handle foreground messages
      NotificationService.handleForegroundMessage(message);
    });

    // Handle background message opening (when user taps notification)
    // Navigation is now handled by NotificationService

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      if (kDebugMode) {
        print('FCM Token refreshed: $token');
      }
      // Update the token on the server
      _loginRepository.updateFCMToken();
    });
  }

  static Future<String?> getFCMToken() async {
    try {
      if (kDebugMode) {
        print('Getting FCM token...');
      }

      // For iOS, ensure APNS token is available first
      if (Platform.isIOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          if (kDebugMode) {
            print('APNS token not available yet, waiting...');
          }
          // Wait a bit and try again
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken == null) {
            if (kDebugMode) {
              print('APNS token still not available');
            }
            // Try to get FCM token anyway
          }
        }
        if (kDebugMode && apnsToken != null) {
          print('APNS Token: ${apnsToken.substring(0, 20)}...');
        }
      }

      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print('FCM Token obtained: $token');
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM token: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) {
        print('Subscribed to topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error subscribing to topic: $e');
      }
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) {
        print('Unsubscribed from topic: $topic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error unsubscribing from topic: $e');
      }
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
      if (kDebugMode) {
        print('Error adding background notification to service: $e');
      }
    }
  }
}