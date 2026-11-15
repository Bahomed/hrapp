import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/widgets/saudi_riyal_display.dart';
import '../../services/theme_service.dart';
import 'compensation_controller.dart';
import 'deduction_history_dialog.dart';
import 'portal_ui.dart';

/// Contract & compensation of the signed-in user (`GET my/contract`).
class CompensationScreen extends StatelessWidget {
  const CompensationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompensationController());
    final themeService = ThemeService.instance;

    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Scaffold(
        backgroundColor: themeService.getBackgroundColor(),
        appBar: PortalUi.appBar(
          context,
          tr('compensation'),
          bottom: TabBar(
            labelColor: themeService.getPrimaryColor(),
            unselectedLabelColor: themeService.getTextSecondaryColor(),
            indicatorColor: themeService.getPrimaryColor(),
            tabs: [
              Tab(icon: const Icon(Icons.assignment_outlined), text: tr('contract')),
              Tab(icon: const Icon(Icons.card_giftcard), text: tr('benefit_details')),
              Tab(icon: const Icon(Icons.remove_circle_outline), text: tr('deduction_details')),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return PortalUi.loading();
          final err = controller.errorMessage.value;
          if (err != null) {
            return PortalUi.error(err, controller.load);
          }
          return TabBarView(
            children: [
              _tab(context, controller, [_buildContractsSection(context, controller, themeService)]),
              _tab(context, controller, [
                _buildBenefitsSummary(context, controller, themeService),
                const SizedBox(height: 24),
                _buildEarningsSection(context, controller, themeService),
                if (controller.gosi.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildGosiSection(context, controller, themeService),
                ],
              ]),
              _tab(context, controller, [
                _buildDeductionsSummary(context, controller, themeService),
                const SizedBox(height: 24),
                _buildDeductionsSection(context, controller, themeService),
              ]),
            ],
          );
        }),
      ),
    );
  }

  Widget _tab(BuildContext context, CompensationController controller, List<Widget> children) {
    return RefreshIndicator(
      onRefresh: controller.load,
      color: ThemeService.instance.getPrimaryColor(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [...children, const SizedBox(height: 100)],
        ),
      ),
    );
  }

  // ── CONTRACT TAB ──────────────────────────────────────────────────────

  Widget _buildContractsSection(BuildContext context, CompensationController controller, ThemeService themeService) {
    if (controller.contracts.isEmpty) {
      return SizedBox(
        height: 300,
        child: PortalUi.empty(tr('no_contract_found')),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PortalUi.sectionTitle(context, tr('contracts')),
        ...controller.contracts.map((c) => _buildContractCard(context, c, themeService)),
      ],
    );
  }

  Widget _buildContractCard(BuildContext context, Map<String, dynamic> c, ThemeService themeService) {
    final isCurrent = PortalUi.truthy(c['current']);
    final color = isCurrent ? themeService.getSuccessColor() : themeService.getTextSecondaryColor();
    String days(dynamic v) => v == null ? '-' : '${PortalUi.number(v)} ${tr('days')}';
    return PortalUi.card(
      borderColor: isCurrent ? color : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeService.getPrimaryColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.assignment_outlined, color: themeService.getPrimaryColor()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${tr('contract_no')} ${PortalUi.text(c['contract_no'])}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),
              ),
              if (isCurrent) PortalUi.chip(tr('current_contract'), color),
            ],
          ),
          const Divider(height: 24),
          PortalUi.row(context, tr('contract_type'), PortalUi.text(c['contract_type'])),
          PortalUi.row(context, tr('contract_term'), PortalUi.text(c['contract_term'])),
          PortalUi.row(context, tr('start_date'), PortalUi.date(c['start'])),
          PortalUi.row(context, tr('probation_end'), PortalUi.date(c['probation_end'])),
          PortalUi.row(context, tr('notice_period'), days(c['notice_days'])),
          PortalUi.row(context, tr('daily_hours'),
              c['daily_hours'] == null ? '-' : '${PortalUi.number(c['daily_hours'])} ${tr('hours')}'),
          PortalUi.row(context, tr('vacation_days'), days(c['vacation_days'])),
          PortalUi.row(context, tr('vacation_due'), PortalUi.text(c['vacation_due'])),
          PortalUi.row(context, tr('bank'), PortalUi.text(c['bank'])),
          PortalUi.row(context, tr('bank_account'), PortalUi.text(c['bank_account'])),
        ],
      ),
    );
  }

  // ── BENEFITS TAB ──────────────────────────────────────────────────────

  Widget _buildBenefitsSummary(BuildContext context, CompensationController controller, ThemeService themeService) {
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
        _gradientCard(
          context,
          themeService.getPrimaryColor(),
          Icons.account_balance_wallet,
          tr('total_salary'),
          controller.totalEarnings,
        ),
      ],
    );
  }

  Widget _gradientCard(BuildContext context, Color color, IconData icon, String label, double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
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
              Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 28),
              const SizedBox(width: 12),
              Text(
                label,
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
            amount: amount,
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

  Widget _buildEarningsSection(BuildContext context, CompensationController controller, ThemeService themeService) {
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
        ...controller.earnings.map((e) => _buildEarningCard(context, e, themeService)),
      ],
    );
  }

  Widget _buildEarningCard(BuildContext context, Map<String, dynamic> earning, ThemeService themeService) {
    // `monthly` is either a flag (paid monthly) or the monthly equivalent.
    final monthly = earning['monthly'];
    String? subtitle;
    double? monthlyAmount;
    if (monthly is bool || monthly == 0 || monthly == 1) {
      subtitle = PortalUi.truthy(monthly) ? tr('monthly') : null;
    } else {
      monthlyAmount = PortalUi.toDouble(monthly);
    }
    return PortalUi.card(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeService.getSuccessColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.account_balance_wallet, color: themeService.getSuccessColor(), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PortalUi.text(earning['name']),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),
                if (subtitle != null)
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: themeService.getTextSecondaryColor())),
                if (monthlyAmount != null)
                  SaudiRiyalDisplay(
                    customText: '${tr('monthly')}: ${monthlyAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: themeService.getTextSecondaryColor()),
                  ),
              ],
            ),
          ),
          SaudiRiyalDisplay(
            amount: PortalUi.toDouble(earning['amount']) ?? 0,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
              fontWeight: FontWeight.w700,
              color: themeService.getSuccessColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGosiSection(BuildContext context, CompensationController controller, ThemeService themeService) {
    final g = controller.gosi;
    final percent = g['employee_percent'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PortalUi.sectionTitle(context, tr('gosi')),
        PortalUi.card(
          child: Column(
            children: [
              PortalUi.row(context, tr('gosi_no'), PortalUi.text(g['gosi_no'])),
              _amountRow(context, tr('gosi_salary'), g['salary']),
              _amountRow(context, tr('employee_share'), g['employee_share']),
              PortalUi.row(context, tr('employee_percent'),
                  percent == null ? '-' : '${PortalUi.number(percent)}%'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _amountRow(BuildContext context, String label, dynamic value, {Color? color}) {
    final d = PortalUi.toDouble(value);
    return PortalUi.row(
      context,
      label,
      '-',
      valueWidget: d == null
          ? null
          : Align(
              alignment: AlignmentDirectional.centerEnd,
              child: SaudiRiyalDisplay(
                amount: d,
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                  color: color ?? ThemeService.instance.getTextPrimaryColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  // ── DEDUCTIONS TAB ────────────────────────────────────────────────────

  Widget _buildDeductionsSummary(BuildContext context, CompensationController controller, ThemeService themeService) {
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
              child: _buildSummaryCard(context, tr('total_amount'), controller.deductionsTotal,
                  Icons.payments, themeService.getErrorColor(), themeService),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(context, tr('amount_paid'), controller.deductionsPaid,
                  Icons.check_circle, themeService.getSuccessColor(), themeService),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _gradientCard(
          context,
          themeService.getWarningColor(),
          Icons.pending_actions,
          tr('balance_remaining'),
          controller.deductionsRemaining,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, double value, IconData icon, Color color, ThemeService themeService) {
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
            amount: value,
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

  Widget _buildDeductionsSection(BuildContext context, CompensationController controller, ThemeService themeService) {
    if (controller.deductions.isEmpty) {
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
        ...controller.deductions.map((d) => _buildDeductionCard(context, d, themeService)),
      ],
    );
  }

  Widget _buildDeductionCard(BuildContext context, Map<String, dynamic> d, ThemeService themeService) {
    final remaining = PortalUi.toDouble(d['remaining']) ?? 0;
    final isPaid = remaining <= 0;
    final statusColor = isPaid ? themeService.getSuccessColor() : themeService.getWarningColor();
    final name = PortalUi.text(d['name']);
    final type = PortalUi.text(d['type'], fallback: '');
    final id = PortalUi.toInt(d['id']);
    final installments = d['installments'];

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
        shape: const Border(),
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
          name,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
            fontWeight: FontWeight.w600,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        subtitle: Text(
          [if (type.isNotEmpty) type, isPaid ? tr('paid') : tr('pending')].join(' • '),
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
              amount: PortalUi.toDouble(d['total']) ?? 0,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.w700,
                color: themeService.getErrorColor(),
              ),
            ),
            if (!isPaid)
              SaudiRiyalDisplay(
                customText: '${tr('balance')}: ${remaining.toStringAsFixed(2)}',
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
          const SizedBox(height: 8),
          _amountRow(context, tr('total_amount'), d['total']),
          _amountRow(context, tr('amount_paid'), d['paid']),
          _amountRow(context, tr('balance'), d['remaining']),
          _amountRow(context, tr('installment_amount'), d['installment']),
          PortalUi.row(context, tr('number_of_installments'),
              installments == null ? '-' : PortalUi.number(installments)),
          PortalUi.row(context, tr('next_payment'), PortalUi.date(d['next_payment'])),
          if (id != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => showDeductionHistoryDialog(id, name),
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
        ],
      ),
    );
  }
}
