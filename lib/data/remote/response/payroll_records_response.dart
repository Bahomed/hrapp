class PayrollRecordsResponse {
  final bool success;
  final List<PayrollRecordResponseData> data;
  final String message;

  PayrollRecordsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory PayrollRecordsResponse.fromJson(Map<String, dynamic> json) {
    var records = (json['data'] as List)
        .map((item) => PayrollRecordResponseData.fromJson(item))
        .toList();
    return PayrollRecordsResponse(
      success: json['success'],
      data: records,
      message: json['message'],
    );
  }
}

class PayrollRecordResponseData {
  final String id;
  final String month;
  final String year;
  final String period;
  final double totalBenefits;
  final double totalDeductions;
  final double netSalary;
  final String status;
  final String processedDate;
  final String paymentDate;
  final List<BenefitResponseData> benefits;
  final List<DeductionResponseData> deductions;

  PayrollRecordResponseData({
    required this.id,
    required this.month,
    required this.year,
    required this.period,
    required this.totalBenefits,
    required this.totalDeductions,
    required this.netSalary,
    required this.status,
    required this.processedDate,
    required this.paymentDate,
    required this.benefits,
    required this.deductions,
  });

  factory PayrollRecordResponseData.fromJson(Map<String, dynamic> json) {
    var benefits = (json['benefits'] as List)
        .map((item) => BenefitResponseData.fromJson(item))
        .toList();
    var deductions = (json['deductions'] as List)
        .map((item) => DeductionResponseData.fromJson(item))
        .toList();
    return PayrollRecordResponseData(
      id: json['id'].toString(),
      month: json['month'],
      year: json['year'],
      period: json['period'],
      totalBenefits: double.parse(json['total_benefits'].toString()),
      totalDeductions: double.parse(json['total_deductions'].toString()),
      netSalary: double.parse(json['net_salary'].toString()),
      status: json['status'],
      processedDate: json['processed_date'],
      paymentDate: json['payment_date'],
      benefits: benefits,
      deductions: deductions,
    );
  }
}

class BenefitResponseData {
  final String id;
  final String description;
  final double amount;

  BenefitResponseData({
    required this.id,
    required this.description,
    required this.amount,
  });

  factory BenefitResponseData.fromJson(Map<String, dynamic> json) {
    return BenefitResponseData(
      id: json['id'].toString(),
      description: json['description'],
      amount: double.parse(json['amount'].toString()),
    );
  }
}

class DeductionResponseData {
  final String id;
  final String description;
  final double amount;

  DeductionResponseData({
    required this.id,
    required this.description,
    required this.amount,
  });

  factory DeductionResponseData.fromJson(Map<String, dynamic> json) {
    return DeductionResponseData(
      id: json['id'].toString(),
      description: json['description'],
      amount: double.parse(json['amount'].toString()),
    );
  }
}