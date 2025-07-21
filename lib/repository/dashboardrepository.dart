import 'dart:io';

import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/data/remote/dio_client/dio_client.dart';
import 'package:injazat_hr_app/data/remote/network_url/network_url.dart';
import 'package:injazat_hr_app/data/remote/response/getdasboard_response.dart';
import 'package:injazat_hr_app/repository/logoutrepository.dart';
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

  Future<GetDashboardResponse> dashBoardFromApi() async {
    try {
      final token = await preferences.getToken();
      var response = await dioClient
          .get(dashBoardUrl, {'Authorization': 'Bearer $token'}, {});
      return GetDashboardResponse.fromJson(response.data);
    }
    on DioException catch (e) {
      if (e.error is SocketException) {
        throw 'No Internet Connection';
      } else {
        throw exceptionHandler(e);
      }

    } catch (e) {
      rethrow;
    }
  }
}
