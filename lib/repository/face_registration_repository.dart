import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/response/face_id_response.dart';
import 'package:co.injazathr.injazathr/utils/exceptionhandler.dart';

class FaceRegistrationRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  Future<FaceIdResponse?> registerFaceApi({
    required String userId,
    required String name,
    required List<double> embeddings,
    required Uint8List faceImage,
  }) async {
    final token = await preferences.getToken();
    final workspaceUrl = await preferences.getWorkspaceUrl();
    final faceregisterurl = '$workspaceUrl/api/face/register';
    try {
      var response = await dioClient.post(
          faceregisterurl,
          {
            'user_id': userId,
            'name': name,
            'embeddings': embeddings,
            'face_image': base64Encode(faceImage)
          },
          {},
          {'Authorization': 'Bearer $token'});
      return FaceIdResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }
}