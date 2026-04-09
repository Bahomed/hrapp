import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/data/remote/response/approval_request_response.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/view/approval/approval_controller.dart';
import 'package:co.injazathr.injazathr/widgets/saudi_riyal_display.dart';

class ApprovalScreen extends StatelessWidget {
  const ApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApprovalController());
    final themeService = Get.find<ThemeService>();

    return Scaffold(
      backgroundColor: themeService.getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          tr('approval'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: themeService.getSurfaceColor(),
        elevation: 0,
        iconTheme: IconThemeData(color: themeService.getTextPrimaryColor()),
        actions: [
          Obx(() =>
              Badge(
                label: Text('${controller.totalPendingCount}'),
                isLabelVisible: controller.totalPendingCount > 0,
                child: IconButton(
                  onPressed: controller.refreshRequests,
                  icon: controller.isLoading.value
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: themeService.getTextPrimaryColor(),
                    ),
                  )
                      : Icon(Icons.refresh),
                ),
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Pills
          _buildFilterSection(controller, themeService),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.allRequests.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: themeService.getActionColor('requests'),
                  ),
                );
              }

              if (controller.allRequests.isEmpty) {
                return _buildEmptyState(themeService, context);
              }

              return RefreshIndicator(
                onRefresh: controller.refreshRequests,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: ResponsiveUtils.responsiveHorizontalPadding(
                      context, mobile: 16, tablet: 20, desktop: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      _buildSummaryCards(controller, themeService),

                      SizedBox(height: ResponsiveUtils.getResponsiveValue<
                          double>(context, mobile: 24,
                          tablet: 28,
                          desktop: 32)),

                      // Request Lists
                      _buildRequestSections(controller, themeService, context),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ApprovalController controller,
      ThemeService themeService) {
    final context = Get.context!;
    return Container(
      padding: ResponsiveUtils.responsiveHorizontalPadding(
          context, mobile: 16, tablet: 20, desktop: 24).add(
          ResponsiveUtils.responsiveVerticalPadding(
              context, mobile: 12, tablet: 14, desktop: 16)
      ),
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
        child: Obx(() =>
            Row(
              children: controller.filters.map((filter) {
                final isSelected = controller.selectedFilter.value ==
                    filter['key'];
                final color = filter['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter['name'] as String),
                    selected: isSelected,
                    onSelected: (_) =>
                        controller.changeFilter(filter['key'] as String),
                    backgroundColor: themeService.getSurfaceColor(),
                    selectedColor: color.withOpacity(0.2),
                    checkmarkColor: color,
                    labelStyle: TextStyle(
                      color: isSelected ? color : themeService
                          .getTextSecondaryColor(),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight
                          .normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? color : themeService
                          .getTextSecondaryColor().withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildSummaryCards(ApprovalController controller,
      ThemeService themeService) {
    final context = Get.context!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveUtils.responsiveCrossAxisCount(
          context, mobile: 2, tablet: 3, desktop: 4),
      childAspectRatio: ResponsiveUtils.getResponsiveValue<double>(
          context, mobile: 2.2, tablet: 2.0, desktop: 1.8),
      mainAxisSpacing: ResponsiveUtils.getResponsiveValue<double>(
          context, mobile: 12, tablet: 16, desktop: 20),
      crossAxisSpacing: ResponsiveUtils.getResponsiveValue<double>(
          context, mobile: 12, tablet: 16, desktop: 20),
      children: [
        _buildSummaryCard(
          context: context,
          title: tr('leave_request'),
          count: controller.leaveRequestCount,
          icon: Icons.calendar_today,
          color: themeService.getActionColor('schedule'),
          themeService: themeService,
        ),
        _buildSummaryCard(
          context: context,
          title: tr('permission_request'),
          count: controller.permissionRequestCount,
          icon: Icons.badge_outlined,
          color: themeService.getActionColor('profile'),
          themeService: themeService,
        ),
        _buildSummaryCard(
          context: context,
          title: tr('loan_request'),
          count: controller.loanRequestCount,
          icon: Icons.account_balance_wallet,
          color: themeService.getSuccessColor(),
          themeService: themeService,
        ),
        _buildSummaryCard(
          context: context,
          title: tr('letter_request'),
          count: controller.letterRequestCount,
          icon: Icons.description,
          color: themeService.getActionColor('documents'),
          themeService: themeService,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required ThemeService themeService,
  }) {
    return Container(
      padding: ResponsiveUtils.responsiveHorizontalPadding(
          context, mobile: 12, tablet: 14, desktop: 16),
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color,
                      size: ResponsiveUtils.responsiveIconSize(
                          context, mobile: 16, tablet: 18, desktop: 20)),
                ),
                const Spacer(),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context, mobile: 20, tablet: 22, desktop: 24),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                  context, mobile: 11, tablet: 12, desktop: 13),
              color: themeService.getTextSecondaryColor(),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSections(ApprovalController controller,
      ThemeService themeService, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.leaveRequests.isNotEmpty) ...[
          _buildSectionHeader(
              tr('leave_request'), controller.leaveRequestCount, themeService,
              context),
          const SizedBox(height: 12),
          ...controller.leaveRequests.map((request) =>
              _buildRequestCard(request, controller, themeService, context)),
          const SizedBox(height: 20),
        ],

        if (controller.permissionRequests.isNotEmpty) ...[
          _buildSectionHeader(
              tr('permission_request'), controller.permissionRequestCount,
              themeService, context),
          const SizedBox(height: 12),
          ...controller.permissionRequests.map((request) =>
              _buildRequestCard(request, controller, themeService, context)),
          const SizedBox(height: 20),
        ],

        if (controller.loanRequests.isNotEmpty) ...[
          _buildSectionHeader(
              tr('loan_request'), controller.loanRequestCount, themeService,
              context),
          const SizedBox(height: 12),
          ...controller.loanRequests.map((request) =>
              _buildRequestCard(request, controller, themeService, context)),
          const SizedBox(height: 20),
        ],

        if (controller.letterRequests.isNotEmpty) ...[
          _buildSectionHeader(
              tr('letter_request'), controller.letterRequestCount, themeService,
              context),
          const SizedBox(height: 12),
          ...controller.letterRequests.map((request) =>
              _buildRequestCard(request, controller, themeService, context)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeService themeService,
      BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(
                context, mobile: 18, tablet: 20, desktop: 22),
            fontWeight: FontWeight.w600,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: ResponsiveUtils.responsiveHorizontalPadding(
              context, mobile: 8, tablet: 10, desktop: 12).add(
              ResponsiveUtils.responsiveVerticalPadding(
                  context, mobile: 4, tablet: 5, desktop: 6)
          ),
          decoration: BoxDecoration(
            color: themeService.getActionColor('requests').withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                  context, mobile: 12, tablet: 13, desktop: 14),
              fontWeight: FontWeight.w600,
              color: themeService.getActionColor('requests'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(ApprovalRequest request,
      ApprovalController controller, ThemeService themeService,
      BuildContext context) {
    final requestTypeColor = controller.getFilterColor(
        request.requestType.toLowerCase());

    return Container(
      margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 12, tablet: 14, desktop: 16)),
      padding: ResponsiveUtils.responsiveHorizontalPadding(
          context, mobile: 16, tablet: 18, desktop: 20),
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: requestTypeColor.withOpacity(0.2),
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
                padding: ResponsiveUtils.responsiveHorizontalPadding(
                    context, mobile: 8, tablet: 10, desktop: 12),
                decoration: BoxDecoration(
                  color: requestTypeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  controller.getFilterIcon(request.requestType),
                  color: requestTypeColor,
                  size: ResponsiveUtils.responsiveIconSize(
                      context, mobile: 20, tablet: 22, desktop: 24),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 12, tablet: 14, desktop: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.employeeName,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                            context, mobile: 16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.w600,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    if (request.requestNumber.isNotEmpty) ...[
                      SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
                          context, mobile: 2, tablet: 3, desktop: 4)),
                      Text(
                        '${tr('request_number')}: #${request.requestNumber}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveFontSize(
                              context, mobile: 12, tablet: 13, desktop: 14),
                          color: themeService.getTextSecondaryColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (request.requestType == 'Leave') ...[
                      const SizedBox(height: 6),
                      _buildLeaveBalanceChip(request.employmentId, themeService, context),
                    ],
                  ],
                ),
              ),
              Container(
                padding: ResponsiveUtils.responsiveHorizontalPadding(
                    context, mobile: 8, tablet: 10, desktop: 12).add(
                    ResponsiveUtils.responsiveVerticalPadding(
                        context, mobile: 4, tablet: 5, desktop: 6)
                ),
                decoration: BoxDecoration(
                  color: themeService.getWarningColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tr('for_approval'),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context, mobile: 11, tablet: 12, desktop: 13),
                    fontWeight: FontWeight.w600,
                    color: themeService.getWarningColor(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Request-specific information based on type
          ..._buildRequestSpecificInfo(request, themeService, context),

          Text(
            '${tr('submitted')}: ${_formatDate(request.requestDateG)}',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                  context, mobile: 13, tablet: 14, desktop: 15),
              color: themeService.getTextSecondaryColor(),
            ),
          ),

          // Show remarks for all request types
          if (request.reason != null && request.reason!.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
                context, mobile: 4, tablet: 5, desktop: 6)),
            Text(
              '${tr('reason')}: ${request.reason}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 16),

          Row(
            children: [
              Flexible(
                child: OutlinedButton(
                  onPressed: () => controller.viewRequestDetails(request),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: themeService.getTextSecondaryColor().withOpacity(
                            0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    tr('view_details'),
                    style: TextStyle(
                      color: themeService.getTextSecondaryColor(),
                      fontSize: ResponsiveUtils.responsiveFontSize(
                          context, mobile: 11, tablet: 12, desktop: 13),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 8, tablet: 10, desktop: 12)),
              Flexible(
                child: OutlinedButton(
                  onPressed: () => controller.showRejectionDialog(request),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: themeService.getErrorColor()),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    tr('reject'),
                    style: TextStyle(
                      color: themeService.getErrorColor(),
                      fontSize: ResponsiveUtils.responsiveFontSize(
                          context, mobile: 11, tablet: 12, desktop: 13),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 8, tablet: 10, desktop: 12)),
              Flexible(
                child: OutlinedButton(
                  onPressed: () => controller.showApprovalDialog(request),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: themeService.getSuccessColor()),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    tr('approved'),
                    style: TextStyle(
                      color: themeService.getSuccessColor(),
                      fontSize: ResponsiveUtils.responsiveFontSize(
                          context, mobile: 10, tablet: 12, desktop: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeService themeService, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: ResponsiveUtils.responsiveHorizontalPadding(
                context, mobile: 24, tablet: 28, desktop: 32),
            decoration: BoxDecoration(
              color: themeService.getActionColor('requests').withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: ResponsiveUtils.responsiveIconSize(
                  context, mobile: 64, tablet: 72, desktop: 80),
              color: themeService.getActionColor('requests'),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 24, tablet: 28, desktop: 32)),
          Text(
            'No Pending Requests',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                  context, mobile: 20, tablet: 22, desktop: 24),
              fontWeight: FontWeight.w600,
              color: themeService.getTextPrimaryColor(),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 8, tablet: 10, desktop: 12)),
          Text(
            'All requests have been processed',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                  context, mobile: 14, tablet: 15, desktop: 16),
              color: themeService.getTextSecondaryColor(),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 24, tablet: 28, desktop: 32)),
          ElevatedButton.icon(
            onPressed: () => Get.find<ApprovalController>().refreshRequests(),
            icon: const Icon(Icons.refresh),
            label: Text(tr('refresh')),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeService.getActionColor('requests'),
              foregroundColor: Colors.white,
              padding: ResponsiveUtils.responsiveHorizontalPadding(
                  context, mobile: 24, tablet: 28, desktop: 32).add(
                  ResponsiveUtils.responsiveVerticalPadding(
                      context, mobile: 12, tablet: 14, desktop: 16)
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRequestSpecificInfo(ApprovalRequest request,
      ThemeService themeService, BuildContext context) {
    List<Widget> widgets = [];

    switch (request.requestType.toLowerCase()) {
      case 'leave':
      // Show leave type
        if (request.leaveType != null) {
          widgets.add(
            Text(
              '${tr('type')}: ${request.leaveType}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }

        // Show leave start and end dates
        if (request.leaveStartDate != null) {
          widgets.add(
            Text(
              '${tr('start_date')}: ${_formatDate(request.leaveStartDate!)}',

              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }

        if (request.leaveEndDate != null) {
          widgets.add(
            Text(
              '${tr('end_date')}: ${_formatDate(request.leaveEndDate!)}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }

        // Show days
        if (request.days != null && request.days! > 0) {
          widgets.add(
            Text(
              '${tr('days')}: ${request.days}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }
        break;

      case 'loan':
      // Show loan type
        if (request.leaveType != null) {
          widgets.add(
            Text(
              '${tr('type')}: ${request.leaveType}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }

        // Show loan amount
        if (request.loanAmount != null && request.loanAmount != '0' &&
            request.loanAmount != '0.00') {
          widgets.add(
            Row(
              children: [
                Text(
                  '${tr('amount')}: ',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context, mobile: 13, tablet: 14, desktop: 15),
                    color: themeService.getTextSecondaryColor(),
                  ),
                ),
                SaudiRiyalDisplay(
                  amount: double.tryParse(request.loanAmount!) ?? 0.0,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context, mobile: 13, tablet: 14, desktop: 15),
                    color: themeService.getTextSecondaryColor(),
                  ),
                ),
              ],
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }

        // Show repayment months
        if (request.loanRepaymentMonths != null &&
            request.loanRepaymentMonths! > 0) {
          widgets.add(
            Text(
              '${tr('instalment')}: ${request.loanRepaymentMonths} ${tr(
                  'months')}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }
        if (request.leaveStartDate != null) {
          widgets.add(
            Text(
              '${tr('start_date')}: ${_formatDate(request.leaveStartDate!)}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }
        break;

      case 'permission':
      case 'permit':
      // Show permission type
        if (request.leaveType != null) {
          widgets.add(
            Text(
              '${tr('permission_type')}: ${request.leaveType}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }

        // Show permit date
        if (request.permitDate != null) {
          widgets.add(
            Text(
              '${tr('date')}: ${_formatDate(request.permitDate!)}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }

        // Show permit time
        if (request.permitFrom != null && request.permitFrom!.isNotEmpty) {
          widgets.add(
            Text(
              '${tr('time')}: ${ _formatTimeDisplay(request.permitFrom!)} ${tr(
                  'to')} ${ _formatTimeDisplay(request.permitTo ?? "")}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }
        break;

      case 'letter':
      // Show letter type
        if (request.leaveType != null) {
          widgets.add(
            Text(
              '${tr('type')}: ${request.leaveType}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          );
          widgets.add(SizedBox(
              height: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 4, tablet: 5, desktop: 6)));
        }
        break;
    }

    return widgets;
  }

  Widget _buildLeaveBalanceSummary(ApprovalController controller, ThemeService themeService, BuildContext context) {
    // Collect unique employees from leave requests
    final seen = <int>{};
    final uniqueLeaveRequests = controller.leaveRequests
        .where((r) => seen.add(r.employmentId))
        .toList();

    return Obx(() {
      final color = themeService.getPrimaryColor();
      return Wrap(
        spacing: 8,
        runSpacing: 6,
        children: uniqueLeaveRequests.map((request) {
          final isLoading = controller.loadingBalances.contains(request.employmentId);
          final balance = controller.leaveBalances[request.employmentId];

          // Label: employee name if multiple, generic if single
          final label = uniqueLeaveRequests.length > 1
              ? request.employeeName.split(' ').first
              : null;

          String balanceText;
          if (isLoading) {
            balanceText = '...';
          } else if (balance == null) {
            return const SizedBox.shrink();
          } else {
            final display = balance % 1 == 0
                ? balance.toInt().toString()
                : balance.toStringAsFixed(2);
            balanceText = '$display ${tr('days')}';
          }

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.beach_access_outlined, size: 14, color: color),
                const SizedBox(width: 6),
                if (label != null) ...[
                  Text(
                    '$label · ',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                Text(
                  '${tr('leave_balance')}: $balanceText',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 10, height: 10,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildLeaveBalanceChip(int employmentId, ThemeService themeService, BuildContext context) {
    final controller = Get.find<ApprovalController>();
    return Obx(() {
      final isLoading = controller.loadingBalances.contains(employmentId);
      final balance = controller.leaveBalances[employmentId];

      if (isLoading) {
        return Row(
          children: [
            Icon(Icons.beach_access_outlined,
                size: 14, color: themeService.getTextSecondaryColor()),
            const SizedBox(width: 4),
            SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          ],
        );
      }

      if (balance == null) return const SizedBox.shrink();

      final displayBalance = balance % 1 == 0 ? balance.toInt().toString() : balance.toString();
      final color = themeService.getPrimaryColor();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.beach_access_outlined, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              '${tr('leave_balance')}: $displayBalance ${tr('days')}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 12, tablet: 13, desktop: 14),
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }

  String _formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatTimeDisplay(String timeString) {
    try {
      // Handle different time formats and remove seconds
      timeString = timeString.trim();

      // If it contains AM/PM (12-hour format)
      if (timeString.contains('AM') || timeString.contains('PM')) {
        final isAM = timeString.contains('AM');
        final timePart = timeString.replaceAll(RegExp(r'\s*(AM|PM)'), '');
        final parts = timePart.split(':');

        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          // Format as HH:MM AM/PM without seconds
          final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final formattedMinute = minute.toString().padLeft(2, '0');
          return '$formattedHour:$formattedMinute ${isAM ? 'AM' : 'PM'}';
        }
      } else {
        // 24-hour format or contains seconds
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          // Format as HH:MM in 24-hour format without seconds
          final formattedHour = hour.toString().padLeft(2, '0');
          final formattedMinute = minute.toString().padLeft(2, '0');
          return '$formattedHour:$formattedMinute';
        }
      }

      // If parsing fails, return original string
      return timeString;
    } catch (e) {
      // Return original string if any error occurs
      return timeString;
    }
  }
}