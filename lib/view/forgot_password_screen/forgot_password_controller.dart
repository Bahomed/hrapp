import 'package:co.injazathr.injazathr/repository/forgot_password_repository.dart';
import 'package:co.injazathr.injazathr/view/otp_verification_screen/otp_verification_screen.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final repository = ForgotPasswordRepository();

  var isLoading = false.obs;

  void sendOtp(String mobileNo) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await repository.sendOtp(mobileNo);

      if (response != null && response.error == false) {
        Get.snackbar(
          tr('success'),
          response.message ?? tr('otp_sent_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to OTP verification screen
        Get.to(() => OtpVerificationScreen(), arguments: {
          'mobile_no': mobileNo,
          'from': 'forgot_password'
        });
      } else {
        Get.snackbar(
          tr('error'),
          response?.message ?? tr('failed_to_send_otp'),
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