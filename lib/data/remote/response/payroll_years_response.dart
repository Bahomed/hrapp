
class PayrollYearsResponse {
  final bool success;
  final List<String> data;
  final String message;

  PayrollYearsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory PayrollYearsResponse.fromJson(Map<String, dynamic> json) {
    var years = (json['data'] as List<dynamic>).cast<String>();
    return PayrollYearsResponse(
      success: json['success'] ?? true,
      data: years,
      message: json['message'] ?? '',
    );
  }
}
