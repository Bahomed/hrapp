// File: lib/data/remote/response/permission_request_response.dart

import 'base_response.dart';

// ================ PERMISSION REQUEST MODELS ================

class PermissionRequest {
  final int id;
  final int userId;
  final String purpose;
  final String fromTime;
  final String toTime;
  final String status;
  final String submittedDate;
  final int? approvedBy;
  final String? approvedDate;
  final String? rejectedReason;
  final String createdAt;
  final String updatedAt;

  PermissionRequest({
    required this.id,
    required this.userId,
    required this.purpose,
    required this.fromTime,
    required this.toTime,
    required this.status,
    required this.submittedDate,
    this.approvedBy,
    this.approvedDate,
    this.rejectedReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PermissionRequest.fromJson(Map<String, dynamic> json) {
    return PermissionRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      purpose: json['purpose'] ?? '',
      fromTime: json['from_time'] ?? '',
      toTime: json['to_time'] ?? '',
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by'] != null ? int.tryParse(json['approved_by'].toString()) : null,
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class PermissionRequestDetails extends PermissionRequest {
  final User? user;
  final User? approver;

  PermissionRequestDetails({
    required super.id,
    required super.userId,
    required super.purpose,
    required super.fromTime,
    required super.toTime,
    required super.status,
    required super.submittedDate,
    super.approvedBy,
    super.approvedDate,
    super.rejectedReason,
    required super.createdAt,
    required super.updatedAt,
    this.user,
    this.approver,
  });

  factory PermissionRequestDetails.fromJson(Map<String, dynamic> json) {
    return PermissionRequestDetails(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      purpose: json['purpose'] ?? '',
      fromTime: json['from_time'] ?? '',
      toTime: json['to_time'] ?? '',
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by'] != null ? int.tryParse(json['approved_by'].toString()) : null,
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      approver: json['approver'] != null ? User.fromJson(json['approver']) : null,
    );
  }
}

class PermissionRequestsResponse extends BaseResponse {
  final List<PermissionRequest> data;

  PermissionRequestsResponse({
    required super.success,
    required super.message,
    super.error,
    required this.data,
  });

  factory PermissionRequestsResponse.fromJson(Map<String, dynamic> json) {
    return PermissionRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => PermissionRequest.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PermissionRequestResponse extends BaseResponse {
  final PermissionRequest? data;

  PermissionRequestResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory PermissionRequestResponse.fromJson(Map<String, dynamic> json) {
    return PermissionRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? PermissionRequest.fromJson(json['data']) : null,
    );
  }
}

class PermissionRequestDetailsResponse extends BaseResponse {
  final PermissionRequestDetails? data;

  PermissionRequestDetailsResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory PermissionRequestDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PermissionRequestDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? PermissionRequestDetails.fromJson(json['data']) : null,
    );
  }
}