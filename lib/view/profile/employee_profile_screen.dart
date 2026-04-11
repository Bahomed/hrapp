import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../utils/responsive_utils.dart';
import 'employee_profile_controller.dart';
import '../../services/theme_service.dart';

class EmployeeProfileScreen extends StatelessWidget {
  final int employeeId;
  
  const EmployeeProfileScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      EmployeeProfileController(),
      tag: 'emp_profile_$employeeId',
    );
    final themeService = ThemeService.instance;

    // Load employee profile data
    controller.loadEmployeeProfile(employeeId);
    controller.loadLeaveBalance(employeeId);

    return Scaffold(
      backgroundColor: themeService.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tr('employee_profile'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Theme Toggle Button
          Padding(
            padding: EdgeInsets.only(right: ResponsiveUtils.responsiveWidth(context, 2)),
            child: IconButton(
              onPressed: () => Get.find<ThemeService>().toggleTheme(),
              icon: Icon(
                Get.find<ThemeService>().isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).iconTheme.color,
                size: ResponsiveUtils.responsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
              ),
              tooltip: tr('theme'),
            ),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.employeeProfile.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: themeService.getPrimaryColor(),
            ),
          );
        }

        if (controller.employeeProfile.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 64,
                  color: themeService.getTextSecondaryColor(),
                ),
                const SizedBox(height: 16),
                Text(
                  tr('no_profile_data'),
                  style: TextStyle(
                    fontSize: 16,
                    color: themeService.getTextSecondaryColor(),
                  ),
                ),
              ],
            ),
          );
        }

        final profile = controller.employeeProfile.value!;

        return RefreshIndicator(
          onRefresh: () => controller.loadEmployeeProfile(employeeId),
          color: themeService.getPrimaryColor(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, profile, themeService),

                const SizedBox(height: 20),

                // Leave Balance Card
                _buildLeaveBalanceCard(context, controller, themeService),

                const SizedBox(height: 20),

                // Profile Sections
                ..._getProfileSections(profile).map((section) =>
                  _buildProfileSection(section, themeService)
                ),
                
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> profile, ThemeService themeService) {
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
                child: profile['image'] != null && profile['image'].toString().isNotEmpty
                    ? Image.network(
                        profile['image'],
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
          
          const SizedBox(height: 20),
          
          // User Name
          Text(
            profile['employee_name'] ?? tr('unknown'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: themeService.getTextPrimaryColor(),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // User Position
          Text(
            profile['position'] ?? tr('no_position'),
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
              color: themeService.getTextSecondaryColor(),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 1)),
          
          // Hired Date with enhanced styling
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
                  Icons.calendar_today_rounded,
                  size: ResponsiveUtils.responsiveIconSize(context, mobile: 14, tablet: 16, desktop: 18),
                  color: themeService.getSuccessColor(),
                ),
                SizedBox(width: ResponsiveUtils.responsiveWidth(context, 2)),
                Text(
                  profile['hireddate_g'] ?? tr('not_available'),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                    color: themeService.getSuccessColor(),
                    fontWeight: FontWeight.w600,
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
                  tr('employee_id'),
                  profile['employee_no']?.toString() ?? tr('n_a'),
                  Icons.badge,
                  themeService.getPrimaryColor(),
                  themeService,
                ),
              ),
              SizedBox(width: ResponsiveUtils.responsiveWidth(context, 3)),
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  tr('department'),
                  profile['department'] ?? tr('n_a'),
                  Icons.business,
                  themeService.getSuccessColor(),
                  themeService,
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
                  tr('section'),
                  profile['section'] ?? tr('n_a'),
                  Icons.group_work,
                  themeService.getWarningColor(),
                  themeService,
                ),
              ),
              SizedBox(width: ResponsiveUtils.responsiveWidth(context, 3)),
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  tr('nationality'),
                  profile['nationality'] ?? tr('n_a'),
                  Icons.flag,
                  const Color(0xFF9C27B0),
                  themeService,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalanceCard(BuildContext context, EmployeeProfileController controller, ThemeService themeService) {
    final primaryColor = themeService.getPrimaryColor();
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Obx(() => Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeService.getTextPrimaryColor().withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.beach_access_outlined,
              color: primaryColor,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('leave_balance'),
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: themeService.getTextSecondaryColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (controller.isLoadingBalance.value)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryColor,
                    ),
                  )
                else if (controller.balanceError.value.isNotEmpty)
                  Text(
                    controller.balanceError.value,
                    style: TextStyle(
                      fontSize: isTablet ? 13 : 12,
                      color: themeService.getErrorColor(),
                    ),
                  )
                else
                  Text(
                    '${controller.vacationBalance.value % 1 == 0 ? controller.vacationBalance.value.toInt() : controller.vacationBalance.value} ${tr('days')}',
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 20,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
              ],
            ),
          ),
          if (!controller.isLoadingBalance.value && controller.balanceError.value.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: themeService.getSuccessColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: themeService.getSuccessColor().withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                tr('balance_remaining'),
                style: TextStyle(
                  fontSize: isTablet ? 11 : 10,
                  color: themeService.getSuccessColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildQuickInfoCard(BuildContext context, String title, String value, IconData icon, Color color, ThemeService themeService) {
    return Container(
      padding: ResponsiveUtils.responsivePadding(context, mobile: 12, tablet: 16, desktop: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: ResponsiveUtils.responsiveBorderRadius(context, mobile: 10, tablet: 12, desktop: 14),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
                size: ResponsiveUtils.responsiveIconSize(context, mobile: 14, tablet: 16, desktop: 18),
                color: color,
              ),
              SizedBox(width: ResponsiveUtils.responsiveWidth(context, 1.5)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 10, tablet: 11, desktop: 12),
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 1)),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
              fontWeight: FontWeight.w700,
              color: themeService.getTextPrimaryColor(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<ProfileSection> _getProfileSections(Map<String, dynamic> profile) {
    return [
      ProfileSection(
        title: tr('personal_information'),
        icon: Icons.person,
        color: const Color(0xFF42A5F5),
        items: [
          ProfileItem(tr('employee_name'), profile['employee_name'] ?? tr('n_a')),
          ProfileItem(tr('employee_no'), profile['employee_no']?.toString() ?? tr('n_a')),
          ProfileItem(tr('email'), profile['email'] ?? tr('n_a')),
          ProfileItem(tr('mobile'), profile['mobile_no'] ?? tr('n_a')),
          ProfileItem(tr('gender'), profile['gender'] ?? tr('n_a')),
          ProfileItem(tr('age'), profile['age']?.toString() ?? tr('n_a')),
          ProfileItem(tr('civil_status'), profile['civil_status'] ?? tr('n_a')),
          ProfileItem(tr('nationality'), profile['nationality'] ?? tr('n_a')),
          ProfileItem(tr('place_of_birth'), profile['place_of_birth'] ?? tr('n_a')),
        ],
      ),
      ProfileSection(
        title: tr('work_information'),
        icon: Icons.work,
        color: const Color(0xFF4CAF50),
        items: [
          ProfileItem(tr('position'), profile['position'] ?? tr('n_a')),
          ProfileItem(tr('department'), profile['department'] ?? tr('n_a')),
          ProfileItem(tr('section'), profile['section'] ?? tr('n_a')),
          ProfileItem(tr('position_iqama_passport'), profile['position_iqama_passport'] ?? tr('n_a')),
        ],
      ),
      ProfileSection(
        title: tr('identification'),
        icon: Icons.badge,
        color: const Color(0xFFFF9800),
        items: [
          ProfileItem(tr('iqama_no'), profile['iqama_no'] ?? tr('n_a')),
          ProfileItem(tr('passport_no'), profile['passport_no'] ?? tr('n_a')),
        ],
      ),
      ProfileSection(
        title: tr('address_information'),
        icon: Icons.location_on,
        color: const Color(0xFF9C27B0),
        items: [
          ProfileItem(tr('current_address'), profile['current_address'] ?? tr('n_a')),
          ProfileItem(tr('permanent_address'), profile['permanent_address'] ?? tr('n_a')),
          ProfileItem(tr('local_country'), profile['local_country'] ?? tr('n_a')),
          ProfileItem(tr('local_city'), profile['local_city'] ?? tr('n_a')),
          ProfileItem(tr('home_country'), profile['home_country'] ?? tr('n_a')),
          ProfileItem(tr('home_city'), profile['home_city'] ?? tr('n_a')),
        ],
      ),
      ProfileSection(
        title: tr('preferences'),
        icon: Icons.settings,
        color: const Color(0xFF607D8B),
        items: [
          ProfileItem(tr('preferred_language'), profile['preferred_lang'] ?? tr('n_a')),
          ProfileItem(tr('report_to_employee'), profile['report_to_employee'] ?? tr('n_a')),
        ],
      ),
    ];
  }

  Widget _buildProfileSection(ProfileSection section, ThemeService themeService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: section.color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  section.icon,
                  color: section.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  section.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: section.color,
                  ),
                ),
              ],
            ),
          ),
          
          // Section Items
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: section.items.map((item) => 
                _buildProfileItem(item, section.color, themeService)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(ProfileItem item, Color accentColor, ThemeService themeService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              color: themeService.getTextSecondaryColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: themeService.getBackgroundColor(),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: themeService.getDividerColor()),
            ),
            child: Text(
              item.value.isEmpty ? tr('not_specified') : item.value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: item.value.isEmpty ? themeService.getTextSecondaryColor() : themeService.getTextPrimaryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper classes for organizing profile data (same as ProfileScreen)
class ProfileSection {
  final String title;
  final IconData icon;
  final Color color;
  final List<ProfileItem> items;

  ProfileSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

class ProfileItem {
  final String label;
  final String value;

  ProfileItem(this.label, this.value);
}