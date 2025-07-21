// ================ IMPORTS ================

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

// ================ PERMISSION REQUEST MODELS ================

class PermissionRequest {
  final int id;
  final int userId;
  final String title;
  final String purpose;
  final String permissionType;
  final String duration;
  final String status;
  final String submittedDate;
  final int? approvedBy;
  final String? approvedDate;
  final String? rejectedReason;
  final List<Attachment> attachments;
  final String createdAt;
  final String updatedAt;

  PermissionRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.purpose,
    required this.permissionType,
    required this.duration,
    required this.status,
    required this.submittedDate,
    this.approvedBy,
    this.approvedDate,
    this.rejectedReason,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PermissionRequest.fromJson(Map<String, dynamic> json) {
    return PermissionRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      purpose: json['purpose'] ?? '',
      permissionType: json['permission_type'] ?? '',
      duration: json['duration'] ?? '',
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

class PermissionRequestDetails extends PermissionRequest {
  final User? user;
  final User? approver;

  PermissionRequestDetails({
    required super.id,
    required super.userId,
    required super.title,
    required super.purpose,
    required super.permissionType,
    required super.duration,
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

  factory PermissionRequestDetails.fromJson(Map<String, dynamic> json) {
    return PermissionRequestDetails(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['title'] ?? '',
      purpose: json['purpose'] ?? '',
      permissionType: json['permission_type'] ?? '',
      duration: json['duration'] ?? '',
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

// ================ LETTER REQUEST MODELS ================

class LetterRequest {
  final int id;
  final int userId;
  final String reason;
  final String letterType;
  final String status;
  final String submittedDate;
  final int? approvedBy;
  final String? approvedDate;
  final String? rejectedReason;
  final List<Attachment> attachments;
  final String? generatedFilePath;
  final String createdAt;
  final String updatedAt;

  LetterRequest({
    required this.id,
    required this.userId,
    required this.reason,
    required this.letterType,
    required this.status,
    required this.submittedDate,
    this.approvedBy,
    this.approvedDate,
    this.rejectedReason,
    required this.attachments,
    this.generatedFilePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LetterRequest.fromJson(Map<String, dynamic> json) {
    return LetterRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      reason: json['reason'] ?? '',
      letterType: json['letter_type'] ?? '',
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by'] != null ? int.tryParse(json['approved_by'].toString()) : null,
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => Attachment.fromJson(attachment))
              .toList() ??
          [],
      generatedFilePath: json['generated_file_path'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class LetterRequestDetails extends LetterRequest {
  final User? user;
  final User? approver;

  LetterRequestDetails({
    required super.id,
    required super.userId,
    required super.reason,
    required super.letterType,
    required super.status,
    required super.submittedDate,
    super.approvedBy,
    super.approvedDate,
    super.rejectedReason,
    required super.attachments,
    super.generatedFilePath,
    required super.createdAt,
    required super.updatedAt,
    this.user,
    this.approver,
  });

  factory LetterRequestDetails.fromJson(Map<String, dynamic> json) {
    return LetterRequestDetails(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      reason: json['reason'] ?? '',
      letterType: json['letter_type'] ?? '',
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by'] != null ? int.tryParse(json['approved_by'].toString()) : null,
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => Attachment.fromJson(attachment))
              .toList() ??
          [],
      generatedFilePath: json['generated_file_path'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      approver: json['approver'] != null ? User.fromJson(json['approver']) : null,
    );
  }
}

class LetterRequestsResponse extends BaseResponse {
  final List<LetterRequest> data;

  LetterRequestsResponse({
    required super.success,
    required super.message,
    super.error,
    required this.data,
  });

  factory LetterRequestsResponse.fromJson(Map<String, dynamic> json) {
    return LetterRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => LetterRequest.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class LetterRequestResponse extends BaseResponse {
  final LetterRequest? data;

  LetterRequestResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory LetterRequestResponse.fromJson(Map<String, dynamic> json) {
    return LetterRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? LetterRequest.fromJson(json['data']) : null,
    );
  }
}

class LetterRequestDetailsResponse extends BaseResponse {
  final LetterRequestDetails? data;

  LetterRequestDetailsResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory LetterRequestDetailsResponse.fromJson(Map<String, dynamic> json) {
    return LetterRequestDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? LetterRequestDetails.fromJson(json['data']) : null,
    );
  }
}

// ================ LETTER DOWNLOAD MODEL ================

class LetterDownloadData {
  final String downloadUrl;
  final String filename;

  LetterDownloadData({
    required this.downloadUrl,
    required this.filename,
  });

  factory LetterDownloadData.fromJson(Map<String, dynamic> json) {
    return LetterDownloadData(
      downloadUrl: json['download_url'] ?? '',
      filename: json['filename'] ?? '',
    );
  }
}

class LetterDownloadResponse extends BaseResponse {
  final LetterDownloadData? data;

  LetterDownloadResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory LetterDownloadResponse.fromJson(Map<String, dynamic> json) {
    return LetterDownloadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? LetterDownloadData.fromJson(json['data']) : null,
    );
  }
}

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
  final String reason;
  final String letterType;

  LetterRequestSummary({
    required super.id,
    required super.status,
    required this.reason,
    required this.letterType,
  });

  factory LetterRequestSummary.fromJson(Map<String, dynamic> json) {
    return LetterRequestSummary(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
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

/////////////////


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

class LoanTypesResponse extends BaseResponse {
  final List<RequestTypeOption> data;

  LoanTypesResponse({
    required bool success,
    required String message,
    required this.data,
  }) : super(success: success, message: message);

  factory LoanTypesResponse.fromJson(Map<String, dynamic> json) {
    return LoanTypesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? List<RequestTypeOption>.from(json['data'].map((x) => RequestTypeOption.fromJson(x)))
          : [],
    );
  }
}

class PermitTypesResponse extends BaseResponse {
  final List<RequestTypeOption> data;

  PermitTypesResponse({
    required bool success,
    required String message,
    required this.data,
  }) : super(success: success, message: message);

  factory PermitTypesResponse.fromJson(Map<String, dynamic> json) {
    return PermitTypesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? List<RequestTypeOption>.from(json['data'].map((x) => RequestTypeOption.fromJson(x)))
          : [],
    );
  }
}

class LetterTypesResponse extends BaseResponse {
  final List<RequestTypeOption> data;

  LetterTypesResponse({
    required bool success,
    required String message,
    required this.data,
  }) : super(success: success, message: message);

  factory LetterTypesResponse.fromJson(Map<String, dynamic> json) {
    return LetterTypesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? List<RequestTypeOption>.from(json['data'].map((x) => RequestTypeOption.fromJson(x)))
          : [],
    );
  }
}
