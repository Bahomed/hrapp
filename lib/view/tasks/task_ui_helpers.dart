import 'package:flutter/material.dart';

/// Parse an API hex colour like "#f0ad4e" / "f0ad4e" / "#ffee8899".
/// Returns [fallback] for null / unparseable values.
Color taskHexColor(String? hex, Color fallback) {
  if (hex == null) return fallback;
  var s = hex.trim().replaceAll('#', '');
  if (s.length == 6) s = 'FF$s';
  if (s.length != 8) return fallback;
  final v = int.tryParse(s, radix: 16);
  return v == null ? fallback : Color(v);
}

/// Readable text/icon colour to sit on top of [background].
Color taskOnColor(Color background) {
  return background.computeLuminance() > 0.55 ? Colors.black87 : Colors.white;
}
