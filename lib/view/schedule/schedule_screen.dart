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
                // Schedule Templates Cards Only
                _buildScheduleSelector(controller),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeService.getVioletStart().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule,
                  color: themeService.getVioletStart(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Schedule Templates',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Schedule Templates Cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.availableSchedules.length,
          itemBuilder: (context, index) {
            final schedule = controller.availableSchedules[index];
            return _buildScheduleCard(schedule, controller, index);
          },
        ),
      ],
    );
  }

  Widget _buildScheduleCard(ScheduleTemplate schedule, ScheduleController controller, int index) {
    final themeService = ThemeService.instance;
    final isSelected = controller.selectedTemplateIndex.value == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? themeService.getVioletStart().withValues(alpha: 0.1)
                            : themeService.getTextSecondaryColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.schedule,
                        color: isSelected 
                            ? themeService.getVioletStart()
                            : themeService.getTextSecondaryColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isSelected 
                                  ? themeService.getVioletStart()
                                  : themeService.getTextPrimaryColor(),
                            ),
                          ),
                          if (schedule.isDefault)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: themeService.getSuccessColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: themeService.getSuccessColor(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Grace Period',
                        '${schedule.gracePeriod} min',
                        Icons.timer,
                        themeService.getWarningColor(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        'Overtime',
                        schedule.overtime == 'Y' ? 'Enabled' : 'Disabled',
                        schedule.overtime == 'Y' ? Icons.trending_up : Icons.trending_down,
                        schedule.overtime == 'Y' ? themeService.getSuccessColor() : themeService.getErrorColor(),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'Start Time',
                        schedule.workSchedule.formattedStartTime,
                        Icons.login,
                        themeService.getVioletStart(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        'End Time',
                        schedule.workSchedule.formattedEndTime,
                        Icons.logout,
                        themeService.getVioletEnd(),
                      ),
                    ),
                  ],
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

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    final themeService = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextSecondaryColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingDaysSection(ScheduleTemplate schedule) {
    final themeService = ThemeService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: themeService.getTextSecondaryColor(),
            ),
            const SizedBox(width: 6),
            Text(
              'Working Days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: schedule.workSchedule.workDays.map((workDay) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 4),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            size: 16,
            color: workDay.isWorking 
                ? themeService.getSuccessColor()
                : themeService.getErrorColor(),
          ),
          const SizedBox(height: 4),
          Text(
            workDay.shortName,
            style: TextStyle(
              fontSize: 10,
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