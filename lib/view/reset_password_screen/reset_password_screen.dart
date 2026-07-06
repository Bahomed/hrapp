import 'package:co.injazathr.injazathr/view/reset_password_screen/reset_password_controller.dart';
import 'package:co.injazathr.injazathr/utils/input_widgets.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/theme_service.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ResetPasswordController());
    final themeService = ThemeService.instance;
    final args = Get.arguments as Map<String, dynamic>;
    final mobileNo = args['mobile_no'] as String;
    final otp = args['otp'] as String;

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
          tr('reset_password'),
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
                  tr('create_new_password'),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  tr('create_new_password_description'),
                  style: TextStyle(
                    fontSize: 14,
                    color: themeService.getTextSecondaryColor(),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),

                // New Password Field
                PasswordVisibilityToggle(
                  controller: newPasswordController,
                  label: tr('new_password'),
                  hint: tr('enter_new_password'),
                  icon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('please_enter_password');
                    }
                    if (value.length < 6) {
                      return tr('password_must_be_6_characters');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                PasswordVisibilityToggle(
                  controller: confirmPasswordController,
                  label: tr('confirm_password'),
                  hint: tr('enter_confirm_password'),
                  icon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return tr('please_enter_confirm_password');
                    }
                    if (value != newPasswordController.text) {
                      return tr('passwords_do_not_match');
                    }
                    return null;
                  },
                ),

                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),

                // Reset Password Button
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                controller.resetPassword(
                                  mobileNo,
                                  otp,
                                  newPasswordController.text,
                                  context,
                                );
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
                                  Icon(Icons.check_circle,
                                      size: 20, color: themeService.getSilver()),
                                  const SizedBox(width: 12),
                                  Text(
                                    tr('reset_password'),
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

                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2)),

                // Password Requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeService.getCardColor(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeService.getTextSecondaryColor().withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('password_requirements'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: themeService.getTextPrimaryColor(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRequirement(
                        themeService,
                        tr('minimum_6_characters'),
                      ),
                      _buildRequirement(
                        themeService,
                        tr('passwords_must_match'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(ThemeService themeService, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: themeService.getActionColor('requests'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}