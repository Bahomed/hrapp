import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/widgets/saudi_riyal_display.dart';

/// Shared UI helpers for My Approvals and Finance (pay / return) screens.
class ApUi {
  ApUi._();

  static ThemeService get theme => ThemeService.instance;

  /// `YYYY-MM-DD[...]` → `DD-MM-YYYY`. Anything else is returned unchanged.
  static String date(String? v) {
    if (v == null || v.isEmpty) return '-';
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(v);
    if (m == null) return v;
    return '${m.group(3)}-${m.group(2)}-${m.group(1)}';
  }

  /// `YYYY-MM-DD HH:mm[:ss]` → `DD-MM-YYYY HH:mm`.
  static String dateTime(String? v) {
    if (v == null || v.isEmpty) return '-';
    final t = RegExp(r'[ T](\d{2}:\d{2})').firstMatch(v);
    return t == null ? date(v) : '${date(v)} ${t.group(1)}';
  }

  /// DateTime → `YYYY-MM-DD` (what the server expects).
  static String apiDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String time(String? v) {
    if (v == null || v.isEmpty) return '';
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(v);
    return m == null ? v : '${m.group(1)!.padLeft(2, '0')}:${m.group(2)}';
  }

  static String fmtNum(double? v) {
    if (v == null) return '-';
    return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);
  }

  static void ok(String message) {
    Get.snackbar(
      tr('ap_success'),
      message.isEmpty ? tr('ap_success') : message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: theme.getSuccessColor(),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  static void fail(String message) {
    Get.snackbar(
      tr('ap_error'),
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: theme.getErrorColor(),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // ── Type styling ─────────────────────────────────────────────────────
  static String typeKey(String type) {
    final t = type.toLowerCase().replaceAll(RegExp(r'[\s_-]'), '');
    return t.startsWith('permi') ? 'permit' : t;
  }

  static Color typeColor(String type) {
    switch (typeKey(type)) {
      case 'all':
        return theme.getActionColor('requests');
      case 'leave':
        return theme.getActionColor('schedule');
      case 'permit':
        return theme.getActionColor('profile');
      case 'loan':
        return theme.getSuccessColor();
      case 'letter':
        return theme.getActionColor('documents');
      case 'overtime':
        return const Color(0xFFFF6B35);
      case 'missingpunch':
        return const Color(0xFF6C5CE7);
      case 'payroll':
        return theme.getActionColor('payroll');
      default:
        return theme.getTextSecondaryColor();
    }
  }

  static IconData typeIcon(String type) {
    switch (typeKey(type)) {
      case 'all':
        return Icons.list;
      case 'leave':
        return Icons.calendar_today;
      case 'permit':
        return Icons.badge_outlined;
      case 'loan':
        return Icons.account_balance_wallet;
      case 'letter':
        return Icons.description;
      case 'overtime':
        return Icons.access_time_filled;
      case 'missingpunch':
        return Icons.fingerprint;
      case 'payroll':
        return Icons.payments_outlined;
      case 'leavesettlement':
        return Icons.beach_access_outlined;
      case 'finalsettlement':
        return Icons.logout;
      default:
        return Icons.circle_outlined;
    }
  }

  static String typeLabel(String type) {
    switch (typeKey(type)) {
      case 'leave':
        return tr('ap_leave');
      case 'permit':
        return tr('ap_permit');
      case 'loan':
        return tr('ap_loan');
      case 'letter':
        return tr('ap_letter');
      case 'overtime':
        return tr('ap_overtime');
      case 'missingpunch':
        return tr('ap_missing_punch');
      default:
        return type;
    }
  }

  // ── Small widgets ────────────────────────────────────────────────────
  static Widget infoRow(String label, String? value, {Color? valueColor}) {
    if (value == null || value.isEmpty || value == '-') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(fontSize: 13, color: theme.getTextSecondaryColor()),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? theme.getTextPrimaryColor(),
            ),
          ),
        ]),
      ),
    );
  }

  static Widget amountRow(String label, double? amount) {
    if (amount == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(fontSize: 13, color: theme.getTextSecondaryColor())),
          SaudiRiyalDisplay(
            amount: amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.getTextPrimaryColor(),
            ),
          ),
        ],
      ),
    );
  }

  static Widget avatar(String? url, String name, Color color, {double size = 40}) {
    final initial = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: color.withValues(alpha: 0.12),
      child: Text(initial,
          style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: size * 0.4)),
    );
    if (url == null || url.isEmpty || !url.startsWith('http')) return fallback;
    return ClipOval(
      child: Image.network(url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback),
    );
  }

  static Widget chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      );

  static BoxDecoration card(Color accent) => BoxDecoration(
        color: theme.getSurfaceColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static Widget actionButton(String label, Color color, VoidCallback? onPressed,
          {bool filled = false}) =>
      filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(label, style: const TextStyle(fontSize: 12), maxLines: 1),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(label,
                  style: TextStyle(color: color, fontSize: 12), maxLines: 1),
            );

  static Widget emptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onRefresh,
  }) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.getActionColor('requests').withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 64, color: theme.getActionColor('requests')),
                ),
                const SizedBox(height: 24),
                Text(title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.getTextPrimaryColor())),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: theme.getTextSecondaryColor())),
                ],
                if (onRefresh != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(tr('ap_refresh')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.getActionColor('requests'),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────

  /// Text dialog that calls [onSubmit] itself. Server errors (403/422,
  /// field errors under [errorField]) stay inside the dialog. Returns the
  /// successful [ApiResult], or null when cancelled.
  static Future<ApiResult?> textActionDialog({
    required String title,
    required String label,
    required String confirmText,
    required Color confirmColor,
    required Future<ApiResult> Function(String text) onSubmit,
    bool required = false,
    String errorField = 'reason',
    String? message,
  }) {
    final ctrl = TextEditingController();
    String? error;
    bool busy = false;
    return Get.dialog<ApiResult>(
      StatefulBuilder(builder: (context, setState) {
        Future<void> submit() async {
          final text = ctrl.text.trim();
          if (required && text.isEmpty) {
            setState(() => error = tr('ap_reason_required'));
            return;
          }
          if (text.length > 500) {
            setState(() => error = tr('ap_max_500'));
            return;
          }
          setState(() {
            busy = true;
            error = null;
          });
          final r = await onSubmit(text);
          if (r.ok) {
            Get.back(result: r);
          } else {
            setState(() {
              busy = false;
              error = r.errorFor(errorField) ?? r.displayMessage();
            });
          }
        }

        return AlertDialog(
          backgroundColor: theme.getSurfaceColor(),
          title: Text(title, style: TextStyle(color: theme.getTextPrimaryColor())),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message != null) ...[
                  Text(message, style: TextStyle(color: theme.getTextSecondaryColor())),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: ctrl,
                  maxLines: 4,
                  maxLength: 500,
                  enabled: !busy,
                  decoration: InputDecoration(
                    labelText: label,
                    errorText: error,
                    errorMaxLines: 4,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Get.back(),
              child: Text(tr('ap_cancel')),
            ),
            ElevatedButton(
              onPressed: busy ? null : submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(confirmText),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  /// Yes / no dialog that runs [onConfirm]; errors stay inside the dialog.
  static Future<ApiResult?> confirmActionDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required Future<ApiResult> Function() onConfirm,
  }) {
    String? error;
    bool busy = false;
    return Get.dialog<ApiResult>(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: theme.getSurfaceColor(),
          title: Text(title, style: TextStyle(color: theme.getTextPrimaryColor())),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: TextStyle(color: theme.getTextSecondaryColor())),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!, style: TextStyle(color: theme.getErrorColor())),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Get.back(),
              child: Text(tr('ap_cancel')),
            ),
            ElevatedButton(
              onPressed: busy
                  ? null
                  : () async {
                      setState(() {
                        busy = true;
                        error = null;
                      });
                      final r = await onConfirm();
                      if (r.ok) {
                        Get.back(result: r);
                      } else {
                        setState(() {
                          busy = false;
                          error = r.allErrors();
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(confirmText),
            ),
          ],
        );
      }),
      barrierDismissible: false,
    );
  }

  /// Bottom sheet that renders an arbitrary JSON object as label / value
  /// rows (used for shapes the API does not document, e.g. settlements).
  static void showDataSheet(String title, Map<String, dynamic> data,
      {List<Widget> actions = const []}) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scroll) => Container(
          decoration: BoxDecoration(
            color: theme.getSurfaceColor(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.getDividerColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.getTextPrimaryColor())),
              ),
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _dataRows(data, 0),
                ),
              ),
              if (actions.isNotEmpty)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        for (int i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(child: actions[i]),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static const _hiddenKeys = {
    'status', 'statusCode', 'status_code', 'error', 'success', 'message', 'code',
    'avatar', 'image', 'photo', 'dev_punch',
  };

  static String _humanize(String key) {
    final k = key.replaceAll('_', ' ').trim();
    return k.isEmpty ? key : '${k[0].toUpperCase()}${k.substring(1)}';
  }

  static String _fmtValue(dynamic v) {
    if (v == null) return '-';
    if (v is bool) return v ? '✓' : '✗';
    if (v is num) return fmtNum(v.toDouble());
    final s = v.toString();
    return RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(s) ? date(s) : s;
  }

  static List<Widget> _dataRows(Map<String, dynamic> data, int depth) {
    final out = <Widget>[];
    data.forEach((k, v) {
      if (_hiddenKeys.contains(k)) return;
      if (v is Map) {
        out.add(Padding(
          padding: EdgeInsetsDirectional.only(top: 12, bottom: 4, start: depth * 8.0),
          child: Text(_humanize(k),
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: theme.getTextPrimaryColor())),
        ));
        out.addAll(_dataRows(Map<String, dynamic>.from(v), depth + 1));
      } else if (v is List) {
        if (v.isEmpty) return;
        out.add(Padding(
          padding: EdgeInsetsDirectional.only(top: 12, bottom: 4, start: depth * 8.0),
          child: Text(_humanize(k),
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: theme.getTextPrimaryColor())),
        ));
        for (final e in v) {
          if (e is Map) {
            out.add(Container(
              margin: EdgeInsetsDirectional.only(bottom: 8, start: depth * 8.0),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: theme.getDividerColor()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _dataRows(Map<String, dynamic>.from(e), 0),
              ),
            ));
          } else {
            out.add(Padding(
              padding: EdgeInsetsDirectional.only(start: depth * 8.0 + 8),
              child: Text('• ${_fmtValue(e)}',
                  style: TextStyle(color: theme.getTextPrimaryColor())),
            ));
          }
        }
      } else {
        out.add(Padding(
          padding: EdgeInsetsDirectional.only(start: depth * 8.0, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(_humanize(k),
                    style: TextStyle(fontSize: 13, color: theme.getTextSecondaryColor())),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(_fmtValue(v),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.getTextPrimaryColor())),
              ),
            ],
          ),
        ));
      }
    });
    return out;
  }

  // ── Files ────────────────────────────────────────────────────────────

  /// Opens an attachment URL: images in a viewer, PDFs downloaded and opened,
  /// anything else in the external browser.
  static Future<void> openAttachment(String url, BuildContext context) async {
    final lower = url.toLowerCase().split('?').first;
    final isImage = lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
    if (isImage) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, p) => p == null
                        ? child
                        : const Center(child: CircularProgressIndicator(color: Colors.white)),
                    errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.white, size: 64)),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 40,
                end: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }
    if (lower.endsWith('.pdf')) {
      try {
        final name = lower.split('/').last;
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/$name';
        if (!File(path).existsSync()) await Dio().download(url, path);
        await OpenFile.open(path);
        return;
      } catch (_) {}
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      fail(tr('ap_could_not_open'));
    }
  }

  /// Saves [bytes] to a temp file and opens it with the system viewer.
  static Future<void> openBytes(List<int> bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final safe = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File('${dir.path}/$safe');
    await file.writeAsBytes(bytes, flush: true);
    final r = await OpenFile.open(file.path);
    if (r.type != ResultType.done) fail(tr('ap_could_not_open'));
  }
}
