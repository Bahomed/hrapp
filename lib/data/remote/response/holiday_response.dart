import 'dart:convert';

HolidayResponse holidayResponseFromJson(String str) =>
    HolidayResponse.fromJson(json.decode(str));

String holidayResponseToJson(HolidayResponse data) =>
    json.encode(data.toJson());

class HolidayResponse {
  int status;
  int statusCode;
  String message;
  HolidayData data;

  HolidayResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory HolidayResponse.fromJson(Map<String, dynamic> json) =>
      HolidayResponse(
        status: json["status"] ?? 0,
        statusCode: json["status_code"] ?? 0,
        message: json["message"] ?? '',
        data: HolidayData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "status_code": statusCode,
        "message": message,
        "data": data.toJson(),
      };
}

class HolidayData {
  List<HolidayItem> items;
  Pagination pagination;

  HolidayData({required this.items, required this.pagination});

  factory HolidayData.fromJson(Map<String, dynamic> json) => HolidayData(
        items: (json["items"] as List<dynamic>?)
                ?.map((x) => HolidayItem.fromJson(x))
                .toList() ??
            [],
        pagination: Pagination.fromJson(json["pagination"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "items": items.map((x) => x.toJson()).toList(),
        "pagination": pagination.toJson(),
      };
}

class Pagination {
  int currentPage;
  int perPage;
  int total;
  int lastPage;
  bool hasMore;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        currentPage: json["current_page"] ?? 1,
        perPage: json["per_page"] ?? 15,
        total: json["total"] ?? 0,
        lastPage: json["last_page"] ?? 1,
        hasMore: json["has_more"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "per_page": perPage,
        "total": total,
        "last_page": lastPage,
        "has_more": hasMore,
      };
}

class HolidayItem {
  String title;
  DateTime fromDate;
  DateTime toDate;

  HolidayItem({
    required this.title,
    required this.fromDate,
    required this.toDate,
  });

  factory HolidayItem.fromJson(Map<String, dynamic> json) => HolidayItem(
        title: json["title"] ?? '',
        fromDate: DateTime.tryParse(json["from_date"] ?? '') ?? DateTime.now(),
        toDate: DateTime.tryParse(json["to_date"] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "from_date":
            "${fromDate.year.toString().padLeft(4, '0')}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
        "to_date":
            "${toDate.year.toString().padLeft(4, '0')}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
      };
}
