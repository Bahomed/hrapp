// File: lib/models/request_models.dart

enum RequestStatus { approved, rejected, pending }

class LeaveRequest {
  final String id;
  final String startDate;
  final String endDate;
  final String reason;
  final String leaveType;
  final int days;
  final RequestStatus status;
  final String submittedDate;

  LeaveRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.leaveType,
    required this.days,
    required this.status,
    required this.submittedDate,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'leaveType': leaveType,
      'days': days,
      'status': status.toString().split('.').last,
      'submittedDate': submittedDate,
    };
  }

  // Create from JSON
  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      reason: json['reason'],
      leaveType: json['leaveType'],
      days: json['days'],
      status: RequestStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      submittedDate: json['submittedDate'],
    );
  }

  // Copy with modifications
  LeaveRequest copyWith({
    String? id,
    String? startDate,
    String? endDate,
    String? reason,
    String? leaveType,
    int? days,
    RequestStatus? status,
    String? submittedDate,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      leaveType: leaveType ?? this.leaveType,
      days: days ?? this.days,
      status: status ?? this.status,
      submittedDate: submittedDate ?? this.submittedDate,
    );
  }
}

class PermitRequest {
  final String id;
  final String title;
  final String purpose;
  final String permitType;
  final String duration;
  final RequestStatus status;
  final String submittedDate;

  PermitRequest({
    required this.id,
    required this.title,
    required this.purpose,
    required this.permitType,
    required this.duration,
    required this.status,
    required this.submittedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'purpose': purpose,
      'permitType': permitType,
      'duration': duration,
      'status': status.toString().split('.').last,
      'submittedDate': submittedDate,
    };
  }

  factory PermitRequest.fromJson(Map<String, dynamic> json) {
    return PermitRequest(
      id: json['id'],
      title: json['title'],
      purpose: json['purpose'],
      permitType: json['permitType'],
      duration: json['duration'],
      status: RequestStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      submittedDate: json['submittedDate'],
    );
  }

  PermitRequest copyWith({
    String? id,
    String? title,
    String? purpose,
    String? permitType,
    String? duration,
    RequestStatus? status,
    String? submittedDate,
  }) {
    return PermitRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      permitType: permitType ?? this.permitType,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      submittedDate: submittedDate ?? this.submittedDate,
    );
  }
}

class LoanRequest {
  final String id;
  final String loanType;
  final String purpose;
  final String amount;
  final int repaymentMonths;
  final RequestStatus status;
  final String submittedDate;

  LoanRequest({
    required this.id,
    required this.loanType,
    required this.purpose,
    required this.amount,
    required this.repaymentMonths,
    required this.status,
    required this.submittedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loanType': loanType,
      'purpose': purpose,
      'amount': amount,
      'repaymentMonths': repaymentMonths,
      'status': status.toString().split('.').last,
      'submittedDate': submittedDate,
    };
  }

  factory LoanRequest.fromJson(Map<String, dynamic> json) {
    return LoanRequest(
      id: json['id'],
      loanType: json['loanType'],
      purpose: json['purpose'],
      amount: json['amount'],
      repaymentMonths: json['repaymentMonths'],
      status: RequestStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      submittedDate: json['submittedDate'],
    );
  }

  LoanRequest copyWith({
    String? id,
    String? loanType,
    String? purpose,
    String? amount,
    int? repaymentMonths,
    RequestStatus? status,
    String? submittedDate,
  }) {
    return LoanRequest(
      id: id ?? this.id,
      loanType: loanType ?? this.loanType,
      purpose: purpose ?? this.purpose,
      amount: amount ?? this.amount,
      repaymentMonths: repaymentMonths ?? this.repaymentMonths,
      status: status ?? this.status,
      submittedDate: submittedDate ?? this.submittedDate,
    );
  }
}

class LetterRequest {
  final String id;
  final String title;
  final String description;
  final String letterType;
  final RequestStatus status;
  final String submittedDate;

  LetterRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.letterType,
    required this.status,
    required this.submittedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'letterType': letterType,
      'status': status.toString().split('.').last,
      'submittedDate': submittedDate,
    };
  }

  factory LetterRequest.fromJson(Map<String, dynamic> json) {
    return LetterRequest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      letterType: json['letterType'],
      status: RequestStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['status'],
      ),
      submittedDate: json['submittedDate'],
    );
  }

  LetterRequest copyWith({
    String? id,
    String? title,
    String? description,
    String? letterType,
    RequestStatus? status,
    String? submittedDate,
  }) {
    return LetterRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      letterType: letterType ?? this.letterType,
      status: status ?? this.status,
      submittedDate: submittedDate ?? this.submittedDate,
    );
  }
}