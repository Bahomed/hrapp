import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:upgrader/upgrader.dart';

class UpdateService {
  /// Android → uses official Google Play In-App Update API.
  /// iOS     → uses upgrader (checks App Store, shows dialog).
  static Future<void> checkForUpdate() async {
    if (Platform.isAndroid) {
      await _checkAndroid();
    }
    // iOS is handled via UpgradeAlert widget — see wrapWithUpgrader()
  }

  static Future<void> _checkAndroid() async {
    try {
      final info = await InAppUpdate.checkForUpdate()
          .timeout(const Duration(seconds: 5));

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          // Force update — full-screen blocker, user cannot skip
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          // Background download — user keeps using app, prompted to restart when done
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        }
      }
    } catch (_) {
      // Silently fail — never block the user
    }
  }

  /// Wrap the root widget with this on iOS to get App Store update dialog.
  /// Set [debugForceShow] to true temporarily to test the dialog in debug mode.
  static Widget wrapWithUpgrader(Widget child, {bool debugForceShow = false}) {
    if (Platform.isIOS) {
      return UpgradeAlert(
        upgrader: Upgrader(
          debugDisplayAlways: debugForceShow,
          debugLogging: debugForceShow,
        ),
        child: child,
      );
    }
    return child;
  }
}
