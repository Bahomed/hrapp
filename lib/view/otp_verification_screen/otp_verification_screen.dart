import 'package:co.injazathr.injazathr/view/otp_verification_screen/otp_verification_controller.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../services/theme_service.dart';

class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({super.key});

  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtpVerificationController());
    final themeService = ThemeService.instance;
    final args = Get.arguments as Map<String, dynamic>;
    final mobileNo = args['mobile_no'] as String;
    final from = args['from'] as String;

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
          tr('otp_verification'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
                    Icons.message_outlined,
                    size: 64,
                    color: themeService.getActionColor('requests'),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                tr('verify_otp'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),

              const SizedBox(height: 12),

              // Description
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: themeService.getTextSecondaryColor(),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(text: tr('otp_sent_to')),
                    TextSpan(
                      text: ' $mobileNo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),

              // OTP Input Fields
              Builder(
                builder: (context) {
                  final boxWidth = (MediaQuery.of(context).size.width - 48 - 30) / 6;
                  return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: boxWidth,
                    child: TextFormField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: boxWidth * 0.4,
                        fontWeight: FontWeight.bold,
                        color: themeService.getTextPrimaryColor(),
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: themeService.getCardColor(),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: themeService.getActionColor('requests'),
                            width: 2,
                          ),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
                  );
                },
              ),

              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 3)),

              // Resend OTP
              Obx(() => Center(
                    child: controller.canResend.value
                        ? TextButton(
                            onPressed: () => controller.resendOtp(mobileNo),
                            child: Text(
                              tr('resend_otp'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: themeService.getActionColor('requests'),
                              ),
                            ),
                          )
                        : Text(
                            '${tr('resend_otp_in')} ${controller.resendTimer.value}s',
                            style: TextStyle(
                              fontSize: 14,
                              color: themeService.getTextSecondaryColor(),
                            ),
                          ),
                  )),

              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),

              // Verify Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              final otp = otpControllers
                                  .map((c) => c.text)
                                  .join();
                              controller.verifyOtp(mobileNo, otp, from);
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
                                Icon(Icons.verified_user,
                                    size: 20, color: themeService.getSilver()),
                                const SizedBox(width: 12),
                                Text(
                                  tr('verify'),
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
            ],
          ),
        ),
      ),
    );
  }
}