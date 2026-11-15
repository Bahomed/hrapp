// Shared form pieces for the "new request" screens (same look as before).
// Dates are shown DD-MM-YYYY; the picked DateTime is handed back so the
// screen can send YYYY-MM-DD.

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../../services/theme_service.dart';
import '../my_request_models.dart';

InputDecoration requestInputDecoration(Color color, {Widget? suffixIcon, String? hint}) {
  final t = ThemeService.instance;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: t.getTextSecondaryColor().withValues(alpha: 0.3)),
  );
  return InputDecoration(
    filled: true,
    fillColor: t.getCardColor(),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: t.getErrorColor()),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: t.getErrorColor()),
    ),
    contentPadding: const EdgeInsets.all(16),
    suffixIcon: suffixIcon,
    hintText: hint,
    hintStyle: TextStyle(color: t.getTextSecondaryColor()),
    errorMaxLines: 3,
  );
}

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ThemeService.instance.getTextPrimaryColor(),
        ),
      ),
    );

Widget _pickerTheme(BuildContext context, Widget? child, Color color) {
  final t = ThemeService.instance;
  return Theme(
    data: Theme.of(context).copyWith(
      colorScheme: t.isDarkMode
          ? ColorScheme.dark(
              primary: color,
              onPrimary: Colors.white,
              surface: t.getCardColor(),
              onSurface: t.getTextPrimaryColor(),
            )
          : ColorScheme.light(
              primary: color,
              onPrimary: Colors.white,
              surface: t.getCardColor(),
              onSurface: t.getTextPrimaryColor(),
            ),
    ),
    child: child!,
  );
}

class RequestFormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const RequestFormHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeService.instance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
                Text(subtitle,
                    style: TextStyle(fontSize: 14, color: t.getTextSecondaryColor())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RequestDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final bool isLoading;
  final Color color;
  final String? Function(T?)? validator;
  final ValueChanged<T?> onChanged;

  const RequestDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.isLoading,
    required this.color,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        DropdownButtonFormField<T>(
          // ignore: deprecated_member_use
          value: value,
          isExpanded: true,
          validator: validator,
          decoration: requestInputDecoration(
            color,
            suffixIcon: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  )
                : null,
          ),
          hint: Text(
            trParams('select_field', {'field': label}),
            style: TextStyle(color: t.getTextSecondaryColor()),
          ),
          style: TextStyle(color: t.getTextPrimaryColor()),
          dropdownColor: t.getCardColor(),
          items: items
              .map((o) => DropdownMenuItem<T>(
                    value: o,
                    child: Text(
                      itemLabel(o),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: t.getTextPrimaryColor()),
                    ),
                  ))
              .toList(),
          onChanged: isLoading ? null : onChanged,
        ),
      ],
    );
  }
}

/// Read-only field that opens a date picker. Shows DD-MM-YYYY.
class RequestDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(String?)? validator;
  final ValueChanged<DateTime> onPicked;

  const RequestDateField({
    super.key,
    required this.label,
    required this.controller,
    required this.color,
    required this.onPicked,
    this.firstDate,
    this.lastDate,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          style: TextStyle(color: t.getTextPrimaryColor()),
          decoration: requestInputDecoration(
            color,
            suffixIcon: Icon(Icons.calendar_today, color: t.getTextSecondaryColor()),
            hint: 'DD-MM-YYYY',
          ),
          onTap: () async {
            final first = firstDate ?? DateTime.now();
            final last = lastDate ?? DateTime.now().add(const Duration(days: 365));
            final current = parseDisplayDate(controller.text);
            var initial = current ?? DateTime.now();
            if (initial.isBefore(first)) initial = first;
            if (initial.isAfter(last)) initial = last;
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: first,
              lastDate: last,
              builder: (ctx, child) => _pickerTheme(ctx, child, color),
            );
            if (picked != null) {
              controller.text = toDisplayDate(picked);
              onPicked(picked);
            }
          },
        ),
      ],
    );
  }
}

/// Read-only field that opens a 24h time picker. Shows / returns HH:mm.
class RequestTimeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onPicked;

  const RequestTimeField({
    super.key,
    required this.label,
    required this.controller,
    required this.color,
    this.validator,
    this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          style: TextStyle(color: t.getTextPrimaryColor()),
          decoration: requestInputDecoration(
            color,
            suffixIcon: Icon(Icons.access_time, color: t.getTextSecondaryColor()),
            hint: 'HH:mm',
          ),
          onTap: () async {
            TimeOfDay initial = TimeOfDay.now();
            final parts = controller.text.split(':');
            if (parts.length == 2) {
              final h = int.tryParse(parts[0]);
              final m = int.tryParse(parts[1]);
              if (h != null && m != null) initial = TimeOfDay(hour: h, minute: m);
            }
            final picked = await showTimePicker(
              context: context,
              initialTime: initial,
              builder: (ctx, child) => MediaQuery(
                data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
                child: _pickerTheme(ctx, child, color),
              ),
            );
            if (picked != null) {
              final v = '${picked.hour.toString().padLeft(2, '0')}:'
                  '${picked.minute.toString().padLeft(2, '0')}';
              controller.text = v;
              onPicked?.call(v);
            }
          },
        ),
      ],
    );
  }
}

class RequestTextAreaField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final String? Function(String?)? validator;
  final int maxLines;

  const RequestTextAreaField({
    super.key,
    required this.label,
    required this.controller,
    required this.color,
    this.validator,
    this.maxLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(color: t.getTextPrimaryColor()),
          decoration: requestInputDecoration(color),
        ),
      ],
    );
  }
}

class RequestNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final bool decimal;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const RequestNumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.color,
    this.decimal = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          style: TextStyle(color: t.getTextPrimaryColor()),
          decoration: requestInputDecoration(color),
        ),
      ],
    );
  }
}

/// One optional (or required) attachment: pdf / jpg / png, max 5 MB.
class RequestAttachmentPicker extends StatelessWidget {
  final File? file;
  final bool required;
  final Color color;
  final String? errorText;
  final ValueChanged<File?> onChanged;

  const RequestAttachmentPicker({
    super.key,
    required this.file,
    required this.color,
    required this.onChanged,
    this.required = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final t = ThemeService.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(required ? '${tr('attachment')} *' : tr('attachment')),
        if (file != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: t.getCardColor(),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_file, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file!.path.split('/').last,
                    style: TextStyle(fontSize: 13, color: t.getTextPrimaryColor()),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: t.getErrorColor()),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => onChanged(null),
                ),
              ],
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
              );
              final f = result?.files.firstOrNull;
              if (f == null || f.path == null) return;
              if (f.size > 5 * 1024 * 1024) {
                Get.snackbar(
                  tr('error'),
                  '1 ${tr('file_size_exceeded')}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: t.getErrorColor(),
                  colorText: Colors.white,
                );
                return;
              }
              onChanged(File(f.path!));
            },
            icon: Icon(Icons.upload_file, color: color),
            label: Text(tr('upload_attachment'), style: TextStyle(color: color)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: errorText != null ? t.getErrorColor() : color),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12, right: 12),
            child: Text(errorText!,
                style: TextStyle(color: t.getErrorColor(), fontSize: 12)),
          ),
      ],
    );
  }
}

class RequestSubmitButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback? onPressed;

  const RequestSubmitButton({
    super.key,
    required this.label,
    required this.color,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
