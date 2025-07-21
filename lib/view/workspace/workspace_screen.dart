import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/appconstants.dart';
import 'package:injazat_hr_app/utils/input_widgets.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/language_service.dart';
import 'package:injazat_hr_app/services/theme_service.dart';
import 'package:injazat_hr_app/view/workspace/workspace_controller.dart';

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
              
              // Simple Logo with business icon
              Stack(
                children: [
                  Image.asset(
                    themeService.isDarkMode ? logoWhite : logoBlack,
                    height: 80,
                  ),

                ],
              ),
              
              const SizedBox(height: 40),
              
              // Welcome Text
              Text(
                tr('setup_workspace', fallback: 'Setup Workspace 🏢'),
                style: TextStyle(
                  fontSize: 32,
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
                        fontWeight: FontWeight.w400,
                        color: themeService.getTextSecondaryColor(),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
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
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.saveWorkspace(workspaceController.text.trim());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeService.getSecondaryColor(),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.business, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              tr('connect_workspace'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
              
              const SizedBox(height: 40),
              
              // Language Selection Section
              _buildLanguageSection(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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