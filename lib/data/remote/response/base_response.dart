
// File: lib/data/remote/response/base_response.dart

// ================ BASE RESPONSE CLASS ================

class BaseResponse {
  final bool success;
  final String message;
  final String? error;

  BaseResponse({
    required this.success,
    required this.message,
    this.error,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
    );
  }
}

// ================ COMMON MODELS ================

class Attachment {
  final String name;
  final String path;
  final int size;

  Attachment({
    required this.name,
    required this.path,
    required this.size,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      name: json['name'] ?? '',
      path: json['path'] ?? '',
      size: json['size'] ?? 0,
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class RequestTypeOption {
  final int id;
  final String name;

  RequestTypeOption({
    required this.id,
    required this.name,
  });

  factory RequestTypeOption.fromJson(Map<String, dynamic> json) {
    return RequestTypeOption(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

