import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/data/remote/dio_client/dio_client.dart';
import 'package:injazat_hr_app/data/remote/network_url/network_url.dart';
import 'package:injazat_hr_app/data/remote/response/notice_response.dart';
import 'package:injazat_hr_app/utils/exceptionhandler.dart';
import 'package:dio/dio.dart';

class NoticeRepository {
  final DioClient dioClient = DioClient();
final Preferences preferences=Preferences();
  Future<NoticeResponse> getAllNotice() async {
    var token = await preferences.getToken();

    try {
      var response = await dioClient.get(getallnoticeurl, {"Authorization": "Bearer $token"}, {});

      return NoticeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }
}
