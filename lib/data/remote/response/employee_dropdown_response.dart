class EmployeeDropdownResponse {
  final String status;
  final int statusCode;
  final String message;
  final List<EmployeeDropdownItem> data;

  EmployeeDropdownResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory EmployeeDropdownResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeDropdownResponse(
      status: json['status'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => EmployeeDropdownItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class EmployeeDropdownItem {
  final int id;
  final String employeeName;

  EmployeeDropdownItem({
    required this.id,
    required this.employeeName,
  });

  factory EmployeeDropdownItem.fromJson(Map<String, dynamic> json) {
    return EmployeeDropdownItem(
      id: json['id'] ?? 0,
      employeeName: json['employee_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_name': employeeName,
    };
  }
}