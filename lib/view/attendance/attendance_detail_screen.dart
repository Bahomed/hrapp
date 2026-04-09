import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../services/theme_service.dart';
import '../../data/remote/response/schedule_models.dart';
import '../schedule/schedule_controller.dart';
import 'attendance_calendar_screen.dart';
import 'weekly_attendance_controller.dart';
import 'widgets/weekly_attendance_table.dart';

class AttendanceDetailScreen extends StatefulWidget {
  final int? employeeId;
  
  const AttendanceDetailScreen({super.key, this.employeeId});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  late WeeklyAttendanceController weeklyController;

  @override
  void initState() {
    super.initState();
    weeklyController = Get.put(WeeklyAttendanceController());
    
    // Initialize with employee ID if provided, otherwise load current user data
    if (widget.employeeId != null) {
      weeklyController.initializeWithEmployeeId(widget.employeeId!);
    } else if (weeklyController.currentWeekData.isEmpty && !weeklyController.isLoading.value) {
      weeklyController.loadCurrentWeekData();
    }
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
          onPressed: () => Navigator.of(context).pop(),
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
              Get.to(() => AttendanceCalendarScreen(employeeId: widget.employeeId));
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
                onDateTap: () => _showDateRangePicker(),
                onPreviousWeek: weeklyController.loadPreviousWeek,
                onNextWeek: weeklyController.canGoToNextWeek ? weeklyController.loadNextWeek : null,
              )),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _showDateRangePicker() async {
    final themeService = ThemeService.instance;
    final now = DateTime.now();
    
    // Show custom date range dialog
    final DateTimeRange? picked = await _showCustomDateRangeDialog();

    if (picked != null) {
      // Use the exact selected date range (can be any number of days)
      weeklyController.selectedWeekStart.value = picked.start;
      weeklyController.loadWeekData(picked.start, picked.end);
    }
  }

  Future<DateTimeRange?> _showCustomDateRangeDialog() async {
    final themeService = ThemeService.instance;
    final now = DateTime.now();
    
    // Use the exact dates from the controller (what's actually being displayed)
    final currentStartDate = weeklyController.selectedWeekStart.value;
    final currentEndDate = weeklyController.selectedWeekEnd.value;
    
    DateTime? startDate = currentStartDate;
    DateTime? endDate = currentEndDate;

    return showDialog<DateTimeRange>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: themeService.getCardColor(),
              title: Text(
                tr('select_date_range'),
                style: TextStyle(
                  color: themeService.getTextPrimaryColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start Date
                  Text(
                    tr('start_date'),
                    style: TextStyle(
                      color: themeService.getTextSecondaryColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? now,
                        firstDate: DateTime(1998, 1, 1),
                        lastDate: now,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: themeService.getVioletStart(),
                                onPrimary: Colors.white,
                                surface: themeService.getCardColor(),
                                onSurface: themeService.getTextPrimaryColor(),
                              ),
                            ),
                            child: Localizations(
                              locale: const Locale('en', 'US'),
                              delegates: const [
                                DefaultMaterialLocalizations.delegate,
                                DefaultWidgetsLocalizations.delegate,
                              ],
                              child: child!,
                            ),
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                          // Don't auto-change end date, let user choose freely
                          // Only ensure end date is not before start date
                          if (endDate != null && endDate!.isBefore(picked)) {
                            endDate = picked;
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: themeService.getDividerColor()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            startDate != null
                                ? '${startDate!.day}-${startDate!.month}-${startDate!.year}'
                                : tr('select_start_date'),
                            style: TextStyle(
                              color: themeService.getTextPrimaryColor(),
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: themeService.getVioletStart(),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // End Date
                  Text(
                    tr('end_date'),
                    style: TextStyle(
                      color: themeService.getTextSecondaryColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      // Ensure initialDate is within valid range
                      DateTime initialEndDate = endDate ?? now;
                      if (initialEndDate.isAfter(now)) {
                        initialEndDate = now;
                      }
                      if (startDate != null && initialEndDate.isBefore(startDate!)) {
                        initialEndDate = startDate!;
                      }

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initialEndDate,
                        firstDate: startDate ?? DateTime(1998, 1, 1),
                        lastDate: now,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: themeService.getVioletStart(),
                                onPrimary: Colors.white,
                                surface: themeService.getCardColor(),
                                onSurface: themeService.getTextPrimaryColor(),
                              ),
                            ),
                            child: Localizations(
                              locale: const Locale('en', 'US'),
                              delegates: const [
                                DefaultMaterialLocalizations.delegate,
                                DefaultWidgetsLocalizations.delegate,
                              ],
                              child: child!,
                            ),
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: themeService.getDividerColor()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            endDate != null
                                ? '${endDate!.day}-${endDate!.month}-${endDate!.year}'
                                : tr('select_end_date'),
                            style: TextStyle(
                              color: themeService.getTextPrimaryColor(),
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: themeService.getVioletStart(),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    tr('cancel'),
                    style: TextStyle(color: themeService.getTextSecondaryColor()),
                  ),
                ),
                TextButton(
                  onPressed: startDate != null && endDate != null
                      ? () {
                          Navigator.of(context).pop(
                            DateTimeRange(start: startDate!, end: endDate!),
                          );
                        }
                      : null,
                  child: Text(
                    tr('ok'),
                    style: TextStyle(
                      color: startDate != null && endDate != null
                          ? themeService.getVioletStart()
                          : themeService.getTextSecondaryColor().withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Get Monday as start of week
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  Widget _buildCompactScheduleSection() {
    final scheduleController = Get.put(ScheduleController());
    final themeService = ThemeService.instance;
    
    // Initialize schedule controller with employee ID if provided
    if (widget.employeeId != null) {
      scheduleController.initializeWithEmployeeId(widget.employeeId!);
    } else if (scheduleController.availableSchedules.isEmpty && !scheduleController.isLoading.value) {
      scheduleController.loadSchedules();
    }

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
            ? themeService.getSuccessColor().withValues(alpha: 0.1)
            : themeService.getErrorColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: workDay.isWorking
              ? themeService.getSuccessColor().withValues(alpha: 0.3)
              : themeService.getErrorColor().withValues(alpha: 0.3),
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
