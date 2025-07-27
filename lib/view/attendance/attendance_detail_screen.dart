import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import '../../services/theme_service.dart';
import '../../data/remote/response/schedule_models.dart';
import '../schedule/schedule_controller.dart';
import 'attendance_calendar_screen.dart';
import 'weekly_attendance_controller.dart';
import 'widgets/weekly_attendance_table.dart';

class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({super.key});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  late WeeklyAttendanceController weeklyController;

  @override
  void initState() {
    super.initState();
    weeklyController = Get.put(WeeklyAttendanceController());
  }

  @override
  void dispose() {
    Get.delete<WeeklyAttendanceController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr('attendance_detail'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const AttendanceCalendarScreen());
            },
            icon: Icon(
              Icons.table_chart,
              color: themeService.getPrimaryColor(),
            ),
            tooltip: tr('weekly_attendance'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCompactScheduleSection(),
            Container(
              margin: const EdgeInsets.all(16),
              child: Obx(() => WeeklyAttendanceTable(
                attendanceData: weeklyController.currentWeekData,
                weekPeriod: weeklyController.currentWeekPeriod.value,
                isLoading: weeklyController.isLoading.value,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactScheduleSection() {
    final scheduleController = Get.put(ScheduleController());
    final themeService = ThemeService.instance;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Schedule Cards with Horizontal Scroll
          Obx(() {
            if (scheduleController.isLoading.value) {
              return _buildLoadingCard(); // You can keep this as-is or adjust its height if needed
            }

            if (scheduleController.availableSchedules.isEmpty) {
              return _buildEmptyCard(); // Same here
            }

            return SizedBox(
              height: MediaQuery.of(Get.context!).size.height * 0.2, // Responsive height (~38% of screen)
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: scheduleController.availableSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = scheduleController.availableSchedules[index];
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildScheduleCard(schedule, scheduleController, index),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    final themeService = ThemeService.instance;
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2, color: themeService.getVioletStart()),
            const SizedBox(height: 6),
            Text(
              tr('loading'),
              style: TextStyle(fontSize: 9, color: themeService.getTextSecondaryColor()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard() {
    final themeService = ThemeService.instance;
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 48, color: themeService.getTextSecondaryColor()),
            const SizedBox(height: 12),
            Text(
              tr('no_schedules_available'),
              style: TextStyle(fontSize: 14, color: themeService.getTextSecondaryColor()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleTemplate schedule, ScheduleController controller, int index) {
    final themeService = ThemeService.instance;
    final isSelected = controller.selectedTemplateIndex.value == index;

    return Container(
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? themeService.getVioletStart() : themeService.getDividerColor(),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.selectScheduleTemplate(index),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        schedule.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: themeService.getVioletStart(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Grace + OT
                Row(
                  children: [
                    Icon(Icons.timer, size: 14, color: themeService.getWarningColor()),
                    const SizedBox(width: 4),
                    Text(
                      '${tr('grace')}: ${schedule.gracePeriod}${tr('minutes')}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: themeService.getWarningColor(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      schedule.overtime == 'Y' ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: schedule.overtime == 'Y'
                          ? themeService.getSuccessColor()
                          : themeService.getErrorColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tr('overtime')}: ${schedule.overtime == 'Y' ? tr('yes') : tr('no')}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: schedule.overtime == 'Y'
                            ? themeService.getSuccessColor()
                            : themeService.getErrorColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Time Range
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: themeService.getVioletStart()),
                    const SizedBox(width: 4),
                    Text(
                      '${schedule.workSchedule.formattedStartTime} - ${schedule.workSchedule.formattedEndTime}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: themeService.getVioletStart(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Working Days
                _buildWorkingDaysSection(schedule),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkingDaysSection(ScheduleTemplate schedule) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: schedule.workSchedule.workDays.map((workDay) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 3),
            child: _buildDayCheckbox(workDay),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCheckbox(WorkDay workDay) {
    final themeService = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: workDay.isWorking
            ? themeService.getSuccessColor().withOpacity(0.1)
            : themeService.getErrorColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: workDay.isWorking
              ? themeService.getSuccessColor().withOpacity(0.3)
              : themeService.getErrorColor().withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            workDay.isWorking ? Icons.check_box : Icons.check_box_outline_blank,
            size: 12,
            color: workDay.isWorking
                ? themeService.getSuccessColor()
                : themeService.getErrorColor(),
          ),
          const SizedBox(height: 2),
          Text(
            tr(workDay.shortName.toLowerCase()),
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: workDay.isWorking
                  ? themeService.getSuccessColor()
                  : themeService.getErrorColor(),
            ),
          ),
        ],
      ),
    );
  }
}
