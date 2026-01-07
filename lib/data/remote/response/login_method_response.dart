class LoginMethodResponse {
  bool? error;
  String? loginMethod;
  String? message;
  int? code;

  LoginMethodResponse({
    this.error,
    this.loginMethod,
    this.message,
    this.code,
  });

  LoginMethodResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    loginMethod = json['login_method'];
    message = json['message'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    data['login_method'] = loginMethod;
    data['message'] = message;
    data['code'] = code;
    return data;
  }
}