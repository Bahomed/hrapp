import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/remote/response/schedule_models.dart';
import '../../repository/schedule_repository.dart';

class ScheduleController extends GetxController {
  final ScheduleRepository _repository = ScheduleRepository();

  final RxBool isLoading = false.obs;
  final Rx<ScheduleTemplate?> currentSchedule = Rx<ScheduleTemplate?>(null);
  final RxList<ScheduleTemplate> availableSchedules = <ScheduleTemplate>[].obs;
  final RxInt selectedTemplateIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
  }

  // Load schedule templates from the API
  Future<void> loadSchedules() async {
    try {
      isLoading.value = true;
      final templates = await _repository.getScheduleTemplates();
      if (templates.isNotEmpty) {
        availableSchedules.assignAll(templates);
        currentSchedule.value = templates.first;
      } else {
        _showErrorSnackbar('No schedules available');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading schedules: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Select schedule by index
  void selectScheduleTemplate(int index) {
    if (index >= 0 && index < availableSchedules.length) {
      selectedTemplateIndex.value = index;
      currentSchedule.value = availableSchedules[index];
    }
  }

  // Get ordered days (Sunday to Saturday)
  List<WorkDay> get orderedWorkDays {
    final schedule = currentSchedule.value?.workSchedule;
    if (schedule == null) return [];
    final orderedDays = <WorkDay>[];

    for (final day in DayOfWeek.values) {
      final workDay = schedule.workDays.firstWhere(
            (wd) => wd.dayOfWeek == day,
        orElse: () => WorkDay(dayOfWeek: day, isWorking: false),
      );
      orderedDays.add(workDay);
    }

    return orderedDays;
  }

  // Time summary
  String get workingHoursSummary {
    final schedule = currentSchedule.value?.workSchedule;
    return schedule != null
        ? '${schedule.formattedStartTime} - ${schedule.formattedEndTime}'
        : '--';
  }

  // Weekly total hours
  int get totalWeeklyHours {
    final schedule = currentSchedule.value?.workSchedule;
    if (schedule == null) return 0;
    final workingDays = orderedWorkDays.where((d) => d.isWorking).length;
    return workingDays * schedule.totalHours;
  }

  // Number of working days
  int get workingDaysCount {
    return orderedWorkDays.where((d) => d.isWorking).length;
  }

  // Is today a working day?
  bool get isTodayWorkingDay {
    final schedule = currentSchedule.value?.workSchedule;
    if (schedule == null) return false;
    final todayEnum = _convertWeekdayToDayOfWeek(DateTime.now().weekday);
    return schedule.isWorkingDay(todayEnum);
  }

  // Next working day name
  String get nextWorkingDay {
    final schedule = currentSchedule.value?.workSchedule;
    if (schedule == null) return '--';
    final today = DateTime.now();

    for (int i = 1; i <= 7; i++) {
      final nextDate = today.add(Duration(days: i));
      final nextDayEnum = _convertWeekdayToDayOfWeek(nextDate.weekday);
      if (schedule.isWorkingDay(nextDayEnum)) {
        final day = orderedWorkDays.firstWhere((d) => d.dayOfWeek == nextDayEnum);
        return day.displayName;
      }
    }

    return 'No working day found';
  }

  // Current status (working/off)
  String get scheduleStatus {
    final schedule = currentSchedule.value?.workSchedule;
    if (schedule == null) return '--';
    if (!isTodayWorkingDay) return 'Off day - Next working day: $nextWorkingDay';

    final now = DateTime.now();
    final start = _parseTime(schedule.startTime);
    final end = _parseTime(schedule.endTime);

    if (now.isBefore(start)) {
      return 'Work starts at ${schedule.formattedStartTime}';
    } else if (now.isAfter(end)) {
      return 'Work day ended';
    } else {
      return 'Currently working';
    }
  }

  // Weekday mapping
  DayOfWeek _convertWeekdayToDayOfWeek(int weekday) {
    switch (weekday) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      case 7:
      default:
        return DayOfWeek.sunday;
    }
  }

  // Time parser
  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  // Day color (UI)
  Color getDayColor(WorkDay workDay) {
    if (!workDay.isWorking) return const Color(0xFFE0E0E0);

    final todayEnum = _convertWeekdayToDayOfWeek(DateTime.now().weekday);
    if (workDay.dayOfWeek == todayEnum) return const Color(0xFF4CAF50);

    return const Color(0xFF42A5F5);
  }

  // Day text color (UI)
  Color getDayTextColor(WorkDay workDay) {
    return workDay.isWorking ? Colors.white : const Color(0xFF757575);
  }

  // Refresh data
  void refreshSchedule() {
    loadSchedules();
    _showSuccessSnackbar('Schedule refreshed');
  }

  // Show details dialog
  void showScheduleDetails() {
    final schedule = currentSchedule.value;
    if (schedule == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(schedule.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(schedule.description, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Text('Working Hours: $workingHoursSummary', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Total Hours/Week: $totalWeeklyHours hours', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Working Days: $workingDaysCount days', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Success toast
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Error toast
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
