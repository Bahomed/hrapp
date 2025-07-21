import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/services/theme_service.dart';

class InputWidgets {
  
  /// Standard Input Field - Consistent across all screens
  static Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isRequired = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    int? maxLines,
    bool enabled = true,
  }) {
    final themeService = Get.find<ThemeService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: enabled ? themeService.getTextPrimaryColor() : themeService.getTextSecondaryColor(),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: themeService.getErrorColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Input Field Container
        Container(
          decoration: BoxDecoration(
            color: enabled ? themeService.getBackgroundColor() : themeService.getBackgroundColor().withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? themeService.getDividerColor() : themeService.getDividerColor().withValues(alpha: 0.5),
            ),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            maxLines: maxLines ?? 1,
            enabled: enabled,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: enabled ? themeService.getTextPrimaryColor() : themeService.getTextSecondaryColor(),
            ),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: themeService.getTextSecondaryColor().withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                icon,
                color: enabled ? themeService.getPrimaryColor() : themeService.getTextSecondaryColor(),
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator ?? (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'Please enter $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Search Input Field
  static Widget buildSearchField({
    required TextEditingController controller,
    required String hint,
    void Function(String)? onChanged,
    VoidCallback? onClear,
    Color? backgroundColor,
  }) {
    final themeService = Get.find<ThemeService>();
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? themeService.getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeService.getDividerColor()),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: themeService.getTextPrimaryColor(),
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: themeService.getTextSecondaryColor(),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: themeService.getPrimaryColor(),
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: themeService.getTextSecondaryColor(),
                    size: 20,
                  ),
                  onPressed: onClear ?? () {
                    controller.clear();
                    if (onChanged != null) onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Dropdown Field
  static Widget buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    required IconData icon,
    String? hint,
    bool isRequired = true,
    bool enabled = true,
  }) {
    final themeService = Get.find<ThemeService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: enabled ? themeService.getTextPrimaryColor() : themeService.getTextSecondaryColor(),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: themeService.getErrorColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Dropdown Container
        Container(
          decoration: BoxDecoration(
            color: enabled ? themeService.getBackgroundColor() : themeService.getBackgroundColor().withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? themeService.getDividerColor() : themeService.getDividerColor().withValues(alpha: 0.5),
            ),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            onChanged: enabled ? onChanged : null,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: enabled ? themeService.getTextPrimaryColor() : themeService.getTextSecondaryColor(),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: themeService.getTextSecondaryColor().withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                icon,
                color: enabled ? themeService.getPrimaryColor() : themeService.getTextSecondaryColor(),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item)),
              );
            }).toList(),
            validator: (value) {
              if (isRequired && value == null) {
                return 'Please select $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Date Picker Field
  static Widget buildDateField({
    required String label,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
    required IconData icon,
    String? hint,
    bool isRequired = true,
    bool enabled = true,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final themeService = Get.find<ThemeService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: enabled ? themeService.getTextPrimaryColor() : themeService.getTextSecondaryColor(),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: themeService.getErrorColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Date Field Container
        GestureDetector(
          onTap: enabled ? () async {
            final date = await showDatePicker(
              context: _getCurrentContext(),
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(2000),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: themeService.isDarkMode
                        ? ColorScheme.dark(
                            primary: themeService.getPrimaryColor(),
                            onPrimary: Colors.white,
                            surface: themeService.getCardColor(),
                            onSurface: themeService.getTextPrimaryColor(),
                          )
                        : ColorScheme.light(
                            primary: themeService.getPrimaryColor(),
                            onPrimary: Colors.white,
                            surface: themeService.getCardColor(),
                            onSurface: themeService.getTextPrimaryColor(),
                          ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              onDateSelected(date);
            }
          } : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: enabled ? themeService.getBackgroundColor() : themeService.getBackgroundColor().withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled ? themeService.getDividerColor() : themeService.getDividerColor().withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: enabled ? themeService.getPrimaryColor() : themeService.getTextSecondaryColor(),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedDate != null 
                        ? _formatDate(selectedDate!)
                        : hint ?? 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selectedDate != null 
                          ? (enabled ? themeService.getTextPrimaryColor() : themeService.getTextSecondaryColor())
                          : themeService.getTextSecondaryColor().withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_month,
                  color: themeService.getTextSecondaryColor(),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// File Upload Field
  static Widget buildFileUploadField({
    required String label,
    String? fileName,
    required VoidCallback onTap,
    required IconData icon,
    bool isRequired = true,
    bool enabled = true,
    Color? acceptColor,
  }) {
    final themeService = Get.find<ThemeService>();
    final hasFile = fileName != null && fileName.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: enabled ? themeService.getTextPrimaryColor() : themeService.getTextSecondaryColor(),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: themeService.getErrorColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Upload Field Container
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: enabled ? themeService.getBackgroundColor() : themeService.getBackgroundColor().withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFile 
                    ? (acceptColor ?? themeService.getSuccessColor())
                    : (enabled ? themeService.getDividerColor() : themeService.getDividerColor().withValues(alpha: 0.5)),
                width: hasFile ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasFile ? Icons.attach_file : icon,
                  color: hasFile 
                      ? (acceptColor ?? themeService.getSuccessColor())
                      : (enabled ? themeService.getPrimaryColor() : themeService.getTextSecondaryColor()),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    hasFile ? fileName : 'Tap to select file',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: hasFile 
                          ? (enabled ? themeService.getTextPrimaryColor() : themeService.getTextSecondaryColor())
                          : themeService.getTextSecondaryColor().withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Icon(
                  hasFile ? Icons.check_circle : Icons.upload_file,
                  color: hasFile 
                      ? (acceptColor ?? themeService.getSuccessColor())
                      : themeService.getTextSecondaryColor(),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Checkbox Field
  static Widget buildCheckboxField({
    required String label,
    required bool value,
    required void Function(bool?) onChanged,
    bool enabled = true,
    String? description,
  }) {
    final themeService = Get.find<ThemeService>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: themeService.getPrimaryColor(),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: enabled ? themeService.getTextPrimaryColor() : themeService.getTextSecondaryColor(),
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: themeService.getTextSecondaryColor(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static BuildContext _getCurrentContext() {
    // Get the current context from the navigator
    return Get.context!;
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Password visibility toggle widget
class PasswordVisibilityToggle extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isRequired;
  final String? Function(String?)? validator;

  const PasswordVisibilityToggle({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isRequired = true,
    this.validator,
  });

  @override
  State<PasswordVisibilityToggle> createState() => _PasswordVisibilityToggleState();
}

class _PasswordVisibilityToggleState extends State<PasswordVisibilityToggle> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    return InputWidgets.buildInputField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      icon: widget.icon,
      isPassword: _isObscured,
      isRequired: widget.isRequired,
      validator: widget.validator,
      suffixIcon: IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: themeService.getTextSecondaryColor(),
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
      ),
    );
  }
}