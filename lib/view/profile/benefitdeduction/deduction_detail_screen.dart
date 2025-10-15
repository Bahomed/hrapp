import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.injazatsoftware.injazathr/view/profile/benefitdeduction/deduction_detail_controller.dart';
import 'package:com.injazatsoftware.injazathr/utils/translation_helper.dart';
import 'package:com.injazatsoftware.injazathr/utils/responsive_utils.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/response/deductions_response.dart';
import '../../../services/theme_service.dart';

class DeductionDetailScreen extends StatelessWidget {
  const DeductionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeductionDetailController());
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
          tr('deduction_details'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: themeService.getPrimaryColor()),
            onPressed: controller.refreshDeductions,
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
          onRefresh: controller.refreshDeductions,
          color: themeService.getPrimaryColor(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummarySection(context, controller, themeService),

                const SizedBox(height: 24),

                // Deductions List
                _buildDeductionsSection(context, controller, themeService),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummarySection(BuildContext context, DeductionDetailController controller, ThemeService themeService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('deduction_summary'),
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            fontWeight: FontWeight.w700,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(height: 16),

        // Summary Cards Grid
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                tr('total_amount'),
                controller.totalDeductionAmount,
                Icons.payments,
                themeService.getErrorColor(),
                themeService,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                tr('amount_paid'),
                controller.totalDeductionAmountPaid,
                Icons.check_circle,
                themeService.getSuccessColor(),
                themeService,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Balance Card (Full Width)
        _buildBalanceCard(context, controller, themeService),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, DeductionDetailController controller, ThemeService themeService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeService.getWarningColor(),
            themeService.getWarningColor().withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeService.getWarningColor().withValues(alpha: 0.3),
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
              Icon(Icons.pending_actions, color: Colors.white.withValues(alpha: 0.9), size: 28),
              const SizedBox(width: 12),
              Text(
                tr('balance_remaining'),
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${controller.totalDeductionAmountTobePaid} SAR',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 32, tablet: 36, desktop: 40),
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color, ThemeService themeService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
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
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
                    color: themeService.getTextSecondaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$value SAR',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
              fontWeight: FontWeight.w700,
              color: themeService.getTextPrimaryColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionsSection(BuildContext context, DeductionDetailController controller, ThemeService themeService) {
    if (controller.userDeductions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: themeService.getSuccessColor(),
              ),
              const SizedBox(height: 16),
              Text(
                tr('no_deductions_found'),
                style: TextStyle(
                  fontSize: 16,
                  color: themeService.getTextSecondaryColor(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('deductions_breakdown'),
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            fontWeight: FontWeight.w700,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(height: 16),

        ...controller.userDeductions.map((deduction) => _buildDeductionCard(context, deduction, themeService)),
      ],
    );
  }

  Widget _buildDeductionCard(BuildContext context, UserDeduction deduction, ThemeService themeService) {
    final deductionName = deduction.deductionName;
    final amount = deduction.amount.toString();
    final installmentAmount = deduction.installmentAmt;
    final noOfInstallments = deduction.noOfInstallment.toString();
    final totalAmountPaid = deduction.totAmtPaid.toString();
    final balance = deduction.balance.toString();
    final startDate = deduction.startDate ?? tr('not_specified');
    final settlementDate = deduction.settlementDate ?? tr('not_specified');

    final isPaid = deduction.balance <= 0;
    final statusColor = isPaid ? themeService.getSuccessColor() : themeService.getWarningColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: statusColor,
            size: 24,
          ),
        ),
        title: Text(
          deductionName,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
            fontWeight: FontWeight.w600,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        subtitle: Text(
          isPaid ? tr('paid') : tr('pending'),
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
            color: statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$amount SAR',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.w700,
                color: themeService.getErrorColor(),
              ),
            ),
            if (!isPaid)
              Text(
                '${tr('balance')}: $balance',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 10, tablet: 11, desktop: 12),
                  fontWeight: FontWeight.w500,
                  color: themeService.getWarningColor(),
                ),
              ),
          ],
        ),
        children: [
          const Divider(),
          const SizedBox(height: 12),
          _buildDetailRow(context, tr('total_amount'), '$amount SAR', themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('amount_paid'), '$totalAmountPaid SAR', themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('balance'), '$balance SAR', themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('installment_amount'), '$installmentAmount SAR', themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('number_of_installments'), noOfInstallments, themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('start_date'), startDate, themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('settlement_date'), settlementDate, themeService),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, ThemeService themeService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
            color: themeService.getTextSecondaryColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
              color: themeService.getTextPrimaryColor(),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}