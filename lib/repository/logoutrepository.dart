import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/data/remote/dio_client/dio_client.dart';
import 'package:injazat_hr_app/data/remote/response/generalresponse.dart';
import 'package:injazat_hr_app/utils/exceptionhandler.dart';
import 'package:dio/dio.dart';

class LogoutRepository {
  final dioClient = DioClient();
  final Preferences preferences = Preferences();

 void clearToken(){
    preferences.clearToken();
  }

  Future<String> getCompanyName() async {
    return await preferences.getCompanyName();
  }

  Future<String> getAddress() async {
    return await preferences.getAddress();
  }

  Future<String> getCompanyImage() async {
    return await preferences.getCompanyImage();
  }

 Future<GeneralResponse?> logOutApi() async {
    var token = await preferences.getToken();
    try {
      // Get workspace URL and construct logout URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final logoutUrl = '$workspaceUrl/api/logout';
      
      var response = await dioClient.post(
          logoutUrl, {}, {}, {"Authorization": "Bearer $token"});
      
      // Handle null or empty response
      if (response.data == null) {
        return GeneralResponse(
          status: 1,
          statusCode: 200,
          message: "Logout successful",
        );
      }
      
      return GeneralResponse.fromJson(response.data);
    }
    on DioException catch (e) {
      throw exceptionHandler(e);
    }catch(e){
      rethrow;
    }
  }

}

