class AttendanceStatusResponse {
  final bool error;
  final String message;
  final AttendanceStatusData? data;

  AttendanceStatusResponse({
    required this.error,
    required this.message,
    this.data,
  });

  factory AttendanceStatusResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceStatusResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AttendanceStatusData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AttendanceStatusData {
  final bool attendanceEnabled;
  final String date;
  final String currentTime;
  final String timestamp;
  final String locale;
  final bool sessionFound;
  final AttendanceData attendanceData;
  final bool canClockIn;
  final bool canClockOut;
  final bool canBreakIn;
  final bool canBreakOut;
  final String statusMessage;
  final String nextAction;
  final SessionTiming? sessionTiming;
  final bool locationRequired;
  final bool wifiRequired;
  final LocationInfo? locationInfo;
  final WorkSummary? workSummary;

  AttendanceStatusData({
    required this.attendanceEnabled,
    required this.date,
    required this.currentTime,
    required this.timestamp,
    required this.locale,
    required this.sessionFound,
    required this.attendanceData,
    required this.canClockIn,
    required this.canClockOut,
    required this.canBreakIn,
    required this.canBreakOut,
    required this.statusMessage,
    required this.nextAction,
    this.sessionTiming,
    required this.locationRequired,
    required this.wifiRequired,
    this.locationInfo,
    this.workSummary,
  });

  factory AttendanceStatusData.fromJson(Map<String, dynamic> json) {
    return AttendanceStatusData(
      attendanceEnabled: json['attendance_enabled'] ?? false,
      date: json['date'] ?? '',
      currentTime: json['current_time'] ?? '',
      timestamp: json['timestamp'] ?? '',
      locale: json['locale'] ?? '',
      sessionFound: json['session_found'] ?? false,
      attendanceData: AttendanceData.fromJson(json['attendance_data'] ?? {}),
      canClockIn: json['can_clock_in'] ?? false,
      canClockOut: json['can_clock_out'] ?? false,
      canBreakIn: json['can_break_in'] ?? false,
      canBreakOut: json['can_break_out'] ?? false,
      statusMessage: json['status_message'] ?? '',
      nextAction: json['next_action'] ?? '',
      sessionTiming: json['session_timing'] != null 
          ? SessionTiming.fromJson(json['session_timing']) 
          : null,
      locationRequired: json['location_required'] ?? true,
      wifiRequired: json['wifi_required'] ?? true,
      locationInfo: json['location_info'] != null 
          ? LocationInfo.fromJson(json['location_info']) 
          : null,
      workSummary: json['work_summary'] != null 
          ? WorkSummary.fromJson(json['work_summary']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_enabled': attendanceEnabled,
      'date': date,
      'current_time': currentTime,
      'timestamp': timestamp,
      'locale': locale,
      'session_found': sessionFound,
      'attendance_data': attendanceData.toJson(),
      'can_clock_in': canClockIn,
      'can_clock_out': canClockOut,
      'can_break_in': canBreakIn,
      'can_break_out': canBreakOut,
      'status_message': statusMessage,
      'next_action': nextAction,
      'session_timing': sessionTiming?.toJson(),
      'location_required': locationRequired,
      'wifi_required': wifiRequired,
      'location_info': locationInfo?.toJson(),
      'work_summary': workSummary?.toJson(),
    };
  }
}

class AttendanceData {
  final String? clockIn;
  final String? clockOut;
  final String? breakIn;
  final String? breakOut;
  final String? secondBreakIn;
  final String? secondBreakOut;
  final String? secondIn;
  final String? secondOut;

  AttendanceData({
    this.clockIn,
    this.clockOut,
    this.breakIn,
    this.breakOut,
    this.secondBreakIn,
    this.secondBreakOut,
    this.secondIn,
    this.secondOut,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      clockIn: json['clock_in'],
      clockOut: json['clock_out'],
      breakIn: json['break_in'],
      breakOut: json['break_out'],
      secondBreakIn: json['second_break_in'],
      secondBreakOut: json['second_break_out'],
      secondIn: json['second_in'],
      secondOut: json['second_out'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clock_in': clockIn,
      'clock_out': clockOut,
      'break_in': breakIn,
      'break_out': breakOut,
      'second_break_in': secondBreakIn,
      'second_break_out': secondBreakOut,
      'second_in': secondIn,
      'second_out': secondOut,
    };
  }
}

class SessionTiming {
  final String checkInBegin;
  final String checkInEnd;
  final String checkOutBegin;
  final String checkOutEnd;
  final int gracePeriod;

  SessionTiming({
    required this.checkInBegin,
    required this.checkInEnd,
    required this.checkOutBegin,
    required this.checkOutEnd,
    required this.gracePeriod,
  });

  factory SessionTiming.fromJson(Map<String, dynamic> json) {
    return SessionTiming(
      checkInBegin: json['check_in_begin'] ?? '',
      checkInEnd: json['check_in_end'] ?? '',
      checkOutBegin: json['check_out_begin'] ?? '',
      checkOutEnd: json['check_out_end'] ?? '',
      gracePeriod: int.tryParse(json['grace_period']?.toString() ?? '15') ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'check_in_begin': checkInBegin,
      'check_in_end': checkInEnd,
      'check_out_begin': checkOutBegin,
      'check_out_end': checkOutEnd,
      'grace_period': gracePeriod,
    };
  }
}

class LocationInfo {
  final String latitude;
  final String longitude;
  final int radius;
  final List<String> wifiBssids;
  final String address;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.wifiBssids,
    required this.address,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      radius: json['radius'] ?? 100,
      wifiBssids: List<String>.from(json['wifi_bssids'] ?? []),
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'wifi_bssids': wifiBssids,
      'address': address,
    };
  }
}

class WorkSummary {
  final int totalWorkMinutes;
  final int totalBreakMinutes;
  final List<WorkSession> sessions;
  final String totalWorkHours;
  final String totalBreakHours;

  WorkSummary({
    required this.totalWorkMinutes,
    required this.totalBreakMinutes,
    required this.sessions,
    required this.totalWorkHours,
    required this.totalBreakHours,
  });

  factory WorkSummary.fromJson(Map<String, dynamic> json) {
    return WorkSummary(
      totalWorkMinutes: json['total_work_minutes'] ?? 0,
      totalBreakMinutes: json['total_break_minutes'] ?? 0,
      sessions: (json['sessions'] as List?)
          ?.map((e) => WorkSession.fromJson(e))
          .toList() ?? [],
      totalWorkHours: json['total_work_hours'] ?? '0h 0m',
      totalBreakHours: json['total_break_hours'] ?? '0h 0m',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_work_minutes': totalWorkMinutes,
      'total_break_minutes': totalBreakMinutes,
      'sessions': sessions.map((e) => e.toJson()).toList(),
      'total_work_hours': totalWorkHours,
      'total_break_hours': totalBreakHours,
    };
  }
}

class WorkSession {
  final int session;
  final String clockIn;
  final String clockOut;
  final int workMinutes;

  WorkSession({
    required this.session,
    required this.clockIn,
    required this.clockOut,
    required this.workMinutes,
  });

  factory WorkSession.fromJson(Map<String, dynamic> json) {
    return WorkSession(
      session: json['session'] ?? 0,
      clockIn: json['clock_in'] ?? '',
      clockOut: json['clock_out'] ?? '',
      workMinutes: json['work_minutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session': session,
      'clock_in': clockIn,
      'clock_out': clockOut,
      'work_minutes': workMinutes,
    };
  }
}