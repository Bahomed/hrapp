import 'package:co.injazathr.injazathr/repository/forgot_password_repository.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final repository = ForgotPasswordRepository();

  var isLoading = false.obs;

  void resetPassword(String mobileNo, String otp, String newPassword) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await repository.resetPassword(mobileNo, otp, newPassword);

      if (response != null && response.error == false) {
        Get.snackbar(
          tr('success'),
          response.message ?? tr('password_reset_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate back to login
        Get.until((route) => route.isFirst);
      } else {
        Get.snackbar(
          tr('error'),
          response?.message ?? tr('failed_to_reset_password'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        tr('error'),
        tr('something_went_wrong'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}