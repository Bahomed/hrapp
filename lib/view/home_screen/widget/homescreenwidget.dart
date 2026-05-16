import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:co.injazathr.injazathr/view/payroll/payroll_screen.dart';
import 'package:co.injazathr.injazathr/view/compensation/compensation_screen.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/app_theme.dart';
import 'package:co.injazathr.injazathr/utils/screen_themes.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';

import '../../assetscreen/asset_screen.dart';
import '../quick_attendance_controller.dart';
import '../../document/document_screen.dart';
import '../homescreen_controller.dart';
import 'package:co.injazathr.injazathr/view/request_leave/request_home_screen.dart';
import 'package:co.injazathr.injazathr/view/approval/approval_screen.dart';
import 'package:co.injazathr.injazathr/view/unexecuted_requests/unexecuted_requests_screen.dart';
import '../../schedule/weekly_shift_schedule_screen.dart';

class HomeScreenWidget extends StatelessWidget {
  const HomeScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Get.find<HomeScreenController>();
    return RefreshIndicator(
      onRefresh: () async {
       /// await model.getDashboardFromApi();
        await model.loadGreeting();

      },
      child: ScreenThemes.buildHomeScreenContainer(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Face ID Attendance Section
                _buildFaceIdAttendanceSection(),

                const SizedBox(height: 20),

                // What would you like to do section
                Text(
                  tr('what_would_you_like_to_do'),
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                    color: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.color,
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons Grid
                _buildActionGrid(),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 120),



              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header section with profile and notifications

  Widget _buildFaceIdAttendanceSection() {
    return Center(
      child: Column(
        children: [
          // Caption
          Text(
            tr('face_recognition_for_attendance'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(Get.context!).textTheme.bodyMedium?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Circular Face Recognition Button
          GestureDetector(
            onTap: () {
              Get.find<QuickAttendanceController>().performQuickAttendance();
            },
            child: Container(
              width: ResponsiveUtils.getResponsiveValue<double>(Get.context!, mobile: 110, tablet: 130, desktop: 150),
              height: ResponsiveUtils.getResponsiveValue<double>(Get.context!, mobile: 110, tablet: 130, desktop: 150),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(Get.context!).primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(Get.context!).primaryColor.withOpacity(0.3),
                    blurRadius: ResponsiveUtils.getResponsiveValue<double>(Get.context!, mobile: 12, tablet: 15, desktop: 18),
                    offset: Offset(0, ResponsiveUtils.getResponsiveValue<double>(Get.context!, mobile: 4, tablet: 5, desktop: 6)),
                  ),
                ],
              ),

              // Center the SVG properly within the circle
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/face_recognition.svg',
                  width: ResponsiveUtils.getResponsiveValue<double>(Get.context!, mobile: 55, tablet: 65, desktop: 75),
                  height: ResponsiveUtils.getResponsiveValue<double>(Get.context!, mobile: 55, tablet: 65, desktop: 75),
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  // Ensure the SVG fits within its bounds
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),



        ],
      ),
    );
  }
  Widget _buildActionGrid() {
    final model = Get.find<HomeScreenController>();

    return Obx(() {
      final actions = <Map<String, dynamic>>[
        {
          'icon': Icons.assignment_outlined,
          'label': tr('requests'),
          'key': 'requests',
          'onTap': () => Get.to(const RequestHomeScreen()),
        },
        {
          'icon': Icons.account_balance_wallet_outlined,
          'label': tr('payroll'),
          'key': 'payroll',
          'onTap': () => Get.to(const PayrollScreen()),
        },
        {
          'icon': Icons.description_outlined,
          'label': tr('documents'),
          'key': 'documents',
          'onTap': () => Get.to(const DocumentScreen()),
        },
        {
          'icon': Icons.access_time_outlined,
          'label': tr('attendance'),
          'key': 'attendance',
          'onTap': () => model.goToAttendanceDetailScreen(),
        },
        {
          'icon': Icons.payments_outlined,
          'label': tr('compensation'),
          'key': 'compensation',
          'onTap': () => Get.to(const CompensationScreen()),
        },
        {
          'icon': Icons.person_outline_rounded,
          'label': tr('profile'),
          'key': 'profile',
          'onTap': () => model.goToProfileScreen(),
        },
        {
          'icon': Icons.inventory_2_outlined,
          'label': tr('my_assets'),
          'key': 'assets',
          'onTap': () => Get.to(const AssetScreen()),
        },
      ];

      // Add manager-only items if user is a manager
      if (model.isManager.value) {
        actions.add({
          'icon': Icons.people_outline,
          'label': tr('subordinates_data'),
          'key': 'subordinates_data',
          'onTap': () => model.goToSubordinatesDataScreen(),
        });
        actions.add({
          'icon': Icons.check_circle_outline,
          'label': tr('approval'),
          'key': 'approval',
          'onTap': () => Get.to(const ApprovalScreen()),
        });
        actions.add({
          'icon': Icons.pending_actions_outlined,
          'label': tr('un_executed'),
          'key': 'unexecuted_requests',
          'onTap': () => Get.to(const UnexecutedRequestsScreen()),
        });
        actions.add({
          'icon': Icons.calendar_view_week_outlined,
          'label': tr('weekly_shift_schedule'),
          'key': 'schedule',
          'onTap': () => Get.to(const WeeklyShiftScheduleScreen()),
        });
      }

      return Builder(
        builder: (context) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.getResponsiveValue<int>(
                context,
                mobile: 3,
                tablet: 4,
                desktop: 5
              ),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.0,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              Widget actionButton = AppTheme.buildActionButton(
                icon: action['icon'] as IconData,
                label: action['label'] as String,
                color: AppTheme.getActionColor(action['key'] as String),
                onTap: action['onTap'] as VoidCallback,
                context: context,
              );

              return actionButton;
            },
          );
        },
      );
    });
  }

}