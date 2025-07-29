class ApprovalRequestResponse {
  final String status;
  final int statusCode;
  final String message;
  final List<ApprovalRequest> userRequests;
  final int userRequestsTotal;

  ApprovalRequestResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.userRequests,
    required this.userRequestsTotal,
  });

  factory ApprovalRequestResponse.fromJson(Map<String, dynamic> json) {
    return ApprovalRequestResponse(
      status: json['status'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      userRequests: (json['userRequests'] as List<dynamic>?)
          ?.map((e) => ApprovalRequest.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      userRequestsTotal: json['userRequestsTotal'] ?? 0,
    );
  }
}

class ApprovalRequest {
  final int id;
  final int employmentId;
  final String requestType;
  final String requestDateG;
  final String requestNumber;
  final String? leaveType;
  final String requestStatus;
  final String employeeNo;
  final String employeeName;
  final String? positionName;
  final String? nationality;
  final String? departmentName;
  final String? addBy;
  final String? requestBcs;

  ApprovalRequest({
    required this.id,
    required this.employmentId,
    required this.requestType,
    required this.requestDateG,
    required this.requestNumber,
    this.leaveType,
    required this.requestStatus,
    required this.employeeNo,
    required this.employeeName,
    this.positionName,
    this.nationality,
    this.departmentName,
    this.addBy,
    this.requestBcs,
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    return ApprovalRequest(
      id: json['id'] ?? 0,
      employmentId: json['employment_id'] ?? 0,
      requestType: json['request_type'] ?? '',
      requestDateG: json['request_date_g'] ?? '',
      requestNumber: json['request_number'] ?? '',
      leaveType: json['leave_type'],
      requestStatus: json['request_status'] ?? '',
      employeeNo: json['employee_no'] ?? '',
      employeeName: json['employee_name'] ?? '',
      positionName: json['position_name'],
      nationality: json['nationality'],
      departmentName: json['department_name'],
      addBy: json['add_by'],
      requestBcs: json['request_bcs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employment_id': employmentId,
      'request_type': requestType,
      'request_date_g': requestDateG,
      'request_number': requestNumber,
      'leave_type': leaveType,
      'request_status': requestStatus,
      'employee_no': employeeNo,
      'employee_name': employeeName,
      'position_name': positionName,
      'nationality': nationality,
      'department_name': departmentName,
      'add_by': addBy,
      'request_bcs': requestBcs,
    };
  }
}