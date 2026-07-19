// Weekly Attendance API Response Model

class WeeklyAttendanceResponse {
  final bool success;
  final List<WeeklyAttendanceItem> data;

  WeeklyAttendanceResponse({
    required this.success,
    required this.data,
  });

  factory WeeklyAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyAttendanceResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List?)
          ?.map((item) => WeeklyAttendanceItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class WeeklyAttendanceItem {
  final String date;
  final String dayName;
  final String timeIn;
  final String timeOut;
  final String? hours;
  final String? breakTime;
  final String penalty;
  final double penaltyAmount;
  final String overtime;
  final String overtimeAmount;
  final String status;

  WeeklyAttendanceItem({
    required this.date,
    required this.dayName,
    required this.timeIn,
    required this.timeOut,
    this.hours,
    this.breakTime,
    required this.penalty,
    required this.penaltyAmount,
    required this.overtime,
    required this.overtimeAmount,
    required this.status,
  });

  factory WeeklyAttendanceItem.fromJson(Map<String, dynamic> json) {
    return WeeklyAttendanceItem(
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      timeIn: json['in'] ?? '',
      timeOut: json['out'] ?? '',
      hours: json['hours'] as String?,
      breakTime: json['break_time'] ?? '00:00',
      penalty: json['penalty'] ?? '0.00',
      penaltyAmount: double.tryParse(json['penalty_amount'].toString()) ?? 0.0,
      overtime: json['overtime'] ?? '0.00',
      overtimeAmount: json['overtime_amount']?.toString() ?? '0.00',
      status: json['status'] ?? 'Absent',
    );
  }

  // Helper methods
  String get formattedDate {
    try {
      final date = DateTime.parse(this.date);
      return '${date.day}-${date.month}-${date.year}';
    } catch (e) {
      return this.date;
    }
  }

  String get workingHours {
    if (hours == null || hours!.isEmpty) return '--';
    return hours!;
  }

  String get formattedTimeIn {
    if (timeIn.isEmpty) return '--';
    try {
      final parts = timeIn.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Handle parsing errors
    }
    return timeIn;
  }

  String get formattedTimeOut {
    if (timeOut.isEmpty) return '--';
    try {
      final parts = timeOut.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Handle parsing errors
    }
    return timeOut;
  }

  String get formattedBreakTime {
    if (breakTime == null || breakTime!.isEmpty || breakTime == '00:00') return '--';
    try {
      final parts = breakTime!.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        if (hour == 0 && minute == 0) return '--';
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // Handle parsing errors
    }
    return breakTime ?? '--';
  }
}