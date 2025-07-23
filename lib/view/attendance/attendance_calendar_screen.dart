import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/translation_helper.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_utils.dart';
import '../../services/theme_service.dart';
import 'attendance_calendar_controller.dart';
import 'attendance_detail_screen.dart';

class AttendanceCalendarScreen extends StatelessWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceCalendarController());
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          tr('attendance_calendar'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: themeService.getCardColor(),
        foregroundColor: themeService.getTextPrimaryColor(),
        elevation: 0,
        iconTheme: IconThemeData(
          color: themeService.getTextPrimaryColor(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const AttendanceDetailScreen());
            },
            icon: Icon(
              Icons.table_chart,
              color: themeService.getPrimaryColor(),
            ),
            tooltip: 'Weekly Attendance',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: themeService.getBackgroundColor(),
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: themeService.getPrimaryColor(),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.refreshAttendanceData,
            color: themeService.getPrimaryColor(),
            child: SingleChildScrollView(
              padding: ResponsiveUtils.responsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month/Year Header
                  _buildMonthYearHeader(context, controller),

                  SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

                  // Calendar
                  _buildCalendar(context, controller),

                  SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

                  // Legend
                  _buildLegend(context),

                  SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

                  // Attendance Summary
                  _buildAttendanceSummary(context, controller),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthYearHeader(
      BuildContext context, AttendanceCalendarController controller) {
    final themeService = ThemeService.instance;
    return Container(
      padding: ResponsiveUtils.responsivePadding(context),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: ResponsiveUtils.responsiveBorderRadius(context),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: controller.goToPreviousMonth,
            icon: Icon(Icons.chevron_left, color: themeService.getPrimaryColor()),
          ),
          Obx(() => Text(
            controller.getFormattedMonthYear(),
            style: TextStyle(
              color: themeService.getPrimaryColor(),
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
              fontWeight: FontWeight.w600,
            ),
          )),
          IconButton(
            onPressed: controller.goToNextMonth,
            icon: Icon(Icons.chevron_right, color: themeService.getPrimaryColor()),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
      BuildContext context, AttendanceCalendarController controller) {
    return Container(
      decoration: AppTheme.getCardDecoration(context),
      child: Obx(() => _buildCustomCalendar(context, controller)),
    );
  }

  Widget _buildCustomCalendar(
      BuildContext context, AttendanceCalendarController controller) {
    final firstDayOfMonth =
    DateTime(controller.currentYear.value, controller.currentMonth.value, 1);
    final lastDayOfMonth = DateTime(
        controller.currentYear.value, controller.currentMonth.value + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday, 1 = Monday, etc.

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Week day headers
          Row(
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ThemeService.instance.getTextSecondaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: (startingWeekday + daysInMonth),
            itemBuilder: (context, index) {
              if (index < startingWeekday) {
                return Container(); // Empty space before first day
              }

              final day = index - startingWeekday + 1;
              final date =
              DateTime(controller.currentYear.value, controller.currentMonth.value, day);
              final isToday = _isToday(date);

              return _buildCalendarDay(context, date, controller, isToday: isToday);
            },
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  Widget _buildCalendarDay(BuildContext context, DateTime day,
      AttendanceCalendarController controller, {bool isToday = false}) {
    final hasData = controller.hasAttendanceData(day);
    final themeService = ThemeService.instance;
    final color = hasData ? controller.getColorForDate(day) : themeService.getCardColor();
    final status = controller.getAttendanceStatusForDate(day);

    return Container(

      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isToday ? Theme.of(context).primaryColor: color,
        shape: BoxShape.circle,
        border: isToday 
            ? Border.all(color: Theme.of(context).primaryColor, width: 2) 
            : Border.all(color: themeService.getDividerColor(), width: 0.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                day.day.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isToday || hasData
                      ? Colors.white
                      : themeService.getTextPrimaryColor(),
                  fontWeight: hasData ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasData && status != 'Present')
              Flexible(
                child: Icon(
                  status == 'Absent' ? Icons.close : Icons.warning,
                  color: Colors.white,
                  size: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final themeService = ThemeService.instance;
    return Container(
      padding: ResponsiveUtils.responsivePadding(context),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: ResponsiveUtils.responsiveBorderRadius(context),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('legend'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                context: context,
                color: ThemeService.instance.getSuccessColor(),
                label: tr('present'),
                icon: Icons.check_circle,
              ),
              _buildLegendItem(
                context: context,
                color: ThemeService.instance.getWarningColor(),
                label: tr('half_day'),
                icon: Icons.warning,
              ),
              _buildLegendItem(
                context: context,
                color: ThemeService.instance.getErrorColor(),
                label: tr('absent'),
                icon: Icons.cancel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required BuildContext context,
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ThemeService.instance.getTextSecondaryColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceSummary(
      BuildContext context, AttendanceCalendarController controller) {
    final themeService = ThemeService.instance;
    return Container(
      padding: ResponsiveUtils.responsivePadding(context),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: ResponsiveUtils.responsiveBorderRadius(context),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('attendance_summary'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(() => _buildSummaryItem(
                context: context,
                color: ThemeService.instance.getSuccessColor(),
                count: controller.presentDays.value,
                label: tr('present_days'),
                icon: Icons.check_circle,
              )),
              Obx(() => _buildSummaryItem(
                context: context,
                color: ThemeService.instance.getWarningColor(),
                count: controller.halfDayAbsentDays.value,
                label: tr('half_days'),
                icon: Icons.warning,
              )),
              Obx(() => _buildSummaryItem(
                context: context,
                color: ThemeService.instance.getErrorColor(),
                count: controller.absentDays.value,
                label: tr('absent_days'),
                icon: Icons.cancel,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required Color color,
    required int count,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ThemeService.instance.getTextSecondaryColor(),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}