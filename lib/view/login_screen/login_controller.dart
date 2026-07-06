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

  // Observable login method
  var loginMethod = 'mobile'.obs;
  var isLoadingLoginMethod = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCompanyLoginMethod();
  }

  /// Fetch company login method from API
  void fetchCompanyLoginMethod() async {
    try {
      isLoadingLoginMethod.value = true;
      final response = await repository.getCompanyLoginMethod();

      if (response != null && response.loginMethod != null) {
        loginMethod.value = response.loginMethod!;
      } else {
        loginMethod.value = 'mobile'; // Default fallback
      }
    } catch (e) {
      loginMethod.value = 'mobile'; // Default fallback on error
    } finally {
      isLoadingLoginMethod.value = false;
    }
  }

  /// Get label for login field based on login method
  String getLoginFieldLabel() {
    switch (loginMethod.value) {
      case 'email':
        return tr('email');
      case 'iqama_no':
        return tr('iqama_no');
      case 'mobile':
        return tr('mobile_no');
      case 'email_or_iqama':
        return tr('email_or_iqama');
      case 'email_or_mobile':
        return tr('email_or_mobile');
      case 'all':
        return tr('email_mobile_or_iqama');
      default:
        return tr('mobile_no');
    }
  }

  /// Get hint for login field based on login method
  String getLoginFieldHint() {
    switch (loginMethod.value) {
      case 'email':
        return tr('enter_email');
      case 'iqama_no':
        return tr('enter_iqama_no');
      case 'mobile':
        return tr('enter_mobile');
      case 'email_or_iqama':
        return tr('enter_email_or_iqama');
      case 'email_or_mobile':
        return tr('enter_email_or_mobile');
      case 'all':
        return tr('enter_email_mobile_or_iqama');
      default:
        return tr('enter_mobile');
    }
  }

  /// Get icon for login field based on login method
  IconData getLoginFieldIcon() {
    switch (loginMethod.value) {
      case 'email':
        return Icons.email_outlined;
      case 'iqama_no':
        return Icons.badge_outlined;
      case 'mobile':
        return Icons.phone_outlined;
      case 'email_or_iqama':
      case 'email_or_mobile':
      case 'all':
        return Icons.person_outline;
      default:
        return Icons.phone_outlined;
    }
  }

  /// Get keyboard type based on login method
  TextInputType getLoginFieldKeyboardType() {
    switch (loginMethod.value) {
      case 'email':
      case 'email_or_iqama':
      case 'email_or_mobile':
        return TextInputType.emailAddress;
      case 'iqama_no':
      case 'mobile':
        return TextInputType.number;
      case 'all':
        return TextInputType.text;
      default:
        return TextInputType.phone;
    }
  }

  /// Validate login field based on login method
  String? validateLoginField(String? value) {
    if (value == null || value.isEmpty) {
      return tr('field_required');
    }

    switch (loginMethod.value) {
      case 'email':
        if (!GetUtils.isEmail(value)) {
          return tr('please_enter_valid_email');
        }
        break;
      case 'iqama_no':
        if (value.length < 10) {
          return tr('please_enter_valid_iqama');
        }
        break;
      case 'mobile':
        if (value.length < 10) {
          return tr('please_enter_valid_mobile');
        }
        break;
      case 'email_or_iqama':
      case 'email_or_mobile':
      case 'all':
        // Accept any non-empty value
        if (value.length < 3) {
          return tr('field_minimum_3_characters');
        }
        break;
    }
    return null;
  }

  void loginClicked(String email, String password) {
    if (!formKey.currentState!.validate()) {
      return;
    }
    loginApi(email, password);
  }

  /// Closes the current dialog without triggering GetX snackbar lifecycle,
  /// avoiding the LateInitializationError when a snackbar is queued but not yet shown.
  void _closeDialog() {
    final ctx = Get.overlayContext;
    if (ctx != null) {
      Navigator.of(ctx).pop();
    }
  }

  void loginApi(String email, String password) async {
    try {
      customLoader();
      var response = await repository.loginApi(email, password, loginMethod.value);
      _closeDialog();

      if (response != null && response.isSuccess) {
        // Get token from response (either direct token field or from data)
        String token = response.accessToken;

       
        // Save login details including user data, refresh token and expiration
        await repository.saveLoginDetails(
          token,
          response.data,
          refreshToken: response.refreshToken,
          expiresAt: response.expiresAt,
          allowBackdateRequest: response.allowBackdateRequest,
        );

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
            if (messages is List) {
              errorMessages.addAll(messages.cast<String>());
            } else if (messages is String) {
              errorMessages.add(messages);
            }
          });
          if (errorMessages.isNotEmpty) errorMessage = errorMessages.join('\n');
        }

        _showErrorSnackbar(errorMessage);
      }
    } catch (e) {
      _closeDialog();
      _showErrorSnackbar(tr('connection_error'));
    }
  }

  void _showSuccessSnackbar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = Get.context ?? Get.overlayContext;
      if (ctx == null || !ctx.mounted) return;
      ScaffoldMessenger.maybeOf(ctx)?.showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ]),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }

  void _showErrorSnackbar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = Get.context ?? Get.overlayContext;
      if (ctx == null || !ctx.mounted) return;
      ScaffoldMessenger.maybeOf(ctx)?.showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ]),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
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
            onPressed: () => _closeDialog(),
            child: Text(tr('cancel'), style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              _closeDialog();
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