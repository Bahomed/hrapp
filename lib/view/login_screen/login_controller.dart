import 'package:co.injazathr.injazathr/repository/loginrepository.dart';
import 'package:co.injazathr.injazathr/utils/alertbox.dart';
import 'package:co.injazathr.injazathr/utils/app_theme.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/home_screen/home_screen.dart';
import 'package:co.injazathr.injazathr/view/workspace/workspace_screen.dart';
import 'package:co.injazathr.injazathr/data/remote/response/login_response.dart' as login_response;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final LoginRepository repository = LoginRepository();

  void loginClicked(String email, String password) {
    if (!formKey.currentState!.validate()) {
      return;
    }
    loginApi(email, password);
  }

  void loginApi(String email, String password) async {
    try {
      customLoader();
      var response = await repository.loginApi(email, password);
      Get.back();

      if (response != null && response.isSuccess) {
        // Get token from response (either direct token field or from data)
        String token = response.accessToken;

        // Save login details including user data
        repository.saveLoginDetails(token, response.data);

        // Navigate to home screen
        Get.offAll(const HomeScreen());
        _showSuccessSnackbar(tr('login_successful'));
      } else {
        // Handle login failure
        String errorMessage = response?.message ?? "Login failed";

        // Check for validation errors
        if (response?.errors != null) {
          List<String> errorMessages = [];
          response!.errors!.forEach((field, messages) {
            errorMessages.addAll(messages.cast<String>());
          });
          errorMessage = errorMessages.join('\n');
        }

        _showErrorSnackbar(errorMessage);
      }
    } catch (e) {
      Get.back();
      _showErrorSnackbar(tr('connection_error'));
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      "Success",
      message,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: AppTheme.errorColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void changeWorkspace() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.business_outlined, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(tr('change_workspace')),
          ],
        ),
        content: Text(tr('change_workspace_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(tr('cancel'), style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _navigateToWorkspaceSelection();
            },
            child: Text(tr('continue'), style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  void _navigateToWorkspaceSelection() {
    // Clear saved workspace data
    repository.clearWorkspaceData();
    
    // Show confirmation snackbar
    Get.snackbar(
      tr('workspace_changed'),
      tr('redirecting_to_workspace_selection'),
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.swap_horiz, color: Colors.white),
    );
    
    // Navigate to workspace selection screen after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(() => WorkspaceScreen());
    });
  }
}