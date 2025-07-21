// File: lib/data/remote/response/letter_request_response.dart

import 'base_response.dart';

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