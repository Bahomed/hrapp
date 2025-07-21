// To parse this JSON data, do
//
//     final deleteUserResponse = deleteUserResponseFromJson(jsonString);

import 'dart:convert';

DeleteUserResponse deleteUserResponseFromJson(String str) => DeleteUserResponse.fromJson(json.decode(str));

String deleteUserResponseToJson(DeleteUserResponse data) => json.encode(data.toJson());

class DeleteUserResponse {
  int status;
  int statusCode;
  String message;
  String data;

  DeleteUserResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory DeleteUserResponse.fromJson(Map<String, dynamic> json) => DeleteUserResponse(
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
