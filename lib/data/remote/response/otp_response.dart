class OtpResponse {
  bool? error;
  String? message;
  int? code;

  OtpResponse({
    this.error,
    this.message,
    this.code,
  });

  OtpResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['message'] = message;
    data['code'] = code;
    return data;
  }
}