import 'package:co.injazathr.injazathr/utils/appconstants.dart';
import 'package:co.injazathr.injazathr/view/forgot_password_screen/forgot_password_controller.dart';
import 'package:co.injazathr.injazathr/utils/input_widgets.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/theme_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getPageBackgroundColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeService.getTextPrimaryColor(),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tr('forgot_password'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: themeService.getActionColor('requests').withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      size: 64,
                      color: themeService.getActionColor('requests'),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  tr('forgot_password_title'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  tr('forgot_password_description'),
                  style: TextStyle(
                    fontSize: 14,
                    color: themeService.getTextSecondaryColor(),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),

                // Mobile Number Field
                InputWidgets.buildInputField(
                  controller: mobileController,
                  label: tr('mobile_no'),
                  hint: tr('enter_mobile'),
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('enter_mobile');
                    }
                    if (value.length < 10) {
                      return tr('please_enter_valid_mobile');
                    }
                    return null;
                  },
                ),

                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),

                // Send OTP Button
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                controller.sendOtp(mobileController.text, context);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeService.getActionColor('requests'),
                          foregroundColor: themeService.getSilver(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: themeService
                              .getActionColor('requests')
                              .withValues(alpha: 0.3),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    themeService.getSilver(),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send, size: 20, color: themeService.getSilver()),
                                  const SizedBox(width: 12),
                                  Text(
                                    tr('send_otp'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: themeService.getSilver(),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    )),

                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 3)),

                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: themeService.getActionColor('requests'),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tr('back_to_login'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: themeService.getActionColor('requests'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}