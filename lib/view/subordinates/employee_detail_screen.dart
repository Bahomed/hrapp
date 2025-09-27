import 'package:flutter/material.dart';
import 'package:com.injazatsoftware.injazathr/utils/translation_helper.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/response/employees_response.dart';
import '../../services/theme_service.dart';
import '../../utils/responsive_utils.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          tr('employee_details'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Employee Header Card
            _buildEmployeeHeader(context),

            SizedBox(height: isTablet ? 24 : 20),


            // Employee Delegation Actions
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                  tr('what_would_you_like_to_do'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 18 : 16,
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  _buildActionGrid(isTablet),
                ],
              ),
            ),

            SizedBox(height: isTablet ? 24 : 20),


          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeHeader(BuildContext context) {
    final themeService = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: employee.image != null && employee.image!.isNotEmpty
                    ? Image.network(
                        employee.image!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: themeService.getPrimaryColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: themeService.getPrimaryColor(),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: themeService.getPrimaryColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: themeService.getPrimaryColor(),
                        ),
                      ),
              ),
              // Online status indicator
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: themeService.getSuccessColor(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeService.getCardColor(),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),


          
          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 1)),
          
          // Employee Number with enhanced styling
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.responsiveWidth(context, 4),
              vertical: ResponsiveUtils.responsiveHeight(context, 0.8),
            ),
            decoration: BoxDecoration(
              color: themeService.getSuccessColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(context, 4)),
              border: Border.all(
                color: themeService.getSuccessColor().withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.badge,
                  size: ResponsiveUtils.responsiveIconSize(context, mobile: 14, tablet: 16, desktop: 18),
                  color: themeService.getSuccessColor(),
                ),
                SizedBox(width: ResponsiveUtils.responsiveWidth(context, 2)),
                Flexible(
                  child: Text(
                    '${tr('emp#')} ${employee.employeeNo}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                      color: themeService.getSuccessColor(),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Quick Info Cards with enhanced responsiveness
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  tr('department'),
                  employee.departmentName,
                  Icons.business,
                  themeService.getPrimaryColor(),
                ),
              ),
              SizedBox(width: ResponsiveUtils.responsiveWidth(context, 3)),
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  tr('section'),
                  employee.sectionName,
                  Icons.group_work,
                  themeService.getSuccessColor(),
                ),
              ),
            ],
          ),
          
          // Additional Work Info Row
          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 1.5)),
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  tr('nationality'),
                  employee.nationalityName,
                  Icons.flag,
                  themeService.getWarningColor(),
                ),
              ),
              SizedBox(width: ResponsiveUtils.responsiveWidth(context, 3)),
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  tr('position'),
                  employee.positionName,
                  Icons.work,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final themeService = ThemeService.instance;
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.responsiveWidth(context, 3)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(context, 3)),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: ResponsiveUtils.responsiveIconSize(context, mobile: 16, tablet: 18, desktop: 20),
                color: color,
              ),
              SizedBox(width: ResponsiveUtils.responsiveWidth(context, 1.5)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 11, tablet: 12, desktop: 13),
                    color: themeService.getTextSecondaryColor(),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 0.5)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isTablet,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : (isTablet ? 16 : 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: isTablet ? 20 : 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: isTablet ? 13 : 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid(bool isTablet) {
    return Builder(
      builder: (context) {
        final actions = [
          {
            'icon': Icons.assignment_outlined,
            'label': tr('requests'),
            'key': 'requests'
          },
          {
            'icon': Icons.account_balance_wallet_outlined,
            'label': tr('payroll'),
            'key': 'payroll'
          },
          {
            'icon': Icons.description_outlined,
            'label': tr('documents'),
            'key': 'documents'
          },
          {
            'icon': Icons.access_time_outlined,
            'label': tr('attendance'),
            'key': 'attendance'
          },
          {
            'icon': Icons.calendar_month_outlined,
            'label': tr('schedule'),
            'key': 'schedule'
          },
          {
            'icon': Icons.person_outline_rounded,
            'label': tr('profile'),
            'key': 'profile'
          },
        ];

        final List<VoidCallback> navigationFunctions = [
          () => _showMessage(context, tr('feature_coming_soon')), // requests
          () => _showMessage(context, tr('feature_coming_soon')), // payroll
          () => _showMessage(context, tr('feature_coming_soon')), // documents
          () => _showMessage(context, tr('feature_coming_soon')), // attendance
          () => _showMessage(context, tr('feature_coming_soon')), // schedule
          () => _showMessage(context, tr('feature_coming_soon')), // profile
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 3,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.0,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildDelegationButton(
              context,
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              onTap: navigationFunctions[index],
              isTablet: isTablet,
            );
          },
        );
      },
    );
  }

  Widget _buildDelegationButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isTablet ? 32 : 28,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}