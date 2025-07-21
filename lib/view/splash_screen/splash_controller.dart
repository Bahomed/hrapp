import 'dart:async';

import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/view/workspace/workspace_screen.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/view/home_screen/home_screen.dart';
import 'package:injazat_hr_app/view/request_leave/request_leave_screen.dart';
import 'package:injazat_hr_app/view/attendance/clocking_screen.dart';
import 'package:injazat_hr_app/view/login_screen/login_screen.dart';

class SplashController extends GetxController {
  final Preferences perferences = Preferences();

  @override
  void onInit() {
    goToNextPage();
    super.onInit();
  }

  void goToNextPage() async {
    var token = await perferences.getToken();
    var workspaceUrl = await perferences.getWorkspaceUrl();

    Timer(
        const Duration(seconds: 1),
            () => Get.offAll(
            token.isEmpty
                ? (workspaceUrl.isEmpty
                ? WorkspaceScreen()
                : LoginScreen())
                : const HomeScreen(),
            transition: Transition.fade,
            duration: const Duration(seconds: 2)));
  }
}