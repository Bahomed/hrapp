import 'package:injazat_hr_app/utils/alertbox.dart';
import 'package:injazat_hr_app/view/attendance/attendance_detail_screen.dart';
import 'package:injazat_hr_app/view/attendance/attendance_calendar_screen.dart';
import 'package:injazat_hr_app/view/holidayscreen/holiday_screen.dart';
import 'package:injazat_hr_app/view/home_screen/widget/homescreenwidget.dart';
import 'package:injazat_hr_app/view/notifications_screen/notification_screen.dart';
import 'package:injazat_hr_app/view/settings/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/preferences.dart';
import '../../repository/dashboardrepository.dart';
import '../profile/profile_screen.dart';
import '../document/document_upload_controller.dart';

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

    getDashboardFromApi();
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

        // Debug print to verify data loading
        print('User data loaded:');
        print('Name: ${userName.value}');
        print('Email: ${userEmail.value}');
        print('Image: ${userImage.value}');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Add method to refresh user data if needed
  Future<void> refreshUserData() async {
    await loadUserData();
  }

  RxInt bottomNavIndex = 1.obs;

  final pages = [
    const HolidayScreen(),
    const HomeScreenWidget(),
    const NotificationScreen()
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

  Future<void> getDashboardFromApi() async {
    try {
      var response = await repository.dashBoardFromApi();
      noticeString.value = response.data.noticeBirthday.trim();
      bannerImage.value = response.data.bannerImage;
      companyName.value = response.data.companyDetail.name;
      companyAddress.value = response.data.companyDetail.address;
      companyImage.value = response.data.companyDetail.image;
      bannerUrl.value = response.data.bannerurl;
      repository
          .saveCheckPassword(response.data.checkPassword == "0" ? false : true);
      repository.saveAppPassword(response.data.appPassword);
      repository.saveCompanyDetail(
          response.data.companyDetail.name,
          response.data.companyDetail.address,
          response.data.companyDetail.image);
    } catch (e) {
      showAlert(e.toString());
    }
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
    // Check if any file picker is active
    // bool isFilePickerActive = false;
    // try {
    //   final uploadController = Get.find<DocumentUploadController>();
    //   isFilePickerActive = uploadController.isPickingFile.value;
    // } catch (e) {
    //   // DocumentUploadController not found, continue normally
    // }
    //
    //
    // // Also refresh user data when app is resumed
    // loadUserData();
  }
}