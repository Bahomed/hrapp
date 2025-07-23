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
      return '${date.day}/${date.month}';
    } catch (e) {
      return this.date;
    }
  }

  String get workingHours {
    if (timeIn.isEmpty || timeOut.isEmpty) return '--';
    
    try {
      final inTime = _parseTime(timeIn);
      final outTime = _parseTime(timeOut);
      
      if (inTime != null && outTime != null) {
        final difference = outTime.difference(inTime);
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        return '${hours}h ${minutes}m';
      }
    } catch (e) {
      // Handle parsing errors
    }
    
    return '--';
  }

  DateTime? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      // Handle parsing errors
    }
    return null;
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
}