enum DayOfWeek { sunday, monday, tuesday, wednesday, thursday, friday, saturday }

class WorkSchedule {
  final String startTime;
  final String endTime;
  final int totalHours;
  final List<WorkDay> workDays;

  WorkSchedule({
    required this.startTime,
    required this.endTime,
    required this.totalHours,
    required this.workDays,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      startTime: json['start_time'] ?? '08:00:00',
      endTime: json['end_time'] ?? '17:00:00',
      totalHours: json['total_hours'] ?? 8,
      workDays: (json['work_days'] as List?)
          ?.map((day) => WorkDay.fromJson(day))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'total_hours': totalHours,
      'work_days': workDays.map((day) => day.toJson()).toList(),
    };
  }

  // Helper methods
  String get formattedStartTime => _formatTime(startTime);
  String get formattedEndTime => _formatTime(endTime);

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  bool isWorkingDay(DayOfWeek day) {
    return workDays.any((workDay) => workDay.dayOfWeek == day && workDay.isWorking);
  }

  int get workingDaysCount => workDays.where((day) => day.isWorking).length;
}

class WorkDay {
  final DayOfWeek dayOfWeek;
  final bool isWorking;
  final String? customStartTime;
  final String? customEndTime;
  final String? notes;

  WorkDay({
    required this.dayOfWeek,
    required this.isWorking,
    this.customStartTime,
    this.customEndTime,
    this.notes,
  });

  factory WorkDay.fromJson(Map<String, dynamic> json) {
    return WorkDay(
      dayOfWeek: DayOfWeek.values.firstWhere(
            (day) => day.toString().split('.').last == json['day_of_week'],
        orElse: () => DayOfWeek.sunday,
      ),
      isWorking: json['is_working'] ?? false,
      customStartTime: json['custom_start_time'],
      customEndTime: json['custom_end_time'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day_of_week': dayOfWeek.toString().split('.').last,
      'is_working': isWorking,
      'custom_start_time': customStartTime,
      'custom_end_time': customEndTime,
      'notes': notes,
    };
  }

  String get displayName {
    switch (dayOfWeek) {
      case DayOfWeek.sunday:
        return 'Sunday';
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
    }
  }

  String get shortName {
    switch (dayOfWeek) {
      case DayOfWeek.sunday:
        return 'Sun';
      case DayOfWeek.monday:
        return 'Mon';
      case DayOfWeek.tuesday:
        return 'Tue';
      case DayOfWeek.wednesday:
        return 'Wed';
      case DayOfWeek.thursday:
        return 'Thu';
      case DayOfWeek.friday:
        return 'Fri';
      case DayOfWeek.saturday:
        return 'Sat';
    }
  }
}

class ScheduleTemplate {
  final String id;
  final String name;
  final String description;
  final String gracePeriod;
  final String overtime;
  final WorkSchedule workSchedule;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleTemplate({
    required this.id,
    required this.name,
    this.description = '',
    required this.gracePeriod,
    required this.overtime,
    required this.workSchedule,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleTemplate.fromJson(Map<String, dynamic> json) {
    return ScheduleTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      gracePeriod: json['grace_period'] ?? '0',
      overtime: json['overtime'] ?? 'N',
      workSchedule: WorkSchedule.fromJson(json['work_schedule'] ?? {}),
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'grace_period': gracePeriod,
      'overtime': overtime,
      'work_schedule': workSchedule.toJson(),
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
