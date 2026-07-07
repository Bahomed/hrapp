
// Fixed RequestRepository with Workspace URL support (matching original DioClient signatures)
import 'dart:io';
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/base_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/leave_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/permission_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/loan_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/letter_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/request_summary_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/request_response.dart' show LoanTypesResponse, LetterTypesResponse;
import 'package:co.injazathr.injazathr/data/remote/response/approval_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/employee_dropdown_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/overtime_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/missing_punch_request_response.dart';
import 'package:co.injazathr.injazathr/repository/logoutrepository.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:dio/dio.dart';
import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

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
      
      Map<String, dynamic> queryParams = {'locale': getCurrentLanguage()};
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
    bool ticket = false,
    bool exitPermit = false,
    List<File>? attachments,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$leaveRequestsUrl';
      final headers = {'Authorization': 'Bearer $token'};

      if (attachments != null && attachments.isNotEmpty) {
        final files = await Future.wait(
          attachments.map((f) async => await MultipartFile.fromFile(
                f.path,
                filename: f.path.split('/').last,
              )),
        );
        final formData = FormData.fromMap({
          'start_date': startDate,
          'end_date': endDate,
          'leave_type': leaveTypeId,
          'reason': reason,
          'ticket': ticket ? 1 : 0,
          'exit_permit': exitPermit ? 1 : 0,
          'attachments[]': files,
        });
        final response = await dioClient.postForImageUpload(apiUrl, formData, headers);
        return LeaveRequestResponse.fromJson(response.data);
      } else {
        final data = {
          'start_date': startDate,
          'end_date': endDate,
          'leave_type': leaveTypeId,
          'reason': reason,
          'ticket': ticket,
          'exit_permit': exitPermit,
        };
        final response = await dioClient.post(apiUrl, data, {}, headers);
        return LeaveRequestResponse.fromJson(response.data);
      }
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
    bool ticket = false,
    bool exitPermit = false,
    List<File>? attachments,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$leaveRequestsUrl/$id';
      final headers = {'Authorization': 'Bearer $token'};

      if (attachments != null && attachments.isNotEmpty) {
        final files = await Future.wait(
          attachments.map((f) async => await MultipartFile.fromFile(
                f.path,
                filename: f.path.split('/').last,
              )),
        );
        final formData = FormData.fromMap({
          '_method': 'PUT',
          'start_date': startDate,
          'end_date': endDate,
          'leave_type': leaveType,
          'reason': reason,
          'ticket': ticket ? 1 : 0,
          'exit_permit': exitPermit ? 1 : 0,
          'attachments[]': files,
        });
        final response = await dioClient.postForImageUpload(apiUrl, formData, headers);
        return LeaveRequestResponse.fromJson(response.data);
      } else {
        final data = {
          'start_date': startDate,
          'end_date': endDate,
          'leave_type': leaveType,
          'reason': reason,
          'ticket': ticket,
          'exit_permit': exitPermit,
        };
        final response = await dioClient.put(apiUrl, headers, data);
        return LeaveRequestResponse.fromJson(response.data);
      }
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

        {'locale': getCurrentLanguage()},
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
      
      Map<String, dynamic> queryParams =
      {'locale': getCurrentLanguage()};
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
    required String date,
    required String fromTime,
    required String toTime,
    List<File>? attachments,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$permitRequestsUrl';
      final headers = {'Authorization': 'Bearer $token'};

      if (attachments != null && attachments.isNotEmpty) {
        final files = await Future.wait(
          attachments.map((f) async => await MultipartFile.fromFile(
                f.path,
                filename: f.path.split('/').last,
              )),
        );
        final formData = FormData.fromMap({
          'purpose': purpose,
          'date': date,
          'from_time': fromTime,
          'to_time': toTime,
          'attachments[]': files,
        });
        final response = await dioClient.postForImageUpload(apiUrl, formData, headers);
        return PermissionRequestResponse.fromJson(response.data);
      } else {
        final data = {
          'purpose': purpose,
          'date': date,
          'from_time': fromTime,
          'to_time': toTime,
        };
        final response = await dioClient.post(apiUrl, data, {}, headers);
        return PermissionRequestResponse.fromJson(response.data);
      }
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
    required String date,
    required String fromTime,
    required String toTime,
    List<File>? attachments,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$permitRequestsUrl/$id';
      final headers = {'Authorization': 'Bearer $token'};

      if (attachments != null && attachments.isNotEmpty) {
        final files = await Future.wait(
          attachments.map((f) async => await MultipartFile.fromFile(
                f.path,
                filename: f.path.split('/').last,
              )),
        );
        final formData = FormData.fromMap({
          '_method': 'PUT',
          'purpose': purpose,
          'date': date,
          'from_time': fromTime,
          'to_time': toTime,
          'attachments[]': files,
        });
        final response = await dioClient.postForImageUpload(apiUrl, formData, headers);
        return PermissionRequestResponse.fromJson(response.data);
      } else {
        final data = {
          'purpose': purpose,
          'date': date,
          'from_time': fromTime,
          'to_time': toTime,
        };
        final response = await dioClient.put(apiUrl, headers, data);
        return PermissionRequestResponse.fromJson(response.data);
      }
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

        {'locale': getCurrentLanguage()},
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
      
      Map<String, dynamic> queryParams =
      {'locale': getCurrentLanguage()};
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
    String? startDate,
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
      
      if (startDate != null) {
        data['start_date'] = startDate;
      }
      
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
    String? startDate,
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
      
      if (startDate != null) {
        data['start_date'] = startDate;
      }
      
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

  Future<LoanRequestResponse> getLoanRequestById(int id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$loanRequestDetailUrl/$id/show';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage()},
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

  Future<LoanRequestDetailsResponse> getLoanRequestDetails(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$loanRequestsUrl/$id';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},

        {'locale': getCurrentLanguage()},
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

  Future<LoanSettlementsResponse> getLoanSettlements(int id) async {
    try {
      final token = await preferences.getToken();
      // Get workspace URL and construct API URL
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$loanRequestsUrl/$id';

      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage()},
      );
      return LoanSettlementsResponse.fromJson(response.data);
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
      
      Map<String, dynamic> queryParams =
      {'locale': getCurrentLanguage()};
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

        {'locale': getCurrentLanguage()},
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

        {'locale': getCurrentLanguage()},
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

        {'locale': getCurrentLanguage()},
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

        {'locale': getCurrentLanguage()},
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

        {'locale': getCurrentLanguage()},
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

        {'locale': getCurrentLanguage()},
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

        {'locale': getCurrentLanguage()},
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

  // ================ APPROVAL METHODS ================

  Future<ApprovalRequestResponse> getDashboardEmployeeRequests() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/get-dashboard-employee-request';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage()},
      );
      return ApprovalRequestResponse.fromJson(response.data);
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

  Future<EmployeeDropdownResponse> getEmployeesDropdown() async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/get-employees-dropdown';
      
      var response = await dioClient.get(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'locale': getCurrentLanguage()},
      );
      return EmployeeDropdownResponse.fromJson(response.data);
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

  Future<BaseResponse> updateRequestStatus({
    required int requestId,
    required String status,
    int? stepId,
    int? replacementEmployeeId,
    String? remarks,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl/api/update-request-status';

      var data = <String, dynamic>{
        'request_id': requestId,
        'status': status,
      };

      if (stepId != null) {
        data['step_id'] = stepId;
      }
      if (replacementEmployeeId != null) {
        data['replacement_employee_id'] = replacementEmployeeId;
      }
      if (remarks != null && remarks.isNotEmpty) {
        data['remarks'] = remarks;
      }
      
      var response = await dioClient.post(
        apiUrl,
        data,
        {},
        {'Authorization': 'Bearer $token'},
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

  // ================ OVERTIME REQUEST METHODS ================

  Future<OvertimeRequestsResponse> getOvertimeRequests({String? status, int? year}) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$overtimeRequestsUrl';

      Map<String, dynamic> queryParams = {'locale': getCurrentLanguage()};
      if (status != null) queryParams['status'] = status;
      if (year != null) queryParams['year'] = year;

      var response = await dioClient.get(apiUrl, {'Authorization': 'Bearer $token'}, queryParams);
      return OvertimeRequestsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<OvertimeRequestResponse> createOvertimeRequest({
    required String fromDate,
    required String toDate,
    required double totalOtHours,
    required String reason,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$overtimeRequestsUrl';

      var response = await dioClient.post(
        apiUrl,
        {'from_date': fromDate, 'to_date': toDate, 'total_ot_hours': totalOtHours, 'reason': reason},
        {},
        {'Authorization': 'Bearer $token'},
      );
      return OvertimeRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<OvertimeRequestResponse> updateOvertimeRequest({
    required int id,
    required String fromDate,
    required String toDate,
    required double totalOtHours,
    required String reason,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$overtimeRequestsUrl/$id';

      var response = await dioClient.put(
        apiUrl,
        {'Authorization': 'Bearer $token'},
        {'from_date': fromDate, 'to_date': toDate, 'total_ot_hours': totalOtHours, 'reason': reason},
      );
      return OvertimeRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponse> deleteOvertimeRequest(int id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$overtimeRequestsUrl/$id';

      var response = await dioClient.delete(apiUrl, {'Authorization': 'Bearer $token'}, {});
      return BaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<OvertimeRequestResponse> getOvertimeRequestDetail(int id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$overtimeRequestsUrl/$id';

      var response = await dioClient.get(apiUrl, {'Authorization': 'Bearer $token'}, {'locale': getCurrentLanguage()});
      return OvertimeRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  // ================ MISSING PUNCH REQUEST METHODS ================

  Future<MissingPunchRequestsResponse> getMissingPunchRequests({int? year}) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$missingPunchRequestsUrl';
      final queryParams = <String, dynamic>{'locale': getCurrentLanguage()};
      if (year != null) queryParams['year'] = year;

      var response = await dioClient.get(apiUrl, {'Authorization': 'Bearer $token'}, queryParams);
      return MissingPunchRequestsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  String _convertTimeToHHmm(String time) {
    time = time.trim();
    if (time.contains('AM') || time.contains('PM')) {
      final isAM = time.toUpperCase().contains('AM');
      final timePart = time.replaceAll(RegExp(r'\s*(AM|PM)', caseSensitive: false), '').trim();
      final parts = timePart.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (!isAM && hour != 12) hour += 12;
        if (isAM && hour == 12) hour = 0;
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    }
    return time.length > 5 ? time.substring(0, 5) : time;
  }

  Future<MissingPunchRequestResponse> createMissingPunchRequest({
    required String date,
    String? checkIn,
    String? checkOut,
    String? reason,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$missingPunchRequestsUrl';
      final data = <String, dynamic>{'date': date};
      if (checkIn != null && checkIn.isNotEmpty) data['check_in'] = _convertTimeToHHmm(checkIn);
      if (checkOut != null && checkOut.isNotEmpty) data['check_out'] = _convertTimeToHHmm(checkOut);
      if (reason != null && reason.isNotEmpty) data['reason'] = reason;

      var response = await dioClient.post(apiUrl, data, {}, {'Authorization': 'Bearer $token'});
      return MissingPunchRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<MissingPunchRequestResponse> updateMissingPunchRequest({
    required int id,
    required String date,
    String? checkIn,
    String? checkOut,
    String? reason,
  }) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$missingPunchRequestsUrl/$id';
      final data = <String, dynamic>{'date': date};
      if (checkIn != null && checkIn.isNotEmpty) data['check_in'] = _convertTimeToHHmm(checkIn);
      if (checkOut != null && checkOut.isNotEmpty) data['check_out'] = _convertTimeToHHmm(checkOut);
      if (reason != null) data['reason'] = reason;

      var response = await dioClient.put(apiUrl, {'Authorization': 'Bearer $token'}, data);
      return MissingPunchRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponse> deleteMissingPunchRequest(int id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$missingPunchRequestsUrl/$id';

      var response = await dioClient.delete(apiUrl, {'Authorization': 'Bearer $token'}, {});
      return BaseResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<MissingPunchRequestResponse> getMissingPunchRequestDetails(int id) async {
    try {
      final token = await preferences.getToken();
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final apiUrl = '$workspaceUrl$missingPunchRequestsUrl/$id';

      var response = await dioClient.get(apiUrl, {'Authorization': 'Bearer $token'}, {'locale': getCurrentLanguage()});
      return MissingPunchRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    } catch (e) {
      rethrow;
    }
  }

}