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

  void resendOtp(String mobileNo, BuildContext context) async {
    try {
      isLoading.value = true;

      final response = await repository.sendOtp(mobileNo);

      if (!context.mounted) return;

      if (response != null && response.error == false) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.message ?? tr('otp_sent_successfully')),
          backgroundColor: Colors.green,
        ));
        startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response?.message ?? tr('failed_to_send_otp')),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('something_went_wrong')),
        backgroundColor: Colors.red,
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void verifyOtp(String mobileNo, String otp, String from, BuildContext context) async {
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('please_enter_valid_otp')),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      isLoading.value = true;

      final response = await repository.verifyOtp(mobileNo, otp);

      if (!context.mounted) return;

      if (response != null && response.error == false) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.message ?? tr('otp_verified_successfully')),
          backgroundColor: Colors.green,
        ));

        Get.to(() => ResetPasswordScreen(), arguments: {
          'mobile_no': mobileNo,
          'otp': otp,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response?.message ?? tr('invalid_otp')),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(tr('something_went_wrong')),
        backgroundColor: Colors.red,
      ));
    } finally {
      isLoading.value = false;
    }
  }
}
