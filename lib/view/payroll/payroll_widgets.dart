import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/data/remote/response/payroll_records_response.dart';
import 'package:injazat_hr_app/data/remote/response/payroll_summary_response.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import 'package:injazat_hr_app/utils/screen_themes.dart';
import 'package:injazat_hr_app/view/payroll/payroll_controller.dart';
import 'package:injazat_hr_app/widgets/saudi_riyal_display.dart';
import '../../../services/theme_service.dart';

class PayrollStatusChip extends StatelessWidget {
  final String status;

  const PayrollStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenWidth < 400;
    
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
        backgroundColor = AppTheme.warningColor.withOpacity(0.1);
        textColor = AppTheme.warningColor;
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case 'failed':
      case 'rejected':
        backgroundColor = AppTheme.errorColor.withOpacity(0.1);
        textColor = AppTheme.errorColor;
        text = 'Failed';
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = AppTheme.textSecondary.withOpacity(0.1);
        textColor = AppTheme.textSecondary;
        text = 'Unknown';
        icon = Icons.circle;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : (isSmallScreen ? 8 : 10),
        vertical: isTablet ? 8 : (isSmallScreen ? 6 : 7),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: isTablet ? 16 : (isSmallScreen ? 12 : 14), 
            color: textColor,
          ),
          SizedBox(width: isTablet ? 6 : (isSmallScreen ? 4 : 5)),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: isTablet ? 14 : (isSmallScreen ? 11 : 12),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenWidth < 400;

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
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
                // Header Row - Stack on very small screens
                if (isSmallScreen && record.status.length > 8)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.period,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeService.instance.getTextPrimaryColor(),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${record.month} ${record.year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ThemeService.instance.getTextSecondaryColor(),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          PayrollStatusChip(status: record.status),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.period,
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w600,
                                color: ThemeService.instance.getTextPrimaryColor(),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${record.month} ${record.year}',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                color: ThemeService.instance.getTextSecondaryColor(),
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      PayrollStatusChip(status: record.status),
                    ],
                  ),

                SizedBox(height: isTablet ? 20 : 16),

                // Amount Section - Stack on mobile for better readability
                if (isTablet)
                  Row(
                    children: [
                      Expanded(
                        child: _buildAmountCard(
                          context,
                          'Gross Pay',
                          SaudiRiyalDisplay(
                            amount: record.totalBenefits,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 13,
                              fontWeight: FontWeight.w700,
                              color: ThemeService.instance.getTextPrimaryColor(),
                            ),
                          ),
                          AppTheme.successColor,
                          AppTheme.successColor.withOpacity(0.1),
                          isTablet: isTablet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAmountCard(
                          context,
                          'Deductions',
                          SaudiRiyalDisplay(
                            amount: record.totalDeductions,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 13,
                              fontWeight: FontWeight.w700,
                              color: ThemeService.instance.getTextPrimaryColor(),
                            ),
                          ),
                          AppTheme.errorColor,
                          AppTheme.errorColor.withOpacity(0.1),
                          isTablet: isTablet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAmountCard(
                          context,
                          'Net Pay',
                          SaudiRiyalDisplay(
                            amount: record.netSalary,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 13,
                              fontWeight: FontWeight.w700,
                              color: ThemeService.instance.getTextPrimaryColor(),
                            ),
                          ),
                          AppTheme.getActionColor('payroll'),
                          AppTheme.getActionColor('payroll').withOpacity(0.1),
                          isTablet: isTablet,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildAmountCard(
                              context,
                              'Gross Pay',
                              SaudiRiyalDisplay(
                                amount: record.totalBenefits,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeService.instance.getTextPrimaryColor(),
                                ),
                              ),
                              AppTheme.successColor,
                              AppTheme.successColor.withOpacity(0.1),
                              isTablet: false,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildAmountCard(
                              context,
                              'Deductions',
                              SaudiRiyalDisplay(
                                amount: record.totalDeductions,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeService.instance.getTextPrimaryColor(),
                                ),
                              ),
                              AppTheme.errorColor,
                              AppTheme.errorColor.withOpacity(0.1),
                              isTablet: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildAmountCard(
                        context,
                        'Net Pay',
                        SaudiRiyalDisplay(
                          amount: record.netSalary,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: ThemeService.instance.getTextPrimaryColor(),
                          ),
                        ),
                        AppTheme.getActionColor('payroll'),
                        AppTheme.getActionColor('payroll').withOpacity(0.1),
                        isTablet: false,
                        isNetPay: true,
                      ),
                    ],
                  ),

                if (record.status.toLowerCase() == 'processed') ...[
                  SizedBox(height: isTablet ? 16 : 12),
                  if (isTablet)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: ThemeService.instance.getTextSecondaryColor(),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Paid on ${record.paymentDate}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ThemeService.instance.getTextSecondaryColor(),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 16,
                              color: ThemeService.instance.getTextSecondaryColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to view details',
                              style: TextStyle(
                                fontSize: 12,
                                color: ThemeService.instance.getTextSecondaryColor(),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: ThemeService.instance.getTextSecondaryColor(),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            'Paid on ${record.paymentDate}',
                            style: TextStyle(
                              fontSize: 11,
                              color: ThemeService.instance.getTextSecondaryColor(),
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ] else if (record.status.toLowerCase() == 'pending') ...[
                  SizedBox(height: isTablet ? 16 : 12),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: isTablet ? 16 : 14,
                        color: AppTheme.warningColor,
                      ),
                      SizedBox(width: isTablet ? 4 : 3),
                      Expanded(
                        child: Text(
                          'Expected payment: ${record.paymentDate}',
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: AppTheme.warningColor,
                            fontWeight: FontWeight.w500,
                          ),
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

  Widget _buildAmountCard(
    BuildContext context, 
    String title, 
    Widget amount, 
    Color textColor, 
    Color backgroundColor, {
    bool isTablet = true,
    bool isNetPay = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isNetPay && !isTablet 
          ? Border.all(color: textColor.withOpacity(0.2), width: 1)
          : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isNetPay && !isTablet 
          ? CrossAxisAlignment.center 
          : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 10 : 9,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: isNetPay && !isTablet 
              ? TextAlign.center 
              : TextAlign.start,
          ),
          SizedBox(height: isTablet ? 4 : 2),
          Flexible(
            child: amount,
          ),
        ],
      ),
    );
  }
}

