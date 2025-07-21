// File: lib/data/remote/response/leave_request_response.dart

import 'base_response.dart';

// ================ LEAVE REQUEST MODELS ================

class LeaveRequest {
  final int id;
  final int userId;
  final String startDate;
  final String endDate;
  final String leaveType;
  final String reason;
  final int days;
  final String status;
  final String submittedDate;
  final int? approvedBy;
  final String? approvedDate;
  final String? rejectedReason;
  final List<Attachment> attachments;
  final String createdAt;
  final String updatedAt;

  LeaveRequest({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
    required this.days,
    required this.status,
    required this.submittedDate,
    this.approvedBy,
    this.approvedDate,
    this.rejectedReason,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      leaveType: json['leave_type'] ?? '',
      reason: json['reason'] ?? '',
      days: json['days'] ?? 0,
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by'] != null ? int.tryParse(json['approved_by'].toString()) : null,
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => Attachment.fromJson(attachment))
              .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class LeaveRequestDetails extends LeaveRequest {
  final User? user;
  final User? approver;

  LeaveRequestDetails({
    required super.id,
    required super.userId,
    required super.startDate,
    required super.endDate,
    required super.leaveType,
    required super.reason,
    required super.days,
    required super.status,
    required super.submittedDate,
    super.approvedBy,
    super.approvedDate,
    super.rejectedReason,
    required super.attachments,
    required super.createdAt,
    required super.updatedAt,
    this.user,
    this.approver,
  });

  factory LeaveRequestDetails.fromJson(Map<String, dynamic> json) {
    return LeaveRequestDetails(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      leaveType: json['leave_type'] ?? '',
      reason: json['reason'] ?? '',
      days: json['days'] ?? 0,
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by'] != null ? int.tryParse(json['approved_by'].toString()) : null,
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => Attachment.fromJson(attachment))
              .toList() ??
          [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      approver: json['approver'] != null ? User.fromJson(json['approver']) : null,
    );
  }
}

class LeaveRequestsResponse extends BaseResponse {
  final List<LeaveRequest> data;

  LeaveRequestsResponse({
    required super.success,
    required super.message,
    super.error,
    required this.data,
  });

  factory LeaveRequestsResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => LeaveRequest.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class LeaveRequestResponse extends BaseResponse {
  final LeaveRequest? data;

  LeaveRequestResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? LeaveRequest.fromJson(json['data']) : null,
    );
  }
}

class LeaveRequestDetailsResponse extends BaseResponse {
  final LeaveRequestDetails? data;

  LeaveRequestDetailsResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory LeaveRequestDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? LeaveRequestDetails.fromJson(json['data']) : null,
    );
  }
}

class LeaveTypesResponse extends BaseResponse {
  final List<RequestTypeOption> data;

  LeaveTypesResponse({
    required bool success,
    required String message,
    required this.data,
  }) : super(success: success, message: message);

  factory LeaveTypesResponse.fromJson(Map<String, dynamic> json) {
    return LeaveTypesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? List<RequestTypeOption>.from(json['data'].map((x) => RequestTypeOption.fromJson(x)))
          : [],
    );
  }
}