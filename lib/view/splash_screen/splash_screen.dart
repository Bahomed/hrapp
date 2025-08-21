import 'package:com.injazatsoftware.injazathr/utils/backgrounddecoration.dart';
import 'package:com.injazatsoftware.injazathr/view/splash_screen/splash_controller.dart';
import 'package:com.injazatsoftware.injazathr/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/appconstants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    Get.put(SplashController());
    return Container(
      decoration: backgroundDecoration(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: Image.asset(
              themeService.isDarkMode ? logoWhite : logoBlack,
              height: 100,
            )),
      ),
    );
  }
}