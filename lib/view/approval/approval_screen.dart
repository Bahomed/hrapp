import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/data/remote/response/approval_request_response.dart';
import 'package:injazat_hr_app/services/theme_service.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/responsive_utils.dart';
import 'package:injazat_hr_app/view/approval/approval_controller.dart';

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
          Obx(() => Badge(
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
              if (controller.isLoading.value && controller.allRequests.isEmpty) {
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
                  padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 16, tablet: 20, desktop: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Cards
                      _buildSummaryCards(controller, themeService),
                      
                      SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 24, tablet: 28, desktop: 32)),
                      
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

  Widget _buildFilterSection(ApprovalController controller, ThemeService themeService) {
    final context = Get.context!;
    return Container(
      padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 16, tablet: 20, desktop: 24).add(
        ResponsiveUtils.responsiveVerticalPadding(context, mobile: 12, tablet: 14, desktop: 16)
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
        child: Obx(() => Row(
          children: controller.filters.map((filter) {
            final isSelected = controller.selectedFilter.value == filter['key'];
            final color = filter['color'] as Color;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter['name'] as String),
                selected: isSelected,
                onSelected: (_) => controller.changeFilter(filter['key'] as String),
                backgroundColor: themeService.getSurfaceColor(),
                selectedColor: color.withOpacity(0.2),
                checkmarkColor: color,
                labelStyle: TextStyle(
                  color: isSelected ? color : themeService.getTextSecondaryColor(),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? color : themeService.getTextSecondaryColor().withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  Widget _buildSummaryCards(ApprovalController controller, ThemeService themeService) {
    final context = Get.context!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveUtils.responsiveCrossAxisCount(context, mobile: 2, tablet: 3, desktop: 4),
      childAspectRatio: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 2.2, tablet: 2.0, desktop: 1.8),
      mainAxisSpacing: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 12, tablet: 16, desktop: 20),
      crossAxisSpacing: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 12, tablet: 16, desktop: 20),
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
      padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 12, tablet: 14, desktop: 16),
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
                  child: Icon(icon, color: color, size: ResponsiveUtils.responsiveIconSize(context, mobile: 16, tablet: 18, desktop: 20)),
                ),
                const Spacer(),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
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
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
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

  Widget _buildRequestSections(ApprovalController controller, ThemeService themeService, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.leaveRequests.isNotEmpty) ...[
          _buildSectionHeader(tr('leave_request'), controller.leaveRequestCount, themeService, context),
          const SizedBox(height: 12),
          ...controller.leaveRequests.map((request) => 
            _buildRequestCard(request, controller, themeService, context)),
          const SizedBox(height: 20),
        ],
        
        if (controller.permissionRequests.isNotEmpty) ...[
          _buildSectionHeader(tr('permission_request'), controller.permissionRequestCount, themeService, context),
          const SizedBox(height: 12),
          ...controller.permissionRequests.map((request) => 
            _buildRequestCard(request, controller, themeService, context)),
          const SizedBox(height: 20),
        ],
        
        if (controller.loanRequests.isNotEmpty) ...[
          _buildSectionHeader(tr('loan_request'), controller.loanRequestCount, themeService, context),
          const SizedBox(height: 12),
          ...controller.loanRequests.map((request) => 
            _buildRequestCard(request, controller, themeService, context)),
          const SizedBox(height: 20),
        ],
        
        if (controller.letterRequests.isNotEmpty) ...[
          _buildSectionHeader(tr('letter_request'), controller.letterRequestCount, themeService, context),
          const SizedBox(height: 12),
          ...controller.letterRequests.map((request) => 
            _buildRequestCard(request, controller, themeService, context)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeService themeService, BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
            fontWeight: FontWeight.w600,
            color: themeService.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 8, tablet: 10, desktop: 12).add(
            ResponsiveUtils.responsiveVerticalPadding(context, mobile: 4, tablet: 5, desktop: 6)
          ),
          decoration: BoxDecoration(
            color: themeService.getActionColor('requests').withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
              fontWeight: FontWeight.w600,
              color: themeService.getActionColor('requests'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard(ApprovalRequest request, ApprovalController controller, ThemeService themeService, BuildContext context) {
    final requestTypeColor = controller.getFilterColor(request.requestType.toLowerCase());
    
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 12, tablet: 14, desktop: 16)),
      padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 16, tablet: 18, desktop: 20),
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
                padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 8, tablet: 10, desktop: 12),
                decoration: BoxDecoration(
                  color: requestTypeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  controller.getFilterIcon(request.requestType),
                  color: requestTypeColor,
                  size: ResponsiveUtils.responsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 12, tablet: 14, desktop: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.employeeName,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.w600,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    Text(
                      '${request.employeeNo} • ${request.requestType}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                        color: themeService.getTextSecondaryColor(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 8, tablet: 10, desktop: 12).add(
                  ResponsiveUtils.responsiveVerticalPadding(context, mobile: 4, tablet: 5, desktop: 6)
                ),
                decoration: BoxDecoration(
                  color: themeService.getWarningColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tr('for_approval'),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
                    fontWeight: FontWeight.w600,
                    color: themeService.getWarningColor(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (request.leaveType != null) ...[
            Text(
              '${tr('leave_type')}: ${request.leaveType}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
            SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 4, tablet: 5, desktop: 6)),
          ],
          
          Text(
            '${tr('date')}: ${request.requestDateG}',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
              color: themeService.getTextSecondaryColor(),
            ),
          ),
          
          if (request.departmentName != null) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 4, tablet: 5, desktop: 6)),
            Text(
              '${tr('department')}: ${request.departmentName}',
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Flexible(
                child: OutlinedButton(
                  onPressed: () => controller.viewRequestDetails(request),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: themeService.getTextSecondaryColor().withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    tr('view_details'),
                    style: TextStyle(
                      color: themeService.getTextSecondaryColor(),
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 8, tablet: 10, desktop: 12)),
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
                    tr('rejected'),
                    style: TextStyle(
                      color: themeService.getErrorColor(),
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
                    ),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 8, tablet: 10, desktop: 12)),
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
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 10, tablet: 12, desktop: 13),
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
            padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 24, tablet: 28, desktop: 32),
            decoration: BoxDecoration(
              color: themeService.getActionColor('requests').withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: ResponsiveUtils.responsiveIconSize(context, mobile: 64, tablet: 72, desktop: 80),
              color: themeService.getActionColor('requests'),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 24, tablet: 28, desktop: 32)),
          Text(
            'No Pending Requests',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
              fontWeight: FontWeight.w600,
              color: themeService.getTextPrimaryColor(),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 8, tablet: 10, desktop: 12)),
          Text(
            'All requests have been processed',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
              color: themeService.getTextSecondaryColor(),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(context, mobile: 24, tablet: 28, desktop: 32)),
          ElevatedButton.icon(
            onPressed: () => Get.find<ApprovalController>().refreshRequests(),
            icon: const Icon(Icons.refresh),
            label: Text(tr('refresh')),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeService.getActionColor('requests'),
              foregroundColor: Colors.white,
              padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 24, tablet: 28, desktop: 32).add(
                ResponsiveUtils.responsiveVerticalPadding(context, mobile: 12, tablet: 14, desktop: 16)
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
}