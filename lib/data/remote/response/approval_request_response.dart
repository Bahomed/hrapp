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

class PrevApprover {
  final int level;
  final String name;

  PrevApprover({required this.level, required this.name});

  factory PrevApprover.fromJson(Map<String, dynamic> json) {
    return PrevApprover(
      level: json['level'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ApprovalRequest {
  final int id;
  final int employmentId;
  final String requestType;
  final String requestDateG;
  final String? startDateG;
  final String requestNumber;
  final String? leaveStartDate;
  final String? leaveEndDate;
  final String? reason;
  final String? loanAmount;
  final int? loanRepaymentMonths;
  final String? permitRemarks;
  final String? permitDate;
  final String? permitFrom;
  final String? permitTo;
  final String? leaveType;
  final String requestStatus;
  final String employeeNo;
  final String employeeName;
  final String? positionName;
  final String? nationality;
  final String? departmentName;
  final String? sectionName;
  final String? addBy;
  final String? requestBcs;
  final int? days;
  final int? stepId;
  final List<PrevApprover> prevApprovers;
  final String? fromDate;
  final String? toDate;
  final double? totalOtHours;

  ApprovalRequest({
    required this.id,
    required this.employmentId,
    required this.requestType,
    required this.requestDateG,
    this.startDateG,
    required this.requestNumber,
    this.leaveStartDate,
    this.leaveEndDate,
    this.reason,
    this.loanAmount,
    this.loanRepaymentMonths,
    this.permitRemarks,
    this.permitDate,
    this.permitFrom,
    this.permitTo,
    this.leaveType,
    required this.requestStatus,
    required this.employeeNo,
    required this.employeeName,
    this.positionName,
    this.nationality,
    this.departmentName,
    this.sectionName,
    this.addBy,
    this.requestBcs,
    this.days,
    this.stepId,
    this.prevApprovers = const [],
    this.fromDate,
    this.toDate,
    this.totalOtHours,
  });

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) {
    return ApprovalRequest(
      id: json['id'] ?? 0,
      employmentId: json['employment_id'] ?? 0,
      requestType: json['request_type'] ?? '',
      requestDateG: json['request_date_g'] ?? '',
      startDateG: json['start_date_g'],
      requestNumber: json['request_number'] ?? '',
      leaveStartDate: json['leave_start_date'],
      leaveEndDate: json['leave_end_date'],
      reason: json['reason'],
      loanAmount: json['loan_amount'],
      loanRepaymentMonths: json['loan_repayment_months'],
      permitRemarks: json['permit_remarks'],
      permitDate: json['permit_date'],
      permitFrom: json['permit_from'],
      permitTo: json['permit_to'],
      leaveType: json['leave_type'],
      requestStatus: json['request_status'] ?? '',
      employeeNo: json['employee_no'] ?? '',
      employeeName: json['employee_name'] ?? '',
      positionName: json['position_name'],
      nationality: json['nationality'],
      departmentName: json['department_name'],
      sectionName: json['section_name'],
      addBy: json['add_by'],
      requestBcs: json['request_bcs'],
      days: json['days'],
      stepId: json['step_id'],
      prevApprovers: (json['prev_approvers'] as List<dynamic>?)
              ?.map((e) => PrevApprover.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      fromDate: json['from_date'],
      toDate: json['to_date'],
      totalOtHours: double.tryParse(json['total_ot_hours']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employment_id': employmentId,
      'request_type': requestType,
      'request_date_g': requestDateG,
      'start_date_g': startDateG,
      'request_number': requestNumber,
      'leave_start_date': leaveStartDate,
      'leave_end_date': leaveEndDate,
      'reason': reason,
      'loan_amount': loanAmount,
      'loan_repayment_months': loanRepaymentMonths,
      'permit_remarks': permitRemarks,
      'permit_date': permitDate,
      'permit_from': permitFrom,
      'permit_to': permitTo,
      'leave_type': leaveType,
      'request_status': requestStatus,
      'employee_no': employeeNo,
      'employee_name': employeeName,
      'position_name': positionName,
      'nationality': nationality,
      'department_name': departmentName,
      'section_name': sectionName,
      'add_by': addBy,
      'request_bcs': requestBcs,
      'days': days,
      'step_id': stepId,
      'prev_approvers': prevApprovers.map((e) => {'level': e.level, 'name': e.name}).toList(),
    };
  }
}