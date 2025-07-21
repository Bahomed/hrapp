import 'dart:convert';

HolidayResponse holidayResponseFromJson(String str) =>
    HolidayResponse.fromJson(json.decode(str));

String holidayResponseToJson(HolidayResponse data) =>
    json.encode(data.toJson());

class HolidayResponse {
  int status;
  int statusCode;
  String message;
  List<Datum> data;

  HolidayResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory HolidayResponse.fromJson(Map<String, dynamic> json) =>
      HolidayResponse(
        status: json["status"],
        statusCode: json["status_code"],
        message: json["message"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "status_code": statusCode,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  String title;
  DateTime date;

  Datum({
    required this.title,
    required this.date,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        title: json["title"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      };
}
