import 'package:com.injazatsoftware.injazathr/data/local/preferences.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/network_url/network_url.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/response/notice_response.dart';
import 'package:com.injazatsoftware.injazathr/utils/exceptionhandler.dart';
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
