import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/remote/response/weekly_attendance_response.dart';
import '../../../services/theme_service.dart';
import '../../../utils/app_theme.dart';
import '../weekly_attendance_controller.dart';

class WeeklyAttendanceTable extends StatelessWidget {
  final RxList<WeeklyAttendanceItem> attendanceData;
  final String weekPeriod;
  final bool isLoading;

  const WeeklyAttendanceTable({
    super.key,
    required this.attendanceData,
    required this.weekPeriod,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Obx(() => Container(
      decoration: BoxDecoration(
        color: ThemeService.instance.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeService.instance.isDarkMode 
                ? Colors.black.withOpacity(0.3)
                : AppTheme.getActionColor('attendance').withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Navigation
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              children: [
                // Title and Days Count Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weekly Attendance',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w700,
                              color: ThemeService.instance.getTextPrimaryColor(),
                            ),
                          ),
                          if (weekPeriod.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              weekPeriod,
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                color: ThemeService.instance.getTextSecondaryColor(),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.getActionColor('attendance').withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.getActionColor('attendance'),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${attendanceData.length} days',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.getActionColor('attendance'),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Week Navigation Controls
                _buildWeekNavigationCard(),
              ],
            ),
          ),

          // Table Content
          if (isLoading)
            _buildLoadingState()
          else if (attendanceData.isEmpty)
            _buildEmptyState()
          else
            _buildTable(isTablet),
        ],
      ),
    ));
  }

  Widget _buildTable(bool isTablet) {
    return Column(
      children: [
        _buildTableHeader(),
        ...attendanceData.map((item) => _buildTableRow(item)),
        //_buildSummaryRow(),
        _buildTotalsFooter(),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getActionColor('attendance').withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'Date',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'In',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Out',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Hours',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Penalty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Overtime',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(WeeklyAttendanceItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: ThemeService.instance.getTextSecondaryColor().withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Date Column
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.formattedDate,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
                Text(
                  item.dayName,
                  style: TextStyle(
                    fontSize: 8,
                    color: ThemeService.instance.getTextSecondaryColor(),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Status Column
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: _buildStatusChip(item.status),
            ),
          ),
          
          // Time In Column
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                item.formattedTimeIn,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.getTextPrimaryColor(),
                ),
              ),
            ),
          ),
          
          // Time Out Column
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                item.formattedTimeOut,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.getTextPrimaryColor(),
                ),
              ),
            ),
          ),
          
          // Working Hours Column
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                item.workingHours,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.getTextPrimaryColor(),
                ),
              ),
            ),
          ),
          
          // Penalty Column
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                item.penalty,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
          ),
          
          // Overtime Column
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                item.overtime,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'present':
        backgroundColor = AppTheme.successColor.withOpacity(0.1);
        textColor = AppTheme.successColor;
        icon = Icons.check_circle_outline;
        break;
      case 'absent':
        backgroundColor = AppTheme.errorColor.withOpacity(0.1);
        textColor = AppTheme.errorColor;
        icon = Icons.cancel_outlined;
        break;
      case 'late':
        backgroundColor = AppTheme.warningColor.withOpacity(0.1);
        textColor = AppTheme.warningColor;
        icon = Icons.access_time;
        break;
      default:
        backgroundColor = AppTheme.textSecondary.withOpacity(0.1);
        textColor = AppTheme.textSecondary;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: textColor),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 8,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    if (attendanceData.isEmpty) return const SizedBox.shrink();

    final presentDays = attendanceData.where((item) => 
        item.status.toLowerCase() == 'present').length;
    final totalDays = attendanceData.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getActionColor('attendance').withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: ThemeService.instance.getTextSecondaryColor().withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Text(
              'Weekly Summary',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.getActionColor('attendance'),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                '$presentDays/$totalDays Days Present',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getActionColor('attendance'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsFooter() {
    if (attendanceData.isEmpty) return const SizedBox.shrink();

    // Calculate totals
    double totalHours = 0.0;
    double totalPenalty = 0.0;
    double totalOvertime = 0.0;

    for (final item in attendanceData) {
      // Calculate working hours from timeIn and timeOut
      if (item.timeIn.isNotEmpty && item.timeOut.isNotEmpty) {
        try {
          final inTime = _parseTime(item.timeIn);
          final outTime = _parseTime(item.timeOut);
          
          if (inTime != null && outTime != null) {
            final difference = outTime.difference(inTime);
            final hours = difference.inMinutes / 60.0;
            totalHours += hours;
          }
        } catch (e) {
          // Handle parsing errors
        }
      }

      // Use penaltyAmount field for penalty total
      totalPenalty += item.penaltyAmount;

      // Parse overtime amount from overtimeAmount field
      final overtimeValue = double.tryParse(item.overtimeAmount.toString()) ?? 0.0;
      totalOvertime += overtimeValue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.getActionColor('attendance').withOpacity(0.15),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Date Column - "TOTAL" label
          Expanded(
            flex: 1,
            child: Text(
              'TOTAL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.getActionColor('attendance'),
              ),
            ),
          ),
          
          // Status Column - Empty
          const Expanded(flex: 1, child: SizedBox()),
          
          // Time In Column - Empty
          const Expanded(flex: 1, child: SizedBox()),
          
          // Time Out Column - Empty
          const Expanded(flex: 1, child: SizedBox()),
          
          // Total Hours Column
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '${totalHours.toStringAsFixed(1)}h',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getActionColor('attendance'),
                ),
              ),
            ),
          ),
          
          // Total Penalty Column
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '${totalPenalty.toStringAsFixed(1)}h',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.errorColor,
                ),
              ),
            ),
          ),
          
          // Total Overtime Column
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '${totalOvertime.toStringAsFixed(1)}h',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.successColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: AppTheme.getActionColor('attendance'),
              strokeWidth: 2,
            ),
            const SizedBox(height: 12),
            Text(
              'Loading attendance data...',
              style: TextStyle(
                fontSize: 14,
                color: ThemeService.instance.getTextSecondaryColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: ThemeService.instance.getTextSecondaryColor().withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No attendance data available',
            style: TextStyle(
              fontSize: 14,
              color: ThemeService.instance.getTextSecondaryColor().withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigationCard() {
    final controller = Get.find<WeeklyAttendanceController>();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getActionColor('attendance').withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getActionColor('attendance').withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Previous Week Button
          _buildNavButton(
            icon: Icons.chevron_left,
            onPressed: controller.loadPreviousWeek,
            tooltip: 'Previous Week',
          ),
          
          const SizedBox(width: 12),
          
          // Current Week Button
          Expanded(
            child: _buildNavButton(
              icon: Icons.today,
              label: 'Current Week',
              onPressed: controller.loadCurrentWeekData,
              tooltip: 'Go to Current Week',
              isPrimary: true,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Refresh Button
          _buildNavButton(
            icon: Icons.refresh,
            onPressed: controller.refreshCurrentWeek,
            tooltip: 'Refresh Data',
          ),
          
          const SizedBox(width: 12),
          
          // Next Week Button
          Obx(() => _buildNavButton(
            icon: Icons.chevron_right,
            onPressed: controller.canGoToNextWeek ? controller.loadNextWeek : null,
            tooltip: 'Next Week',
            isDisabled: !controller.canGoToNextWeek,
          )),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    String? label,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isPrimary = false,
    bool isDisabled = false,
  }) {
    final color = isDisabled 
        ? ThemeService.instance.getTextSecondaryColor().withOpacity(0.3)
        : isPrimary 
            ? AppTheme.getActionColor('attendance')
            : ThemeService.instance.getTextSecondaryColor();
    
    final backgroundColor = isPrimary 
        ? AppTheme.getActionColor('attendance').withOpacity(0.1)
        : Colors.transparent;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: label != null ? 12 : 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              if (label != null) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  DateTime? _parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      }
    } catch (e) {
      // Handle parsing errors
    }
    return null;
  }
}