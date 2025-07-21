import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/data/remote/response/payroll_records_response.dart';
import 'package:injazat_hr_app/data/remote/response/payroll_summary_response.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import 'package:injazat_hr_app/utils/screen_themes.dart';
import 'package:injazat_hr_app/view/payroll/payroll_controller.dart';
import 'package:saudi_riyal_symbol/saudi_riyal_symbol.dart';

class PayrollStatusChip extends StatelessWidget {
  final String status;

  const PayrollStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'processed':
      case 'approved':
        backgroundColor = AppTheme.successColor.withOpacity(0.1);
        textColor = AppTheme.successColor;
        text = 'Processed';
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
        backgroundColor = AppTheme.warningColor.withOpacity( 0.1);
        textColor = AppTheme.warningColor;
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case 'failed':
      case 'rejected':
        backgroundColor = AppTheme.errorColor.withOpacity( 0.1);
        textColor = AppTheme.errorColor;
        text = 'Failed';
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = AppTheme.textSecondary.withOpacity( 0.1);
        textColor = AppTheme.textSecondary;
        text = 'Unknown';
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PayrollCard extends StatelessWidget {
  final PayrollRecordResponseData record;

  const PayrollCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayrollController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.viewPayrollDetails(record),
          borderRadius: BorderRadius.circular(16),
          child: ScreenThemes.buildPayrollCard(
            context: context,
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.period, // Using period as formattedPeriod
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${record.month} ${record.year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              PayrollStatusChip(status: record.status),
            ],
          ),

          const SizedBox(height: 20),

          // Amount Section
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  context,
                  'Gross Pay',
                  SaudiCurrencySymbol(
                    price: record.totalBenefits,
                    priceStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    symbolFontSize: 14,
                  ),
                  AppTheme.successColor,
                  AppTheme.successColor.withOpacity( 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  context,
                  'Deductions',
                  SaudiCurrencySymbol(
                    price: record.totalDeductions,
                    priceStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    symbolFontSize: 14,
                  ),
                  AppTheme.errorColor,
                  AppTheme.errorColor.withOpacity( 0.1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAmountCard(
                  context,
                  'Net Pay',
                  SaudiCurrencySymbol(
                    price: record.netSalary,
                    priceStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    symbolFontSize: 14,
                  ),
                  AppTheme.getActionColor('payroll'),
                  AppTheme.getActionColor('payroll').withOpacity( 0.1),
                ),
              ),
            ],
          ),

          if (record.status.toLowerCase() == 'processed') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity( 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Paid on ${record.paymentDate}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity( 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity( 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap to view details',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity( 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ] else if (record.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppTheme.warningColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Expected payment: ${record.paymentDate}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.warningColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context, String title, Widget amount, Color textColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withOpacity( 0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          amount,
        ],
      ),
    );
  }
}

class PayrollSummaryCard extends StatelessWidget {
  final PayrollSummaryResponseData summary;

  const PayrollSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.getActionColor('payroll'), AppTheme.getActionColor('payroll').withOpacity( 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getActionColor('payroll').withOpacity( 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Year to Date Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity( 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${summary.totalPayslips} payslips',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Gross Earnings',
                  SaudiCurrencySymbol(
                    price: summary.totalGrossEarnings,
                    priceStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
                    symbolFontSize: 16,
                    symbolFontColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  'Total Deductions',
                  SaudiCurrencySymbol(
                    price: summary.totalDeductions,
                    priceStyle: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700),
                    symbolFontSize: 16,
                    symbolFontColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity( 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Net Earnings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SaudiCurrencySymbol(
                  price: summary.netEarnings,
                  priceStyle: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700),
                  symbolFontSize: 20,
                  symbolFontColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, Widget amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity( 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        amount,
      ],
    );
  }
}

class EmptyPayrollState extends StatelessWidget {
  final String message;

  const EmptyPayrollState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity( 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity( 0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              final controller = Get.find<PayrollController>();
              controller.refreshPayrollData();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getActionColor('payroll'),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class PayrollYearSelector extends StatelessWidget {
  const PayrollYearSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayrollController>();

    return Obx(() => GestureDetector(
          onTap: controller.showYearPicker,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 100),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.getActionColor('payroll')),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getActionColor('payroll').withOpacity( 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppTheme.getActionColor('payroll'),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    controller.selectedYear.value,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.getActionColor('payroll'),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: AppTheme.getActionColor('payroll'),
                ),
              ],
            ),
          ),
        ));
  }
}