import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/repository/workspacerepository.dart';
import 'package:injazat_hr_app/utils/alertbox.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/view/login_screen/login_screen.dart';

import '../../data/local/preferences.dart';

class WorkspaceController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final WorkspaceRepository repository = WorkspaceRepository();
  final Preferences preferences = Preferences();

  Future<void> saveWorkspace(String workspaceName) async {
    if (workspaceName.isEmpty) {
      _showErrorSnackbar(tr('please_enter_workspace_id'));
      return;
    }
    final Preferences preferences = Preferences();

    //String savedWorkspace = await preferences.getWorkspaceUrl();
    //String savedWorkspace = await repository.getSavedWorkspace();
    //print(savedWorkspace);
   // print('llll');
    checkWorkspaceAndSave(workspaceName);
  }

  void checkWorkspaceAndSave(String workspaceName) async {
    try {
      customLoader();

      // Send company code exactly as user typed
      String companyCode = workspaceName;

      // Call API to validate company code
      var response = await repository.checkWorkspaceApi(companyCode);
      Get.back();

      if (response != null && !response.error && response.code == 200 && response.data != null) {
        // Save workspace using repository with actual company data
        repository.saveWorkspaceDetails(
            companyCode,
            response.data!.name,
            response.data!.url
        );

        // Navigate to login screen
        Get.offAll(() => LoginScreen());
        _showSuccessSnackbar(tr('company_validated_successfully'));
      } else {
        // Handle different error cases
        String errorMessage = tr('workspace_not_found');
        if (response != null) {
          // Check specific error codes
          if (response.code == 114) {
            errorMessage = tr('workspace_not_found');
          } else if (response.message.isNotEmpty) {
            errorMessage = response.message;
          }
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
}