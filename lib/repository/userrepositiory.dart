import 'package:injazat_hr_app/data/remote/dio_client/dio_client.dart';
import 'package:injazat_hr_app/utils/exceptionhandler.dart';
import 'package:dio/dio.dart';
import '../data/local/preferences.dart';
import '../data/remote/response/login_response.dart' as login_response;
import '../utils/language_service.dart';

class UserRepositiory {
  final DioClient dioClient = DioClient();
  final Preferences preferences = Preferences();


<<<<<<< HEAD
  // Update user language preference and refresh all user data
  Future<login_response.LoginResponse> updateUserLanguage(String languageCode) async {
    final token = await preferences.getToken();
    final workspaceUrl = await preferences.getWorkspaceUrl();
    final getUserUrl = '$workspaceUrl/api/get-user-detail';
    
    try {
      // Fetch user data with new language locale
      var getUserResponse = await dioClient.post(
        getUserUrl,
=======
  // Update user language preference
  Future<login_response.LoginResponse> updateUserLanguage(String languageCode) async {
    final token = await preferences.getToken();
    final workspaceUrl = await preferences.getWorkspaceUrl();
    final apiUrl = '$workspaceUrl/api/get-user-detail';
    
    try {
      var response = await dioClient.post(
        apiUrl,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        {'locale': languageCode},
        {},
        {'Authorization': 'Bearer $token'}
      );
      
<<<<<<< HEAD
      if (getUserResponse.data != null) {
        var loginResponse = login_response.LoginResponse.fromJson(getUserResponse.data);
        
        // Save the complete updated user data including employee name, etc.
        if (loginResponse.data != null) {
          // Update the preferredLang field to match the requested language

          await preferences.saveUserData(loginResponse.data!);
        } else {
          // Fallback: Update only language in existing local data
          final currentUser = await preferences.getUserData();
          if (currentUser != null) {
            currentUser.preferredLang = languageCode;
            await preferences.saveUserData(currentUser);
          }
=======
      if (response.data != null) {
        var loginResponse = login_response.LoginResponse.fromJson(response.data);
        
        // Update preferences with new user data if available
        if (loginResponse.data != null) {
          await preferences.saveUserData(loginResponse.data!);
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        }
        
        return loginResponse;
      } else {
<<<<<<< HEAD
        throw Exception("No user data received from server");
      }
    } on DioException catch (e) {
      // If API fails, update local user data with new language
      final currentUser = await preferences.getUserData();
      if (currentUser != null) {
        currentUser.preferredLang = languageCode;
        await preferences.saveUserData(currentUser);
      }
      
      // Parse and return error response if possible
      if (e.response?.data != null) {
        try {
=======
        throw Exception("No data received from server");
      }
    } on DioException catch (e) {
      // Handle HTTP errors and convert response to LoginResponse if possible
      if (e.response?.data != null) {
        try {
          // Try to parse error response as LoginResponse
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          var errorResponse = login_response.LoginResponse.fromJson(e.response!.data);
          return errorResponse;
        } catch (parseError) {
          throw exceptionHandler(e);
        }
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
<<<<<<< HEAD
      // Final fallback: Update local user data
      final currentUser = await preferences.getUserData();
      if (currentUser != null) {
        currentUser.preferredLang = languageCode;
        await preferences.saveUserData(currentUser);
      }
=======
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
      rethrow;
    }
  }

  // Update user profile
  Future<login_response.LoginResponse> updateUserProfile({
    required String email,
    required String mobile,
    required String currentAddress,
    required String permanentAddress,
  }) async {
    final token = await preferences.getToken();
    final workspaceUrl = await preferences.getWorkspaceUrl();
    final apiUrl = '$workspaceUrl/api/update-profile';
    final currentLanguage = LanguageService.instance.getLanguageCode();
    
    try {
      var response = await dioClient.post(
        apiUrl,
        {
          'locale': currentLanguage,
          'email': email,
          'mobile': mobile,
          'current_address': currentAddress,
          'permanent_address': permanentAddress,
        },
        {},
        {'Authorization': 'Bearer $token'}
      );
      
      if (response.data != null) {
        // Transform the response to match LoginResponse format
        var transformedResponse = {
          'status': response.data['success'],
          'status_code': 200,
          'message': response.data['message'],
          'data': response.data['data']
        };
        
        var loginResponse = login_response.LoginResponse.fromJson(transformedResponse);
        
        // Update preferences with new user data if available
        if (loginResponse.data != null) {
          await preferences.saveUserData(loginResponse.data!);
        }
        
        return loginResponse;
      } else {
        throw Exception("No data received from server");
      }
    } on DioException catch (e) {
      // Handle HTTP errors and convert response to LoginResponse if possible
      if (e.response?.data != null) {
        try {
          // Transform error response to match LoginResponse format
          var transformedErrorResponse = {
            'status': e.response!.data['success'] ?? false,
            'status_code': e.response!.statusCode ?? 500,
            'message': e.response!.data['message'] ?? 'An error occurred',
            'data': e.response!.data['data']
          };
          
          var errorResponse = login_response.LoginResponse.fromJson(transformedErrorResponse);
          return errorResponse;
        } catch (parseError) {
          throw exceptionHandler(e);
        }
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }
}
