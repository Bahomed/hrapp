class PayrollSummaryResponse {
  final bool success;
  final PayrollSummaryResponseData data;
  final String message;

  PayrollSummaryResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory PayrollSummaryResponse.fromJson(Map<String, dynamic> json) {
    return PayrollSummaryResponse(
      success: json['success'],
      data: PayrollSummaryResponseData.fromJson(json['data']),
      message: json['message'],
    );
  }
}

class PayrollSummaryResponseData {
  final double totalGrossEarnings;
  final double totalDeductions;
  final int totalPayslips;
  final double netEarnings;

  PayrollSummaryResponseData({
    required this.totalGrossEarnings,
    required this.totalDeductions,
    required this.totalPayslips,
    required this.netEarnings,
  });

  factory PayrollSummaryResponseData.fromJson(Map<String, dynamic> json) {
    return PayrollSummaryResponseData(
      totalGrossEarnings: double.parse(json['total_gross_earnings'].toString()),
      totalDeductions: double.parse(json['total_deductions'].toString()),
      totalPayslips: int.parse(json['total_payslips'].toString()),
      netEarnings: double.parse(json['net_earnings'].toString()),
    );
  }
}