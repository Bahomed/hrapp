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
import '../../schedule/manager_weekly_shift_schedule_screen.dart';
import '../../tasks/tasks_screen.dart';
import '../../my_portal/leave_balance_screen.dart';
import '../../my_portal/earned_leave_balance_screen.dart';
import '../../overtime/assigned_overtime_screen.dart';
import '../app_settings_controller.dart';
import 'portal_home_summary.dart';

class HomeScreenWidget extends StatelessWidget {
  const HomeScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Get.find<HomeScreenController>();
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          model.loadGreeting(),
          AppSettingsController.to.reload(),
          PortalHomeController.to.reload(),
        ]);

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

                // Today / overtime / KPI cards, as the web My Portal home.
                const PortalHomeSummary(),

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
    // Hidden when Settings › Mobile › Allow Mobile Clock-In is off.
    return Obx(() => AppSettingsController.to.allowClockIn.value
        ? _buildFaceIdButton()
        : const SizedBox.shrink());
  }

  Widget _buildFaceIdButton() {
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
    final settings = AppSettingsController.to;

    return Obx(() {
      // Touch the observables so the grid rebuilds when settings arrive.
      settings.homeItems.length;
      final isManager = model.isManager.value;

      // `setting` = the home_items key from GET my/app-settings.
      // `key` = colour key for AppTheme.getActionColor (unchanged).
      final all = <Map<String, dynamic>>[
        {
          'icon': Icons.assignment_outlined,
          'label': tr('requests'),
          'key': 'requests',
          'setting': 'requests',
          'onTap': () => Get.to(const RequestHomeScreen()),
        },
        {
          'icon': Icons.account_balance_wallet_outlined,
          'label': tr('payroll'),
          'key': 'payroll',
          'setting': 'payroll',
          'onTap': () => Get.to(const PayrollScreen()),
        },
        {
          'icon': Icons.description_outlined,
          'label': tr('documents'),
          'key': 'documents',
          'setting': 'documents',
          'onTap': () => Get.to(const DocumentScreen()),
        },
        {
          'icon': Icons.access_time_outlined,
          'label': tr('attendance'),
          'key': 'attendance',
          'setting': 'attendance',
          'onTap': () => model.goToAttendanceDetailScreen(),
        },
        {
          'icon': Icons.payments_outlined,
          'label': tr('compensation'),
          'key': 'compensation',
          'setting': 'compensation',
          'onTap': () => Get.to(const CompensationScreen()),
        },
        {
          'icon': Icons.person_outline_rounded,
          'label': tr('profile'),
          'key': 'profile',
          'setting': 'profile',
          'onTap': () => model.goToProfileScreen(),
        },
        {
          'icon': Icons.inventory_2_outlined,
          'label': tr('my_assets'),
          'key': 'assets',
          'setting': 'my_assets',
          'onTap': () => Get.to(const AssetScreen()),
        },
        {
          'icon': Icons.calendar_today_outlined,
          'label': tr('weekly_shift_schedule'),
          'key': 'schedule',
          'setting': 'weekly_shift_schedule',
          'onTap': () => Get.to(const WeeklyShiftScheduleScreen()),
        },
        {
          'icon': Icons.beach_access_outlined,
          'label': tr('leave_balance'),
          'key': 'leave_balance',
          'setting': 'leave_balance',
          'onTap': () => Get.to(const LeaveBalanceScreen()),
        },
        {
          'icon': Icons.event_available_outlined,
          'label': tr('earned_leave_balance'),
          'key': 'earned_leave_balance',
          'setting': 'earned_leave_balance',
          'visible': settings.earnedLeaveEnabled.value,
          'onTap': () => Get.to(const EarnedLeaveBalanceScreen()),
        },
        {
          'icon': Icons.more_time_outlined,
          'label': tr('my_overtime'),
          'key': 'my_overtime',
          'setting': 'my_overtime',
          'badge': settings.overtimePendingCount.value,
          'onTap': () => Get.to(const AssignedOvertimeScreen())
              ?.then((_) => PortalHomeController.to.reload()),
        },
        {
          'icon': Icons.task_alt_outlined,
          'label': tr('tasks'),
          'key': 'tasks',
          'setting': 'tasks',
          'visible': settings.hasTasksAccess.value,
          'onTap': () => Get.to(const TasksScreen()),
        },
        // Approvals: anyone can be an approver (not only managers).
        {
          'icon': Icons.check_circle_outline,
          'label': tr('approval'),
          'key': 'approval',
          'setting': 'awaiting_approval',
          'visible': isManager ||
              settings.approvalsCount.value > 0 ||
              settings.payrollsCount.value > 0,
          'badge': settings.approvalsCount.value,
          'onTap': () =>
              Get.to(const ApprovalScreen())?.then((_) => settings.reload()),
        },
        // Payments waiting for me (Settings › Task Responsibility).
        {
          'icon': Icons.pending_actions_outlined,
          'label': tr('un_executed'),
          'key': 'unexecuted_requests',
          'setting': 'not_executed',
          'visible': isManager || settings.notExecutedCount > 0,
          'badge': settings.notExecutedCount,
          'onTap': () => Get.to(const UnexecutedRequestsScreen())
              ?.then((_) => settings.reload()),
        },
        {
          'icon': Icons.people_outline,
          'label': tr('subordinates_data'),
          'key': 'subordinates_data',
          'setting': 'subordinates',
          'visible': isManager,
          'onTap': () => model.goToSubordinatesDataScreen(),
        },
        {
          'icon': Icons.calendar_view_week_outlined,
          'label': tr('manager_shift_schedule'),
          'key': 'manager_schedule',
          'setting': 'employees_shift_schedule',
          'visible': isManager,
          'onTap': () => Get.to(const ManagerWeeklyShiftScheduleScreen()),
        },
      ];

      final actions = all
          .where((a) =>
              (a['visible'] as bool? ?? true) &&
              settings.isOn(a['setting'] as String))
          .toList();

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

              final badge = action['badge'] as int? ?? 0;
              if (badge <= 0) return actionButton;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: actionButton),
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      constraints: const BoxConstraints(minWidth: 20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge > 99 ? '99+' : '$badge',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }

}