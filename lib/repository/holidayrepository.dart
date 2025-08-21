import 'dart:io';
import 'package:com.injazatsoftware.injazathr/data/remote/network_url/network_url.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/response/holiday_response.dart';
import 'package:com.injazatsoftware.injazathr/utils/translation_helper.dart';
import 'package:com.injazatsoftware.injazathr/utils/api_helper.dart';
import 'package:dio/dio.dart';

import '../data/local/preferences.dart';
import '../data/remote/dio_client/dio_client.dart';
import '../utils/exceptionhandler.dart';

class HolidayRepository{
  final DioClient dioClient = DioClient();
  final Preferences preferences = Preferences();
  
  Future<HolidayResponse> getAllNotice() async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$getallholidayurl';
      
      Map<String, dynamic> queryParams = {'locale': getCurrentLanguage()};
      queryParams = ApiHelper.instance.addLocaleToQuery(queryParams);
      
      var response = await dioClient.get(
        apiUrl, 
        {"Authorization": "Bearer $token"}, 
        queryParams
      );

      return HolidayResponse.fromJson(response.data);
    } on DioException catch (e) {
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