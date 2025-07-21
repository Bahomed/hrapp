import 'dart:convert';

DeleteFaceIdResponse deleteFaceIdResponseFromJson(String str) =>
    DeleteFaceIdResponse.fromJson(json.decode(str));

String deleteFaceIdResponseToJson(DeleteFaceIdResponse data) =>
    json.encode(data.toJson());

class DeleteFaceIdResponse {
  int status;
  int statusCode;
  String message;
  String data;

  DeleteFaceIdResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory DeleteFaceIdResponse.fromJson(Map<String, dynamic> json) =>
      DeleteFaceIdResponse(
        status: json["status"],
        statusCode: json["status_code"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "status_code": statusCode,
        "message": message,
        "data": data,
      };
}
