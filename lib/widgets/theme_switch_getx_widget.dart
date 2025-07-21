import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/theme_service.dart';
import '../utils/app_theme.dart';

class ThemeSwitchGetXWidget extends StatelessWidget {
  final bool showLabel;
  final EdgeInsets? padding;
  final bool compact;

  const ThemeSwitchGetXWidget({
    Key? key,
    this.showLabel = true,
    this.padding,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() {
      if (compact) {
        return _buildCompactSwitch(themeService);
      }
      return _buildFullSwitch(themeService);
    });
  }

  Widget _buildCompactSwitch(ThemeService themeService) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: IconButton(
        icon: Icon(
          themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: themeService.getPrimaryColor(),
        ),
        onPressed: () => themeService.toggleTheme(),
        tooltip: themeService.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      ),
    );
  }

  Widget _buildFullSwitch(ThemeService themeService) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel) ...[
            Icon(
              themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: themeService.getTextPrimaryColor(),
              size: 20,
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(
              themeService.isDarkMode ? 'Dark Mode' : 'Light Mode',
              style: TextStyle(
                color: themeService.getTextPrimaryColor(),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
          ],
          Switch(
            value: themeService.isDarkMode,
            onChanged: (value) => themeService.toggleTheme(),
            activeColor: themeService.getPrimaryColor(),
            inactiveThumbColor: themeService.getTextSecondaryColor(),
            inactiveTrackColor: themeService.getDividerColor(),
          ),
        ],
      ),
    );
  }
}

class ThemeSelectionBottomSheetGetX extends StatelessWidget {
  const ThemeSelectionBottomSheetGetX({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.borderRadiusLarge),
          topRight: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: themeService.getDividerColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          Text(
            'Choose Theme',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: themeService.getTextPrimaryColor(),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildThemeOption(
            themeService,
            'Light Mode',
            Icons.light_mode,
            ThemeMode.light,
          ),
          _buildThemeOption(
            themeService,
            'Dark Mode',
            Icons.dark_mode,
            ThemeMode.dark,
          ),
          _buildThemeOption(
            themeService,
            'System Default',
            Icons.settings_system_daydream,
            ThemeMode.system,
          ),
          const SizedBox(height: AppTheme.spacingLarge),
        ],
      ),
    ));
  }

  Widget _buildThemeOption(
    ThemeService themeService,
    String title,
    IconData icon,
    ThemeMode mode,
  ) {
    final isSelected = themeService.themeMode == mode;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          onTap: () {
            themeService.setThemeMode(mode);
            Get.back();
          },
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: isSelected 
                  ? themeService.getPrimaryColor().withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(
                color: isSelected 
                    ? themeService.getPrimaryColor()
                    : themeService.getDividerColor(),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected 
                      ? themeService.getPrimaryColor()
                      : themeService.getTextSecondaryColor(),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected 
                          ? themeService.getPrimaryColor()
                          : themeService.getTextPrimaryColor(),
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: themeService.getPrimaryColor(),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeSettingsCardGetX extends StatelessWidget {
  const ThemeSettingsCardGetX({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    
    return Obx(() => Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: themeService.getPrimaryColor(),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Text(
                  'Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            ListTile(
              leading: Icon(
                themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeService.getPrimaryColor(),
              ),
              title: Text(
                _getThemeTitle(themeService.themeMode),
                style: TextStyle(
                  color: themeService.getTextPrimaryColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                _getThemeSubtitle(themeService.themeMode),
                style: TextStyle(
                  color: themeService.getTextSecondaryColor(),
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: themeService.getTextSecondaryColor(),
              ),
              onTap: () {
                Get.bottomSheet(
                  const ThemeSelectionBottomSheetGetX(),
                  backgroundColor: Colors.transparent,
                );
              },
            ),
          ],
        ),
      ),
    ));
  }

  String _getThemeTitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _getThemeSubtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light theme is always used';
      case ThemeMode.dark:
        return 'Dark theme is always used';
      case ThemeMode.system:
        return 'Matches your system setting';
    }
  }
}