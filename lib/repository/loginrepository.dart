import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/data/remote/dio_client/dio_client.dart';
import 'package:injazat_hr_app/data/remote/network_url/network_url.dart';
import 'package:injazat_hr_app/data/remote/response/login_response.dart' as login_response;
import 'package:injazat_hr_app/utils/exceptionhandler.dart';
import 'package:injazat_hr_app/utils/api_helper.dart';
import 'package:dio/dio.dart';

class LoginRepository {
  final DioClient dioClient = DioClient();
  final Preferences preferences = Preferences();

  void saveLoginDetails(String token, login_response.Data? userData) {
    preferences.saveToken(token);
    if (userData != null) {
      preferences.saveUserData(userData);
    }
  }

  void clearWorkspaceData() {
    preferences.clearWorkspace();
  }

  Future<login_response.LoginResponse?> loginApi(String email, String password) async {
    try {
      // Get workspace URL and construct login URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final loginUrl = '$workspaceUrl/api/login';

      // Prepare login data with dynamic locale
      Map<String, dynamic> loginData = {
        'mobile_no': email, 
        'password': password
      };
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