class LeaveBalanceResponse {
  final String status;
  final int statusCode;
  final double vacationBalance;
  final bool phPdEnabled;
  final double phBalance;
  final double pdBalance;
  final String message;

  LeaveBalanceResponse({
    required this.status,
    required this.statusCode,
    required this.vacationBalance,
    required this.phPdEnabled,
    required this.phBalance,
    required this.pdBalance,
    required this.message,
  });

  factory LeaveBalanceResponse.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceResponse(
      status: json['status'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      vacationBalance: (json['vacation_balance'] ?? 0).toDouble(),
      phPdEnabled: json['ph_pd_enabled'] ?? false,
      phBalance: (json['ph_balance'] ?? 0).toDouble(),
      pdBalance: (json['pd_balance'] ?? 0).toDouble(),
      message: json['message'] ?? '',
    );
  }
}
