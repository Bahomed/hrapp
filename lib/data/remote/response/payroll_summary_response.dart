class PayrollSummaryResponse {
  final bool success;
  final List<PayrollSummaryItem> data;
  final String message;

  PayrollSummaryResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory PayrollSummaryResponse.fromJson(Map<String, dynamic> json) {
    var dataList = <PayrollSummaryItem>[];
    if (json['data'] != null) {
      dataList = (json['data'] as List)
          .map((item) => PayrollSummaryItem.fromJson(item))
          .toList();
    }

    return PayrollSummaryResponse(
      success: json['success'],
      data: dataList,
      message: json['message'],
    );
  }
}

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
    );
  }
}