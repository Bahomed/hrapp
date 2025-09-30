import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../repository/employee_profile_repository.dart';

class EmployeeProfileController extends GetxController {
  final EmployeeProfileRepository _repository = EmployeeProfileRepository();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final Rx<Map<String, dynamic>?> employeeProfile = Rx<Map<String, dynamic>?>(null);

  // Load employee profile data
  Future<void> loadEmployeeProfile(int employeeId) async {
    try {
      isLoading.value = true;
      final profile = await _repository.getEmployeeProfile(employeeId);
      employeeProfile.value = profile;
    } catch (e) {
      _showErrorSnackbar('Error loading employee profile: $e');
      employeeProfile.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  // Snackbar helper
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