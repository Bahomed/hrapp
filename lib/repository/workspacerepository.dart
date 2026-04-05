import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/workspace_response.dart';
import 'package:co.injazathr.injazathr/utils/exceptionhandler.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:dio/dio.dart';

class WorkspaceRepository {
  final DioClient dioClient = DioClient();
  final Preferences preferences = Preferences();

  void saveWorkspaceDetails(String companyCode, String companyName, String companyUrl) {
    preferences.saveWorkspaceName(companyName);
    preferences.saveWorkspaceUrl(companyUrl);
  }

  Future<String> getSavedWorkspace() async {
    return preferences.getWorkspaceUrl();
  }

  Future<WorkspaceResponse?> checkWorkspaceApi(String companyCode) async {
    try {
      // Prepare query parameters with locale
      Map<String, dynamic> queryParams = {'company_code': companyCode};
      queryParams = ApiHelper.instance.addLocaleToQuery(queryParams);

      var response = await dioClient.get(
        '$baseurl/companies', // URL
        {}, // Headers (empty or custom headers)
        queryParams, // Query parameters with locale
      );

      return WorkspaceResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

}