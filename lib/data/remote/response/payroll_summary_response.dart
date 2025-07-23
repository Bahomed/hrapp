class PayrollSummaryResponse {
  final bool success;
<<<<<<< HEAD
  final List<PayrollSummaryItem> data;
=======
  final PayrollSummaryResponseData data;
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
  final String message;

  PayrollSummaryResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory PayrollSummaryResponse.fromJson(Map<String, dynamic> json) {
<<<<<<< HEAD
    var dataList = <PayrollSummaryItem>[];
    if (json['data'] != null) {
      dataList = (json['data'] as List)
          .map((item) => PayrollSummaryItem.fromJson(item))
          .toList();
    }

    return PayrollSummaryResponse(
      success: json['success'],
      data: dataList,
=======
    return PayrollSummaryResponse(
      success: json['success'],
      data: PayrollSummaryResponseData.fromJson(json['data']),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
      message: json['message'],
    );
  }
}

<<<<<<< HEAD
class PayrollSummaryItem {
  final String month;
  final String monthYearId;
  final double totalEarnings;
  final double totalDeductions;
  final double netPay;

  PayrollSummaryItem({
    required this.month,
    required this.monthYearId,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netPay,
  });

  factory PayrollSummaryItem.fromJson(Map<String, dynamic> json) {
    return PayrollSummaryItem(
      month: json['month'] ?? '',
      monthYearId: json['month_year_id'] ?? '',
      totalEarnings: double.tryParse(json['total_earnings'].toString()) ?? 0.0,
      totalDeductions: double.tryParse(json['total_deductions'].toString()) ?? 0.0,
      netPay: double.tryParse(json['net_pay'].toString()) ?? 0.0,
=======
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
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
    );
  }
}