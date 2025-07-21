import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../repository/attendancerepository.dart';
import '../../data/remote/response/attendance_response.dart';
import '../../utils/translation_helper.dart';
import '../../utils/app_theme.dart';
import '../../services/theme_service.dart';

class AttendanceCalendarController extends GetxController {
  final AttendanceRepository _attendanceRepository = AttendanceRepository();
  
  // Reactive variables
  final RxList<AttendanceEntry> attendanceEntries = <AttendanceEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Calendar state
  final RxInt currentMonth = DateTime.now().month.obs;
  final RxInt currentYear = DateTime.now().year.obs;
  
  // Attendance counts
  final RxInt presentDays = 0.obs;
  final RxInt absentDays = 0.obs;
  final RxInt halfDayAbsentDays = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadAttendanceData();
  }
  
  /// Load attendance data for current month/year
  Future<void> loadAttendanceData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _attendanceRepository.getUserAttendanceByMonthYear(
        currentMonth.value,
        currentYear.value,
      );
      
      if (response.success) {
        attendanceEntries.assignAll(response.data);
        _calculateAttendanceCounts();
      } else {
        errorMessage.value = response.message.isNotEmpty ? response.message : 'Failed to load attendance data';
        _showErrorSnackbar(tr('error'), errorMessage.value);
      }
    } catch (e) {
      final errorMsg = e.toString();
      errorMessage.value = errorMsg;
      _showErrorSnackbar(tr('error'), tr('failed_to_load_attendance_data'));
      // Use debugPrint instead of print for better logging
      debugPrint('Error loading attendance data: $errorMsg');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Calculate attendance counts for summary
  void _calculateAttendanceCounts() {
    presentDays.value = attendanceEntries.where((entry) => entry.isPresent).length;
    absentDays.value = attendanceEntries.where((entry) => entry.isAbsent).length;
    halfDayAbsentDays.value = attendanceEntries.where((entry) => entry.isHalfDayAbsent).length;
  }
  
  /// Get attendance status for a specific date
  String getAttendanceStatusForDate(DateTime date) {
    final entry = attendanceEntries.firstWhereOrNull(
      (entry) => entry.date.day == date.day && 
                 entry.date.month == date.month && 
                 entry.date.year == date.year,
    );
    
    return entry?.status ?? 'No_Data';
  }
  
  /// Get color for attendance status
  Color getColorForStatus(String status) {
    final themeService = Get.find<ThemeService>();
    switch (status) {
      case 'Absent':
        return themeService.getErrorColor();
      case 'Half_Day_Absent':
        return themeService.getWarningColor();
      case 'Present':
        return themeService.getSuccessColor();
      default:
        return themeService.getDividerColor();
    }
  }
  
  /// Get color for a specific date
  Color getColorForDate(DateTime date) {
    final status = getAttendanceStatusForDate(date);
    return getColorForStatus(status);
  }
  
  /// Check if date has attendance data
  bool hasAttendanceData(DateTime date) {
    return attendanceEntries.any(
      (entry) => entry.date.day == date.day && 
                 entry.date.month == date.month && 
                 entry.date.year == date.year,
    );
  }
  
  /// Navigate to previous month
  void goToPreviousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value--;
    } else {
      currentMonth.value--;
    }
    loadAttendanceData();
  }
  
  /// Navigate to next month
  void goToNextMonth() {
    if (currentMonth.value == 12) {
      currentMonth.value = 1;
      currentYear.value++;
    } else {
      currentMonth.value++;
    }
    loadAttendanceData();
  }
  
  /// Navigate to specific month/year
  void goToMonthYear(int month, int year) {
    currentMonth.value = month;
    currentYear.value = year;
    loadAttendanceData();
  }
  
  /// Refresh attendance data
  Future<void> refreshAttendanceData() async {
    await loadAttendanceData();
  }
  
  /// Get month name
  String getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
  
  /// Get formatted month/year string
  String getFormattedMonthYear() {
    return '${getMonthName(currentMonth.value)} ${currentYear.value}';
  }
  
  /// Show error snackbar
  void _showErrorSnackbar(String title, String message) {
    final themeService = Get.find<ThemeService>();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: themeService.getErrorColor(),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
  
}