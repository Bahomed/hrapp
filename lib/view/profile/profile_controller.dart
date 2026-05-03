import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../data/local/preferences.dart';
import '../../data/remote/response/login_response.dart';
import '../../repository/employees_repository.dart';
import '../../repository/logoutrepository.dart';
import '../../repository/userrepositiory.dart';
import '../login_screen/login_screen.dart';
import '../../services/theme_service.dart';
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
  final EmployeesRepository _employeesRepository = EmployeesRepository();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool isEditing = false.obs;
  final Rx<Data?> userData = Rx<Data?>(null);

  // Leave balance
  final isLoadingBalance = false.obs;
  final vacationBalance = 0.0.obs;
  final balanceError = ''.obs;

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
        if (user.id != null) loadLeaveBalance(user.id!);
      } else {
        _showErrorSnackbar(tr('no_user_data_found'));
      }
    } catch (e) {
      _showErrorSnackbar(tr('error_loading_profile') + ': $e');
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

  Future<void> loadLeaveBalance(int empId) async {
    isLoadingBalance.value = true;
    balanceError.value = '';
    try {
      final response = await _employeesRepository.getLeaveBalance(empId);
      vacationBalance.value = response.vacationBalance;
    } catch (e) {
      balanceError.value = e.toString();
    } finally {
      isLoadingBalance.value = false;
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
        _showErrorSnackbar(tr('no_user_data_available'));
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
        localCity: currentUser.localCity,
        homeCountry: currentUser.homeCountry,
        homeCity: currentUser.homeCity,
        currentAddress: currentAddressController.text.trim(),
        permanentAddress: permanentAddressController.text.trim(),
        token: currentUser.token,
        reportToEmployee: currentUser.reportToEmployee,
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
        _showSuccessSnackbar(tr('profile_updated_successfully'));
      } else {
        // API returned error
        throw Exception(response.message);
      }
      
    } catch (e) {
      _showErrorSnackbar(tr('error_saving_profile') + ': $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  // Pick and upload profile picture
  Future<void> changeProfilePicture() async {
    try {
      final ImagePicker picker = ImagePicker();

      // Show dialog to choose between camera and gallery
      await Get.dialog(
        Builder(
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(tr('change_profile_picture')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.camera_alt, color: ThemeService.instance.getPrimaryColor()),
                  title: Text(tr('take_photo')),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? photo = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85,
                    );
                    if (photo != null) {
                      await _uploadProfilePicture(photo.path);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library, color: ThemeService.instance.getPrimaryColor()),
                  title: Text(tr('choose_from_gallery')),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      await _uploadProfilePicture(image.path);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      _showErrorSnackbar(tr('error_selecting_image') + ': $e');
    }
  }

  // Upload profile picture to server
  Future<void> _uploadProfilePicture(String imagePath) async {
    try {
      isLoading.value = true;

      var response = await _userRepository.uploadProfilePicture(imagePath);

      if (response.status == true || response.statusCode == 200) {
        // Update local data with response data if available
        if (response.data != null) {
          userData.value = response.data;
          await _preferences.saveUserData(response.data!);
        }

        _showSuccessSnackbar(tr('profile_picture_updated'));
        await refreshProfile();
      } else {
        throw Exception(response.message ?? tr('failed_to_upload_image'));
      }
    } catch (e) {
      _showErrorSnackbar(tr('error_uploading_image') + ': $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods for getting user info
  String get userName => userData.value?.employeeName ?? tr('n_a');
  String get userEmail => userData.value?.email ?? tr('n_a');
  String get userMobile => userData.value?.mobileNo ?? tr('n_a');
  String get userEmployeeNo => userData.value?.employeeNo ?? tr('n_a');
  String get userIqamaNo => userData.value?.iqamaNo ?? tr('n_a');
  String get userPosition => userData.value?.position ?? tr('n_a');
  String get userDepartment => userData.value?.department ?? tr('n_a');
  String get userSection => userData.value?.section ?? tr('n_a');
  String get userGender => userData.value?.gender ?? tr('n_a');
  String get userNationality => userData.value?.nationality ?? tr('n_a');
  String get userAge => userData.value?.age?.toString() ?? tr('n_a');
  String get userCivilStatus => userData.value?.civilStatus ?? tr('n_a');
  String get userPlaceOfBirth => userData.value?.placeOfBirth ?? tr('n_a');
  String get userPassportNo => userData.value?.passportNo ?? tr('n_a');
  String get userLocalCountry => userData.value?.localCountry ?? tr('n_a');
  String get userLocalCity=> userData.value?.localCity ?? tr('n_a');
  String get userHomeCountry => userData.value?.homeCountry ?? tr('n_a');
  String get userHomeCity => userData.value?.homeCity?? tr('n_a');
  String get userCurrentAddress => userData.value?.currentAddress ?? tr('n_a');
  String get userPermanentAddress => userData.value?.permanentAddress ?? tr('n_a');
  String get userImage => userData.value?.image ?? '';
  String get userHiredDate => userData.value?.hiredDate ?? '';
  String get userPreferredLang => userData.value?.preferredLang ?? tr('n_a');
  String get userReportToEmployee=> userData.value?.reportToEmployee?? tr('n_a');

  // Profile sections for organized display
  List<ProfileSection> get profileSections {
    return [
      ProfileSection(
        title: tr('personal_information'),
        icon: Icons.person,
        color: const Color(0xFF42A5F5),
        items: [
          ProfileItem(tr('employee_name'), userName, isEditable: false),
          ProfileItem(tr('employee_no'), userEmployeeNo),
          ProfileItem(tr('email'), userEmail, isEditable: true),
          ProfileItem(tr('mobile'), userMobile, isEditable: true),
          ProfileItem(tr('gender'), userGender),
          ProfileItem(tr('age'), userAge),
          ProfileItem(tr('civil_status'), userCivilStatus),
          ProfileItem(tr('nationality'), userNationality),
          ProfileItem(tr('place_of_birth'), userPlaceOfBirth),
        ],
      ),
      ProfileSection(
        title: tr('work_information'),
        icon: Icons.work,
        color: const Color(0xFF4CAF50),
        items: [
          ProfileItem(tr('position'), userPosition),
          ProfileItem(tr('department'), userDepartment),
          ProfileItem(tr('section'), userSection),
        ],
      ),
      ProfileSection(
        title: tr('identification'),
        icon: Icons.badge,
        color: const Color(0xFFFF9800),
        items: [
          ProfileItem(tr('iqama_no'), userIqamaNo),
          ProfileItem(tr('passport_no'), userPassportNo),
        ],
      ),
      ProfileSection(
        title: tr('address_information'),
        icon: Icons.location_on,
        color: const Color(0xFF9C27B0),
        items: [
          ProfileItem(tr('current_address'), userCurrentAddress, isEditable: true),
          ProfileItem(tr('permanent_address'), userPermanentAddress, isEditable: true),
          ProfileItem(tr('local_country'), userLocalCountry),
          ProfileItem(tr('local_city'), userLocalCity),
          ProfileItem(tr('home_country'), userHomeCountry),
          ProfileItem(tr('home_city'), userHomeCity),
        ],
      ),
      ProfileSection(
        title: tr('preferences'),
        icon: Icons.settings,
        color: const Color(0xFF607D8B),
        items: [
          ProfileItem(tr('preferred_language'), userPreferredLang),
        ],
      ),
    ];
  }

  // Logout functionality
  Future<void> logout() async {
    Get.dialog(
      Builder(
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(tr('logout')),
          content: Text(tr('are_you_sure_logout')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('cancel'), style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout();
              },
              child: Text(tr('logout'), style: const TextStyle(color: Color(0xFFF44336))),
            ),
          ],
        ),
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
        }
      } catch (apiError) {
      }
      
      // Clear ALL local data and reset all controllers
      await _clearAllAppData();
      
      _showSuccessSnackbar(tr('logged_out_successfully'));
      
      // Navigate to login screen and clear all routes
      Get.offAll(() => LoginScreen());
    } catch (e) {
      // Even if logout API fails, still clear local data
      try {
        await _clearAllAppData();
      } catch (clearError) {
      }
      _showErrorSnackbar(tr('logout_completed_with_errors') + ': $e');
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
    }
  }

  void _resetAllControllers() {
    try {
      // Reset specific controllers if they exist
      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>(force: true);
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
      if (Get.isRegistered<NotificationController>()) {
        Get.delete<NotificationController>(force: true);
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