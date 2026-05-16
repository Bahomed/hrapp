class WeeklyShiftScheduleResponse {
  final bool success;
  final String view;
  final String rangeStart;
  final String rangeEnd;
  final List<DaySchedule> days;

  WeeklyShiftScheduleResponse({
    required this.success,
    required this.view,
    required this.rangeStart,
    required this.rangeEnd,
    required this.days,
  });

  factory WeeklyShiftScheduleResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyShiftScheduleResponse(
      success: json['success'] ?? true,
      view: json['view'] ?? '',
      rangeStart: json['range_start'] ?? '',
      rangeEnd: json['range_end'] ?? '',
      days: (json['days'] as List? ?? [])
          .map((e) => DaySchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DaySchedule {
  final String date;
  final String dayName;
  final bool isWorking;
  final bool isOff;
  final List<DaySessionEntry> sessions;

  DaySchedule({
    required this.date,
    required this.dayName,
    required this.isWorking,
    required this.isOff,
    required this.sessions,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      date: json['date'] ?? '',
      dayName: json['day_name'] ?? '',
      isWorking: json['is_working'] ?? false,
      isOff: json['is_off'] ?? false,
      sessions: (json['sessions'] as List? ?? [])
          .map((e) => DaySessionEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DaySessionEntry {
  final DaySessionInfo session;
  final DayLocationInfo? location;

  DaySessionEntry({required this.session, this.location});

  factory DaySessionEntry.fromJson(Map<String, dynamic> json) {
    return DaySessionEntry(
      session: DaySessionInfo.fromJson(
          json['session'] as Map<String, dynamic>? ?? {}),
      location: json['location'] != null
          ? DayLocationInfo.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DaySessionInfo {
  final int id;
  final String name;
  final String checkIn;
  final String checkOut;
  final String? gracePeriod;
  final String? kind;
  final String hrsPerDay;
  final bool overtime;

  DaySessionInfo({
    required this.id,
    required this.name,
    required this.checkIn,
    required this.checkOut,
    this.gracePeriod,
    this.kind,
    required this.hrsPerDay,
    this.overtime = false,
  });

  String get timeRange {
    final ci = checkIn.length >= 5 ? checkIn.substring(0, 5) : checkIn;
    final co = checkOut.length >= 5 ? checkOut.substring(0, 5) : checkOut;
    return '$ci – $co';
  }

  factory DaySessionInfo.fromJson(Map<String, dynamic> json) {
    return DaySessionInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'] ?? '',
      gracePeriod: json['grace_p']?.toString(),
      kind: json['kind']?.toString(),
      hrsPerDay: (json['hrs_per_day'] ?? '0').toString(),
      overtime: json['ot']?.toString().toUpperCase() == 'Y',
    );
  }
}

class DayLocationInfo {
  final int id;
  final String name;

  DayLocationInfo({required this.id, required this.name});

  factory DayLocationInfo.fromJson(Map<String, dynamic> json) =>
      DayLocationInfo(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
      );
}

// ── Manager view models ──────────────────────────────────────────────────────

class ManagerWeeklyShiftScheduleResponse {
  final bool success;
  final String view;
  final String rangeStart;
  final String rangeEnd;
  final List<ManagerShiftEmployee> employees;

  ManagerWeeklyShiftScheduleResponse({
    required this.success,
    required this.view,
    required this.rangeStart,
    required this.rangeEnd,
    required this.employees,
  });

  factory ManagerWeeklyShiftScheduleResponse.fromJson(
      Map<String, dynamic> json) {
    return ManagerWeeklyShiftScheduleResponse(
      success: json['success'] ?? true,
      view: json['view'] ?? '',
      rangeStart: json['range_start'] ?? '',
      rangeEnd: json['range_end'] ?? '',
      employees: (json['employees'] as List? ?? [])
          .map((e) => ManagerShiftEmployee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ManagerShiftEmployee {
  final int id;
  final String employeeNo;
  final String name;
  final String? image;
  final List<DaySchedule> days;

  ManagerShiftEmployee({
    required this.id,
    required this.employeeNo,
    required this.name,
    this.image,
    required this.days,
  });

  factory ManagerShiftEmployee.fromJson(Map<String, dynamic> json) {
    return ManagerShiftEmployee(
      id: json['id'] ?? 0,
      employeeNo: json['employee_no'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] as String?,
      days: (json['days'] as List? ?? [])
          .map((e) => DaySchedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
