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
  final String? startDate;
  final String status;
  final String submittedDate;
  final int? approvedBy;
  final String? approvedDate;
  final String? rejectedReason;
  final String? executedDate;
  final String? executedAmount;
  final int? executedInstallments;
  final String? executedDeductionStartDate;
  final int? executedDeductionId;
  final List<Attachment> attachments;
  final String requestNumber;
  final String createdAt;
  final String updatedAt;

  LoanRequest({
    required this.id,
    required this.userId,
    required this.loanType,
    required this.purpose,
    required this.amount,
    required this.repaymentMonths,
    this.startDate,
    required this.status,
    required this.submittedDate,
    this.approvedBy,
    this.approvedDate,
    this.rejectedReason,
    this.executedDate,
    this.executedAmount,
    this.executedInstallments,
    this.executedDeductionStartDate,
    this.executedDeductionId,
    required this.attachments,
    required this.requestNumber,
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
      startDate: json['start_date'],
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by'] != null ? int.tryParse(json['approved_by'].toString()) : null,
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
      executedDate: json['executed_date'],
      executedAmount: json['executed_amount'],
      executedInstallments: json['executed_installments'] != null ? int.tryParse(json['executed_installments'].toString()) : null,
      executedDeductionStartDate: json['executed_deduction_start_date'],
      executedDeductionId: json['executed_deduction_id'] != null ? int.tryParse(json['executed_deduction_id'].toString()) : null,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => Attachment.fromJson(attachment))
              .toList() ??
          [],
      requestNumber: json['request_number'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class LoanSettlement {
  final String settleDate;
  final String loanAmount;
  final String amountPaid;
  final String status;
  final String settlementId;
  final dynamic amountToBePaid; // Can be int or double
  final String? remarks;

  LoanSettlement({
    required this.settleDate,
    required this.loanAmount,
    required this.amountPaid,
    required this.status,
    required this.settlementId,
    required this.amountToBePaid,
    this.remarks,
  });

  factory LoanSettlement.fromJson(Map<String, dynamic> json) {
    return LoanSettlement(
      settleDate: json['settle_date'] ?? '',
      loanAmount: json['loan_amount'] ?? '0.00',
      amountPaid: json['amount_paid'] ?? '0.00',
      status: json['status'] ?? '',
      settlementId: json['settlement_id']?.toString() ?? '',
      amountToBePaid: json['amount_to_be_paid'],
      remarks: json['remarks'],
    );
  }
}

class LoanRequestDetails extends LoanRequest {
  final User? user;
  final User? approver;
  final List<LoanSettlement>? settlements;

  LoanRequestDetails({
    required super.id,
    required super.userId,
    required super.loanType,
    required super.purpose,
    required super.amount,
    required super.repaymentMonths,
    super.startDate,
    required super.status,
    required super.submittedDate,
    super.approvedBy,
    super.approvedDate,
    super.rejectedReason,
    super.executedDate,
    super.executedAmount,
    super.executedInstallments,
    super.executedDeductionStartDate,
    super.executedDeductionId,
    required super.attachments,
    required super.requestNumber,
    required super.createdAt,
    required super.updatedAt,
    this.user,
    this.approver,
    this.settlements,
  });

  factory LoanRequestDetails.fromJson(Map<String, dynamic> json) {
    return LoanRequestDetails(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      loanType: json['loan_type'] ?? '',
      purpose: json['purpose'] ?? '',
      amount: json['amount'] ?? '0.00',
      repaymentMonths: json['repayment_months'] ?? 0,
      startDate: json['start_date'],
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by'] != null ? int.tryParse(json['approved_by'].toString()) : null,
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
      executedDate: json['executed_date'],
      executedAmount: json['executed_amount'],
      executedInstallments: json['executed_installments'] != null ? int.tryParse(json['executed_installments'].toString()) : null,
      executedDeductionStartDate: json['executed_deduction_start_date'],
      executedDeductionId: json['executed_deduction_id'] != null ? int.tryParse(json['executed_deduction_id'].toString()) : null,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => Attachment.fromJson(attachment))
              .toList() ??
          [],
      requestNumber: json['request_number'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      approver: json['approver'] != null ? User.fromJson(json['approver']) : null,
      settlements: (json['settlements'] as List<dynamic>?)
              ?.map((settlement) => LoanSettlement.fromJson(settlement))
              .toList(),
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

class LoanSettlementsResponse extends BaseResponse {
  final List<LoanSettlement> data;

  LoanSettlementsResponse({
    required super.success,
    required super.message,
    super.error,
    required this.data,
  });

  factory LoanSettlementsResponse.fromJson(Map<String, dynamic> json) {
    return LoanSettlementsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: (json['data'] as List<dynamic>?)
              ?.map((settlement) => LoanSettlement.fromJson(settlement))
              .toList() ??
          [],
    );
  }
}