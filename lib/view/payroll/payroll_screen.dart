// File: lib/view/payroll/payroll_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/view/payroll/payroll_controller.dart';
import 'package:injazat_hr_app/view/payroll/payroll_widgets.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
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
        backgroundColor: themeService.getSurfaceColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr('payroll'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          const PayrollYearSelector(),
          const SizedBox(width: 20),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: themeService.getActionColor('payroll'),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshPayrollData,
          color: themeService.getActionColor('payroll'),
          child: CustomScrollView(
            slivers: [
              // Summary Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (controller.payrollSummary.isNotEmpty)
                        PayrollSummaryTable(summaryItems: controller.payrollSummary),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tr('payroll_history', fallback: 'Payroll History'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: themeService.getTextPrimaryColor(),
                            ),
                          ),
                          Text(
                            '${controller.payrollRecords.length} records',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeService.getTextSecondaryColor(),
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
                  //child: EmptyPayrollState(message: 'No payroll records found'),
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

}