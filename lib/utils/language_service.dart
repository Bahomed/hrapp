import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:injazat_hr_app/utils/translations/en.dart';
import 'package:injazat_hr_app/utils/translations/ar.dart';
import 'package:injazat_hr_app/repository/userrepositiory.dart';
import 'package:injazat_hr_app/view/home_screen/homescreen_controller.dart';

class LanguageService extends GetxController {
  static LanguageService get instance => Get.find<LanguageService>();
  
  final GetStorage _storage = GetStorage();
  final String _languageKey = 'app_language';
  final UserRepositiory _userRepository = UserRepositiory();
  
  // Current language observable
  var currentLanguage = 'en'.obs;
  var currentLocale = const Locale('en', 'US').obs;

  // Supported languages
  final Map<String, Locale> supportedLanguages = {
    'en': const Locale('en', 'US'),
    'ar': const Locale('ar', 'SA'),
  };

  // Translation maps
  final Map<String, Map<String, String>> _translations = {
    'en': enTranslations,
    'ar': arTranslations,
  };

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  /// Load saved language from storage
  void _loadSavedLanguage() {
    final savedLang = _storage.read(_languageKey) ?? 'en';
    currentLanguage.value = savedLang;
    currentLocale.value = supportedLanguages[savedLang] ?? const Locale('en', 'US');
  }

  /// Change language and save to storage
  Future<void> changeLanguage(String languageCode) async {
    if (supportedLanguages.containsKey(languageCode)) {
      try {
        // Call API to update user language preference
        var response = await _userRepository.updateUserLanguage(languageCode);
        
        // Only update locally if API call was successful
        if (response.status == true || response.statusCode == 200) {
          currentLanguage.value = languageCode;
          currentLocale.value = supportedLanguages[languageCode]!;
          
          // Save to storage
          await _storage.write(_languageKey, languageCode);
          
          // Update GetX locale
          Get.updateLocale(currentLocale.value);
          
          // Refresh home screen user data after successful language change
          try {
            final homeController = Get.find<HomeScreenController>();
            await homeController.refreshUserData();
          } catch (e) {
            // HomeScreenController not found, continue normally
            print('HomeScreenController not found: $e');
          }
          
          // Update text direction for Arabic
          if (languageCode == 'ar') {
            Get.forceAppUpdate();
          }
        } else {
          // API returned error, throw exception with message
          throw Exception(response.message);
        }
      } catch (e) {
        // If API call fails, still update locally as fallback
        print('Language API update failed: $e');
        
        currentLanguage.value = languageCode;
        currentLocale.value = supportedLanguages[languageCode]!;
        
        // Save to storage
        await _storage.write(_languageKey, languageCode);
        
        // Update GetX locale
        Get.updateLocale(currentLocale.value);
        
        // Even in fallback case, try to refresh user data to show updated language preference
        try {
          final homeController = Get.find<HomeScreenController>();
          await homeController.refreshUserData();
        } catch (e) {
          // HomeScreenController not found, continue normally
          print('HomeScreenController not found: $e');
        }
        
        // Update text direction for Arabic
        if (languageCode == 'ar') {
          Get.forceAppUpdate();
        }
      }
    }
  }


  /// Get current language code for API calls
  String getLanguageCode() {
    return currentLanguage.value;
  }

  /// Get current locale for API calls
  String getLocaleCode() {
    return currentLanguage.value;
  }

  /// Check if current language is RTL
  bool isRTL() {
    return currentLanguage.value == 'ar';
  }

  /// Get language name for display
  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  /// Get language flag emoji
  String getLanguageFlag(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'ar':
        return '🇸🇦';
      default:
        return '🇺🇸';
    }
  }

  /// Get translated string by key
  String translate(String key) {
    final currentTranslations = _translations[currentLanguage.value];
    return currentTranslations?[key] ?? key;
  }

  /// Get translated string with fallback
  String tr(String key, {String? fallback}) {
    final currentTranslations = _translations[currentLanguage.value];
    return currentTranslations?[key] ?? fallback ?? key;
  }

  /// Get translated string with parameters
  String trParams(String key, Map<String, String> params) {
    String translation = translate(key);
    params.forEach((key, value) {
      translation = translation.replaceAll('{$key}', value);
    });
    return translation;
  }

  /// Check if translation exists for key
  bool hasTranslation(String key) {
    final currentTranslations = _translations[currentLanguage.value];
    return currentTranslations?.containsKey(key) ?? false;
  }

  /// Get all available translation keys
  List<String> getAvailableKeys() {
    final currentTranslations = _translations[currentLanguage.value];
    return currentTranslations?.keys.toList() ?? [];
  }
}

/// Initialize language service
Future<void> initLanguageService() async {
  Get.put(LanguageService());
}