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
import 'app_settings_controller.dart';
import '../chat/conversations_controller.dart';
import '../chat/chat_unread_controller.dart';
import 'widget/portal_home_summary.dart';

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

    // Mobile Settings (home tiles, clock-in) — every time the home opens.
    final settings = AppSettingsController.to;
    // New session (login / another user): never show the last user's data.
    settings.reset();
    PortalHomeController.to.reset();
    ever(settings.homeItems, (_) => _clampNavIndex());
    settings.reload();
    PortalHomeController.to.reload();

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


  /// Bottom bar tabs. `holidays` and `chat` follow Mobile Settings
  /// (home_items); `home` and `notifications` are always shown.
  static const allTabs = ['holidays', 'home', 'chat', 'notifications'];

  /// Selected tab key (index-free so hiding a tab never shifts the selection).
  final RxString currentTab = 'home'.obs;

  List<String> get visibleTabs {
    final s = AppSettingsController.to;
    return allTabs
        .where((t) => (t != 'holidays' && t != 'chat') || s.isOn(t))
        .toList();
  }

  /// Index of [currentTab] in [visibleTabs] (for the curved bar).
  int get bottomNavIndexValue {
    final i = visibleTabs.indexOf(currentTab.value);
    return i < 0 ? visibleTabs.indexOf('home') : i;
  }

  void selectTabIndex(int index) {
    final tabs = visibleTabs;
    if (index < 0 || index >= tabs.length) return;
    final previous = currentTab.value;
    currentTab.value = tabs[index];
    // The embedded chat list is not a route, so GetX never disposes it:
    // delete it on leaving the tab, or it keeps polling every 15 s.
    if (previous == 'chat' && currentTab.value != 'chat' &&
        Get.isRegistered<ConversationsController>()) {
      Get.delete<ConversationsController>();
    }
    if (Get.isRegistered<ChatUnreadController>()) {
      Get.find<ChatUnreadController>().setChatOpen(currentTab.value == 'chat');
    }
    if (currentTab.value == 'home') {
      AppSettingsController.to.reload();
      PortalHomeController.to.reload();
    }
  }

  void _clampNavIndex() {
    if (!visibleTabs.contains(currentTab.value)) currentTab.value = 'home';
  }

  Widget pageFor(String tab) {
    switch (tab) {
      case 'holidays':
        return const HolidayScreen();
      case 'chat':
        return const ConversationsScreen(embedded: true);
      case 'notifications':
        return const NotificationScreen();
      default:
        return const HomeScreenWidget();
    }
  }







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
    if (currentTab.value == 'home') {
      AppSettingsController.to.reload();
      PortalHomeController.to.reload();
    }
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