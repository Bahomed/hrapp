import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/data/remote/dio_client/dio_client.dart';
import 'package:injazat_hr_app/data/remote/network_url/network_url.dart';
import 'package:injazat_hr_app/data/remote/response/workspace_response.dart';
import 'package:injazat_hr_app/utils/exceptionhandler.dart';
import 'package:injazat_hr_app/utils/api_helper.dart';
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
        'http://injazatsoftware.net/api/companies', // URL
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