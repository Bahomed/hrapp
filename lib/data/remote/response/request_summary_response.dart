// File: lib/data/remote/response/request_summary_response.dart

import 'base_response.dart';

// ================ ALL REQUESTS MODELS ================

class AllRequestsSummary {
  final int id;
  final String status;

  AllRequestsSummary({
    required this.id,
    required this.status,
  });
}

class LeaveRequestSummary extends AllRequestsSummary {
  final String startDate;
  final String endDate;
  final String leaveType;
  final int days;

  LeaveRequestSummary({
    required super.id,
    required super.status,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.days,
  });

  factory LeaveRequestSummary.fromJson(Map<String, dynamic> json) {
    return LeaveRequestSummary(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      leaveType: json['leave_type'] ?? '',
      days: json['days'] ?? 0,
    );
  }
}

class PermissionRequestSummary extends AllRequestsSummary {
  final String title;
  final String permissionType;

  PermissionRequestSummary({
    required super.id,
    required super.status,
    required this.title,
    required this.permissionType,
  });

  factory PermissionRequestSummary.fromJson(Map<String, dynamic> json) {
    return PermissionRequestSummary(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      title: json['title'] ?? '',
      permissionType: json['permission_type'] ?? '',
    );
  }
}

class LoanRequestSummary extends AllRequestsSummary {
  final String loanType;
  final String amount;

  LoanRequestSummary({
    required super.id,
    required super.status,
    required this.loanType,
    required this.amount,
  });

  factory LoanRequestSummary.fromJson(Map<String, dynamic> json) {
    return LoanRequestSummary(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      loanType: json['loan_type'] ?? '',
      amount: json['amount'] ?? '0.00',
    );
  }
}

class LetterRequestSummary extends AllRequestsSummary {
  final String title;
  final String letterType;

  LetterRequestSummary({
    required super.id,
    required super.status,
    required this.title,
    required this.letterType,
  });

  factory LetterRequestSummary.fromJson(Map<String, dynamic> json) {
    return LetterRequestSummary(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      title: json['title'] ?? '',
      letterType: json['letter_type'] ?? '',
    );
  }
}

class AllRequestsData {
  final List<LeaveRequestSummary> leaveRequests;
  final List<PermissionRequestSummary> permissionRequests;
  final List<LoanRequestSummary> loanRequests;
  final List<LetterRequestSummary> letterRequests;

  AllRequestsData({
    required this.leaveRequests,
    required this.permissionRequests,
    required this.loanRequests,
    required this.letterRequests,
  });

  factory AllRequestsData.fromJson(Map<String, dynamic> json) {
    return AllRequestsData(
      leaveRequests: (json['leave_requests'] as List<dynamic>?)
              ?.map((item) => LeaveRequestSummary.fromJson(item))
              .toList() ??
          [],
      permissionRequests: (json['permission_requests'] as List<dynamic>?)
              ?.map((item) => PermissionRequestSummary.fromJson(item))
              .toList() ??
          [],
      loanRequests: (json['loan_requests'] as List<dynamic>?)
              ?.map((item) => LoanRequestSummary.fromJson(item))
              .toList() ??
          [],
      letterRequests: (json['letter_requests'] as List<dynamic>?)
              ?.map((item) => LetterRequestSummary.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class AllRequestsResponse extends BaseResponse {
  final AllRequestsData? data;

  AllRequestsResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory AllRequestsResponse.fromJson(Map<String, dynamic> json) {
    return AllRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? AllRequestsData.fromJson(json['data']) : null,
    );
  }
}

// ================ REQUEST TYPES MODEL ================

class RequestTypesData {
  final List<String> leaveTypes;
  final List<String> loanTypes;
  final List<String> letterTypes;

  RequestTypesData({
    required this.leaveTypes,
    required this.loanTypes,
    required this.letterTypes,
  });

  factory RequestTypesData.fromJson(Map<String, dynamic> json) {
    return RequestTypesData(
      leaveTypes: (json['leave_types'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      loanTypes: (json['loan_types'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      letterTypes: (json['letter_types'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }
}

class RequestTypesResponse extends BaseResponse {
  final RequestTypesData? data;

  RequestTypesResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory RequestTypesResponse.fromJson(Map<String, dynamic> json) {
    return RequestTypesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? RequestTypesData.fromJson(json['data']) : null,
    );
  }
}