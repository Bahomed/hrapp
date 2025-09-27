class Employee {
  final int id;
  final String employeeNo;
  final String employeeName;
  final String positionName;
  final String departmentName;
  final String sectionName;
  final String nationalityName;
  final String empStatus;
  final String? image;

  Employee({
    required this.id,
    required this.employeeNo,
    required this.employeeName,
    required this.positionName,
    required this.departmentName,
    required this.sectionName,
    required this.nationalityName,
    required this.empStatus,
    this.image,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      employeeNo: json['employee_no'] ?? '',
      employeeName: json['employee_name'] ?? '',
      positionName: json['position_name'] ?? '',
      departmentName: json['department_name'] ?? '',
      sectionName: json['section_name'] ?? '',
      nationalityName: json['nationality_name'] ?? '',
      empStatus: json['emp_status'] ?? '',
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_no': employeeNo,
      'employee_name': employeeName,
      'position_name': positionName,
      'department_name': departmentName,
      'section_name': sectionName,
      'nationality_name': nationalityName,
      'emp_status': empStatus,
      'image': image,
    };
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}

class EmployeesPagination {
  final int currentPage;
  final List<Employee> data;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  EmployeesPagination({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory EmployeesPagination.fromJson(Map<String, dynamic> json) {
    return EmployeesPagination(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List?)
          ?.map((item) => Employee.fromJson(item))
          .toList() ?? [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List?)
          ?.map((item) => PaginationLink.fromJson(item))
          .toList() ?? [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class EmployeesResponse {
  final String status;
  final int statusCode;
  final String message;
  final EmployeesPagination employees;

  EmployeesResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.employees,
  });

  factory EmployeesResponse.fromJson(Map<String, dynamic> json) {
    return EmployeesResponse(
      status: json['status'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      employees: EmployeesPagination.fromJson(json['employees'] ?? {}),
    );
  }
}