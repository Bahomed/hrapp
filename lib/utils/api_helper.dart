import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/language_service.dart';

class ApiHelper {
  static ApiHelper? _instance;
  ApiHelper._internal();
  
  static ApiHelper get instance {
    _instance ??= ApiHelper._internal();
    return _instance!;
  }

  /// Add locale parameter to query parameters
  Map<String, dynamic> addLocaleToQuery(Map<String, dynamic> query) {
    try {
      final languageService = Get.find<LanguageService>();
      query['locale'] = languageService.getLocaleCode();
    } catch (e) {
      // Fallback to English if language service is not initialized
      query['locale'] = 'en';
    }
    return query;
  }

  /// Add locale parameter to headers
  Map<String, dynamic> addLocaleToHeaders(Map<String, dynamic> headers) {
    try {
      final languageService = Get.find<LanguageService>();
      headers['Accept-Language'] = languageService.getLocaleCode();
    } catch (e) {
      // Fallback to English if language service is not initialized
      headers['Accept-Language'] = 'en';
    }
    return headers;
  }

  /// Add locale parameter to form data
  Map<String, dynamic> addLocaleToData(Map<String, dynamic> data) {
    try {
      final languageService = Get.find<LanguageService>();
      data['locale'] = languageService.getLocaleCode();
    } catch (e) {
      // Fallback to English if language service is not initialized
      data['locale'] = 'en';
    }
    return data;
  }

  /// Get current locale for API calls
  String getCurrentLocale() {
    try {
      final languageService = Get.find<LanguageService>();
      return languageService.getLocaleCode();
    } catch (e) {
      return 'en';
    }
  }
}