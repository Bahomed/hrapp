import 'package:injazat_hr_app/view/splash_screen/splash_screen.dart';
import 'package:injazat_hr_app/utils/language_service.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import 'package:injazat_hr_app/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  
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

