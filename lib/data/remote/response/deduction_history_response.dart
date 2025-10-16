class DeductionHistoryResponse {
  final String status;
  final int statusCode;
  final String message;
  final List<DeductionHistoryItem> data;

  DeductionHistoryResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory DeductionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return DeductionHistoryResponse(
      status: json['status'] ?? '',
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((item) => DeductionHistoryItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'statusCode': statusCode,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class DeductionHistoryItem {
  final String settleDate;
  final String loanAmount;
  final String amountPaid;
  final String status;
  final String settlementId;
  final double amountToBePaid;
  final String remarks;

  DeductionHistoryItem({
    required this.settleDate,
    required this.loanAmount,
    required this.amountPaid,
    required this.status,
    required this.settlementId,
    required this.amountToBePaid,
    required this.remarks,
  });

  factory DeductionHistoryItem.fromJson(Map<String, dynamic> json) {
    return DeductionHistoryItem(
      settleDate: json['settle_date']?.toString() ?? '',
      loanAmount: json['loan_amount']?.toString() ?? '0.00',
      amountPaid: json['amount_paid']?.toString() ?? '0.00',
      status: json['status']?.toString() ?? '',
      settlementId: json['settlement_id']?.toString() ?? '',
      amountToBePaid: _parseDouble(json['amount_to_be_paid']),
      remarks: json['remarks']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'settle_date': settleDate,
      'loan_amount': loanAmount,
      'amount_paid': amountPaid,
      'status': status,
      'settlement_id': settlementId,
      'amount_to_be_paid': amountToBePaid,
      'remarks': remarks,
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