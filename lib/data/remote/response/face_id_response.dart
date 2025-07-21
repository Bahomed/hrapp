import 'dart:convert';

FaceIdResponse faceIdResponseFromJson(String str) =>
    FaceIdResponse.fromJson(json.decode(str));

String faceIdResponseToJson(FaceIdResponse data) => json.encode(data.toJson());

class FaceIdResponse {
  int status;
  int statusCode;
  String message;
  Data data;

  FaceIdResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory FaceIdResponse.fromJson(Map<String, dynamic> json) => FaceIdResponse(
        status: json["status"] as int? ?? 0,
        statusCode: json["status_code"] as int? ?? 0,
        message: json["message"] as String? ?? "",
        data: Data.fromJson(json["data"] as Map<String, dynamic>? ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "status_code": statusCode,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  Map<String, dynamic> data;

  Data({
    required this.data,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        data: json["data"] as Map<String, dynamic>? ?? {},
      );

  Map<String, dynamic> toJson() => {
        "data": data,
      };
}
