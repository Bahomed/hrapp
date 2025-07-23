import 'package:injazat_hr_app/utils/appconstants.dart';
import 'package:injazat_hr_app/utils/image.dart';
import 'package:injazat_hr_app/utils/theme_toggle_widget.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/responsive_utils.dart';
import 'package:injazat_hr_app/services/theme_service.dart';
import 'package:injazat_hr_app/view/home_screen/homescreen_controller.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Get.put(HomeScreenController());
    final preferences = Preferences();
    final themeService = ThemeService.instance;

    return Obx(
        () => Scaffold(
          backgroundColor: themeService.getPageBackgroundColor(),
          extendBody: true,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).cardColor,
            toolbarHeight: ResponsiveUtils.responsiveAppBarHeight(context, mobile: 70, tablet: 80, desktop: 90),
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: ResponsiveUtils.responsiveBorderRadius(context, mobile: 20, tablet: 25, desktop: 30).topLeft,
                  bottomRight: ResponsiveUtils.responsiveBorderRadius(context, mobile: 20, tablet: 25, desktop: 30).topRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            title: Padding(
              padding: ResponsiveUtils.responsiveHorizontalPadding(context, mobile: 6, tablet: 8, desktop: 12),
              child: Row(
                children: [
                  // User Avatar with better styling and tap functionality
                  GestureDetector(
                    onTap: () => model.goToProfileScreen(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.responsiveWidth(context, 12)),
                        child: Obx(() => model.userImage.value.isNotEmpty
                            ? Image.network(
                          model.userImage.value,
                          errorBuilder: (context, error, stackTrace) {
                            return const CustomImage(size: 50);
                          },
                          fit: BoxFit.cover,
                          width: ResponsiveUtils.responsiveWidth(context, 12),
                          height: ResponsiveUtils.responsiveWidth(context, 12),
                        )
                            : CustomImage(size: ResponsiveUtils.responsiveWidth(context, 12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Greeting text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tr('good_morning'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Obx(() => Text(
                          model.userName.value.isNotEmpty ? model.userName.value : 'User',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Theme toggle with better padding


              Padding(
                padding: EdgeInsets.only(right: ResponsiveUtils.responsiveWidth(context, 2)),
                child: IconButton(
                  onPressed: () => Get.find<ThemeService>().toggleTheme(),
                  icon: Icon(
                    Get.find<ThemeService>().isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: Theme.of(context).iconTheme.color,
                    size: ResponsiveUtils.responsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                  ),
                  tooltip: tr('theme'),
                ),
              ),
              // Settings Icon with better styling
              Padding(
                padding: EdgeInsets.only(right: ResponsiveUtils.responsiveWidth(context, 2)),
                child: IconButton(
                  onPressed: () {
                    model.goToSettingsScreen();
                  },
                  icon: Icon(
                    Icons.settings_outlined,
                    color: Theme.of(context).iconTheme.color,
                    size: ResponsiveUtils.responsiveIconSize(context, mobile: 20, tablet: 22, desktop: 24),
                  ),
                  tooltip: tr('settings'),
                ),
              ),
            ],
          ),
          bottomNavigationBar: CurvedNavigationBar(
            animationCurve: Curves.linear,
            animationDuration: const Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            color: Theme.of(context).cardColor,
            index: model.bottomNavIndex.value,
            height: 60,
            buttonBackgroundColor: Theme.of(context).primaryColor,
            items: <Widget>[
              // Calendar Icon
              Icon(
                Icons.calendar_month,
                color: model.bottomNavIndex.value == 0
                    ? Colors.white  // White when active (selected)
                    : Theme.of(context).iconTheme.color, // Theme color when inactive
                size: ResponsiveUtils.responsiveIconSize(context, mobile: 22, tablet: 24, desktop: 26),
              ),

              // Home Icon - Always visible
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                    Icons.home,
                    color: model.bottomNavIndex.value == 1
                        ? Colors.white  // White when active
                        : Theme.of(context).primaryColor, // Primary color when inactive (still visible!)
                    size: 30
                ),
              ),

              // Notifications Icon
              Icon(
                Icons.notifications_active,
                color: model.bottomNavIndex.value == 2
                    ? Colors.white  // White when active
                    : Theme.of(context).iconTheme.color, // Theme color when inactive
                size: ResponsiveUtils.responsiveIconSize(context, mobile: 22, tablet: 24, desktop: 26),
              )
            ],
            onTap: (value) {
              model.bottomNavIndex.value = value;
            },
          ),

          body: model.pages[model.bottomNavIndex.value],
        )
    );
  }
}