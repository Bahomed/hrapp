import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';

const _kDisclosureShownKey = 'bg_location_disclosure_shown';

/// Called at app launch (from SplashController) to show the disclosure once
/// before the user does anything. Uses Get.dialog() — no BuildContext needed.
Future<void> showBackgroundLocationDisclosureIfNeeded() async {
  final storage = GetStorage();
  final alreadyShown = storage.read<bool>(_kDisclosureShownKey) ?? false;
  if (alreadyShown) return;

  await Get.dialog<void>(
    const _BackgroundLocationDisclosureDialog(dismissible: false),
    barrierDismissible: false,
  );

  await storage.write(_kDisclosureShownKey, true);
}

/// Requests location permission. Disclosure is already shown at launch,
/// so this just handles the system permission request.
Future<LocationPermission> requestBackgroundLocationWithDisclosure(
    BuildContext context) async {
  LocationPermission current = await Geolocator.checkPermission();

  if (current == LocationPermission.always ||
      current == LocationPermission.whileInUse) {
    return current;
  }

  if (current == LocationPermission.deniedForever) return current;

  current = await Geolocator.requestPermission();
  return current;
}

class _BackgroundLocationDisclosureDialog extends StatelessWidget {
  final bool dismissible;
  const _BackgroundLocationDisclosureDialog({this.dismissible = false});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tr('bg_location_disclosure_title'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          tr('bg_location_disclosure_body'),
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(),
          child: Text(tr('bg_location_allow')),
        ),
      ],
    );
  }
}
