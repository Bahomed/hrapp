// File: lib/data/remote/response/loan_request_response.dart

import 'base_response.dart';

// ================ LOAN REQUEST MODELS ================

class LoanRequest {
  final int id;
  final int userId;
  final String loanType;
  final String purpose;
  final String amount;
  final int repaymentMonths;
  final String status;
  final String submittedDate;
  final int? approvedBy;
  final String? approvedDate;
  final String? rejectedReason;
  final List<Attachment> attachments;
  final String createdAt;
  final String updatedAt;

  LoanRequest({
    required this.id,
    required this.userId,
    required this.loanType,
    required this.purpose,
    required this.amount,
    required this.repaymentMonths,
    required this.status,
    required this.submittedDate,
    this.approvedBy,
    this.approvedDate,
    this.rejectedReason,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoanRequest.fromJson(Map<String, dynamic> json) {
    return LoanRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      loanType: json['loan_type'] ?? '',
      purpose: json['purpose'] ?? '',
      amount: json['amount'] ?? '0.00',
      repaymentMonths: json['repayment_months'] ?? 0,
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

class LoanRequestDetails extends LoanRequest {
  final User? user;
  final User? approver;

  LoanRequestDetails({
    required super.id,
    required super.userId,
    required super.loanType,
    required super.purpose,
    required super.amount,
    required super.repaymentMonths,
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

  factory LoanRequestDetails.fromJson(Map<String, dynamic> json) {
    return LoanRequestDetails(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      loanType: json['loan_type'] ?? '',
      purpose: json['purpose'] ?? '',
      amount: json['amount'] ?? '0.00',
      repaymentMonths: json['repayment_months'] ?? 0,
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

class LoanRequestsResponse extends BaseResponse {
  final List<LoanRequest> data;

  LoanRequestsResponse({
    required super.success,
    required super.message,
    super.error,
    required this.data,
  });

  factory LoanRequestsResponse.fromJson(Map<String, dynamic> json) {
    return LoanRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => LoanRequest.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class LoanRequestResponse extends BaseResponse {
  final LoanRequest? data;

  LoanRequestResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory LoanRequestResponse.fromJson(Map<String, dynamic> json) {
    return LoanRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? LoanRequest.fromJson(json['data']) : null,
    );
  }
}

class LoanRequestDetailsResponse extends BaseResponse {
  final LoanRequestDetails? data;

  LoanRequestDetailsResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory LoanRequestDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LoanRequestDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? LoanRequestDetails.fromJson(json['data']) : null,
    );
  }
}