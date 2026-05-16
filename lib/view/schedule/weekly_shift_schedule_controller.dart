import 'dart:async';

import 'package:get/get.dart';

import '../../data/remote/response/weekly_shift_schedule_response.dart';
import '../../repository/shift_schedule_repository.dart';

class WeeklyShiftScheduleController extends GetxController {
  final ShiftScheduleRepository _repo = ShiftScheduleRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DaySchedule> days = <DaySchedule>[].obs;

  // 'today' | 'weekly' | 'monthly'
  final RxString viewMode = 'weekly'.obs;

  final Rx<DateTime> weekStart = DateTime.now().obs;
  final Rx<DateTime> monthAnchor = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _setCurrentWeek();
    fetchData();
  }

  // ──────────────────────────────────────────────
  // View mode
  // ──────────────────────────────────────────────

  void setView(String mode) {
    viewMode.value = mode;
    if (mode == 'weekly') _setCurrentWeek();
    if (mode == 'monthly') {
      monthAnchor.value = DateTime(DateTime.now().year, DateTime.now().month);
    }
    fetchData();
  }

  void goToToday() {
    viewMode.value = 'today';
    fetchData();
  }

  // ──────────────────────────────────────────────
  // Week navigation
  // ──────────────────────────────────────────────

  void _setCurrentWeek() {
    final now = DateTime.now();
    final offset = now.weekday % 7;
    weekStart.value =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: offset));
  }

  DateTime get weekEnd => weekStart.value.add(const Duration(days: 6));

  List<DateTime> get weekDates =>
      List.generate(7, (i) => weekStart.value.add(Duration(days: i)));

  void goToPreviousWeek() {
    viewMode.value = 'weekly';
    weekStart.value = weekStart.value.subtract(const Duration(days: 7));
    fetchData();
  }

  void goToNextWeek() {
    viewMode.value = 'weekly';
    weekStart.value = weekStart.value.add(const Duration(days: 7));
    fetchData();
  }

  // ──────────────────────────────────────────────
  // Month navigation
  // ──────────────────────────────────────────────

  List<DateTime> get monthDates {
    final m = monthAnchor.value;
    final daysInMonth = DateTime(m.year, m.month + 1, 0).day;
    return List.generate(
        daysInMonth, (i) => DateTime(m.year, m.month, i + 1));
  }

  void goToPreviousMonth() {
    viewMode.value = 'monthly';
    final m = monthAnchor.value;
    monthAnchor.value = DateTime(m.year, m.month - 1);
    fetchData();
  }

  void goToNextMonth() {
    viewMode.value = 'monthly';
    final m = monthAnchor.value;
    monthAnchor.value = DateTime(m.year, m.month + 1);
    fetchData();
  }

  // ──────────────────────────────────────────────
  // Period label for nav row
  // ──────────────────────────────────────────────

  String get periodLabel {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (viewMode.value == 'today') {
      final now = DateTime.now();
      return '${months[now.month]} ${now.day}, ${now.year}';
    }
    if (viewMode.value == 'monthly') {
      final m = monthAnchor.value;
      return '${months[m.month]} ${m.year}';
    }
    // weekly
    final s = weekStart.value;
    final e = weekEnd;
    return '${months[s.month]} ${s.day} – ${months[e.month]} ${e.day} ${e.year}';
  }

  // ──────────────────────────────────────────────
  // Day lookup
  // ──────────────────────────────────────────────

  DaySchedule? getDaySchedule(DateTime date) {
    final dateStr = _fmt(date);
    try {
      return days.firstWhere((d) => d.date == dateStr);
    } catch (_) {
      return null;
    }
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ──────────────────────────────────────────────
  // Fetch
  // ──────────────────────────────────────────────

  Future<void> fetchData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final mode = viewMode.value;
      final response = await _repo.getSchedule(
        view: mode,
        weekStart: mode == 'weekly' ? _fmt(weekStart.value) : null,
        month: mode == 'monthly'
            ? '${monthAnchor.value.year}-${monthAnchor.value.month.toString().padLeft(2, '0')}'
            : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('No response from server. Please try again.'),
      );
      days.assignAll(response.days);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message ?? 'Request timed out. Please try again.';
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
