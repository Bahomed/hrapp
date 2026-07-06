import 'package:co.injazathr.injazathr/repository/forgot_password_repository.dart';
import 'package:co.injazathr.injazathr/view/otp_verification_screen/otp_verification_screen.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final repository = ForgotPasswordRepository();

  var isLoading = false.obs;

  void sendOtp(String mobileNo, BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await repository.sendOtp(mobileNo);

      if (!context.mounted) return;

      if (response != null && response.error == false) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.message ?? tr('otp_sent_successfully')),
          backgroundColor: Colors.green,
        ));

        Get.to(() => OtpVerificationScreen(), arguments: {
          'mobile_no': mobileNo,
          'from': 'forgot_password'
        });
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
}
