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
    print('🔍 FCMTokenHelper: Starting...');
    
    try {
      // Wait a bit for FCM to be fully initialized
      print('⏳ Waiting for Firebase initialization...');
      await Future.delayed(const Duration(seconds: 2));
      
      // Check notification permissions first
      print('📋 Getting notification settings...');
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.getNotificationSettings();
      
      print('=== NOTIFICATION PERMISSION CHECK ===');
      print('Platform: ${Platform.isIOS ? "iOS" : "Android"}');
      print('Authorization Status: ${settings.authorizationStatus}');
      print('Alert Setting: ${settings.alert}');
      print('Badge Setting: ${settings.badge}');
      print('Sound Setting: ${settings.sound}');
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('❌ NOTIFICATIONS DENIED - Go to iOS Settings > App > Notifications');
      } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ NOTIFICATIONS AUTHORIZED');
      } else {
        print('⚠️ NOTIFICATIONS STATUS: ${settings.authorizationStatus}');
      }
      print('====================================');
      
      print('🎫 Getting FCM Token...');
      String? token = await FCMService.getFCMToken();
      if (token == null) {
        // Try again after a longer delay
        print('FCM token not ready, waiting...');
        await Future.delayed(const Duration(seconds: 3));
        token = await FCMService.getFCMToken();
      }
      
      print('=================================');
      print('FCM TOKEN FOR TESTING:');
      print(token ?? 'NULL TOKEN');
      print('=================================');
      if (token != null) {
        print('Copy this token and paste it in Firebase Console');
        print('for "Single device" testing');
        print('IMPORTANT: Test with app in BACKGROUND (minimized)');
        
        // Test local notification to verify notification system works
        print('🧪 Testing local notification in 3 seconds...');
        await Future.delayed(const Duration(seconds: 3));
        await _testLocalNotification();
        
        // Test FCM notification
        print('🚀 Sending test FCM notification in 5 seconds...');
        print('   Make sure to minimize the app to see background notification!');
        await Future.delayed(const Duration(seconds: 5));
        await _sendTestFCMNotification(token);
        
      } else {
        print('❌ Failed to get FCM token');
      }
      print('=================================');
      
    } catch (e, stackTrace) {
      print('❌ Error in FCMTokenHelper: $e');
      print('Stack trace: $stackTrace');
    }
    
    print('✅ FCMTokenHelper: Complete');
  }
  
  static Future<void> _testLocalNotification() async {
    try {
      print('📱 Sending test local notification...');
      
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
      
      print('✅ Test notification sent');
    } catch (e) {
      print('❌ Failed to send test notification: $e');
    }
  }
  
  static Future<void> _sendTestFCMNotification(String fcmToken) async {
    try {
      print('📡 Sending FCM notification using HTTP v1 API...');
      
      // Get access token using service account
      String? accessToken = await _getAccessToken();
      if (accessToken == null) {
        print('❌ Failed to get access token');
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
        print('✅ FCM notification sent successfully using HTTP v1 API!');
        print('Response: ${response.data}');
      } else {
        print('❌ Failed to send FCM notification');
        print('Status: ${response.statusCode}');
        print('Response: ${response.data}');
      }
      
    } catch (e) {
      print('❌ Error sending FCM notification: $e');
      if (e is DioException) {
        print('Dio Error: ${e.response?.data}');
      }
    }
  }

  static Future<String?> _getAccessToken() async {
    try {
      print('🔑 Getting access token from service account...');
      
      // Load service account credentials from environment variables
      const String serviceAccountJson = String.fromEnvironment(
        'FIREBASE_SERVICE_ACCOUNT_JSON',
        defaultValue: '{}',
      );
      
      if (serviceAccountJson == '{}') {
        print('❌ Firebase service account JSON not found in environment variables');
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
      
      print('✅ Access token obtained successfully');
      return accessToken;
      
    } catch (e) {
      print('❌ Failed to get access token: $e');
      return null;
    }
  }
}