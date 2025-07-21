import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/language_service.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import 'package:injazat_hr_app/utils/screen_themes.dart';
import 'package:injazat_hr_app/services/theme_service.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    final themeService = Get.find<ThemeService>();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('settings')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Section
              ScreenThemes.buildSettingsSection(
                title: tr('language'),
                icon: Icons.language,
                iconColor: AppTheme.primaryColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('choose_preferred_language'),
                      style: AppTheme.bodySmall,
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
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                : Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected 
                                    ? Theme.of(context).primaryColor
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
                                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : null,
                            onTap: () async {
                              await languageService.changeLanguage(entry.key);
                              // Show confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${tr('language_changed_to')} ${languageService.getLanguageName(entry.key)}',
                                  ),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Theme Section
              ScreenThemes.buildSettingsSection(
                title: tr('theme'),
                icon: Icons.palette,
                iconColor: AppTheme.accentColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('choose_app_theme'),
                      style: AppTheme.bodySmall,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Theme Options
                    Obx(() => Column(
                      children: [
                        // Light Theme
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            tileColor: themeService.themeMode == ThemeMode.light
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                : Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: themeService.themeMode == ThemeMode.light
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            leading: const Icon(
                              Icons.light_mode,
                              color: Colors.orange,
                            ),
                            title: Text(
                              tr('light_theme'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: themeService.themeMode == ThemeMode.light ? FontWeight.w600 : FontWeight.normal,
                                color: themeService.themeMode == ThemeMode.light ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            trailing: themeService.themeMode == ThemeMode.light
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : null,
                            onTap: () {
                              themeService.setLightTheme();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr('theme_changed')),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Dark Theme
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            tileColor: themeService.themeMode == ThemeMode.dark
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                                : Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: themeService.themeMode == ThemeMode.dark
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            leading: const Icon(
                              Icons.dark_mode,
                              color: Colors.blueGrey,
                            ),
                            title: Text(
                              tr('dark_theme'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: themeService.themeMode == ThemeMode.dark ? FontWeight.w600 : FontWeight.normal,
                                color: themeService.themeMode == ThemeMode.dark ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            trailing: themeService.themeMode == ThemeMode.dark
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : null,
                            onTap: () {
                              themeService.setDarkTheme();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr('theme_changed')),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                        
                      ],
                    )),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Privacy & Legal Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.privacy_tip,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tr('privacy_legal'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Privacy Policy
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Icon(
                        Icons.policy,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        tr('privacy_policy'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        tr('read_privacy_policy'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () {
                        Get.to(() => const PrivacyPolicyScreen());
                      },
                    ),
                    
                    const Divider(),
                    
                    // Terms of Service
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Icon(
                        Icons.description,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      title: Text(
                        tr('terms_of_service'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        tr('terms_conditions'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: () {
                        // Navigate to Terms of Service
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(tr('terms_coming_soon')),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // App Information Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info,
                            color: Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tr('app_information'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // App Version
                    Row(
                      children: [
                        Icon(
                          Icons.app_settings_alt,
                          color: Theme.of(context).iconTheme.color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tr('version'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Current Language
                    Row(
                      children: [
                        Icon(
                          Icons.translate,
                          color: Theme.of(context).iconTheme.color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tr('current_language'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const Spacer(),
                        Obx(() => Text(
                          '${languageService.getLanguageFlag(languageService.currentLanguage.value)} ${languageService.getLanguageName(languageService.currentLanguage.value)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}