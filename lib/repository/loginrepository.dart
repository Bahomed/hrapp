import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/login_response.dart' as login_response;
import 'package:co.injazathr.injazathr/data/remote/response/login_method_response.dart';
import 'package:co.injazathr.injazathr/utils/exceptionhandler.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:co.injazathr.injazathr/services/fcm_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class LoginRepository {
  final DioClient dioClient = DioClient();
  final Preferences preferences = Preferences();

  Future<void> saveLoginDetails(
    String token,
    login_response.Data? userData, {
    String? refreshToken,
    String? expiresAt,
  }) async {
    await preferences.saveToken(token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await preferences.saveRefreshToken(refreshToken);
    }
    if (expiresAt != null && expiresAt.isNotEmpty) {
      await preferences.saveTokenExpiresAt(expiresAt);
    }
    if (userData != null) {
      await preferences.saveUserData(userData);
    }
  }

  void clearWorkspaceData() {
    preferences.clearWorkspace();
  }

  /// Get company login method (email, iqama_no, mobile, email_or_iqama, email_or_mobile, all)
  Future<LoginMethodResponse?> getCompanyLoginMethod() async {
    try {
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final loginMethodUrl = '$workspaceUrl/api/company-login-method';

      var response = await dioClient.get(
        loginMethodUrl,
        {},
        {},
      );

      if (response.data != null) {
        return LoginMethodResponse.fromJson(response.data);
      } else {
        // Return default mobile if no data
        return LoginMethodResponse(
          error: false,
          loginMethod: 'mobile',
          message: 'Using default login method',
          code: 200,
        );
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        try {
          var errorResponse = LoginMethodResponse.fromJson(e.response!.data);
          return errorResponse;
        } catch (parseError) {
          // Return default on error
          return LoginMethodResponse(
            error: false,
            loginMethod: 'mobile',
            message: 'Using default login method',
            code: 200,
          );
        }
      } else {
        // Return default on error
        return LoginMethodResponse(
          error: false,
          loginMethod: 'mobile',
          message: 'Using default login method',
          code: 200,
        );
      }
    } catch (e) {
      // Return default on error
      return LoginMethodResponse(
        error: false,
        loginMethod: 'mobile',
        message: 'Using default login method',
        code: 200,
      );
    }
  }

  Future<bool> updateFCMToken() async {
    try {
      // Get workspace URL and construct update FCM URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final updateFcmUrl = '$workspaceUrl/api/update-fcm-token';

      // Get FCM token
      String? fcmToken = await FCMService.getFCMToken();
      
      if (fcmToken == null) {
        return false;
      }

      // Prepare data
      Map<String, dynamic> data = {
        'fcm_id': fcmToken
      };
      data = ApiHelper.instance.addLocaleToData(data);

      // Get authentication token
      String? authToken = await preferences.getToken();
      Map<String, String> headers = {};
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      var response = await dioClient.post(
          updateFcmUrl,
          data,
          headers,
          {}
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<login_response.LoginResponse?> loginApi(String loginValue, String password, String loginMethod) async {
    try {
      // Get workspace URL and construct login URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final loginUrl = '$workspaceUrl/api/login';

      // Get FCM token
      String? fcmToken = await FCMService.getFCMToken();

      // Prepare login data based on login method
      Map<String, dynamic> loginData = {
        'password': password
      };

      // Add the appropriate field based on login method
      switch (loginMethod) {
        case 'email':
          loginData['email'] = loginValue;
          break;
        case 'iqama_no':
          loginData['iqama_no'] = loginValue;
          break;
        case 'mobile':
          loginData['mobile_no'] = loginValue;
          break;
        case 'email_or_iqama':
          // Check if it's an email or iqama
          if (GetUtils.isEmail(loginValue)) {
            loginData['email'] = loginValue;
          } else {
            loginData['iqama_no'] = loginValue;
          }
          break;
        case 'email_or_mobile':
          // Check if it's an email or mobile
          if (GetUtils.isEmail(loginValue)) {
            loginData['email'] = loginValue;
          } else {
            loginData['mobile_no'] = loginValue;
          }
          break;
        case 'all':
          // Try to detect what type of input it is
          if (GetUtils.isEmail(loginValue)) {
            loginData['email'] = loginValue;
          } else if (loginValue.length >= 10 && RegExp(r'^[0-9]+$').hasMatch(loginValue)) {
            // If it's all numbers and >= 10 digits, treat as mobile/iqama
            // Backend will handle whether it's mobile or iqama
            loginData['mobile_no'] = loginValue;
            loginData['iqama_no'] = loginValue;
          } else {
            // Default to mobile_no for any other input
            loginData['mobile_no'] = loginValue;
          }
          break;
        default:
          loginData['mobile_no'] = loginValue;
      }
      // Add FCM token if available
      if (fcmToken != null) {
        loginData['fcm_id'] = fcmToken;
      }

      loginData = ApiHelper.instance.addLocaleToData(loginData);

      var response = await dioClient.post(
          loginUrl,
          loginData,
          {},
          {}
      );

      if (response.data != null) {
        return login_response.LoginResponse.fromJson(response.data);
      } else {
        throw Exception("No data received from server");
      }
    } on DioException catch (e) {
      // Handle HTTP errors and convert response to LoginResponse if possible
      if (e.response?.data != null) {
        try {
          // Try to parse error response as LoginResponse
          var errorResponse = login_response.LoginResponse.fromJson(e.response!.data);
          return errorResponse;
        } catch (parseError) {
          // If parsing fails, throw the original exception
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