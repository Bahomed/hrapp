import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/data/remote/response/benefits_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/deductions_response.dart';
import 'package:co.injazathr.injazathr/widgets/saudi_riyal_display.dart';
import '../../services/theme_service.dart';
import './benefitdeduction/benefit_detail_controller.dart';
import './benefitdeduction/deduction_detail_controller.dart';
import 'deduction_history_dialog.dart';

class CompensationScreen extends StatelessWidget {
  const CompensationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final benefitController = Get.put(BenefitDetailController());
    final deductionController = Get.put(DeductionDetailController());
    final themeService = ThemeService.instance;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: themeService.getBackgroundColor(),
        appBar: AppBar(
          backgroundColor: themeService.getCardColor(),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            tr('compensation'),
            style: TextStyle(
              color: themeService.getTextPrimaryColor(),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            labelColor: themeService.getPrimaryColor(),
            unselectedLabelColor: themeService.getTextSecondaryColor(),
            indicatorColor: themeService.getPrimaryColor(),
            tabs: [
              Tab(
                icon: Icon(Icons.card_giftcard),
                text: tr('benefit_details'),
              ),
              Tab(
                icon: Icon(Icons.remove_circle_outline),
                text: tr('deduction_details'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Benefits Tab
            _buildBenefitsTab(context, benefitController, themeService),
            // Deductions Tab
            _buildDeductionsTab(context, deductionController, themeService),
          ],
        ),
      ),
    );
  }

  // BENEFITS TAB
  Widget _buildBenefitsTab(BuildContext context, BenefitDetailController controller, ThemeService themeService) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: themeService.getPrimaryColor(),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshBenefits,
        color: themeService.getPrimaryColor(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Section
              _buildBenefitsSummary(context, controller, themeService),
              const SizedBox(height: 24),
              // Earnings List
              _buildEarningsSection(context, controller, themeService),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBenefitsSummary(BuildContext context, BenefitDetailController controller, ThemeService themeService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('salary_summary'),
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            fontWeight: FontWeight.w700,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                themeService.getPrimaryColor(),
                themeService.getPrimaryColor().withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: themeService.getPrimaryColor().withValues(alpha: 0.3),
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
                  Icon(Icons.account_balance_wallet, color: Colors.white.withValues(alpha: 0.9), size: 28),
                  const SizedBox(width: 12),
                  Text(
                    tr('total_salary'),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SaudiRiyalDisplay(
                amount: double.tryParse(controller.totalSalary) ?? 0.0,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 32, tablet: 36, desktop: 40),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsSection(BuildContext context, BenefitDetailController controller, ThemeService themeService) {
    if (controller.earnings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.inbox, size: 64, color: themeService.getTextSecondaryColor()),
              const SizedBox(height: 16),
              Text(
                tr('no_earnings_found'),
                style: TextStyle(fontSize: 16, color: themeService.getTextSecondaryColor()),
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
          tr('earnings_breakdown'),
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            fontWeight: FontWeight.w700,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(height: 16),
        ...controller.earnings.map((earning) => _buildEarningCard(context, earning, themeService)).toList(),
      ],
    );
  }

  Widget _buildEarningCard(BuildContext context, Earning earning, ThemeService themeService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: themeService.getSuccessColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.account_balance_wallet, color: themeService.getSuccessColor(), size: 24),
        ),
        title: Text(
          earning.benefit,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
            fontWeight: FontWeight.w600,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        subtitle: Text(
          earning.paymentSchemeLabel,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
            color: themeService.getTextSecondaryColor(),
          ),
        ),
        trailing: SaudiRiyalDisplay(
          amount: earning.benefitAmt.toDouble(),
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
            fontWeight: FontWeight.w700,
            color: themeService.getSuccessColor(),
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 12),
          _buildDetailRow(context, tr('payment_scheme'), earning.paymentSchemeLabel, themeService),
          //const SizedBox(height: 8),
          //_buildDetailRow(context, tr('use_factor'), earning.useFactor.toString(), themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('effectivity_date'), earning.effectivityDateG ?? tr('not_specified'), themeService),
        ],
      ),
    );
  }

  // DEDUCTIONS TAB
  Widget _buildDeductionsTab(BuildContext context, DeductionDetailController controller, ThemeService themeService) {
    return Obx(() {
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
              // Summary Section
              _buildDeductionsSummary(context, controller, themeService),
              const SizedBox(height: 24),
              // Deductions List
              _buildDeductionsSection(context, controller, themeService),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDeductionsSummary(BuildContext context, DeductionDetailController controller, ThemeService themeService) {
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
        Container(
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
              SaudiRiyalDisplay(
                amount: double.tryParse(controller.totalDeductionAmountTobePaid) ?? 0.0,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 32, tablet: 36, desktop: 40),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, IconData icon, Color color, ThemeService themeService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
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
          SaudiRiyalDisplay(
            amount: double.tryParse(value) ?? 0.0,
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
              Icon(Icons.check_circle_outline, size: 64, color: themeService.getSuccessColor()),
              const SizedBox(height: 16),
              Text(
                tr('no_deductions_found'),
                style: TextStyle(fontSize: 16, color: themeService.getTextSecondaryColor()),
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
    final isPaid = deduction.balance <= 0;
    final statusColor = isPaid ? themeService.getSuccessColor() : themeService.getWarningColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
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
          child: Icon(isPaid ? Icons.check_circle : Icons.pending, color: statusColor, size: 24),
        ),
        title: Text(
          deduction.deductionName,
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
            SaudiRiyalDisplay(
              amount: deduction.amount.toDouble(),
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.w700,
                color: themeService.getErrorColor(),
              ),
            ),
            if (!isPaid)
              SaudiRiyalDisplay(
                customText: '${tr('balance')}: ${deduction.balance}',
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
          _buildDetailRowWithAmount(context, tr('total_amount'), deduction.amount, themeService),
          const SizedBox(height: 8),
          _buildDetailRowWithAmount(context, tr('amount_paid'), deduction.totAmtPaid, themeService),
          const SizedBox(height: 8),
          _buildDetailRowWithAmount(context, tr('balance'), deduction.balance, themeService),
          const SizedBox(height: 8),
          _buildDetailRowWithAmount(context, tr('installment_amount'), double.tryParse(deduction.installmentAmt) ?? 0.0, themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('number_of_installments'), deduction.noOfInstallment.toString(), themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('start_date'), deduction.startDate ?? tr('not_specified'), themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('settlement_date'), deduction.settlementDate ?? tr('not_specified'), themeService),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDeductionHistoryDialog(
                  deduction.id,
                  deduction.deductionName,
                );
              },
              icon: const Icon(Icons.history),
              label: Text(tr('view_history', fallback: 'View History')),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeService.getPrimaryColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
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

  Widget _buildDetailRowWithAmount(BuildContext context, String label, double amount, ThemeService themeService) {
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
          child: SaudiRiyalDisplay(
            amount: amount,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
              color: themeService.getTextPrimaryColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}