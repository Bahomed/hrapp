// To parse this JSON data, do
//
//     final saveEmployeeAttendanceResponse = saveEmployeeAttendanceResponseFromJson(jsonString);

import 'dart:convert';

SaveEmployeeAttendanceResponse saveEmployeeAttendanceResponseFromJson(String str) => SaveEmployeeAttendanceResponse.fromJson(json.decode(str));

String saveEmployeeAttendanceResponseToJson(SaveEmployeeAttendanceResponse data) => json.encode(data.toJson());

class SaveEmployeeAttendanceResponse {
  bool error;
  String message;
  String validationMessage;
  Data? data;

  SaveEmployeeAttendanceResponse({
    required this.error,
    required this.message,
    required this.validationMessage,
    this.data,
  });

  factory SaveEmployeeAttendanceResponse.fromJson(Map<String, dynamic> json) => SaveEmployeeAttendanceResponse(
    error: json["error"] == true || json["success"] == false || json["status"] == false,
    message: json["message"]?.toString() ?? "",
    validationMessage: json["validation_message"]?.toString() ?? "",
    data: json["data"] != null && json["data"] is Map<String, dynamic> && (json["data"] as Map<String, dynamic>).isNotEmpty 
        ? Data.fromJson(json["data"]) 
        : null,
  );

  /// A punch counts as recorded only when `error` is false AND there is no
  /// `validation_message` (e.g. wrong location now answers `error: true`).
  bool get isSuccess => !error && validationMessage.trim().isEmpty;

  /// What to show in red when [isSuccess] is false.
  String get errorText =>
      validationMessage.trim().isNotEmpty ? validationMessage : message;

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "validation_message": validationMessage,
    "data": data?.toJson(),
  };
}

class Data {
  String? attendanceType;
  String? clockIn;
  String? breakIn;
  String? breakOut;
  String? secondBreakIn;
  String? secondBreakOut;
  String? clockOut;
  String? secondIn;
  String? secondOut;

  Data({
    this.attendanceType,
    this.clockIn,
    this.breakIn,
    this.breakOut,
    this.secondBreakIn,
    this.secondBreakOut,
    this.clockOut,
    this.secondIn,
    this.secondOut,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    attendanceType: json["attendanceType"],
    clockIn: json["clock_in"],
    breakIn: json["break_in"],
    breakOut: json["break_out"],
    secondBreakIn: json["second_break_in"],
    secondBreakOut: json["second_break_out"],
    clockOut: json["clock_out"],
    secondIn: json["second_in"],
    secondOut: json["second_out"],
  );

  Map<String, dynamic> toJson() => {
    "attendanceType": attendanceType,
    "clock_in": clockIn,
    "break_in": breakIn,
    "break_out": breakOut,
    "second_break_in": secondBreakIn,
    "second_break_out": secondBreakOut,
    "clock_out": clockOut,
    "second_in": secondIn,
    "second_out": secondOut,
  };
}
