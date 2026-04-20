import 'package:co.injazathr.injazathr/view/holidayscreen/holidayscreencontroller.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/language_service.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HolidayScreenController());
    final themeService = ThemeService.instance;

    return Column(
      children: [
        _buildFilterSection(context, controller),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.filteredholidaylist.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredholidaylist.isEmpty) {
              return _buildEmptyState(context, controller);
            }

            return _buildHolidaysList(context, controller);
          }),
        ),
      ],
    );
  }

  Widget _buildFilterSection(BuildContext context, HolidayScreenController controller) {
    final themeService = ThemeService.instance;
    
    return Container(
      padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 16, tablet: 20, desktop: 24)
          .add(ResponsiveUtils.responsiveVerticalPadding(context, mobile: 12, tablet: 14, desktop: 16)),
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
          children: [
            // Upcoming filter
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 16,
                      color: controller.selectedFilter.value == 'upcoming' 
                          ? themeService.getSuccessColor() 
                          : themeService.getTextSecondaryColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(tr('upcoming')),
                  ],
                ),
                selected: controller.selectedFilter.value == 'upcoming',
                onSelected: (_) => controller.filterByType('upcoming'),
                backgroundColor: themeService.getSurfaceColor(),
                selectedColor: themeService.getSuccessColor().withOpacity(0.2),
                checkmarkColor: themeService.getSuccessColor(),
                labelStyle: TextStyle(
                  color: controller.selectedFilter.value == 'upcoming' 
                      ? themeService.getSuccessColor() 
                      : themeService.getTextSecondaryColor(),
                  fontWeight: controller.selectedFilter.value == 'upcoming' ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: controller.selectedFilter.value == 'upcoming' 
                      ? themeService.getSuccessColor() 
                      : themeService.getTextSecondaryColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            // Past filter
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: 16,
                      color: controller.selectedFilter.value == 'past' 
                          ? themeService.getTextSecondaryColor() 
                          : themeService.getTextSecondaryColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(tr('past')),
                  ],
                ),
                selected: controller.selectedFilter.value == 'past',
                onSelected: (_) => controller.filterByType('past'),
                backgroundColor: themeService.getSurfaceColor(),
                selectedColor: themeService.getTextSecondaryColor().withOpacity(0.2),
                checkmarkColor: themeService.getTextSecondaryColor(),
                labelStyle: TextStyle(
                  color: themeService.getTextSecondaryColor(),
                  fontWeight: controller.selectedFilter.value == 'past' ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: controller.selectedFilter.value == 'past' 
                      ? themeService.getTextSecondaryColor() 
                      : themeService.getTextSecondaryColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildHolidaysList(BuildContext context, HolidayScreenController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshHolidays,
      child: Obx(() {
        final items = controller.filteredholidaylist;
        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        return ListView.builder(
          controller: controller.controller,
          padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 16, tablet: 20, desktop: 24),
          itemCount: items.length + (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final holiday = items[index];
            final isUpcoming = holiday.toDate.isAfter(today) || holiday.toDate.isAtSameMomentAs(today);
            return _buildHolidayCard(holiday, isUpcoming, ThemeService.instance);
          },
        );
      }),
    );
  }

  Widget _buildHolidayCard(dynamic holiday, bool isUpcoming, ThemeService themeService) {
    final statusColor = isUpcoming
        ? themeService.getSuccessColor()
        : themeService.getWarningColor();
    final days = holiday.toDate.difference(holiday.fromDate).inDays + 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUpcoming ? Icons.event_available : Icons.history,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      holiday.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUpcoming ? tr('upcoming') : tr('past'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd').format(holiday.fromDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM').format(holiday.fromDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, y').format(holiday.fromDate),
                      style: TextStyle(
                        fontSize: 13,
                        color: themeService.getTextSecondaryColor(),
                      ),
                    ),
                    Text(
                      '${LanguageService.instance.isRTL() ? '←' : '→'} ${DateFormat('MMM d, y').format(holiday.toDate)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: themeService.getTextSecondaryColor(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  '$days ${tr('days')}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HolidayScreenController controller) {
    final themeService = ThemeService.instance;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: themeService.getTextSecondaryColor().withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            controller.selectedFilter.value == 'upcoming'
                ? tr('no_upcoming_holidays')
                : tr('no_past_holidays'),
            style: TextStyle(
              fontSize: 16,
              color: themeService.getTextSecondaryColor(),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}