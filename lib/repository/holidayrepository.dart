import 'package:injazat_hr_app/data/remote/network_url/network_url.dart';
import 'package:injazat_hr_app/data/remote/response/holiday_response.dart';
import 'package:dio/dio.dart';

import '../data/local/preferences.dart';
import '../data/remote/dio_client/dio_client.dart';
import '../utils/exceptionhandler.dart';

class HolidayRepository{
  final DioClient dioClient = DioClient();
  final Preferences preferences=Preferences();
  Future<HolidayResponse> getAllNotice() async {
    var token = await preferences.getToken();
    try {
      var response = await dioClient.get(getallholidayurl, {"Authorization": "Bearer $token"}, {});

      return HolidayResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }
}