import 'base_response.dart';

class MissingPunchRequest {
  final int id;
  final int userId;
  final String requestNumber;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String? reason;
  final String status;
  final String submittedDate;
  final int? approvedBy;
  final String? approvedDate;
  final String? rejectedReason;

  MissingPunchRequest({
    required this.id,
    required this.userId,
    required this.requestNumber,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.reason,
    required this.status,
    required this.submittedDate,
    this.approvedBy,
    this.approvedDate,
    this.rejectedReason,
  });

  factory MissingPunchRequest.fromJson(Map<String, dynamic> json) {
    return MissingPunchRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      requestNumber: json['request_number']?.toString() ?? '',
      date: json['date'] ?? '',
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      reason: json['reason'],
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by'] != null ? int.tryParse(json['approved_by'].toString()) : null,
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
    );
  }
}

class MissingPunchRequestsResponse extends BaseResponse {
  final List<MissingPunchRequest> data;

  MissingPunchRequestsResponse({
    required super.success,
    required super.message,
    super.error,
    required this.data,
  });

  factory MissingPunchRequestsResponse.fromJson(Map<String, dynamic> json) {
    return MissingPunchRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => MissingPunchRequest.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class MissingPunchRequestResponse extends BaseResponse {
  final MissingPunchRequest? data;

  MissingPunchRequestResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory MissingPunchRequestResponse.fromJson(Map<String, dynamic> json) {
    return MissingPunchRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? MissingPunchRequest.fromJson(json['data']) : null,
    );
  }
}
