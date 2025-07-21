import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/view/payroll/payroll_screen.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import 'package:injazat_hr_app/utils/screen_themes.dart';

import '../../../data/local/preferences.dart';
import '../../attendance/clocking_screen.dart';
import '../../document/document_screen.dart';
import '../../schedule/schedule_screen.dart';
import '../homescreen_controller.dart';
import 'package:injazat_hr_app/view/request_leave/request_home_screen.dart';

class HomeScreenWidget extends StatelessWidget {
  const HomeScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Get.find<HomeScreenController>();
    return RefreshIndicator(
      onRefresh: () async {
        await model.getDashboardFromApi();
      },
      child: ScreenThemes.buildHomeScreenContainer(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header
              const SizedBox(height: 30),

              // Welcome Section
              ScreenThemes.buildWelcomeCard(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tr('welcome')} 👋',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      model.userName.value.isNotEmpty ? model.userName.value : 'User',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )),
              ),

              const SizedBox(height: 25),

              // Face ID Attendance Section
              _buildFaceIdAttendanceSection(),

              const SizedBox(height: 40),

              // What would you like to do section
              Text(
                tr('what_would_you_like_to_do'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),

              const SizedBox(height: 25),

              // Action Buttons Grid
              _buildActionGrid(),

              const SizedBox(height: 40),

              // Pending Requests Section
              Text(
                tr('pending_requests'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),

              const SizedBox(height: 20),

              // Pending Request Card
              _buildPendingRequestCard(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
    );
  }

  // Header section with profile and notifications
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(15),
                  bottomLeft: Radius.circular(5),
                ),
                gradient: const LinearGradient(
                  colors: [AppTheme.secondaryColor, Color(0xCC4ECDC4)],
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppTheme.secondaryColor, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('good_morning'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Text(
                  'Sarah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(12),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              // Handle notification tap
            },
            icon: Icon(Icons.notifications_outlined, color: AppTheme.secondaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildFaceIdAttendanceSection() {
    return ScreenThemes.buildFaceIdCard(
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.face_retouching_natural,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('face_id_attendance'),
                      style: AppTheme.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('secure_attendance_with_face_verification'),
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Face ID Scan Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.to(const ClockingScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.accentColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.face_outlined, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    tr('scan_face_for_attendance'),
                    style: AppTheme.buttonText.copyWith(
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    final actions = [
      {'icon': Icons.assignment_outlined, 'label': tr('requests'), 'key': 'requests'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': tr('payroll'), 'key': 'payroll'},
      {'icon': Icons.description_outlined, 'label': tr('documents'), 'key': 'documents'},
      {'icon': Icons.access_time_outlined, 'label': tr('attendance'), 'key': 'attendance'},
      {'icon': Icons.calendar_month_outlined, 'label': tr('schedule'), 'key': 'schedule'},
      {'icon': Icons.person_outline_rounded, 'label': tr('profile'), 'key': 'profile'},
    ];

    // List of navigation functions - Fixed to match the number of actions
    final List<VoidCallback> navigationFunctions = [
          () => Get.to(const RequestHomeScreen()),
          ()  => Get.to(const PayrollScreen()),
          () => Get.to(const DocumentScreen()),
          () => Get.find<HomeScreenController>().goToAttendanceDetailScreen(),
          () => Get.to(const ScheduleScreen()),
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
        return AppTheme.buildActionButton(
          icon: action['icon'] as IconData,
          label: action['label'] as String,
          color: AppTheme.getActionColor(action['key'] as String),
          onTap: navigationFunctions[index],
        );
      },
    );
  }


  Widget _buildPendingRequestCard() {
    return Builder(
      builder: (context) => AppTheme.buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Oct 16, 2020 - Oct 18, 2020',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(2),
                      bottomRight: Radius.circular(8),
                      bottomLeft: Radius.circular(2),
                    ),
                  ),
                  child: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).iconTheme.color,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Going on a vacation',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F7FA), // Light cyan background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(12),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: const Text(
                  'Annual leave',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF8E1), // Light yellow background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(4),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.warningColor, // Yellow warning color
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}