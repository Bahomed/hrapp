import 'dart:io';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/asset_response.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:dio/dio.dart';

import '../data/local/preferences.dart';
import '../data/remote/dio_client/dio_client.dart';
import '../utils/exceptionhandler.dart';

class AssetRepository {
  final DioClient dioClient = DioClient();
  final Preferences preferences = Preferences();

  Future<AssetListResponse> getMyAssets({
    int page = 1,
    String status = 'assigned',
    int perPage = 15,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$myAssetsUrl';

      Map<String, dynamic> queryParams = {
        'page': page,
        'status': status,
        'per_page': perPage,
      };
      queryParams = ApiHelper.instance.addLocaleToQuery(queryParams);

      final response = await dioClient.get(
        apiUrl,
        {"Authorization": "Bearer $token"},
        queryParams,
      );

      return AssetListResponse.fromJson(response.data);
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

  Future<AssetSummaryResponse> getMyAssetsSummary() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$myAssetsSummaryUrl';

      Map<String, dynamic> queryParams = {};
      queryParams = ApiHelper.instance.addLocaleToQuery(queryParams);

      final response = await dioClient.get(
        apiUrl,
        {"Authorization": "Bearer $token"},
        queryParams,
      );

      return AssetSummaryResponse.fromJson(response.data);
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

  Future<AssetDetailResponse> getMyAssetDetail(int id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$myAssetsUrl/$id';

      Map<String, dynamic> queryParams = {};
      queryParams = ApiHelper.instance.addLocaleToQuery(queryParams);

      final response = await dioClient.get(
        apiUrl,
        {"Authorization": "Bearer $token"},
        queryParams,
      );

      return AssetDetailResponse.fromJson(response.data);
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
