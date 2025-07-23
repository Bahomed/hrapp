import 'package:get/get.dart';
import '../../data/remote/response/weekly_attendance_response.dart';
import '../../repository/attendancerepository.dart';

class WeeklyAttendanceController extends GetxController {
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  // Reactive variables
  final RxList<WeeklyAttendanceItem> currentWeekData = <WeeklyAttendanceItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentWeekPeriod = ''.obs;
  final Rx<DateTime> selectedWeekStart = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentWeekData();
  }

  void loadCurrentWeekData() {
    final now = DateTime.now();
    final startOfWeek = _getStartOfWeek(now);
    final endOfWeek = _getEndOfWeek(startOfWeek);
    
    selectedWeekStart.value = startOfWeek;
    loadWeekData(startOfWeek, endOfWeek);
  }

  void loadWeekData(DateTime startDate, DateTime endDate) async {
    try {
      isLoading.value = true;
      
      // Update week period display
      currentWeekPeriod.value = _formatWeekPeriod(startDate, endDate);
      
      // Call API
      final response = await _attendanceRepository.getWeeklyAttendance(
        startDate: _formatDateForAPI(startDate),
        endDate: _formatDateForAPI(endDate),
      );
      
      if (response.success) {
        currentWeekData.assignAll(response.data);
      } else {
        _showErrorMessage('Failed to load attendance data');
        currentWeekData.clear();
      }
    } catch (e) {
      _showErrorMessage('Error loading attendance data: $e');
      currentWeekData.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void loadPreviousWeek() {
    final previousWeekStart = selectedWeekStart.value.subtract(const Duration(days: 7));
    final previousWeekEnd = _getEndOfWeek(previousWeekStart);
    
    selectedWeekStart.value = previousWeekStart;
    loadWeekData(previousWeekStart, previousWeekEnd);
  }

  void loadNextWeek() {
    final nextWeekStart = selectedWeekStart.value.add(const Duration(days: 7));
    final nextWeekEnd = _getEndOfWeek(nextWeekStart);
    
    selectedWeekStart.value = nextWeekStart;
    loadWeekData(nextWeekStart, nextWeekEnd);
  }

  void refreshCurrentWeek() {
    final startOfWeek = selectedWeekStart.value;
    final endOfWeek = _getEndOfWeek(startOfWeek);
    loadWeekData(startOfWeek, endOfWeek);
  }

  // Helper methods
  DateTime _getStartOfWeek(DateTime date) {
    // Get Monday as start of week
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  DateTime _getEndOfWeek(DateTime startOfWeek) {
    return startOfWeek.add(const Duration(days: 6));
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatWeekPeriod(DateTime start, DateTime end) {
    final startStr = '${start.day}/${start.month}/${start.year}';
    final endStr = '${end.day}/${end.month}/${end.year}';
    return '$startStr - $endStr';
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }

  // Getters for summary data
  int get totalPresentDays => currentWeekData.where((item) => 
      item.status.toLowerCase() == 'present').length;

  int get totalAbsentDays => currentWeekData.where((item) => 
      item.status.toLowerCase() == 'absent').length;

  int get totalLateDays => currentWeekData.where((item) => 
      item.status.toLowerCase() == 'late').length;

  String get weeklyAttendancePercentage {
    if (currentWeekData.isEmpty) return '0%';
    final percentage = (totalPresentDays / currentWeekData.length * 100);
    return '${percentage.toStringAsFixed(1)}%';
  }

  bool get canGoToNextWeek {
    final nextWeekStart = selectedWeekStart.value.add(const Duration(days: 7));
    final today = DateTime.now();
    return nextWeekStart.isBefore(today) || nextWeekStart.isAtSameMomentAs(today);
  }
}