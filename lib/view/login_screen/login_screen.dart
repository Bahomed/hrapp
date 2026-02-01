import 'package:co.injazathr.injazathr/utils/appconstants.dart';
import 'package:co.injazathr.injazathr/view/login_screen/login_controller.dart';
import 'package:co.injazathr.injazathr/view/forgot_password_screen/forgot_password_screen.dart';
import 'package:co.injazathr.injazathr/utils/input_widgets.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/utils/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/theme_service.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final model = Get.put(LoginController());

    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Logo that adapts to theme
                  Image.asset(
                    themeService.isDarkMode ? logoWhite : logoBlack,
                    height: 80,
                  ),


              Text(
                tr('app_name'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: themeService.getTextSecondaryColor(),
                ),
              ),
              // Welcome Text
              Text(
                '${tr('welcome')} 👋',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
              

              
              const SizedBox(height: 50),
              
              // Login Form
              Form(
                key: model.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Login Title
                    Text(
                      tr('login'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      tr('enter_credentials'),
                      style: TextStyle(
                        fontSize: 14,
                        color: themeService.getTextSecondaryColor(),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),

                    // Dynamic Login Field (Mobile/Email/Iqama based on company preference)
                    Obx(() => model.isLoadingLoginMethod.value
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : InputWidgets.buildInputField(
                            controller: emailController,
                            label: model.getLoginFieldLabel(),
                            hint: model.getLoginFieldHint(),
                            icon: model.getLoginFieldIcon(),
                            keyboardType: model.getLoginFieldKeyboardType(),
                            validator: model.validateLoginField,
                          )),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    PasswordVisibilityToggle(
                      controller: passwordController,
                      label: tr('password'),
                      hint: tr('enter_password'),
                      icon: Icons.lock_outline,
                    ),
                    
                    SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2)),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.to(() => ForgotPasswordScreen());
                        },
                        child: Text(
                          tr('forgot_password'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: themeService.getActionColor('requests'),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2)),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton
                        (
                        onPressed: () {
                          model.loginClicked(
                            emailController.text, 
                            passwordController.text
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
                          shadowColor: themeService.getActionColor('requests').withValues(alpha: 0.3),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, size: 20, color: themeService.getSilver()),
                            const SizedBox(width: 12),
                            Text(
                              tr('login'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: themeService.getSilver(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 3)),
              
              // Change Workspace Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeService.getCardColor(),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeService.getTextSecondaryColor().withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 32,
                      color: themeService.getActionColor('profile'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr('different_workspace'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('change_workspace_hint'),
                      style: TextStyle(
                        fontSize: 13,
                        color: themeService.getTextSecondaryColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        model.changeWorkspace();
                      },
                      icon: Icon(
                        Icons.swap_horiz,
                        size: 18,
                        color: themeService.getActionColor('profile'),
                      ),
                      label: Text(
                        tr('change_workspace'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: themeService.getActionColor('profile'),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: themeService.getActionColor('profile'),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2)),

              // Privacy Policy & Terms
              _buildPrivacyTermsSection(context, themeService),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Language button positioned at top right
            Positioned(
              top: 8,
              right: 8,
              child: _buildLanguageButton(themeService),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(ThemeService themeService) {
    final languageService = LanguageService.instance;

    return Obx(() {
      final currentLang = languageService.currentLanguage.value;
      final isArabic = currentLang == 'ar';

      return Container(
        decoration: BoxDecoration(
          color: themeService.getCardColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeService.getTextSecondaryColor().withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final newLang = isArabic ? 'en' : 'ar';
              await languageService.changeLanguage(newLang);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getLanguageFlag(currentLang),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    getLanguageName(currentLang),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeService.getTextPrimaryColor(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: themeService.getTextSecondaryColor(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPrivacyTermsSection(BuildContext context, ThemeService themeService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            tr('by_continuing_you_agree'),
            style: TextStyle(
              fontSize: 12,
              color: themeService.getTextSecondaryColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _launchURL('https://injazathr.com/en/privacy-policy/'),
            child: Text(
              tr('privacy_policy'),
              style: TextStyle(
                fontSize: 12,
                color: themeService.getActionColor('requests'),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            tr('and'),
            style: TextStyle(
              fontSize: 12,
              color: themeService.getTextSecondaryColor(),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _launchURL('https://injazathr.com/en/term/'),
            child: Text(
              tr('terms_and_conditions'),
              style: TextStyle(
                fontSize: 12,
                color: themeService.getActionColor('requests'),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      Get.snackbar(
        tr('error'),
        'Could not open link',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

}
