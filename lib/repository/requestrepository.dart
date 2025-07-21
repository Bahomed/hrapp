
// Fixed RequestRepository with Workspace URL support (matching original DioClient signatures)
import 'dart:io';
import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/data/remote/dio_client/dio_client.dart';
import 'package:injazat_hr_app/data/remote/network_url/network_url.dart';
import 'package:injazat_hr_app/data/remote/response/base_response.dart';
import 'package:injazat_hr_app/data/remote/response/leave_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/permission_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/loan_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/letter_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/request_summary_response.dart';
import 'package:injazat_hr_app/data/remote/response/request_response.dart' show LoanTypesResponse, LetterTypesResponse;
import 'package:injazat_hr_app/repository/logoutrepository.dart';
import 'package:injazat_hr_app/utils/api_helper.dart';
import 'package:dio/dio.dart';
import '../utils/exceptionhandler.dart';

class RequestRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  // ================ LEAVE REQUEST METHODS ================

  Future<LeaveRequestsResponse> getLeaveRequests({String? status, int? year}) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$leaveRequestsUrl';
      
      Map<String, dynamic> queryParams = {};
      if (status != null && status != 'All') {
        queryParams['status'] = status;
      }
      if (year != null) {
        queryParams['year'] = year;
      }
      queryParams = ApiHelper.instance.addLocaleToQuery(queryParams);
      
      var response = await dioClient.get(
        apiUrl, 
        {'Authorization': 'Bearer $token'}, 
        queryParams
      );
      return LeaveRequestsResponse.fromJson(response.data);
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

  Future<LeaveRequestResponse> createLeaveRequest({
    required String startDate,
    required String endDate,
    required int leaveTypeId,
    required String reason,
  }) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$leaveRequestsUrl';
      
      var data = {
        'start_date': startDate,
        'end_date': endDate,
        'leave_type': leaveTypeId,
        'reason': reason,
      };
      
      var response = await dioClient.post(
        apiUrl,
        data,
        {},
        {'Authorization': 'Bearer $token'},
      );
      return LeaveRequestResponse.fromJson(response.data);
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

  Future<LeaveRequestResponse> updateLeaveRequest({
    required int id,
    required String startDate,
    required String endDate,
    required int leaveType,
    required String reason,
  }) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$leaveRequestsUrl/$id';
      
      var data = {
        'start_date': startDate,
        'end_date': endDate,
        'leave_type': leaveType,
        'reason': reason,
      };
      
      var response = await dioClient.put(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        data,
      );
      return LeaveRequestResponse.fromJson(response.data);
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

  Future<BaseResponse> deleteLeaveRequest(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$leaveRequestsUrl/$id';
      
      var response = await dioClient.delete(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return BaseResponse.fromJson(response.data);
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

  Future<LeaveRequestDetailsResponse> getLeaveRequestDetails(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$leaveRequestsUrl/$id';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return LeaveRequestDetailsResponse.fromJson(response.data);
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

  // ================ PERMIT REQUEST METHODS ================

  Future<PermissionRequestsResponse> getPermissionRequests({String? status, int? year}) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$permitRequestsUrl';
      
      Map<String, dynamic> queryParams = {};
      if (status != null && status != 'All') {
        queryParams['status'] = status;
      }
      if (year != null) {
        queryParams['year'] = year;
      }
      queryParams = ApiHelper.instance.addLocaleToQuery(queryParams);
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        queryParams,
      );
      return PermissionRequestsResponse.fromJson(response.data);
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

  Future<PermissionRequestResponse> createPermissionRequest({
    required String purpose,
    required String fromTime,
    required String toTime,
  }) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$permitRequestsUrl';
      
      var data = {
        'purpose': purpose,
        'from_time': fromTime,
        'to_time': toTime,
      };
      
      var response = await dioClient.post(
        apiUrl,
        data,
        {},
        {'Authorization': 'Bearer $token'},
      );
      return PermissionRequestResponse.fromJson(response.data);
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

  Future<PermissionRequestResponse> updatePermissionRequest({
    required int id,
    required String purpose,
    required String fromTime,
    required String toTime,
  }) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$permitRequestsUrl/$id';
      
      var data = {
        'purpose': purpose,
        'from_time': fromTime,
        'to_time': toTime,
      };
      
      var response = await dioClient.put(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        data,
      );
      return PermissionRequestResponse.fromJson(response.data);
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

  Future<BaseResponse> deletePermissionRequest(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$permitRequestsUrl/$id';
      
      var response = await dioClient.delete(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return BaseResponse.fromJson(response.data);
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

  Future<PermissionRequestDetailsResponse> getPermissionRequestDetails(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$permitRequestsUrl/$id';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return PermissionRequestDetailsResponse.fromJson(response.data);
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

  // ================ LOAN REQUEST METHODS ================

  Future<LoanRequestsResponse> getLoanRequests({String? status, int? year}) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$loanRequestsUrl';
      
      Map<String, dynamic> queryParams = {};
      if (status != null && status != 'All') {
        queryParams['status'] = status;
      }
      if (year != null) {
        queryParams['year'] = year;
      }
      queryParams = ApiHelper.instance.addLocaleToQuery(queryParams);
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        queryParams,
      );
      return LoanRequestsResponse.fromJson(response.data);
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

  Future<LoanRequestResponse> createLoanRequest({
    required int loanTypeId,
    required String purpose,
    required double amount,
    required int repaymentMonths,
  }) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$loanRequestsUrl';
      
      var data = {
        'loan_type': loanTypeId,
        'purpose': purpose,
        'amount': amount,
        'repayment_months': repaymentMonths,
      };
      
      var response = await dioClient.post(
        apiUrl,
        data,
        {},
        {'Authorization': 'Bearer $token'}
      );
      return LoanRequestResponse.fromJson(response.data);
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

  Future<LoanRequestResponse> updateLoanRequest({
    required int id,
    required int loanTypeId,
    required String purpose,
    required double amount,
    required int repaymentMonths,
  }) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$loanRequestsUrl/$id';
      
      var data = {
        'loan_type': loanTypeId,
        'purpose': purpose,
        'amount': amount,
        'repayment_months': repaymentMonths,
      };
      
      var response = await dioClient.put(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        data,
      );
      return LoanRequestResponse.fromJson(response.data);
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

  Future<BaseResponse> deleteLoanRequest(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$loanRequestsUrl/$id';
      
      var response = await dioClient.delete(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return BaseResponse.fromJson(response.data);
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

  Future<LoanRequestDetailsResponse> getLoanRequestDetails(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$loanRequestsUrl/$id';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return LoanRequestDetailsResponse.fromJson(response.data);
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

  // ================ LETTER REQUEST METHODS ================

  Future<LetterRequestsResponse> getLetterRequests({String? status, int? year}) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$letterRequestsUrl';
      
      Map<String, dynamic> queryParams = {};
      if (status != null && status != 'All') {
        queryParams['status'] = status;
      }
      if (year != null) {
        queryParams['year'] = year;
      }
      queryParams = ApiHelper.instance.addLocaleToQuery(queryParams);
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        queryParams,
      );
      return LetterRequestsResponse.fromJson(response.data);
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

  Future<LetterRequestResponse> createLetterRequest({
    required String reason,
    required int letterTypeId,
  }) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$letterRequestsUrl';
      
      var data = {
        'reason': reason,
        'letter_type': letterTypeId,
      };
      
      var response = await dioClient.post(
        apiUrl,
        data,
        {},
        {'Authorization': 'Bearer $token'},
      );
      return LetterRequestResponse.fromJson(response.data);
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

  Future<LetterRequestResponse> updateLetterRequest({
    required int id,
    required String reason,
    required int letterTypeId,
  }) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$letterRequestsUrl/$id';
      
      var data = {
        'reason': reason,
        'letter_type': letterTypeId,
      };
      
      var response = await dioClient.put(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        data,
      );
      return LetterRequestResponse.fromJson(response.data);
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

  Future<BaseResponse> deleteLetterRequest(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$letterRequestsUrl/$id';
      
      var response = await dioClient.delete(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return BaseResponse.fromJson(response.data);
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

  Future<LetterRequestDetailsResponse> getLetterRequestDetails(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$letterRequestsUrl/$id';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return LetterRequestDetailsResponse.fromJson(response.data);
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

  Future<LetterDownloadResponse> downloadLetter(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$letterRequestsUrl/$id/download';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return LetterDownloadResponse.fromJson(response.data);
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

  // ================ GENERAL METHODS ================

  Future<AllRequestsResponse> getAllRequests() async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$allRequestsUrl';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return AllRequestsResponse.fromJson(response.data);
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

  Future<RequestTypesResponse> getRequestTypes() async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$requestTypesUrl';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return RequestTypesResponse.fromJson(response.data);
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

  Future<LeaveTypesResponse> getLeaveTypes() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/requests/leave_types/types';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return LeaveTypesResponse.fromJson(response.data);
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

  Future<LoanTypesResponse> getLoanTypes() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/requests/loan_types/types';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return LoanTypesResponse.fromJson(response.data);
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

  Future<LetterTypesResponse> getLetterTypes() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/requests/letter_types/types';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {},
      );
      return LetterTypesResponse.fromJson(response.data);
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