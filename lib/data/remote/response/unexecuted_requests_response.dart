import 'dart:convert';

UnexecutedRequestsResponse unexecutedRequestsResponseFromJson(String str) => UnexecutedRequestsResponse.fromJson(json.decode(str));

String unexecutedRequestsResponseToJson(UnexecutedRequestsResponse data) => json.encode(data.toJson());

class UnexecutedRequestsResponse {
  final String status;
  final int statusCode;
  final String message;
  final List<UnexecutedRequest> unexecutedRequests;
  final int unexecutedRequestsTotal;

  UnexecutedRequestsResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.unexecutedRequests,
    required this.unexecutedRequestsTotal,
  });

  factory UnexecutedRequestsResponse.fromJson(Map<String, dynamic> json) {
    return UnexecutedRequestsResponse(
      status: json['status'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      unexecutedRequests: (json['unexecutedRequests'] as List<dynamic>?)
          ?.map((e) => UnexecutedRequest.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      unexecutedRequestsTotal: json['unexecutedRequestsTotal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "unexecutedRequests": unexecutedRequests.map((x) => x.toJson()).toList(),
    "unexecutedRequestsTotal": unexecutedRequestsTotal,
  };
}

class UnexecutedRequest {
  final int id;
  final int employmentId;
  final String requestType;
  final String requestDateG;
  final String actionDateG;
  final String requestNumber;
  final String requestBcs;
  final String leaveType;
  final String requestStatus;
  final String employeeNo;
  final String employeeName;
  final String positionName;
  final String nationality;
  final String departmentName;
  final String sectionName;
  final List<String> attachments;

  UnexecutedRequest({
    required this.id,
    required this.employmentId,
    required this.requestType,
    required this.requestDateG,
    required this.actionDateG,
    required this.requestNumber,
    required this.requestBcs,
    required this.leaveType,
    required this.requestStatus,
    required this.employeeNo,
    required this.employeeName,
    required this.positionName,
    required this.nationality,
    required this.departmentName,
    required this.sectionName,
    this.attachments = const [],
  });

  factory UnexecutedRequest.fromJson(Map<String, dynamic> json) {
    return UnexecutedRequest(
      id: json['id'] ?? 0,
      employmentId: json['employment_id'] ?? 0,
      requestType: json['request_type'] ?? '',
      requestDateG: json['request_date_g'] ?? '',
      actionDateG: json['action_date_g'] ?? '',
      requestNumber: json['request_number'] ?? '',
      requestBcs: json['request_bcs'] ?? '',
      leaveType: json['leave_type'] ?? '',
      requestStatus: json['request_status'] ?? '',
      employeeNo: json['employee_no'] ?? '',
      employeeName: json['employee_name'] ?? '',
      positionName: json['position_name'] ?? '',
      nationality: json['nationality'] ?? '',
      departmentName: json['department_name'] ?? '',
      sectionName: json['section_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "employment_id": employmentId,
    "request_type": requestType,
    "request_date_g": requestDateG,
    "action_date_g": actionDateG,
    "request_number": requestNumber,
    "request_bcs": requestBcs,
    "leave_type": leaveType,
    "request_status": requestStatus,
    "employee_no": employeeNo,
    "employee_name": employeeName,
    "position_name": positionName,
    "nationality": nationality,
    "department_name": departmentName,
    "section_name": sectionName,
  };
}