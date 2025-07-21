import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/services/theme_service.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';

class ThemeToggleWidget extends StatelessWidget {
  final bool showLabel;
  final bool showTooltip;
  final Color? iconColor;
  final double? iconSize;

  const ThemeToggleWidget({
    super.key,
    this.showLabel = false,
    this.showTooltip = true,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Obx(() {
      IconData icon;
      String tooltip;
      String label;

      switch (themeService.themeMode) {
        case ThemeMode.light:
          icon = Icons.light_mode;
          tooltip = tr('light_theme');
          label = tr('light_theme');
          break;
        case ThemeMode.dark:
          icon = Icons.dark_mode;
          tooltip = tr('dark_theme');
          label = tr('dark_theme');
          break;
        case ThemeMode.system:
          // Fallback to light theme since we removed system theme support
          icon = Icons.light_mode;
          tooltip = tr('light_theme');
          label = tr('light_theme');
          break;
      }

      Widget iconButton = IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? Theme.of(context).iconTheme.color,
          size: iconSize,
        ),
        onPressed: () => _showThemeBottomSheet(context),
        tooltip: showTooltip ? tooltip : null,
      );

      if (showLabel) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconButton,
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        );
      }

      return iconButton;
    });
  }

  void _showThemeBottomSheet(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              tr('choose_app_theme'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            // Theme options
            Obx(() => Column(
              children: [
                _buildThemeOption(
                  context,
                  ThemeMode.light,
                  Icons.light_mode,
                  tr('light_theme'),
                  Colors.orange,
                  themeService.themeMode == ThemeMode.light,
                  () {
                    themeService.setLightTheme();
                    Navigator.pop(context);
                  },
                ),
                _buildThemeOption(
                  context,
                  ThemeMode.dark,
                  Icons.dark_mode,
                  tr('dark_theme'),
                  Colors.blueGrey,
                  themeService.themeMode == ThemeMode.dark,
                  () {
                    themeService.setDarkTheme();
                    Navigator.pop(context);
                  },
                ),
              ],
            )),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode mode,
    IconData icon,
    String title,
    Color iconColor,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Theme.of(context).primaryColor : iconColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleThemeToggle extends StatelessWidget {
  final double? size;
  final Color? color;

  const SimpleThemeToggle({
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Obx(() {
      return GestureDetector(
        onTap: () => themeService.toggleTheme(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color?.withOpacity(0.1) ?? 
                   Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            size: size ?? 20,
            color: color ?? Theme.of(context).primaryColor,
          ),
        ),
      );
    });
  }
}