class AttendanceCalendarResponse {
  final bool success;
  final List<AttendanceEntry> data;
  final String message;

  AttendanceCalendarResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory AttendanceCalendarResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceCalendarResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => AttendanceEntry.fromJson(item))
          .toList() ?? [],
      message: json['message'] ?? '',
    );
  }
}

class AttendanceEntry {
  final String belongsToDate;
  final int month;
  final int year;
  final String status;

  AttendanceEntry({
    required this.belongsToDate,
    required this.month,
    required this.year,
    required this.status,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      belongsToDate: json['belongs_to_date'] ?? '',
      month: json['month'] ?? 0,
      year: json['year'] ?? 0,
      status: json['status'] ?? 'Present',
    );
  }

  DateTime get date {
    try {
      return DateTime.parse(belongsToDate);
    } catch (e) {
      // Fallback to current date if parsing fails
      return DateTime(year, month, 1);
    }
  }
  
  bool get isAbsent => status == 'Absent';
  bool get isHalfDayAbsent => status == 'Half_Day_Absent';
  bool get isPresent => status == 'Present';
}