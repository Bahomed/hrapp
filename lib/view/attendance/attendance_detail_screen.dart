import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import '../../services/theme_service.dart';
import '../../data/remote/response/schedule_models.dart';
import '../schedule/schedule_controller.dart';
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('attendance_detail'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Schedule Templates Section
            _buildCompactScheduleSection(),

            // Weekly Attendance Table
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
              return _buildLoadingCard();
            }

            if (scheduleController.availableSchedules.isEmpty) {
              return _buildEmptyCard();
            }

            return SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: scheduleController.availableSchedules.length,
                itemBuilder: (context, index) {
                  final schedule = scheduleController.availableSchedules[index];
                  return Container(
                    width: 300,
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
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: themeService.getVioletStart(),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 9,
                color: themeService.getTextSecondaryColor(),
              ),
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
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 48,
              color: themeService.getTextSecondaryColor().withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No schedules available',
              style: TextStyle(
                fontSize: 14,
                color: themeService.getTextSecondaryColor(),
              ),
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
          color: isSelected
              ? themeService.getVioletStart()
              : themeService.getDividerColor(),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.selectScheduleTemplate(index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - Single Line
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeService.getVioletStart().withValues(alpha: 0.1)
                            : themeService.getTextSecondaryColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),


                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        schedule.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? themeService.getVioletStart()
                              : themeService.getTextPrimaryColor(),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: themeService.getWarningColor()),
                        const SizedBox(width: 4),
                        Text(
                          'Grace: ${schedule.gracePeriod}min',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: themeService.getWarningColor(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          schedule.overtime == 'Y' ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: schedule.overtime == 'Y' ? themeService.getSuccessColor() : themeService.getErrorColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'OT: ${schedule.overtime == 'Y' ? 'Yes' : 'No'}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: schedule.overtime == 'Y' ? themeService.getSuccessColor() : themeService.getErrorColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Combined Time Display
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeService.getVioletStart().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: themeService.getVioletStart()),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${schedule.workSchedule.formattedStartTime} - ${schedule.workSchedule.formattedEndTime}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: themeService.getVioletStart(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

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
    final themeService = ThemeService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: schedule.workSchedule.workDays.map((workDay) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 3),
                child: _buildDayCheckbox(workDay),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDayCheckbox(WorkDay workDay) {
    final themeService = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: workDay.isWorking
            ? themeService.getSuccessColor().withValues(alpha: 0.1)
            : themeService.getErrorColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: workDay.isWorking
              ? themeService.getSuccessColor().withValues(alpha: 0.3)
              : themeService.getErrorColor().withValues(alpha: 0.3),
          width: 1,
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
            workDay.shortName,
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