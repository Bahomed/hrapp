import 'dart:io';

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/employees_response.dart';
import 'package:dio/dio.dart';

import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

class EmployeesRepository {
  final Preferences preferences = Preferences();
  final dioClient = DioClient();

  Future<EmployeesResponse> getEmployees({int page = 1, String? search}) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$getEmployeesUrl';
      
      Map<String, dynamic> queryParams = {
        'page': page,
        'locale': getCurrentLanguage(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      var response = await dioClient
          .get(apiUrl, {'Authorization': 'Bearer $token'}, queryParams);
      
      return EmployeesResponse.fromJson(response.data);
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