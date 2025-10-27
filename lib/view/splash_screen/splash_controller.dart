import 'dart:async';
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/view/workspace/workspace_screen.dart';
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
    
    /// Print FCM token for testing (remove in production)
    // print('About to call FCMTokenHelper.printFCMToken()');
    // try {
    //   // Add delay to ensure Firebase is ready
      //await Future.delayed(const Duration(seconds: 3));
      //await FCMTokenHelper.printFCMToken();
      //print('FCMTokenHelper.printFCMToken() completed');
    // } catch (e) {
    //   print('Error in FCMTokenHelper.printFCMToken(): $e');
    //   print('Stack trace: $e');
    // }*/

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