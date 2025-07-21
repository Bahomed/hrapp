import 'package:injazat_hr_app/utils/appconstants.dart';
import 'package:injazat_hr_app/view/login_screen/login_controller.dart';
import 'package:injazat_hr_app/utils/screen_themes.dart';
import 'package:injazat_hr_app/utils/input_widgets.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        child: SingleChildScrollView(
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
              
              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 5)),
              
              // Welcome Text
              Text(
                '${tr('welcome')} 👋',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                tr('app_name'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: themeService.getTextSecondaryColor(),
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
                    
                    // Mobile No Field
                    InputWidgets.buildInputField(
                      controller: emailController,
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
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    PasswordVisibilityToggle(
                      controller: passwordController,
                      label: tr('password'),
                      hint: tr('enter_password'),
                      icon: Icons.lock_outline,
                    ),
                    
                    SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),
                    
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
            ],
          ),
        ),
      ),
    );
  }

}
