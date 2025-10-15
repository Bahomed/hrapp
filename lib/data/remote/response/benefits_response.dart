class BenefitsResponse {
  final bool error;
  final String message;
  final int code;
  final BenefitsData? data;

  BenefitsResponse({
    required this.error,
    required this.message,
    required this.code,
    this.data,
  });

  factory BenefitsResponse.fromJson(Map<String, dynamic> json) {
    return BenefitsResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      code: json['code'] ?? 200,
      data: json['data'] != null ? BenefitsData.fromJson(json['data']) : null,
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

class BenefitsData {
  final List<Earning> earnings;
  final BenefitTotals totals;

  BenefitsData({
    required this.earnings,
    required this.totals,
  });

  factory BenefitsData.fromJson(Map<String, dynamic> json) {
    return BenefitsData(
      earnings: (json['earnings'] as List?)
              ?.map((item) => Earning.fromJson(item))
              .toList() ??
          [],
      totals: json['totals'] != null
          ? BenefitTotals.fromJson(json['totals'])
          : BenefitTotals(
              totalEarning: 0,

            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earnings': earnings.map((e) => e.toJson()).toList(),
      'totals': totals.toJson(),
    };
  }
}

class Earning {
  final int id;
  final String benefit;
  final double benefitAmt;
  final int useFactor;
  final String paymentScheme;
  final String paymentSchemeLabel;
  final String? effectivityDateG;
  final double benefitAmount;

  Earning({
    required this.id,
    required this.benefit,
    required this.benefitAmt,
    required this.useFactor,
    required this.paymentScheme,
    required this.paymentSchemeLabel,
    this.effectivityDateG,
    required this.benefitAmount,
  });

  factory Earning.fromJson(Map<String, dynamic> json) {
    return Earning(
      id: json['id'] ?? 0,
      benefit: json['benefit']?.toString() ?? 'Unknown Benefit',
      benefitAmt: _parseDouble(json['benefit_amt']),
      useFactor: json['use_factor'] ?? 0,
      paymentScheme: json['paymentscheme']?.toString() ?? '',
      paymentSchemeLabel: json['payment_scheme_label']?.toString() ?? '',
      effectivityDateG: json['effectivity_date_g']?.toString(),
      benefitAmount: _parseDouble(json['benefit_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'benefit': benefit,
      'benefit_amt': benefitAmt,
      'use_factor': useFactor,
      'paymentscheme': paymentScheme,
      'payment_scheme_label': paymentSchemeLabel,
      'effectivity_date_g': effectivityDateG,
      'benefit_amount': benefitAmount,
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

class BenefitTotals {
  final double totalEarning;

  BenefitTotals({
    required this.totalEarning,
  });

  factory BenefitTotals.fromJson(Map<String, dynamic> json) {
    return BenefitTotals(
      totalEarning: _parseDouble(json['totalEarning']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalEarning': totalEarning,
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