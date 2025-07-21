// File: lib/view/payroll/payroll_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/view/payroll/payroll_controller.dart';
import 'package:injazat_hr_app/view/payroll/payroll_widgets.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import '../../services/theme_service.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PayrollController());
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr('payroll'),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          const PayrollYearSelector(),
          const SizedBox(width: 20),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Filter Buttons
                _buildFilterButtons(context, controller),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: ThemeService.instance.getActionColor('payroll'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPayrollData,
          color: ThemeService.instance.getActionColor('payroll'),
          child: CustomScrollView(
            slivers: [
              // Summary Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (controller.payrollSummary.value != null)
                        PayrollSummaryCard(summary: controller.payrollSummary.value!),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('payroll_history', fallback: 'Payroll History'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                          Text(
                            '${controller.payrollRecords.length} records',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity( 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Payroll Records List
              if (controller.payrollRecords.isEmpty)
                const SliverFillRemaining(
                  child: EmptyPayrollState(message: 'No payroll records found'),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final record = controller.payrollRecords[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          index == controller.payrollRecords.length - 1 ? 100 : 0,
                        ),
                        child: PayrollCard(record: record),
                      );
                    },
                    childCount: controller.payrollRecords.length,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterButtons(BuildContext context, PayrollController controller) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            final filterName = filter['name'] as String;
            final filterColor = filter['color'] as Color;
            final isSelected = controller.selectedFilter.value == filterName;

            return Container(
              constraints: const BoxConstraints(minWidth: 65, maxWidth: 90),
              margin: EdgeInsets.only(
                right: index < controller.filters.length - 1 ? 8 : 0,
              ),
              child: GestureDetector(
                onTap: () => controller.changeFilter(filterName),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? filterColor : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? filterColor : Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: filterColor.withOpacity( 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          controller.getFilterIcon(filterName),
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                      ],
                      Flexible(
                        child: Text(
                          filterName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : filterColor,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )),
    );
  }
}