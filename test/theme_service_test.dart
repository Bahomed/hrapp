import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injazat_hr_app/services/theme_service.dart';

void main() {
  group('ThemeService Tests', () {
    late ThemeService themeService;

    setUpAll(() async {
      // Initialize GetStorage for testing
      await GetStorage.init();
    });

    setUp(() {
      // Clear any previous dependencies
      Get.reset();
      
      // Create theme service
      themeService = Get.put(ThemeService());
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize with light theme mode by default', () {
      expect(themeService.themeMode, ThemeMode.light);
    });

    test('should set light theme correctly', () {
      themeService.setLightTheme();
      expect(themeService.themeMode, ThemeMode.light);
    });

    test('should set dark theme correctly', () {
      themeService.setDarkTheme();
      expect(themeService.themeMode, ThemeMode.dark);
    });

    test('should toggle between light and dark themes', () {
      // Start with light theme
      themeService.setLightTheme();
      expect(themeService.themeMode, ThemeMode.light);
      
      // Toggle to dark
      themeService.toggleTheme();
      expect(themeService.themeMode, ThemeMode.dark);
      
      // Toggle back to light
      themeService.toggleTheme();
      expect(themeService.themeMode, ThemeMode.light);
    });

    test('should correctly identify dark mode status', () {
      // Test with light theme
      themeService.setLightTheme();
      expect(themeService.isDarkMode, false);
      
      // Test with dark theme
      themeService.setDarkTheme();
      expect(themeService.isDarkMode, true);
      
      // Note: System theme test would depend on platform brightness
      // which is not available in unit tests
    });

    test('should persist theme selection', () async {
      // Set dark theme
      themeService.setDarkTheme();
      expect(themeService.themeMode, ThemeMode.dark);
      
      // Create new instance to simulate app restart
      Get.reset();
      final newThemeService = Get.put(ThemeService());
      await Future.delayed(const Duration(milliseconds: 100)); // Allow initialization
      
      // Should remember dark theme
      expect(newThemeService.themeMode, ThemeMode.dark);
    });
  });
}