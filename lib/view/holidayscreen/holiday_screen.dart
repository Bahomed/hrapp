import 'package:co.injazathr.injazathr/view/holidayscreen/holidayscreencontroller.dart';
import 'package:co.injazathr.injazathr/view/holidayscreen/widget/customtabbar.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HolidayScreen extends StatelessWidget {
  const HolidayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HolidayScreenController());
    final themeService = ThemeService.instance;
    
    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      body: const CustomTabBar(),
    );
  }
}
