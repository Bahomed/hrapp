import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/local/preferences.dart';
import '../../data/remote/response/login_response.dart';
import '../../repository/logoutrepository.dart';
import '../../repository/userrepositiory.dart';
import '../login_screen/login_screen.dart';
import '../../services/theme_service.dart';
import '../attendancescreen/attendancecontroller.dart';
import '../document/document_controller.dart';
import '../payroll/payroll_controller.dart';
import '../request_leave/request_controller.dart';
import '../schedule/schedule_controller.dart';
import '../workspace/workspace_controller.dart';
import '../notifications_screen/notification_controller.dart';
import '../holidayscreen/holidayscreencontroller.dart';
import '../attendance/clocking_controller.dart';
import '../attendance/face_verify_controller.dart';
import '../attendance/attendance_calendar_controller.dart';
import '../document/document_upload_controller.dart';

class ProfileController extends GetxController {
  final Preferences _preferences = Preferences();
  final LogoutRepository _logoutRepository = LogoutRepository();
  final UserRepositiory _userRepository = UserRepositiory();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;
  final Rx<Data?> userData = Rx<Data?>(null);

  // Text controllers for editable fields
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final currentAddressController = TextEditingController();
  final permanentAddressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    currentAddressController.dispose();
    permanentAddressController.dispose();
    super.onClose();
  }

  // Load user profile data
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      final user = await _preferences.getUserData();
      
      if (user != null) {
        userData.value = user;
        _populateControllers();
      } else {
        _showErrorSnackbar('No user data found');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Populate text controllers with user data
  void _populateControllers() {
    final user = userData.value;
    if (user != null) {
      nameController.text = user.employeeName ?? '';
      emailController.text = user.email ?? '';
      mobileController.text = user.mobileNo ?? '';
      currentAddressController.text = user.currentAddress ?? '';
      permanentAddressController.text = user.permanentAddress ?? '';
    }
  }

  // Toggle edit mode
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      // Reset controllers to original values when canceling edit
      _populateControllers();
    }
  }

  // Save profile changes
  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      
      final currentUser = userData.value;
      if (currentUser == null) {
        _showErrorSnackbar('No user data available');
        return;
      }

      // Create updated user data
      final updatedUser = Data(
        id: currentUser.id,
        fcmId: currentUser.fcmId,
        employeeName: nameController.text.trim(),
        mobileNo: mobileController.text.trim(),
        iqamaNo: currentUser.iqamaNo,
        employeeNo: currentUser.employeeNo,
        image: currentUser.image,
        gender: currentUser.gender,
        email: emailController.text.trim(),
        preferredLang: currentUser.preferredLang,
        age: currentUser.age,
        civilStatus: currentUser.civilStatus,
        nationality: currentUser.nationality,
        placeOfBirth: currentUser.placeOfBirth,
        passportNo: currentUser.passportNo,
        position: currentUser.position,
        positionIqamaPassport: currentUser.positionIqamaPassport,
        department: currentUser.department,
        section: currentUser.section,
        localCountry: currentUser.localCountry,
        homeCountry: currentUser.homeCountry,
        currentAddress: currentAddressController.text.trim(),
        permanentAddress: permanentAddressController.text.trim(),
        token: currentUser.token,
        appPassword: currentUser.appPassword,
      );

      // Call API to update profile
      var response = await _userRepository.updateUserProfile(
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        currentAddress: currentAddressController.text.trim(),
        permanentAddress: permanentAddressController.text.trim(),
      );
      
      // Check if API call was successful
      if (response.status == true || response.statusCode == 200) {
        // Update local data with response data if available
        if (response.data != null) {
          userData.value = response.data;
        } else {
          // Fallback to local update if no response data
          await _preferences.saveUserData(updatedUser);
          userData.value = updatedUser;
        }
        
        isEditing.value = false;
        _showSuccessSnackbar('Profile updated successfully');
      } else {
        // API returned error
        throw Exception(response.message);
      }
      
    } catch (e) {
      _showErrorSnackbar('Error saving profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  // Helper methods for getting user info
  String get userName => userData.value?.employeeName ?? 'N/A';
  String get userEmail => userData.value?.email ?? 'N/A';
  String get userMobile => userData.value?.mobileNo ?? 'N/A';
  String get userEmployeeNo => userData.value?.employeeNo ?? 'N/A';
  String get userIqamaNo => userData.value?.iqamaNo ?? 'N/A';
  String get userPosition => userData.value?.position ?? 'N/A';
  String get userDepartment => userData.value?.department ?? 'N/A';
  String get userSection => userData.value?.section ?? 'N/A';
  String get userGender => userData.value?.gender ?? 'N/A';
  String get userNationality => userData.value?.nationality ?? 'N/A';
  String get userAge => userData.value?.age?.toString() ?? 'N/A';
  String get userCivilStatus => userData.value?.civilStatus ?? 'N/A';
  String get userPlaceOfBirth => userData.value?.placeOfBirth ?? 'N/A';
  String get userPassportNo => userData.value?.passportNo ?? 'N/A';
  String get userLocalCountry => userData.value?.localCountry ?? 'N/A';
  String get userHomeCountry => userData.value?.homeCountry ?? 'N/A';
  String get userCurrentAddress => userData.value?.currentAddress ?? 'N/A';
  String get userPermanentAddress => userData.value?.permanentAddress ?? 'N/A';
  String get userImage => userData.value?.image ?? '';
  String get userPreferredLang => userData.value?.preferredLang ?? 'N/A';

  // Profile sections for organized display
  List<ProfileSection> get profileSections {
    return [
      ProfileSection(
        title: 'Personal Information',
        icon: Icons.person,
        color: const Color(0xFF42A5F5),
        items: [
          ProfileItem('Employee Name', userName, isEditable: false),
          ProfileItem('Employee No', userEmployeeNo),
          ProfileItem('Email', userEmail, isEditable: true),
          ProfileItem('Mobile', userMobile, isEditable: true),
          ProfileItem('Gender', userGender),
          ProfileItem('Age', userAge),
          ProfileItem('Civil Status', userCivilStatus),
          ProfileItem('Nationality', userNationality),
          ProfileItem('Place of Birth', userPlaceOfBirth),
        ],
      ),
      ProfileSection(
        title: 'Work Information',
        icon: Icons.work,
        color: const Color(0xFF4CAF50),
        items: [
          ProfileItem('Position', userPosition),
          ProfileItem('Department', userDepartment),
          ProfileItem('Section', userSection),
        ],
      ),
      ProfileSection(
        title: 'Identification',
        icon: Icons.badge,
        color: const Color(0xFFFF9800),
        items: [
          ProfileItem('Iqama No', userIqamaNo),
          ProfileItem('Passport No', userPassportNo),
        ],
      ),
      ProfileSection(
        title: 'Address Information',
        icon: Icons.location_on,
        color: const Color(0xFF9C27B0),
        items: [
          ProfileItem('Current Address', userCurrentAddress, isEditable: true),
          ProfileItem('Permanent Address', userPermanentAddress, isEditable: true),
          ProfileItem('Local Country', userLocalCountry),
          ProfileItem('Home Country', userHomeCountry),
        ],
      ),
      ProfileSection(
        title: 'Preferences',
        icon: Icons.settings,
        color: const Color(0xFF607D8B),
        items: [
          ProfileItem('Preferred Language', userPreferredLang),
        ],
      ),
    ];
  }

  // Logout functionality
  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _performLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Color(0xFFF44336))),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      isLoading.value = true;
      
      // Call API logout with null safety
      try {
        final response = await _logoutRepository.logOutApi();
        if (response != null && response.status == 1) {
          print('Logout API successful: ${response.message}');
        }
      } catch (apiError) {
        print('Logout API error (continuing with local cleanup): $apiError');
      }
      
      // Clear ALL local data and reset all controllers
      await _clearAllAppData();
      
      _showSuccessSnackbar('Logged out successfully');
      
      // Navigate to login screen and clear all routes
      Get.offAll(() => LoginScreen());
    } catch (e) {
      // Even if logout API fails, still clear local data
      try {
        await _clearAllAppData();
      } catch (clearError) {
        print('Error clearing app data: $clearError');
      }
      _showErrorSnackbar('Logout completed with errors: $e');
      Get.offAll(() => LoginScreen());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearAllAppData() async {
    try {
      // Clear all stored preferences data
      await _preferences.clearAllAppData();
      
      // Reset all GetX controllers that might be registered
      _resetAllControllers();
      
      // Clear any cached data
      await _clearCachedData();
      
    } catch (e) {
      print('Error clearing app data: $e');
    }
  }

  void _resetAllControllers() {
    try {
      // Reset specific controllers if they exist
      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>(force: true);
      }
      
      // Reset attendance controllers
      if (Get.isRegistered<AttendanceController>()) {
        Get.delete<AttendanceController>(force: true);
      }
      
      // Reset document controller
      if (Get.isRegistered<DocumentController>()) {
        Get.delete<DocumentController>(force: true);
      }
      
      // Reset payroll controller
      if (Get.isRegistered<PayrollController>()) {
        Get.delete<PayrollController>(force: true);
      }
      
      // Reset request controller
      if (Get.isRegistered<RequestController>()) {
        Get.delete<RequestController>(force: true);
      }
      
      // Reset schedule controller
      if (Get.isRegistered<ScheduleController>()) {
        Get.delete<ScheduleController>(force: true);
      }
      
      // Don't reset theme service - it's a core service that should persist
      // ThemeService should remain available across login/logout cycles
      
      // Don't reset workspace controller - workspace should persist
      // WorkspaceController manages workspace settings that should remain across login/logout
      
      // Reset notification controller
      if (Get.isRegistered<NotificatiionController>()) {
        Get.delete<NotificatiionController>(force: true);
      }
      
      // Reset holiday controller
      if (Get.isRegistered<HolidayScreenController>()) {
        Get.delete<HolidayScreenController>(force: true);
      }
      
      // Reset clocking controller
      if (Get.isRegistered<ClockingController>()) {
        Get.delete<ClockingController>(force: true);
      }
      
      // Reset face verify controller
      if (Get.isRegistered<FaceVerifyController>()) {
        Get.delete<FaceVerifyController>(force: true);
      }
      
      // Reset attendance calendar controller
      if (Get.isRegistered<AttendanceCalendarController>()) {
        Get.delete<AttendanceCalendarController>(force: true);
      }
      
      // Reset document upload controller
      if (Get.isRegistered<DocumentUploadController>()) {
        Get.delete<DocumentUploadController>(force: true);
      }
      
    } catch (e) {
      print('Error resetting controllers: $e');
    }
  }

  Future<void> _clearCachedData() async {
    try {
      // Clear any additional cached data here
      // This could include temporary files, cached images, etc.
      
      // Reset reactive variables
      userData.value = null;
      isEditing.value = false;
      
      // Clear text controllers
      nameController.clear();
      emailController.clear();
      mobileController.clear();
      currentAddressController.clear();
      permanentAddressController.clear();
      
    } catch (e) {
      print('Error clearing cached data: $e');
    }
  }

  // Snackbar helpers
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}

// Helper classes for organizing profile data
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
  final bool isEditable;

  ProfileItem(this.label, this.value, {this.isEditable = false});
}