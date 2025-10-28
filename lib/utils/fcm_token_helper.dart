import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:co.injazathr.injazathr/services/fcm_service.dart';

class FCMTokenHelper {
  static Future<void> printFCMToken() async {
    
    try {
      // Wait a bit for FCM to be fully initialized
      await Future.delayed(const Duration(seconds: 2));
      
      // Check notification permissions first
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.getNotificationSettings();
      
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
      } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      } else {
      }
      
      String? token = await FCMService.getFCMToken();
      if (token == null) {
        // Try again after a longer delay
        await Future.delayed(const Duration(seconds: 3));
        token = await FCMService.getFCMToken();
      }
      
      if (token != null) {
        
        // Test local notification to verify notification system works
        await Future.delayed(const Duration(seconds: 3));
        await _testLocalNotification();
        
        // Test FCM notification
        await Future.delayed(const Duration(seconds: 5));
        await _sendTestFCMNotification(token);
        
      } else {
      }
      
    } catch (e, stackTrace) {
    }
    
  }
  
  static Future<void> _testLocalNotification() async {
    try {
      
      final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
      
      const DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notification channel',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );
      
      await localNotifications.show(
        999,
        'Test Notification',
        'If you see this, local notifications work!',
        notificationDetails,
      );
      
    } catch (e) {
    }
  }
  
  static Future<void> _sendTestFCMNotification(String fcmToken) async {
    try {
      
      // Get access token using service account
      String? accessToken = await _getAccessToken();
      if (accessToken == null) {
        return;
      }
      
      final dio = Dio();
      const projectId = 'injazathr-defdb';
      
      final response = await dio.post(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
        data: {
          'message': {
            'token': fcmToken,
            'notification': {
              'title': 'Test Payroll Notification 🎉',
              'body': 'Testing payroll navigation with ID: 4391',
            },
            'data': {
              'type': 'payroll', // Test payroll navigation
              'payroll_id': '4391', // Specific payroll ID for testing
              'timestamp': DateTime.now().toIso8601String(),
              'test_data': 'navigation_test',
            },
            'android': {
              'priority': 'high',
            },
            'apns': {
              'payload': {
                'aps': {
                  'sound': 'default',
                  'content-available': 1,
                }
              }
            }
          }
        },
      );
      
      if (response.statusCode == 200) {
      } else {
      }
      
    } catch (e) {
      if (e is DioException) {
      }
    }
  }

  static Future<String?> _getAccessToken() async {
    try {
      
      // Load service account credentials from environment variables
      const String serviceAccountJson = String.fromEnvironment(
        'FIREBASE_SERVICE_ACCOUNT_JSON',
        defaultValue: '{}',
      );
      
      if (serviceAccountJson == '{}') {
        return null;
      }
      
      final Map<String, dynamic> serviceAccount = jsonDecode(serviceAccountJson);
      
      // Create service account credentials
      final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccount);
      
      // Define the required scopes for FCM
      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      
      // Get access token
      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = client.credentials.accessToken.data;
      
      client.close();
      
      return accessToken;
      
    } catch (e) {
      return null;
    }
  }
}