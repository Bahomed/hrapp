import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/language_service.dart';

/// Global translation helper functions
/// These functions provide easy access to translations throughout the app

/// Get translated string by key
String tr(String key, {String? fallback}) {
  if (Get.isRegistered<LanguageService>()) {
    return LanguageService.instance.tr(key, fallback: fallback);
  }
  return fallback ?? key;
}

/// Get translated string with parameters
String trParams(String key, Map<String, String> params, {String? fallback}) {
  if (Get.isRegistered<LanguageService>()) {
    return LanguageService.instance.trParams(key, params);
  }
  String result = fallback ?? key;
  params.forEach((paramKey, value) {
    result = result.replaceAll('{$paramKey}', value);
  });
  return result;
}

/// Check if translation exists for key
bool hasTranslation(String key) {
  if (Get.isRegistered<LanguageService>()) {
    return LanguageService.instance.hasTranslation(key);
  }
  return false;
}

/// Get current language code
String getCurrentLanguage() {
  if (Get.isRegistered<LanguageService>()) {
    return LanguageService.instance.getLanguageCode();
  }
  return 'en';
}

/// Check if current language is RTL
bool isRTL() {
  if (Get.isRegistered<LanguageService>()) {
    return LanguageService.instance.isRTL();
  }
  return false;
}

/// Get language name for display
String getLanguageName(String code) {
  if (Get.isRegistered<LanguageService>()) {
    return LanguageService.instance.getLanguageName(code);
  }
  return code == 'ar' ? 'العربية' : 'English';
}

/// Get language flag emoji
String getLanguageFlag(String code) {
  if (Get.isRegistered<LanguageService>()) {
    return LanguageService.instance.getLanguageFlag(code);
  }
  return code == 'ar' ? '🇸🇦' : '🇺🇸';
}