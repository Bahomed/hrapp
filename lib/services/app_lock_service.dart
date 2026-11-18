import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';

/// App lock with fingerprint / Face ID (biometric only, no phone PIN).
///
/// When enabled (Settings › Security), the app is locked:
///  - on cold start, and
///  - when the user comes back after more than [_lockAfter] in the background.
/// Short trips out (camera, file picker, GPS settings) do not lock the app.
class AppLockService extends GetxService with WidgetsBindingObserver {
  static AppLockService get to => Get.find();

  static const _enabledKey = 'APP_LOCK_ENABLED';
  static const _lockAfter = Duration(seconds: 30);

  final _storage = GetStorage();
  final _auth = LocalAuthentication();
  final _preferences = Preferences();

  final isEnabled = false.obs;
  final isLocked = false.obs;

  DateTime? _backgroundedAt;
  bool _authenticating = false;

  @override
  void onInit() {
    super.onInit();
    isEnabled.value = _storage.read(_enabledKey) ?? false;
    WidgetsBinding.instance.addObserver(this);
    _lockIfNeeded();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The biometric prompt itself pauses the app on some devices — ignore that.
    if (_authenticating) return;

    if (state == AppLifecycleState.paused) {
      _backgroundedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final away = _backgroundedAt;
      _backgroundedAt = null;
      if (away != null && DateTime.now().difference(away) >= _lockAfter) {
        _lockIfNeeded();
      }
    }
  }

  Future<void> _lockIfNeeded() async {
    // Re-read: logout (Preferences.clearLoginSession) removes the key
    isEnabled.value = _storage.read(_enabledKey) ?? false;
    if (!isEnabled.value || isLocked.value) return;
    if (!await _preferences.isLoggedIn()) return;
    // Fingerprint/face removed from the phone → don't trap the user behind a lock
    if (!await isAvailable()) return;
    isLocked.value = true;
    unlock();
  }

  /// Phone has a fingerprint or face enrolled.
  Future<bool> isAvailable() async {
    try {
      if (!await _auth.canCheckBiometrics) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _authenticate() async {
    if (_authenticating) return false;
    _authenticating = true;
    try {
      return await _auth.authenticate(
        localizedReason: tr('app_lock_reason'),
        biometricOnly: true, // fingerprint / Face ID only — no phone PIN
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    } finally {
      _authenticating = false;
    }
  }

  /// Called from the lock screen.
  Future<void> unlock() async {
    if (await _authenticate()) isLocked.value = false;
  }

  /// Settings toggle. Turning it on requires a successful scan first.
  Future<bool> setEnabled(bool value) async {
    if (value) {
      if (!await isAvailable()) {
        Get.snackbar(tr('app_lock'), tr('app_lock_not_available'),
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      if (!await _authenticate()) return false;
    }
    isEnabled.value = value;
    await _storage.write(_enabledKey, value);
    return true;
  }
}

/// Full-screen cover shown on top of the app while locked.
class AppLockOverlay extends StatelessWidget {
  final Widget child;
  const AppLockOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final lock = AppLockService.to;
    return Obx(() => Stack(
          children: [
            child,
            if (lock.isLocked.value)
              Positioned.fill(
                child: Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline,
                                size: 72, color: Theme.of(context).primaryColor),
                            const SizedBox(height: 24),
                            Text(
                              tr('app_locked'),
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tr('app_lock_reason'),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            FilledButton.icon(
                              onPressed: lock.unlock,
                              icon: const Icon(Icons.fingerprint),
                              label: Text(tr('unlock')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ));
  }
}
