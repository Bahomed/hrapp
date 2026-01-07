import 'dart:async';
import 'package:co.injazathr.injazathr/repository/forgot_password_repository.dart';
import 'package:co.injazathr.injazathr/view/reset_password_screen/reset_password_screen.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpVerificationController extends GetxController {
  final repository = ForgotPasswordRepository();

  var isLoading = false.obs;
  var canResend = false.obs;
  var resendTimer = 60.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startResendTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startResendTimer() {
    resendTimer.value = 60;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  void resendOtp(String mobileNo) async {
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
        startResendTimer();
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

  void verifyOtp(String mobileNo, String otp, String from) async {
    if (otp.length != 6) {
      Get.snackbar(
        tr('error'),
        tr('please_enter_valid_otp'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await repository.verifyOtp(mobileNo, otp);

      if (response != null && response.error == false) {
        Get.snackbar(
          tr('success'),
          response.message ?? tr('otp_verified_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to reset password screen
        Get.to(() => ResetPasswordScreen(), arguments: {
          'mobile_no': mobileNo,
          'otp': otp,
        });
      } else {
        Get.snackbar(
          tr('error'),
          response?.message ?? tr('invalid_otp'),
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