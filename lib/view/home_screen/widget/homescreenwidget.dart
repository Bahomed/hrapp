import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:injazat_hr_app/view/payroll/payroll_screen.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import 'package:injazat_hr_app/utils/screen_themes.dart';
import 'package:injazat_hr_app/utils/responsive_utils.dart';

import '../../attendance/clocking_screen.dart';
import '../../document/document_screen.dart';
import '../../schedule/schedule_screen.dart';
import '../homescreen_controller.dart';
import 'package:injazat_hr_app/view/request_leave/request_home_screen.dart';
import 'package:injazat_hr_app/view/approval/approval_screen.dart';
import 'package:injazat_hr_app/view/unexecuted_requests/unexecuted_requests_screen.dart';

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
                // Top Header
                const SizedBox(height: 5),

                // Face ID Attendance Section
                _buildFaceIdAttendanceSection(),

                const SizedBox(height: 25),

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

                const SizedBox(height: 25),

                // Action Buttons Grid
                _buildActionGrid(),

                const SizedBox(height: 40),



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
              Get.to(const ClockingScreen());
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
        'icon': Icons.check_circle_outline,
        'label': tr('approval'),
        'key': 'approval'
      },
      {
        'icon': Icons.pending_actions_outlined,
        'label': tr('un_executed'),
        'key': 'unexecuted_requests'
      },
      {
        'icon': Icons.person_outline_rounded,
        'label': tr('profile'),
        'key': 'profile'
      },
    ];

    // List of navigation functions - Fixed to match the number of actions
    final List<VoidCallback> navigationFunctions = [
          () => Get.to(const RequestHomeScreen()),
          () => Get.to(const PayrollScreen()),
          () => Get.to(const DocumentScreen()),
          () => Get.find<HomeScreenController>().goToAttendanceDetailScreen(),
          () => Get.to(const ScheduleScreen()),
          () => Get.to(const ApprovalScreen()),
          () => Get.to(const UnexecutedRequestsScreen()),
          () => Get.find<HomeScreenController>().goToProfileScreen(),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        Widget actionButton = AppTheme.buildActionButton(
          icon: action['icon'] as IconData,
          label: action['label'] as String,
          color: AppTheme.getActionColor(action['key'] as String),
          onTap: navigationFunctions[index],
        );


        return actionButton;
      },
    );
  }

}