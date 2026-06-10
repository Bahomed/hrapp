import 'dart:async';
import 'package:flutter/scheduler.dart';
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/auth_interceptor.dart';
import 'package:co.injazathr.injazathr/services/update_service.dart';
import 'package:co.injazathr.injazathr/view/workspace/workspace_screen.dart';
import 'package:co.injazathr.injazathr/utils/background_location_disclosure.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/view/home_screen/home_screen.dart';
import 'package:co.injazathr.injazathr/view/login_screen/login_screen.dart';

import '../../utils/fcm_token_helper.dart';

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

    // Check for update before navigating (Android official Play Store API)
    await UpdateService.checkForUpdate();

    // Ensure the navigator overlay is mounted before calling Get.dialog().
    // endOfFrame schedules a new frame if none is pending, so this always
    // resolves — unlike addPostFrameCallback which never fires on a static screen.
    await SchedulerBinding.instance.endOfFrame;

    // Show background location disclosure on first launch (Google Play policy)
    await showBackgroundLocationDisclosureIfNeeded();

    // If we have a token but it's expired, proactively refresh before navigating.
    // This prevents all HomeScreen API calls from hitting 401 simultaneously.
    if (token.isNotEmpty && await perferences.isTokenExpired()) {
      final refreshed = await AuthInterceptor.refreshTokenOnce(perferences);
      if (!refreshed) {
        await perferences.clearLoginSession();
        token = '';
      }
    }

    Timer(
        const Duration(seconds: 1),
            () => Get.offAll(
            token.isEmpty
                ? (workspaceUrl.isEmpty
                ? WorkspaceScreen()
                : LoginScreen())
                : const HomeScreen(),
            transition: Transition.fade,
            duration: const Duration(milliseconds: 400)));
  }
}