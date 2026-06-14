import 'base_response.dart';

class OvertimeRequest {
  final int id;
  final String requestNumber;
  final String fromDate;
  final String toDate;
  final double totalOtHours;
  final String reason;
  final String status;
  final String submittedDate;
  final String? approvedBy;
  final String? approvedDate;
  final String? rejectedReason;

  OvertimeRequest({
    required this.id,
    required this.requestNumber,
    required this.fromDate,
    required this.toDate,
    required this.totalOtHours,
    required this.reason,
    required this.status,
    required this.submittedDate,
    this.approvedBy,
    this.approvedDate,
    this.rejectedReason,
  });

  factory OvertimeRequest.fromJson(Map<String, dynamic> json) {
    return OvertimeRequest(
      id: json['id'] ?? 0,
      requestNumber: json['request_number'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      totalOtHours: double.tryParse(json['total_ot_hours']?.toString() ?? '0') ?? 0.0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      submittedDate: json['submitted_date'] ?? '',
      approvedBy: json['approved_by']?.toString(),
      approvedDate: json['approved_date'],
      rejectedReason: json['rejected_reason'],
    );
  }
}

class OvertimeRequestsResponse extends BaseResponse {
  final List<OvertimeRequest> data;

  OvertimeRequestsResponse({
    required super.success,
    required super.message,
    super.error,
    required this.data,
  });

  factory OvertimeRequestsResponse.fromJson(Map<String, dynamic> json) {
    return OvertimeRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => OvertimeRequest.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OvertimeRequestResponse extends BaseResponse {
  final OvertimeRequest? data;

  OvertimeRequestResponse({
    required super.success,
    required super.message,
    super.error,
    this.data,
  });

  factory OvertimeRequestResponse.fromJson(Map<String, dynamic> json) {
    return OvertimeRequestResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? OvertimeRequest.fromJson(json['data']) : null,
    );
  }
}
