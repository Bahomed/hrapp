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
  final String? executedDate;
  final List<Attachment> attachments;
  final String requestNumber;
  final String createdAt;
  final String updatedAt;
  final bool ticket;
  final bool exitPermit;
  final int? currentLevel;
  final String? pendingWith;

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
    this.executedDate,
    required this.attachments,
    required this.requestNumber,
    required this.createdAt,
    required this.updatedAt,
    this.ticket = false,
    this.exitPermit = false,
    this.currentLevel,
    this.pendingWith,
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
      executedDate: json['executed_date'],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => attachment is Map<String, dynamic>
                  ? Attachment.fromJson(attachment)
                  : Attachment(name: attachment.toString(), path: attachment.toString(), size: 0))
              .toList() ??
          [],
      requestNumber: json['request_number'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      ticket: json['ticket'] == true || json['ticket'] == 1 || json['ticket'] == '1',
      exitPermit: json['exit_permit'] == true || json['exit_permit'] == 1 || json['exit_permit'] == '1',
      currentLevel: json['current_level'] != null ? int.tryParse(json['current_level'].toString()) : null,
      pendingWith: json['pending_with'],
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
    super.executedDate,
    required super.attachments,
    required super.requestNumber,
    required super.createdAt,
    required super.updatedAt,
    super.currentLevel,
    super.pendingWith,
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
      executedDate: json['executed_date'],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => attachment is Map<String, dynamic>
                  ? Attachment.fromJson(attachment)
                  : Attachment(name: attachment.toString(), path: attachment.toString(), size: 0))
              .toList() ??
          [],
      requestNumber: json['request_number'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      currentLevel: json['current_level'] != null ? int.tryParse(json['current_level'].toString()) : null,
      pendingWith: json['pending_with'],
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