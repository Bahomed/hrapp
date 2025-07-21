import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'schedule_controller.dart';
import '../../data/remote/response/schedule_models.dart';
import '../../services/theme_service.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScheduleController());
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
          tr('schedule'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: themeService.getPrimaryColor()),
            onPressed: controller.refreshSchedule,
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: themeService.getPrimaryColor()),
            onPressed: controller.showScheduleDetails,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: themeService.getPrimaryColor(),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshSchedule(),
          color: themeService.getPrimaryColor(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Schedule Selector
                _buildScheduleSelector(controller),

                const SizedBox(height: 20),

                // Schedule Header
                _buildScheduleHeader(controller),

                const SizedBox(height: 30),

                // Working Hours Summary
                _buildWorkingHoursSummary(controller),

                const SizedBox(height: 30),

                // Weekly Schedule
                _buildWeeklySchedule(controller),

                const SizedBox(height: 30),

                // Schedule Status
                _buildScheduleStatus(controller),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildScheduleSelector(ScheduleController controller) {
    final themeService = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeService.getVioletStart().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.swap_horiz,
                  color: themeService.getVioletStart(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                tr('my_schedule'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Schedule options
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.availableSchedules.length,
              itemBuilder: (context, index) {
                final schedule = controller.availableSchedules[index];
                final isSelected = controller.selectedTemplateIndex.value == index;

                return Container(
                  width: 200,
                  margin: EdgeInsets.only(right: index < controller.availableSchedules.length - 1 ? 12 : 0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => controller.selectScheduleTemplate(index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? themeService.getVioletStart().withValues(alpha: 0.1)
                              : themeService.getBackgroundColor(),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? themeService.getVioletStart()
                                : themeService.getDividerColor(),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.check_circle : Icons.schedule,
                                  color: isSelected
                                      ? themeService.getVioletStart()
                                      : themeService.getTextSecondaryColor(),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    schedule.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? themeService.getVioletStart()
                                          : themeService.getTextPrimaryColor(),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            Expanded(
                              child: Text(
                                schedule.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: themeService.getTextSecondaryColor(),
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 10,
                                  color: themeService.getTextSecondaryColor(),
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    '${schedule.workSchedule.formattedStartTime} - ${schedule.workSchedule.formattedEndTime}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: themeService.getTextSecondaryColor(),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleHeader(ScheduleController controller) {
    final themeService = ThemeService.instance;
    final currentSchedule = controller.currentSchedule.value;
    
    if (currentSchedule == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: themeService.getVioletGradient(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: themeService.getVioletStart().withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No schedule selected',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeService.getSilver(),
            ),
          ),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: themeService.getVioletGradient(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeService.getVioletStart().withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeService.getSilver().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule,
                  color: themeService.getSilver(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSchedule.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: themeService.getSilver(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentSchedule.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeService.getSilver().withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Working Hours',
                  controller.workingHoursSummary,
                  Icons.access_time,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Working Days',
                  '${controller.workingDaysCount} days',
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Weekly Hours',
                  '${controller.totalWeeklyHours}h',
                  Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    final themeService = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeService.getSilver().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: themeService.getSilver(), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: themeService.getSilver(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: themeService.getSilver().withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursSummary(ScheduleController controller) {
    final themeService = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeService.getSuccessColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color: themeService.getSuccessColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Working Hours',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Time Display
          Center(
            child: Column(
              children: [
                Text(
                  controller.workingHoursSummary,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: themeService.getSuccessColor(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${controller.currentSchedule.value?.workSchedule.totalHours} hours per day',
                  style: TextStyle(
                    fontSize: 14,
                    color: themeService.getTextSecondaryColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule(ScheduleController controller) {
    final themeService = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeService.getWarningColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_view_week,
                  color: themeService.getWarningColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Weekly Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Days Grid
          ...controller.orderedWorkDays.map((workDay) =>
            _buildDayItem(controller, workDay)
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(ScheduleController controller, workDay) {
    final themeService = ThemeService.instance;
    final dayColor = controller.getDayColor(workDay);
    final textColor = controller.getDayTextColor(workDay);
    final isToday = _isToday(workDay, controller);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dayColor,
        borderRadius: BorderRadius.circular(12),
        border: isToday ? Border.all(
          color: themeService.getSuccessColor(),
          width: 2,
        ) : null,
      ),
      child: Row(
        children: [
          // Day Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              workDay.isWorking ? Icons.work : Icons.weekend,
              color: textColor,
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          // Day Name
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workDay.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (isToday)
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),

          // Status
          Expanded(
            flex: 3,
            child: Text(
              workDay.isWorking
                  ? controller.workingHoursSummary
                  : 'Off Day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),

          // Status Icon
          const SizedBox(width: 8),
          Icon(
            workDay.isWorking ? Icons.check_circle : Icons.cancel,
            color: textColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStatus(ScheduleController controller) {
    final themeService = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: controller.isTodayWorkingDay
              ? [themeService.getSuccessColor().withValues(alpha: 0.1), themeService.getSuccessColor().withValues(alpha: 0.05)]
              : [themeService.getWarningColor().withValues(alpha: 0.1), themeService.getWarningColor().withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: controller.isTodayWorkingDay
              ? themeService.getSuccessColor().withValues(alpha: 0.3)
              : themeService.getWarningColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.isTodayWorkingDay
                      ? themeService.getSuccessColor().withValues(alpha: 0.2)
                      : themeService.getWarningColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  controller.isTodayWorkingDay ? Icons.work : Icons.weekend,
                  color: controller.isTodayWorkingDay
                      ? themeService.getSuccessColor()
                      : themeService.getWarningColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            controller.scheduleStatus,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: themeService.getTextPrimaryColor(),
            ),
          ),

          if (!controller.isTodayWorkingDay) ...[
            const SizedBox(height: 12),
            Text(
              'Enjoy your day off!',
              style: TextStyle(
                fontSize: 14,
                color: themeService.getTextSecondaryColor(),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isToday(workDay, ScheduleController controller) {
    final today = DateTime.now().weekday;
    final todayEnum = _convertWeekdayToDayOfWeek(today);
    return controller.isTodayWorkingDay && workDay.dayOfWeek == todayEnum;
  }

  _convertWeekdayToDayOfWeek(int weekday) {
    switch (weekday) {
      case 1: return DayOfWeek.monday;
      case 2: return DayOfWeek.tuesday;
      case 3: return DayOfWeek.wednesday;
      case 4: return DayOfWeek.thursday;
      case 5: return DayOfWeek.friday;
      case 6: return DayOfWeek.saturday;
      case 7: return DayOfWeek.sunday;
      default: return DayOfWeek.monday;
    }
  }
}