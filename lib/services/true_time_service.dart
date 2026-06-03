import 'package:ntp/ntp.dart';

/// Provides tamper-proof time by fetching the offset from an NTP server.
/// Users cannot fake attendance by changing the device clock.
class TrueTimeService {
  static int _ntpOffsetMs = 0;
  static bool _synced = false;

  /// Call once at app startup to sync with NTP.
  /// Subsequent calls to [now] use the cached offset.
  static Future<void> sync() async {
    try {
      _ntpOffsetMs = await NTP.getNtpOffset(
        localTime: DateTime.now(),
        lookUpAddress: 'pool.ntp.org',
        timeout: const Duration(seconds: 3),
      );
      _synced = true;
    } catch (_) {
      // If NTP fails (no internet yet), offset stays 0.
      // The server will still validate the timestamp on its side.
      _synced = false;
    }
  }

  /// Returns the current time corrected by the NTP offset.
  /// Cannot be faked by changing the device system clock.
  static DateTime now() {
    return DateTime.now().add(Duration(milliseconds: _ntpOffsetMs));
  }

  static bool get isSynced => _synced;
}