class PayrollSummaryTable extends StatelessWidget {
  final RxList<PayrollSummaryItem> summaryItems;

  const PayrollSummaryTable({super.key, required this.summaryItems});

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
                : AppTheme.getActionColor('payroll').withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isTablet)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payroll Summary',
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color: ThemeService.instance.getTextPrimaryColor(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.getActionColor('payroll').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 14,
                              color: AppTheme.getActionColor('payroll'),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${summaryItems.length} months',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getActionColor('payroll'),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Payroll Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ThemeService.instance.getTextPrimaryColor(),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.getActionColor('payroll').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 14,
                              color: AppTheme.getActionColor('payroll'),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${summaryItems.length} months',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getActionColor('payroll'),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          if (isTablet)
            Column(
              children: [
                _buildTableHeader(),
                if (summaryItems.isEmpty)
                  _buildEmptyState()
                else
                  ...summaryItems.map((item) => _buildTableRow(item)),
                if (summaryItems.isNotEmpty) _buildTotalRow(),
              ],
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: screenWidth - 32),
                child: IntrinsicWidth(
                  child: Column(
                    children: [
                      _buildTableHeader(),
                      if (summaryItems.isEmpty)
                        _buildEmptyState()
                      else
                        ...summaryItems.map((item) => _buildTableRow(item)),
                      if (summaryItems.isNotEmpty) _buildTotalRow(),
                    ],
                  ),
                ),
              ),
            ),

        ],
      ),
    ));
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(

        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Month',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Earnings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Deductions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Net Pay',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(PayrollSummaryItem item) {
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
          Expanded(
            flex: 2,
            child: Text(
              item.month.isNotEmpty ? item.month : 'N/A',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeService.instance.isDarkMode 
                  ? ThemeService.instance.getTextPrimaryColor()
                  : Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: SaudiRiyalDisplay(
                amount: item.totalEarnings,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.isDarkMode 
                    ? ThemeService.instance.getTextPrimaryColor()
                    : Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: SaudiRiyalDisplay(
                amount: item.totalDeductions,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.isDarkMode 
                    ? ThemeService.instance.getTextPrimaryColor()
                    : Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerRight,
              child: SaudiRiyalDisplay(
                amount: item.netPay,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.isDarkMode 
                    ? ThemeService.instance.getTextPrimaryColor()
                    : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    if (summaryItems.isEmpty) return const SizedBox.shrink();

    double totalEarnings = summaryItems.fold(0, (sum, item) => sum + (item.totalEarnings));
    double totalDeductions = summaryItems.fold(0, (sum, item) => sum + (item.totalDeductions));
    double totalNet = summaryItems.fold(0, (sum, item) => sum + (item.netPay));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.getActionColor('payroll').withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'TOTAL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.getActionColor('payroll'),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: SaudiRiyalDisplay(
                amount: totalEarnings,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.isDarkMode 
                    ? ThemeService.instance.getTextPrimaryColor()
                    : Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.center,
              child: SaudiRiyalDisplay(
                amount: totalDeductions,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.isDarkMode 
                    ? ThemeService.instance.getTextPrimaryColor()
                    : Colors.black87,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              alignment: Alignment.centerRight,
              child: SaudiRiyalDisplay(
                amount: totalNet,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getActionColor('payroll'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.table_view_outlined,
            size: 48,
            color: ThemeService.instance.getTextSecondaryColor().withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'No payroll data available',
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
}

class PayrollYearSelector extends StatelessWidget {
  const PayrollYearSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PayrollController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isSmallScreen = screenWidth < 400;

    return Obx(() => GestureDetector(
      onTap: controller.showYearPicker,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 100 : (isSmallScreen ? 80 : 90),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 12 : (isSmallScreen ? 8 : 10),
          vertical: isTablet ? 6 : (isSmallScreen ? 4 : 5),
        ),
        decoration: BoxDecoration(
          color: ThemeService.instance.getCardColor(),
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
          border: Border.all(color: AppTheme.getActionColor('payroll')),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getActionColor('payroll').withOpacity(0.1),
              blurRadius: isTablet ? 6 : 4,
              offset: Offset(0, isTablet ? 2 : 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: isTablet ? 14 : (isSmallScreen ? 12 : 13),
              color: AppTheme.getActionColor('payroll'),
            ),
            SizedBox(width: isTablet ? 6 : (isSmallScreen ? 4 : 5)),
            Flexible(
              child: Text(
                controller.selectedYear.value,
                style: TextStyle(
                  fontSize: isTablet ? 13 : (isSmallScreen ? 11 : 12),
                  color: AppTheme.getActionColor('payroll'),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: isTablet ? 2 : 1),
            Icon(
              Icons.keyboard_arrow_down,
              size: isTablet ? 14 : (isSmallScreen ? 12 : 13),
              color: AppTheme.getActionColor('payroll'),
            ),
          ],
        ),
      ),
    ));
  }
}