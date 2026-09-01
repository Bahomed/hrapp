import 'package:co.injazathr.injazathr/utils/alertbox.dart';
import 'package:co.injazathr.injazathr/view/attendance/attendance_detail_screen.dart';
import 'package:co.injazathr.injazathr/view/attendance/attendance_calendar_screen.dart';
import 'package:co.injazathr.injazathr/view/holidayscreen/holiday_screen.dart';
import 'package:co.injazathr.injazathr/view/home_screen/widget/homescreenwidget.dart';
import 'package:co.injazathr.injazathr/view/notifications_screen/notification_screen.dart';
import 'package:co.injazathr.injazathr/view/chat/conversations_screen.dart';
import 'package:co.injazathr.injazathr/services/notification_service.dart';
import 'package:co.injazathr.injazathr/view/settings/settings_screen.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/auth_interceptor.dart';
import 'package:co.injazathr.injazathr/view/login_screen/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/preferences.dart';
import '../../repository/dashboardrepository.dart';
import '../profile/profile_screen.dart';
import '../document/document_upload_controller.dart';
import '../Manager/subordinates/subordinates_data_screen.dart';

class HomeScreenController extends SuperController {
  final repository = DashboardRepository();
  final preferences = Preferences(); // Add preferences instance

  var noticeString = "".obs;
  var bannerImage = "".obs;
  var bannerUrl = "".obs;
  var companyName = "".obs;
  var companyAddress = "".obs;
  var companyImage = "".obs;

  // Add user image observable
  var userImage = "".obs;
  var userName = "".obs;
  var userEmail = "".obs;
  var greetingText = "".obs;
  var isManager = false.obs;

  final controller = ScrollController();

  @override
  Future<void> onInit() async {
    controller.addListener(loadmore);

    // Load company data
    companyName.value = await repository.getCompanyName();
    companyAddress.value = await repository.getAddress();
    companyImage.value = await repository.getCompanyImage();

    // Load user data
    await loadUserData();

    // Load greeting
    await loadGreeting();

    // Handle any push notification tap that arrived before the navigator was ready
    // (terminated state or background tap during splash)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.handlePendingNavigation();
    });

    super.onInit();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void loadmore() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      // Remove dashboard API call from scroll - this should be for pagination only
      // getDashboardFromApi();
    }
  }

  // Add method to load user data
  Future<void> loadUserData() async {
    try {
      final userData = await preferences.getUserData();
      if (userData != null) {
        userImage.value = userData.image ?? '';
        userName.value = userData.employeeName ?? '';
        userEmail.value = userData.email ?? '';
        isManager.value = userData.manager ?? false;

        // Debug print to verify data loading
      }
    } catch (e) {
    }
  }

  // Add method to refresh user data if needed
  Future<void> refreshUserData() async {
    await loadUserData();
    await loadGreeting(); // Also refresh greeting when refreshing user data
  }

  // Add method to load greeting from API
  Future<void> loadGreeting() async {
    try {
      final locale = Get.locale?.languageCode ?? 'en';
      final datetime = DateTime.now().toIso8601String();


      final greeting = await repository.getGreeting(
        locale: locale,
        datetime: datetime,
      );

      greetingText.value = greeting;
    } catch (e) {
    }
  }


  RxInt bottomNavIndex = 1.obs;

  final pages = [
    const HolidayScreen(),
    const HomeScreenWidget(),
    const ConversationsScreen(embedded: true),
    const NotificationScreen(),
  ];







  void goToProfileScreen() {
    Get.to(const ProfileScreen());
  }
  void goToNotificationScreen() {
    Get.to(const NotificationScreen());
  }

  void goToHolidayScreen() {
    Get.to(const HolidayScreen());
  }

  void goToAttendanceDetailScreen() {
    Get.to(const AttendanceDetailScreen());
  }

  void goToSettingsScreen() {
    Get.to(const SettingsScreen());
  }

  void goToSubordinatesDataScreen() {
    Get.to(const SubordinatesDataScreen());
  }


  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void onInactive() {
    // TODO: implement onInactive
  }

  @override
  void onPaused() {
    // TODO: implement onPaused
  }

  DateTime? lastDashboardCall;

  @override
  void onResumed() {
    _checkTokenOnResume();
  }

  void _checkTokenOnResume() async {
    if (await preferences.isTokenExpired()) {
      final refreshed = await AuthInterceptor.refreshTokenOnce(preferences);
      if (!refreshed) {
        await preferences.clearLoginSession();
        Get.offAll(() => LoginScreen());
      }
    }
  }
}