// To parse this JSON data, do
//
//     final noticeResponse = noticeResponseFromJson(jsonString);

import 'dart:convert';

NoticeResponse noticeResponseFromJson(String str) => NoticeResponse.fromJson(json.decode(str));

String noticeResponseToJson(NoticeResponse data) => json.encode(data.toJson());

class NoticeResponse {
  int status;
  int statusCode;
  String message;
  Data data;

  NoticeResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory NoticeResponse.fromJson(Map<String, dynamic> json) => NoticeResponse(
    status: json["status"],
    statusCode: json["status_code"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "status_code": statusCode,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  List<Notice> notice;
  List<Birthday> birthday;

  Data({
    required this.notice,
    required this.birthday,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    notice: List<Notice>.from(json["notice"].map((x) => Notice.fromJson(x))),
    birthday: List<Birthday>.from(json["birthday"].map((x) => Birthday.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "notice": List<dynamic>.from(notice.map((x) => x.toJson())),
    "birthday": List<dynamic>.from(birthday.map((x) => x.toJson())),
  };
}

class Birthday {
  String name;
  String date;

  Birthday({
    required this.name,
    required this.date,
  });

  factory Birthday.fromJson(Map<String, dynamic> json) => Birthday(
    name: json["name"],
    date: json["date"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "date": date,
  };
}

class Notice {
  String title;
  String description;
  DateTime startDate;
  DateTime endDate;

  Notice({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
    title: json["title"],
    description: json["description"],
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "start_date": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    "end_date": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
  };
}
