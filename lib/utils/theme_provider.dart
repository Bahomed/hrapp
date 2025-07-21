import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app_theme.dart';

class ThemeProvider extends GetxController {
  static const String _themeKey = 'theme_mode';
  
  final _themeMode = ThemeMode.light.obs;
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode.value;
  
  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  void _loadTheme() {
    final savedTheme = _storage.read(_themeKey);
    
    if (savedTheme != null) {
      _themeMode.value = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.light,
      );
    }
  }

  void toggleTheme() {
    _themeMode.value = _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
    Get.changeThemeMode(_themeMode.value);
  }

  void setTheme(ThemeMode mode) {
    if (_themeMode.value != mode) {
      _themeMode.value = mode;
      _saveTheme();
      Get.changeThemeMode(_themeMode.value);
    }
  }

  void _saveTheme() {
    _storage.write(_themeKey, _themeMode.value.toString());
  }

  // Helper methods for accessing theme-aware colors
  Color getPrimaryColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;
  }

  Color getSecondaryColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.secondaryColor;
  }

  Color getBackgroundColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.backgroundColor;
  }

  Color getSurfaceColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor;
  }

  Color getTextPrimaryColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkTextPrimary : AppTheme.textPrimary;
  }

  Color getTextSecondaryColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkTextSecondary : AppTheme.textSecondary;
  }

  Color getCardColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkCardColor : AppTheme.surfaceColor;
  }

  Color getDividerColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkDividerColor : AppTheme.dividerColor;
  }

  Color getErrorColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkErrorColor : AppTheme.errorColor;
  }

  Color getSuccessColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkSuccessColor : AppTheme.successColor;
  }

  Color getWarningColor(BuildContext context) {
    return isDarkMode ? AppTheme.darkWarningColor : AppTheme.warningColor;
  }

  // Status color helpers
  Color getStatusColor(String status) {
    return AppTheme.getStatusColor(status);
  }

  Color getStatusBackgroundColor(String status) {
    return AppTheme.getStatusBackgroundColor(status, isDark: isDarkMode);
  }

  Color getActionColor(String action) {
    return AppTheme.getActionColor(action, isDark: isDarkMode);
  }

  Color getFilterColor(String filter) {
    return AppTheme.getFilterColor(filter);
  }

  Color getDocumentColor(int index) {
    return AppTheme.getDocumentColor(index);
  }
}