import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/app_theme.dart';

class ThemeService extends GetxController {
  final _storage = GetStorage();
  static const String _themeKey = 'theme_mode';
  
  // Reactive theme mode
  final _themeMode = ThemeMode.light.obs;
  ThemeMode get themeMode => _themeMode.value;
  
  // Check if current theme is dark
  bool get isDarkMode {
    switch (_themeMode.value) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return false; // Fallback to light if somehow system is set
    }
  }
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }
  
  // Load theme from storage
  void _loadThemeFromStorage() {
    final savedTheme = _storage.read(_themeKey);
    if (savedTheme != null) {
      _themeMode.value = _getThemeModeFromString(savedTheme);
    }
  }
  
  // Save theme to storage
  void _saveThemeToStorage(ThemeMode mode) {
    _storage.write(_themeKey, mode.toString());
  }
  
  // Convert string to ThemeMode
  ThemeMode _getThemeModeFromString(String themeString) {
    switch (themeString) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.system':
        return ThemeMode.light; // Convert old system theme to light
      default:
        return ThemeMode.light;
    }
  }
  
  // Switch theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _saveThemeToStorage(mode);
    Get.changeThemeMode(mode);
  }
  
  // Toggle between light and dark theme
  void toggleTheme() {
    if (_themeMode.value == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
  
  // Set light theme
  void setLightTheme() {
    setThemeMode(ThemeMode.light);
  }
  
  // Set dark theme
  void setDarkTheme() {
    setThemeMode(ThemeMode.dark);
  }
  
  
  // Helper methods for accessing theme-aware colors
  Color getPrimaryColor() {
    return isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;
  }

  Color getSecondaryColor() {
    return isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.secondaryColor;
  }

  Color getBackgroundColor() {
    return isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor;
  }

  Color getSurfaceColor() {
    return isDarkMode ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor;
  }

  Color getTextPrimaryColor() {
    return isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
  }

  Color getTextSecondaryColor() {
    return isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
  }

  Color getCardColor() {
    return isDarkMode ? AppTheme.darkCardColor : AppTheme.surfaceColor;
  }

  Color getDividerColor() {
    return isDarkMode ? AppTheme.darkDividerColor : AppTheme.dividerColor;
  }

  Color getErrorColor() {
    return isDarkMode ? AppTheme.darkErrorColor : AppTheme.errorColor;
  }

  Color getSuccessColor() {
    return isDarkMode ? AppTheme.darkSuccessColor : AppTheme.successColor;
  }

  Color getWarningColor() {
    return isDarkMode ? AppTheme.darkWarningColor : AppTheme.warningColor;
  }

  Color getPageBackgroundColor() {
    return isDarkMode ? AppTheme.darkPageBackgroundColor : AppTheme.pageBackgroundColor;
  }

  // Status color helpers
  Color getStatusColor(String status) {
    return AppTheme.getStatusColor(status, isDark: isDarkMode);
  }

  Color getStatusBackgroundColor(String status) {
    return AppTheme.getStatusBackgroundColor(status, isDark: isDarkMode);
  }

  Color getActionColor(String action) {
    return AppTheme.getActionColor(action, isDark: isDarkMode);
  }

  Color getFilterColor(String filter) {
    return AppTheme.getFilterColor(filter, isDark: isDarkMode);
  }

  Color getDocumentColor(int index) {
    return AppTheme.getDocumentColor(index);
  }

  // Gradient helpers
  LinearGradient getMainGradient() {
    return AppTheme.getMainGradient(isDark: isDarkMode);
  }

  LinearGradient getAccentGradient() {
    return AppTheme.getAccentGradient(isDark: isDarkMode);
  }

  // CSS Root color helpers - Direct access to constants
  Color getVioletStart() {
    return AppTheme.violetStart;
  }

  Color getVioletEnd() {
    return AppTheme.violetEnd;
  }

  Color getJetBlack() {
    return AppTheme.jetBlack;
  }

  Color getMainDarkBlue() {
    return AppTheme.getMainDarkBlue();
  }

  Color getDarkBlack() {
    return isDarkMode ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor;
  }

  LinearGradient getVioletGradient() {
    return isDarkMode ? AppTheme.darkAccentGradient : AppTheme.primaryGradient;
  }

  Color getSilver() {
    return AppTheme.silver;
  }

  Color getGray800() {
    return AppTheme.gray800;
  }

  Color getGray600() {
    return AppTheme.gray600;
  }

  // Additional gradient and text color helpers
  LinearGradient getBlueGradient() {
    return const LinearGradient(
      colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  Color getGradientTextColor() {
    return Colors.white;
  }

  Color getContrastTextColor(Color backgroundColor) {
    // Simple contrast logic - return white for dark colors, dark for light colors
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  // Helper method to safely get ThemeService instance
  static ThemeService get instance {
    if (!Get.isRegistered<ThemeService>()) {
      Get.put(ThemeService());
    }
    return Get.find<ThemeService>();
  }
}