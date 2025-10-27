import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/appconstants.dart';
import 'package:co.injazathr.injazathr/utils/input_widgets.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/language_service.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/view/workspace/workspace_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkspaceScreen extends StatelessWidget {
  WorkspaceScreen({super.key});

  final workspaceController = TextEditingController();
  final WorkspaceController controller = Get.put(WorkspaceController());

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
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
                '${tr('setup_workspace', fallback: 'Setup Workspace')} 🏢',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
const SizedBox(height: 8),
              
              Text(
                tr('connect_to_company', fallback: 'Connect to your company'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: themeService.getTextSecondaryColor(),
                ),
              ),
              
              
              
              const SizedBox(height: 50),

              // Workspace Form
              Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      tr('enter_workspace', fallback: 'Enter Workspace'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      tr('enter_workspace_description', fallback: 'Enter your company workspace ID to continue'),
                      style: TextStyle(
                        fontSize: 14,
                        color: themeService.getTextSecondaryColor(),
                      ),
                    ),

                    SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),
                    
                    // Workspace ID Field
                    InputWidgets.buildInputField(
                      controller: workspaceController,
                      label: tr('workspace_id', fallback: 'Workspace ID'),
                      hint: tr('enter_workspace_id', fallback: 'Enter workspace ID (e.g., 10001)'),
                      icon: Icons.business_outlined,
                      keyboardType: TextInputType.number,
                      suffixIcon: Icon(
                        Icons.tag,
                        color: themeService.getTextSecondaryColor(),
                        size: 20,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr('please_enter_workspace_id', fallback: 'Please enter workspace ID');
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.saveWorkspace(workspaceController.text.trim());
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
                            Icon(Icons.business, size: 20, color: themeService.getSilver()),
                            const SizedBox(width: 12),
                            Text(
                              tr('connect_workspace'),
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
                    
                    const SizedBox(height: 24),
                    
                    // Help Text
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          // Show help dialog
                          _showHelpDialog(context);
                        },
                        icon: Icon(
                          Icons.help_outline,
                          color: themeService.getTextSecondaryColor(),
                          size: 18,
                        ),
                        label: Text(
                          tr('need_help_workspace'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: themeService.getTextSecondaryColor(),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 3)),

              // Connect to Company Section
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
                      tr('connect_to_your_company'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tr('connect_company_hint'),
                      style: TextStyle(
                        fontSize: 13,
                        color: themeService.getTextSecondaryColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2)),

              // Language Selection Section
              _buildLanguageSection(),

              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2)),

              // Privacy Policy & Terms
              _buildPrivacyTermsSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyTermsSection() {
    final themeService = Get.find<ThemeService>();
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
            onTap: () => _launchURL('https://injazathr.com/en/privacy-policy/'),
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


  void _showHelpDialog(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeService.getCardColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeService.getSecondaryColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.help_outline,
                color: themeService.getSecondaryColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              tr('workspace_help'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr('workspace_help_description'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tr('common_examples'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 8),
            ...['10001', '12345', '98765'].map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: themeService.getTextSecondaryColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(example, style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: themeService.getTextSecondaryColor(),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tr('contact_hr_department'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: themeService.getTextSecondaryColor(),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              tr('got_it'),
              style: TextStyle(color: themeService.getSecondaryColor()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    final themeService = Get.find<ThemeService>();
    final languageService = Get.find<LanguageService>();

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeService.getPrimaryColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.language,
                  color: themeService.getPrimaryColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                tr('language'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            tr('choose_preferred_language'),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: themeService.getTextSecondaryColor(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Language Options
          Obx(() => Column(
            children: languageService.supportedLanguages.entries.map((entry) {
              final isSelected = languageService.currentLanguage.value == entry.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  tileColor: isSelected 
                      ? themeService.getSecondaryColor().withValues(alpha: 0.1)
                      : themeService.getDividerColor().withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected 
                          ? themeService.getSecondaryColor()
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  leading: Text(
                    languageService.getLanguageFlag(entry.key),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    languageService.getLanguageName(entry.key),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? themeService.getSecondaryColor() : themeService.getTextPrimaryColor(),
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: themeService.getSecondaryColor(),
                        )
                      : null,
                  onTap: () async {
                    await languageService.changeLanguage(entry.key);
                    // Show confirmation
                    Get.snackbar(
                      tr('success'),
                      '${tr('language_changed_to')} ${languageService.getLanguageName(entry.key)}',
                      backgroundColor: themeService.getSecondaryColor(),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                      duration: const Duration(seconds: 2),
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                    );
                  },
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}