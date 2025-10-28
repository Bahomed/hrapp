import 'dart:io';

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/getdasboard_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/unexecuted_requests_response.dart';
import 'package:co.injazathr.injazathr/repository/logoutrepository.dart';
import 'package:dio/dio.dart';

import '../utils/exceptionhandler.dart';

class DashboardRepository {
  final Preferences preferences = Preferences();
  final dioClient = DioClient();

  final lgoutRespository = LogoutRepository();

  Future<bool> getCheckPassword() async {
    return await preferences.getCheckPassword();
  }

  void saveCheckPassword(bool value) {
    preferences.saveCheckPassword(value);
  }
  void saveAppPassword(String value){
    preferences.saveAppPassword(value);
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

  void saveCompanyDetail(String companyName, String address, String image) {
    preferences.saveCompanyName(companyName);
    preferences.saveAddress(address);
    preferences.saveCompanyImage(image);
  }



  Future<String> getGreeting({String? locale, String? datetime}) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$getGreetingUrl';
      
      Map<String, dynamic> queryParams = {};
      
      if (locale != null) {
        queryParams['locale'] = locale;
      }
      
      if (datetime != null) {
        queryParams['datetime'] = datetime;
      }
      
      var response = await dioClient
          .get(apiUrl, {'Authorization': 'Bearer $token'}, queryParams);
      
      final greeting = response.data['greeting'] ?? 'Good morning';
      return greeting;
    }
    on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      return 'Good morning'; // Fallback greeting
    }
  }

  Future<UnexecutedRequestsResponse> getUnexecutedRequests({String? locale}) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$getUnexecutedRequestsUrl';

      Map<String, dynamic> queryParams = {};

      if (locale != null) {
        queryParams['locale'] = locale;
      }

      var response = await dioClient
          .get(apiUrl, {'Authorization': 'Bearer $token'}, queryParams);

      return UnexecutedRequestsResponse.fromJson(response.data);
    }
    on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      throw e.toString();
    }
  }
}
