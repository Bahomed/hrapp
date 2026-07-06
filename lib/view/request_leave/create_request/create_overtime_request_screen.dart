import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/view/request_leave/request_controller.dart';

class CreateOvertimeRequestScreen extends StatelessWidget {
  const CreateOvertimeRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();
    final themeService = ThemeService.instance;
    final formKey = GlobalKey<FormState>();
    const overtimeColor = Color(0xFFFF6B35);

    final fromDateController = TextEditingController();
    final toDateController = TextEditingController();
    final hoursController = TextEditingController();
    final reasonController = TextEditingController();

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tr('create_overtime_request'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: overtimeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: overtimeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.access_time_filled, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('overtime_request'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: overtimeColor,
                            ),
                          ),
                          Text(
                            tr('overtime_request_description'),
                            style: TextStyle(
                              fontSize: 14,
                              color: themeService.getTextSecondaryColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // From Date *
              _buildDateField(
                label: tr('from_date'),
                controller: fromDateController,
                context: context,
                accentColor: overtimeColor,
                firstDate: controller.firstAllowedDate,
                required: true,
                validator: (v) => (v == null || v.isEmpty) ? tr('please_select_from_date') : null,
              ),
              const SizedBox(height: 20),

              // To Date *
              _buildDateField(
                label: tr('to_date'),
                controller: toDateController,
                context: context,
                accentColor: overtimeColor,
                firstDate: controller.firstAllowedDate,
                required: true,
                validator: (v) => (v == null || v.isEmpty) ? tr('please_select_to_date') : null,
              ),
              const SizedBox(height: 20),

              // Total OT Hours *
              _buildTextField(
                label: tr('total_ot_hours'),
                controller: hoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hintText: tr('eg_3_5'),
                accentColor: overtimeColor,
                required: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return tr('please_enter_ot_hours');
                  final h = double.tryParse(v);
                  if (h == null || h <= 0) return tr('please_enter_valid_hours');
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Reason *
              _buildTextAreaField(
                label: tr('reason'),
                controller: reasonController,
                accentColor: overtimeColor,
                required: true,
                validator: (v) => (v == null || v.isEmpty) ? tr('please_enter_reason') : null,
              ),
              const SizedBox(height: 32),

              // Submit button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final success = await controller.createOvertimeRequestWithData(
                              fromDate: fromDateController.text,
                              toDate: toDateController.text,
                              totalOtHours: double.parse(hoursController.text),
                              reason: reasonController.text,
                            );
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tr('overtime_request_created_successfully')),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              await Future.delayed(const Duration(milliseconds: 1500));
                              if (context.mounted) Navigator.of(context).pop();
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: overtimeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          tr('submit_overtime_request'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildRequiredLabel(String label, ThemeService themeService) {
  return RichText(
    text: TextSpan(
      text: label,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeService.getTextPrimaryColor()),
      children: const [
        TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  String? hintText,
  required Color accentColor,
  bool required = false,
}) {
  final themeService = ThemeService.instance;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      required
          ? _buildRequiredLabel(label, themeService)
          : Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeService.getTextPrimaryColor())),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          hintText: hintText,
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getErrorColor())),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    ],
  );
}

Widget _buildTextAreaField({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator,
  required Color accentColor,
  bool required = false,
}) {
  final themeService = ThemeService.instance;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      required
          ? _buildRequiredLabel(label, themeService)
          : Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeService.getTextPrimaryColor())),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        maxLines: 4,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getErrorColor())),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    ],
  );
}

Widget _buildDateField({
  required String label,
  required TextEditingController controller,
  required BuildContext context,
  String? Function(String?)? validator,
  required Color accentColor,
  bool required = false,
  DateTime? firstDate,
}) {
  final themeService = ThemeService.instance;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      required
          ? _buildRequiredLabel(label, themeService)
          : Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeService.getTextPrimaryColor())),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        readOnly: true,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          hintText: label,
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
          suffixIcon: Icon(Icons.calendar_today, color: themeService.getTextSecondaryColor()),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getErrorColor())),
          contentPadding: const EdgeInsets.all(16),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: firstDate ?? DateTime(DateTime.now().year - 1),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: themeService.isDarkMode
                    ? ColorScheme.dark(primary: accentColor, onPrimary: Colors.white, surface: themeService.getCardColor(), onSurface: themeService.getTextPrimaryColor())
                    : ColorScheme.light(primary: accentColor, onPrimary: Colors.white, surface: themeService.getCardColor(), onSurface: themeService.getTextPrimaryColor()),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            controller.text = picked.toIso8601String().split('T')[0];
          }
        },
      ),
    ],
  );
}
