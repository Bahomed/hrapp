import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import '../../utils/responsive_utils.dart';
import 'profile_controller.dart';
import '../../services/theme_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
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
          tr('profile'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isEditing.value ? Icons.close : Icons.edit,
              color: controller.isEditing.value ? themeService.getErrorColor() : themeService.getPrimaryColor(),
            ),
            onPressed: controller.toggleEditMode,
          )),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: themeService.getTextPrimaryColor()),
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  controller.refreshProfile();
                  break;
                case 'logout':
                  controller.logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: themeService.getPrimaryColor()),
                    const SizedBox(width: 12),
                    Text(tr('refresh')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: themeService.getErrorColor()),
                    const SizedBox(width: 12),
                    Text(tr('logout', fallback: 'Logout')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.userData.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: themeService.getPrimaryColor(),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshProfile,
          color: themeService.getPrimaryColor(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, controller),
                
                const SizedBox(height: 30),
                
                // Action Buttons (only show save/cancel in edit mode)
                if (controller.isEditing.value) ...[
                  _buildActionButtons(controller),
                  const SizedBox(height: 20),
                ],
                
                // Profile Sections
                ...controller.profileSections.map((section) => 
                  _buildProfileSection(controller, section)
                ),
                
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileController controller) {
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
                child: controller.userImage.isNotEmpty
                    ? Image.network(
                        controller.userImage,
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
            controller.userName,
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
            controller.userPosition,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 16, desktop: 18),
              color: themeService.getTextSecondaryColor(),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 1)),
          
          // Department with enhanced styling
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
                  Icons.mobile_friendly_outlined ,
                  size: ResponsiveUtils.responsiveIconSize(context, mobile: 14, tablet: 16, desktop: 18),
                  color: themeService.getSuccessColor(),
                ),
                SizedBox(width: ResponsiveUtils.responsiveWidth(context, 2)),
                Text(
                  controller.userMobile,
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
                  'Employee ID',
                  controller.userEmployeeNo,
                  Icons.badge,
                  themeService.getPrimaryColor(),
                ),
              ),
              SizedBox(width: ResponsiveUtils.responsiveWidth(context, 3)),
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  'Department',
                  controller.userDepartment,
                  Icons.business,
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
                  'Section',
                  controller.userSection,
                  Icons.group_work,
                  themeService.getWarningColor(),
                ),
              ),
              SizedBox(width: ResponsiveUtils.responsiveWidth(context, 3)),
              Expanded(
                child: _buildQuickInfoCard(
                  context,
                  'Report To',
                  controller.userReportToEmployee,
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

  Widget _buildQuickInfoCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final themeService = ThemeService.instance;
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

  Widget _buildActionButtons(ProfileController controller) {
    final themeService = ThemeService.instance;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.isLoading.value ? null : controller.saveProfile,
            icon: controller.isLoading.value
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: themeService.getSilver(),
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.save, color: themeService.getSilver()),
            label: Text(
              controller.isLoading.value ? tr('saving') : tr('save_changes'),
              style: TextStyle(
                color: themeService.getSilver(),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeService.getSuccessColor(),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.isLoading.value ? null : controller.toggleEditMode,
            icon: Icon(Icons.cancel, color: themeService.getErrorColor()),
            label: Text(
              tr('cancel'),
              style: TextStyle(
                color: themeService.getErrorColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: themeService.getErrorColor()),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection(ProfileController controller, ProfileSection section) {
    final themeService = ThemeService.instance;
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
                _buildProfileItem(controller, item, section.color)
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(ProfileController controller, ProfileItem item, Color accentColor) {
    final themeService = ThemeService.instance;
    final isEditable = item.isEditable && controller.isEditing.value;
    TextEditingController? textController;
    
    // Get appropriate controller for editable fields
    if (isEditable) {
      switch (item.label) {
        case 'Employee Name':
          textController = controller.nameController;
          break;
        case 'Email':
          textController = controller.emailController;
          break;
        case 'Mobile':
          textController = controller.mobileController;
          break;
        case 'Current Address':
          textController = controller.currentAddressController;
          break;
        case 'Permanent Address':
          textController = controller.permanentAddressController;
          break;
      }
    }

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
          
          if (isEditable && textController != null)
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: trParams('enter_field', {'field': item.label.toLowerCase()}),
                hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: themeService.getDividerColor()),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accentColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: themeService.getTextPrimaryColor(),
              ),
            )
          else
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