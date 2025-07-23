import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
<<<<<<< HEAD
import '../../services/theme_service.dart';
import '../../data/remote/response/schedule_models.dart';
import '../schedule/schedule_controller.dart';
import 'weekly_attendance_controller.dart';
import 'widgets/weekly_attendance_table.dart';
=======
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604

class AttendanceDetailScreen extends StatefulWidget {
  const AttendanceDetailScreen({super.key});

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
<<<<<<< HEAD
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
=======
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();

  // Sample attendance data - replace with real data from your API
  final Map<DateTime, List<AttendanceEntry>> attendanceData = {
    DateTime(2024, 1, 15): [
      AttendanceEntry('Clock In', '09:00 AM', Icons.login, const Color(0xFF4CAF50)),
      AttendanceEntry('Break Start', '12:00 PM', Icons.pause_circle, const Color(0xFF2196F3)),
      AttendanceEntry('Break End', '01:00 PM', Icons.play_circle, const Color(0xFF9C27B0)),
      AttendanceEntry('Clock Out', '06:00 PM', Icons.logout, const Color(0xFFFF9800)),
    ],
    DateTime(2024, 1, 16): [
      AttendanceEntry('Clock In', '08:45 AM', Icons.login, const Color(0xFF4CAF50)),
      AttendanceEntry('Clock Out', '05:30 PM', Icons.logout, const Color(0xFFFF9800)),
    ],
    DateTime.now(): [
      AttendanceEntry('Clock In', '09:15 AM', Icons.login, const Color(0xFF4CAF50)),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          tr('attendance_calendar'),
          style: const TextStyle(
            color: Colors.black,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
<<<<<<< HEAD
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
=======
      body: Column(
        children: [
          // Calendar Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Calendar Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          focusedDate = DateTime(focusedDate.year, focusedDate.month - 1);
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      _getMonthYearString(focusedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          focusedDate = DateTime(focusedDate.year, focusedDate.month + 1);
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Days of week
                Row(
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Calendar Grid
                _buildCalendarGrid(),
              ],
            ),
          ),
          
          // Selected Date Attendance Details
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance for ${_getDateString(selectedDate)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildAttendanceList(),
                  ),
                ],
              ),
            ),
          ),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        ],
      ),
    );
  }

<<<<<<< HEAD


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
=======
  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(focusedDate.year, focusedDate.month, 1);
    final lastDayOfMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42, // 6 weeks
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        final isCurrentMonth = date.month == focusedDate.month;
        final isSelected = _isSameDay(date, selectedDate);
        final hasAttendance = attendanceData.containsKey(DateTime(date.year, date.month, date.day));
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFF00BCD4)
                  : (hasAttendance ? const Color(0xFF00BCD4).withOpacity(0.1) : null),
              borderRadius: BorderRadius.circular(8),
              border: hasAttendance && !isSelected
                  ? Border.all(color: const Color(0xFF00BCD4), width: 1)
                  : null,
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isCurrentMonth ? Colors.black : Colors.grey),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceList() {
    final dateKey = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final entries = attendanceData[dateKey] ?? [];
    
    if (entries.isEmpty) {
      return const Center(
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
<<<<<<< HEAD
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
=======
              Icons.event_busy,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No attendance records for this date',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
              ),
            ),
          ],
        ),
<<<<<<< HEAD
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
=======
      );
    }
    
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: entry.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: entry.color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: entry.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  entry.icon,
                  color: entry.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.action,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      entry.time,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getDateString(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class AttendanceEntry {
  final String action;
  final String time;
  final IconData icon;
  final Color color;

  AttendanceEntry(this.action, this.time, this.icon, this.color);
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
}