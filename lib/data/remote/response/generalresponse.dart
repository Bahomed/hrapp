import 'dart:convert';

GeneralResponse generalResponseFromJson(String str) =>
    GeneralResponse.fromJson(json.decode(str));

String generalResponseToJson(GeneralResponse data) =>
    json.encode(data.toJson());

class GeneralResponse {
  int status;
  int statusCode;
  String message;

  GeneralResponse({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  factory GeneralResponse.fromJson(Map<String, dynamic> json) =>
      GeneralResponse(
        status: json["status"] is int ? json["status"] : (json["status"] == true ? 1 : 0),
        statusCode: json["status_code"] is int ? json["status_code"] : (json["status_code"] ?? 200),
        message: json["message"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "status_code": statusCode,
        "message": message,
      };
}
