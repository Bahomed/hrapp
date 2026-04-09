class LeaveBalanceResponse {
  final String status;
  final int statusCode;
  final double vacationBalance;
  final String message;

  LeaveBalanceResponse({
    required this.status,
    required this.statusCode,
    required this.vacationBalance,
    required this.message,
  });

  factory LeaveBalanceResponse.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceResponse(
      status: json['status'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      vacationBalance: (json['vacation_balance'] ?? 0).toDouble(),
      message: json['message'] ?? '',
    );
  }
}
