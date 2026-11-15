import 'package:flutter/material.dart';

import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';

/// Small shared helpers for the My Portal screens (contract, leave balances,
/// earned leave, assigned overtime). Server data is parsed defensively.
class PortalUi {
  PortalUi._();

  static ThemeService get theme => ThemeService.instance;

  /// `YYYY-MM-DD` (optionally followed by a time) → `DD-MM-YYYY [time]`.
  /// Anything else is returned unchanged; null/empty → '-'.
  static String date(dynamic value) {
    final s = value?.toString().trim() ?? '';
    if (s.isEmpty || s == 'null') return '-';
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{2}:\d{2}))?').firstMatch(s);
    if (m == null) return s;
    final time = m.group(4);
    return '${m.group(3)}-${m.group(2)}-${m.group(1)}${time != null ? ' $time' : ''}';
  }

  static double? toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', ''));
  }

  static int? toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  /// Number without useless decimals: 2.0 → "2", 1.93 → "1.93".
  static String number(dynamic v, {String fallback = '-'}) {
    final d = toDouble(v);
    if (d == null) return v?.toString().isNotEmpty == true ? v.toString() : fallback;
    if (d == d.roundToDouble()) return d.toInt().toString();
    return d.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
  }

  static String text(dynamic v, {String fallback = '-'}) {
    final s = v?.toString().trim() ?? '';
    return (s.isEmpty || s == 'null') ? fallback : s;
  }

  static Map<String, dynamic> map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static List<Map<String, dynamic>> list(dynamic v) => v is List
      ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : <Map<String, dynamic>>[];

  static bool truthy(dynamic v) =>
      v == true || v == 1 || v == '1' || v?.toString().toLowerCase() == 'true';

  // ── Widgets ──────────────────────────────────────────────────────────

  static PreferredSizeWidget appBar(BuildContext context, String title,
      {PreferredSizeWidget? bottom, List<Widget>? actions}) {
    return AppBar(
      backgroundColor: theme.getCardColor(),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.getTextPrimaryColor()),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: theme.getTextPrimaryColor(),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  static Widget loading() => Center(
        child: CircularProgressIndicator(color: theme.getPrimaryColor()),
      );

  /// Scrollable so it still works inside a RefreshIndicator.
  static Widget message({
    required IconData icon,
    required String text,
    Color? color,
    VoidCallback? onRetry,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 64, color: color ?? theme.getTextSecondaryColor()),
                  const SizedBox(height: 16),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: theme.getTextSecondaryColor()),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: Text(tr('retry')),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget error(String text, VoidCallback onRetry) => message(
        icon: Icons.error_outline,
        text: text,
        color: theme.getErrorColor(),
        onRetry: onRetry,
      );

  static Widget empty(String text) => message(icon: Icons.inbox, text: text);

  static Widget sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
          fontWeight: FontWeight.w700,
          color: theme.getTextPrimaryColor(),
        ),
      ),
    );
  }

  static Widget card({required Widget child, Color? borderColor, EdgeInsets? padding}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null
            ? Border.all(color: borderColor.withValues(alpha: 0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.getTextPrimaryColor().withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Label on the start side, value on the end side (RTL-aware).
  static Widget row(BuildContext context, String label, String value,
      {Color? valueColor, Widget? valueWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                color: theme.getTextSecondaryColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: valueWidget ??
                Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 13, tablet: 14, desktop: 15),
                    color: valueColor ?? theme.getTextPrimaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  /// Small coloured pill for statuses.
  static Widget chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// A coloured stat box (value + label), used for used / available etc.
  static Widget stat(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(fontSize: 11, color: theme.getTextSecondaryColor()),
          ),
        ],
      ),
    );
  }

  static Color statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
      case 'accepted':
      case 'paid':
        return theme.getSuccessColor();
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return theme.getErrorColor();
      case 'pending':
      case 'for-approval':
        return theme.getWarningColor();
      default:
        return theme.getTextSecondaryColor();
    }
  }
}
