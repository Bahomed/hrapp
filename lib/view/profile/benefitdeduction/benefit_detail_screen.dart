import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.injazatsoftware.injazathr/view/profile/benefitdeduction/benefit_detail_controller.dart';
import 'package:com.injazatsoftware.injazathr/utils/translation_helper.dart';
import 'package:com.injazatsoftware.injazathr/utils/responsive_utils.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/response/benefits_response.dart';
import '../../../services/theme_service.dart';

class BenefitDetailScreen extends StatelessWidget {
  const BenefitDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BenefitDetailController());
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
          tr('benefit_details'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: themeService.getPrimaryColor()),
            onPressed: controller.refreshBenefits,
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
          onRefresh: controller.refreshBenefits,
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

                // Earnings List
                _buildEarningsSection(context, controller, themeService),

                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummarySection(BuildContext context, BenefitDetailController controller, ThemeService themeService) {
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

        // Total Salary Card (Main)
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
              Text(
                '${controller.totalSalary} SAR',
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
              Icon(
                Icons.inbox,
                size: 64,
                color: themeService.getTextSecondaryColor(),
              ),
              const SizedBox(height: 16),
              Text(
                tr('no_earnings_found'),
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
    final benefitName = earning.benefit;
    final benefitAmount = earning.benefitAmt.toString();
    final effectivityDate = earning.effectivityDateG ?? tr('not_specified');
    final paymentScheme = earning.paymentSchemeLabel;
    final useFactor = earning.useFactor.toString();

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
          child: Icon(
            Icons.account_balance_wallet,
            color: themeService.getSuccessColor(),
            size: 24,
          ),
        ),
        title: Text(
          benefitName,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
            fontWeight: FontWeight.w600,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        subtitle: Text(
          paymentScheme,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
            color: themeService.getTextSecondaryColor(),
          ),
        ),
        trailing: Text(
          '$benefitAmount SAR',
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
            fontWeight: FontWeight.w700,
            color: themeService.getSuccessColor(),
          ),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 12),
          _buildDetailRow(context, tr('payment_scheme'), paymentScheme, themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('use_factor'), useFactor, themeService),
          const SizedBox(height: 8),
          _buildDetailRow(context, tr('effectivity_date'), effectivityDate, themeService),
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
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
            color: themeService.getTextPrimaryColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
