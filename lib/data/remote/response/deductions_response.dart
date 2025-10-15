class DeductionsResponse {
  final bool error;
  final String message;
  final int code;
  final DeductionsData? data;

  DeductionsResponse({
    required this.error,
    required this.message,
    required this.code,
    this.data,
  });

  factory DeductionsResponse.fromJson(Map<String, dynamic> json) {
    return DeductionsResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? 200,
      data: json['data'] != null ? DeductionsData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'code': code,
      'data': data?.toJson(),
    };
  }
}

class DeductionsData {
  final List<UserDeduction> userDeduction;
  final double totalDeductionAmount;
  final double totalDeductionAmountPaid;
  final double totalDeductionAmountTobePaid;

  DeductionsData({
    required this.userDeduction,
    required this.totalDeductionAmount,
    required this.totalDeductionAmountPaid,
    required this.totalDeductionAmountTobePaid,
  });

  factory DeductionsData.fromJson(Map<String, dynamic> json) {
    return DeductionsData(
      userDeduction: (json['userDeduction'] as List?)
              ?.map((item) => UserDeduction.fromJson(item))
              .toList() ??
          [],
      totalDeductionAmount: _parseDouble(json['totalDeductionAmount']),
      totalDeductionAmountPaid: _parseDouble(json['totalDeductionAmountPaid']),
      totalDeductionAmountTobePaid: _parseDouble(json['totalDeductionAmountTobePaid']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userDeduction': userDeduction.map((e) => e.toJson()).toList(),
      'totalDeductionAmount': totalDeductionAmount,
      'totalDeductionAmountPaid': totalDeductionAmountPaid,
      'totalDeductionAmountTobePaid': totalDeductionAmountTobePaid,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class UserDeduction {
  final int id;
  final String deductionName;
  final int noOfInstallment;
  final String installmentAmt;
  final double amount;
  final double totAmtPaid;
  final double balance;
  final String? startDate;
  final String? settlementDate;

  UserDeduction({
    required this.id,
    required this.deductionName,
    required this.noOfInstallment,
    required this.installmentAmt,
    required this.amount,
    required this.totAmtPaid,
    required this.balance,
    this.startDate,
    this.settlementDate,
  });

  factory UserDeduction.fromJson(Map<String, dynamic> json) {
    return UserDeduction(
      id: json['id'] ?? 0,
      deductionName: json['deduction_name']?.toString() ?? 'Unknown Deduction',
      noOfInstallment: json['no_of_installment'] ?? 0,
      installmentAmt: json['installment_amt']?.toString() ?? '0.00',
      amount: _parseDouble(json['amount']),
      totAmtPaid: _parseDouble(json['tot_amt_paid']),
      balance: _parseDouble(json['balance']),
      startDate: json['start_date']?.toString(),
      settlementDate: json['settlement_date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deduction_name': deductionName,
      'no_of_installment': noOfInstallment,
      'installment_amt': installmentAmt,
      'amount': amount,
      'tot_amt_paid': totAmtPaid,
      'balance': balance,
      'start_date': startDate,
      'settlement_date': settlementDate,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}