import 'package:co.injazathr.injazathr/view/splash_screen/splash_screen.dart';
import 'package:co.injazathr.injazathr/utils/language_service.dart';
import 'package:co.injazathr.injazathr/utils/app_theme.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/services/fcm_service.dart';
import 'package:co.injazathr.injazathr/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      // Firebase already initialized, continue
      print('Firebase already initialized');
    } else {
      rethrow;
    }
  }
  
  // Initialize FCM
  await FCMService.initialize();
  
  // Initialize Notification Service
  await NotificationService.initialize();
  
  // Initialize services
  await initLanguageService();
  Get.put(ThemeService());
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      
      // Basic locale support without external dependencies
      locale: languageService.currentLocale.value,
      fallbackLocale: const Locale('en', 'US'),
      
      // Theme configuration with dark/light support
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      
      home: const SplashScreen(),
    ));
  }
}

