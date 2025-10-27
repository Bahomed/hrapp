import 'dart:io';
import 'package:dio/dio.dart';
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/response/benefits_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/deductions_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/deduction_history_response.dart';
import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

class BenefitDeductionRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  // Get benefits
  Future<BenefitsResponse> getBenefits() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/get-benefits';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage()},
      );

      return BenefitsResponse.fromJson(response.data);
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

  // Get deductions
  Future<DeductionsResponse> getDeductions() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/get-deductions';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage()},
      );

      return DeductionsResponse.fromJson(response.data);
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

  // Get deduction history by ID
  Future<DeductionHistoryResponse> getDeductionHistory(int deductionId) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/get-deduction-history/$deductionId';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage()},
      );

      return DeductionHistoryResponse.fromJson(response.data);
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