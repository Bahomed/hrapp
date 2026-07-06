import 'package:co.injazathr.injazathr/repository/forgot_password_repository.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final repository = ForgotPasswordRepository();

  var isLoading = false.obs;

  void resetPassword(String mobileNo, String otp, String newPassword, BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await repository.resetPassword(mobileNo, otp, newPassword);

      if (!context.mounted) return;

      if (response != null && response.error == false) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response.message ?? tr('password_reset_successfully')),
          backgroundColor: Colors.green,
        ));

        Get.until((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(response?.message ?? tr('failed_to_reset_password')),
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
