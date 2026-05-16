import 'dart:async';
import 'dart:io' show Platform;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../data/local/preferences.dart';
import '../../data/remote/response/attendance_status_response.dart';
import '../../repository/attendancerepository.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import '../attendance/clocking_screen.dart';
import '../scan/AutoRecognitionScreen.dart';

class QuickAttendanceController extends GetxController {
  final Preferences _preferences = Preferences();
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  var isLocationReady = false.obs;
  var isProcessing = false.obs;

  double? _currentLat;
  double? _currentLng;
  String? _wifiSSID;
  String? _wifiBSSID;
  String? _street;
  String? _city;
  String? _state;
  String? _country;
  String? _postalCode;

  int _userId = 0;
  String _userName = '';

  @override
  void onInit() {
    super.onInit();
    _initInBackground();
  }

  Future<void> _initInBackground() async {
    try {
      final userData = await _preferences.getUserData();
      if (userData != null) {
        _userId = userData.id ?? 0;
        _userName = userData.employeeName ?? '';
      }
    } catch (_) {}

    await _collectLocation();
  }

  Future<void> _collectLocation() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isWifi = connectivityResult.contains(ConnectivityResult.wifi);

      if (isWifi) {
        final info = NetworkInfo();
        try {
          if (Platform.isIOS) {
            final perm = await Geolocator.checkPermission();
            if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
              _wifiSSID = await info.getWifiName();
              _wifiBSSID = await info.getWifiBSSID();
            }
          } else {
            _wifiSSID = await info.getWifiName();
            _wifiBSSID = await info.getWifiBSSID();
          }
        } catch (_) {}
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        ),
      ).timeout(const Duration(seconds: 30));

      _currentLat = position.latitude;
      _currentLng = position.longitude;

      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks[0];
          _street = '${place.street ?? ''} ${place.subThoroughfare ?? ''}'.trim();
          if (_street!.isEmpty) _street = place.thoroughfare;
          _city = place.locality ?? place.subAdministrativeArea;
          _state = place.administrativeArea;
          _country = place.country;
          _postalCode = place.postalCode;
        }
      } catch (_) {}

      isLocationReady.value = true;
    } catch (_) {}
  }

  Map<String, dynamic> _getLocationData() {
    return {
      'street': _street,
      'city': _city,
      'state': _state,
      'country': _country,
      'postalCode': _postalCode,
      'latitude': _currentLat,
      'longitude': _currentLng,
      'wifiSSID': _wifiSSID,
      'wifiBSSID': _wifiBSSID,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> performQuickAttendance() async {
    if (isProcessing.value) return;
    isProcessing.value = true;

    try {
      // 1. If face not registered → go to ClockingScreen for setup
      final hasFace = await _preferences.userFaceExists();
      if (!hasFace) {
        await Get.to(const ClockingScreen());
        return;
      }

      // 2. Wait briefly for location if still loading
      bool dialogOpen = false;
      if (!isLocationReady.value) {
        dialogOpen = true;
        Get.dialog(
          AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(tr('getting_location')),
              ],
            ),
          ),
          barrierDismissible: false,
        );
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (isLocationReady.value) break;
        }
        if (dialogOpen && (Get.isDialogOpen ?? false)) {
          Get.back();
          dialogOpen = false;
        }
      }

      // 3. Get attendance status
      AttendanceStatusData? statusData;
      try {
        final response = await _attendanceRepository.getAttendanceStatus();
        final statusResponse = AttendanceStatusResponse.fromJson(response);
        if (!statusResponse.error && statusResponse.data != null) {
          statusData = statusResponse.data;
        }
      } catch (_) {}

      // 4. Determine valid attendance action from boolean flags
      final attendanceType = statusData != null ? _resolveAttendanceType(statusData) : 'clock_in';

      if (attendanceType == null) {
        // No action available — show status bottom sheet with all timing info
        _showStatusSheet(statusData!);
        return;
      }

      // 5. Navigate directly to face recognition
      final result = await Get.to(
        () => AutoRecognitionScreen(
          attendanceType: attendanceType,
          locationData: _getLocationData(),
        ),
        arguments: {
          'userId': _userId,
          'username': _userName,
          'attendanceType': attendanceType,
          'locationData': _getLocationData(),
        },
      );

      // Refresh location for next tap
      isLocationReady.value = false;
      _collectLocation();

      // 6. Show result snackbar
      if (result is Map<String, dynamic>) {
        if (result['success'] == true) {
          _showSuccessSnackbar(_successMessage(attendanceType));
        } else if (result['warning'] == true && result['message'] != null) {
          _showWarningSnackbar(result['message']);
        } else {
          _showErrorSnackbar(result['message'] ?? tr('face_verification_failed_retry'));
        }
      }
    } finally {
      isProcessing.value = false;
    }
  }

  /// Determine the correct attendance type from API boolean flags.
  /// Returns null when no action is currently available (e.g. waiting for clock-out window).
  String? _resolveAttendanceType(AttendanceStatusData data) {
    if (data.canClockIn) return 'clock_in';
    if (data.canBreakOut) return 'break_out';
    if (data.canBreakIn) return 'break_in';
    if (data.canClockOut) return 'clock_out';
    return null;
  }

  /// Show a bottom sheet with full attendance status and all recorded times.
  void _showStatusSheet(AttendanceStatusData data) {
    final themeService = ThemeService.instance;
    final attData = data.attendanceData;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: themeService.getCardColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              tr('attendance_status'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 4),

            // Status message — build formatted version from session timing if available
            if (data.statusMessage.isNotEmpty)
              Text(
                _buildFormattedStatusMessage(data),
                style: TextStyle(
                  fontSize: 13,
                  color: themeService.getWarningColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),

            const SizedBox(height: 20),

            // Attendance times
            _timeRow(tr('clock_in'), attData.clockIn, themeService),
            _timeRow(tr('break_start'), attData.breakIn, themeService),
            _timeRow(tr('break_end'), attData.breakOut, themeService),
            _timeRow(tr('clock_out'), attData.clockOut, themeService),

            // Session timing info
            if (data.sessionTiming != null) ...[
              const SizedBox(height: 16),
              Divider(color: themeService.getTextSecondaryColor().withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              Text(
                tr('session_timing'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextSecondaryColor(),
                ),
              ),
              const SizedBox(height: 8),
              _sessionRow(tr('clock_in_window'),
                  '${_formatTime(data.sessionTiming!.checkInBegin)} - ${_formatTime(data.sessionTiming!.checkInEnd)}',
                  themeService),
              _sessionRow(tr('clock_out_window'),
                  '${_formatTime(data.sessionTiming!.checkOutBegin)} - ${_formatTime(data.sessionTiming!.checkOutEnd)}',
                  themeService),
            ],

            const SizedBox(height: 20),

            // View full attendance button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.back();
                  Get.to(const ClockingScreen());
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: themeService.getPrimaryColor()),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  tr('view_details'),
                  style: TextStyle(color: themeService.getPrimaryColor()),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  String _buildFormattedStatusMessage(AttendanceStatusData data) {
    final timing = data.sessionTiming;
    if (timing == null) return data.statusMessage;
    // If waiting for clock-in window
    if (data.canClockIn == false && data.attendanceData.clockIn == null) {
      return '${tr('clock_in_window')}: ${_formatTime(timing.checkInBegin)} - ${_formatTime(timing.checkInEnd)}';
    }
    // If waiting for clock-out window
    if (data.canClockOut == false && data.attendanceData.clockIn != null && data.attendanceData.clockOut == null) {
      return '${tr('clock_out_window')}: ${_formatTime(timing.checkOutBegin)} - ${_formatTime(timing.checkOutEnd)}';
    }
    return data.statusMessage;
  }

  Widget _timeRow(String label, String? time, ThemeService themeService) {
    if (time == null) return const SizedBox.shrink();
    final displayTime = _formatTime(time);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14, color: themeService.getTextSecondaryColor())),
          Text(displayTime,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              )),
        ],
      ),
    );
  }

  Widget _sessionRow(String label, String value, ThemeService themeService) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: themeService.getTextSecondaryColor())),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: themeService.getTextPrimaryColor(),
              )),
        ],
      ),
    );
  }

  String _formatTime(String timeStr) {
    try {
      DateTime dt;
      if (timeStr.contains('T') || (timeStr.contains(' ') && timeStr.length > 10)) {
        dt = DateTime.parse(timeStr);
      } else {
        final parts = timeStr.split(':');
        final now = DateTime.now();
        dt = DateTime(now.year, now.month, now.day,
            int.parse(parts[0]), int.parse(parts[1]),
            parts.length > 2 ? int.parse(parts[2]) : 0);
      }
      final hour = dt.hour > 12
          ? (dt.hour - 12).toString().padLeft(2, '0')
          : dt.hour == 0
              ? '12'
              : dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      final second = dt.second.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? tr('pm') : tr('am');
      return '$hour:$minute:$second $period';
    } catch (_) {
      return timeStr;
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar('', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ThemeService.instance.getSuccessColor(),
        colorText: Colors.white,
        titleText: const SizedBox.shrink(),
        duration: const Duration(seconds: 3));
  }

  void _showWarningSnackbar(String message) {
    Get.snackbar('', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ThemeService.instance.getWarningColor(),
        colorText: Colors.white,
        titleText: const SizedBox.shrink(),
        duration: const Duration(seconds: 4));
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar('', message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: ThemeService.instance.getErrorColor(),
        colorText: Colors.white,
        titleText: const SizedBox.shrink(),
        duration: const Duration(seconds: 3));
  }

  String _successMessage(String attendanceType) {
    switch (attendanceType) {
      case 'clock_in':
        return tr('clocked_in_successfully');
      case 'clock_out':
        return tr('clocked_out_successfully');
      case 'break_in':
        return tr('break_started_successfully');
      case 'break_out':
        return tr('break_ended_successfully');
      default:
        return tr('clocked_in_successfully');
    }
  }
}
