import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../../services/theme_service.dart';
import '../request_controller.dart';

class CreateMissingPunchRequestScreen extends StatelessWidget {
  const CreateMissingPunchRequestScreen({super.key});

  static const _color = Color(0xFF6C5CE7);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();
    final themeService = ThemeService.instance;
    final formKey = GlobalKey<FormState>();

    final dateController = TextEditingController();
    final checkInController = TextEditingController();
    final checkOutController = TextEditingController();
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
          tr('create_missing_punch_request'),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.fingerprint, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('missing_punch_request'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _color,
                            ),
                          ),
                          Text(
                            tr('missing_punch_request_description'),
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

              _buildDateField(
                label: tr('date'),
                controller: dateController,
                context: context,
                firstDate: controller.firstAllowedDate,
                validator: (v) => (v == null || v.isEmpty) ? tr('please_select_date') : null,
              ),

              const SizedBox(height: 20),

              _buildTimeField(
                label: tr('check_in'),
                controller: checkInController,
                context: context,
                accentColor: _color,
              ),

              const SizedBox(height: 20),

              _buildTimeField(
                label: tr('check_out'),
                controller: checkOutController,
                context: context,
                accentColor: _color,
              ),

              const SizedBox(height: 20),

              _buildTextAreaField(
                label: tr('reason'),
                controller: reasonController,
              ),

              const SizedBox(height: 32),

              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          FocusScope.of(context).unfocus();
                          final navigator = Navigator.of(context);
                          final success = await controller.createMissingPunchRequestWithData(
                            date: dateController.text,
                            checkIn: checkInController.text.isNotEmpty ? checkInController.text : null,
                            checkOut: checkOutController.text.isNotEmpty ? checkOutController.text : null,
                            reason: reasonController.text.isNotEmpty ? reasonController.text : null,
                          );
                          if (success) navigator.pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                          tr('submit_missing_punch_request'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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

Widget _buildDateField({
  required String label,
  required TextEditingController controller,
  required BuildContext context,
  String? Function(String?)? validator,
  DateTime? firstDate,
}) {
  final themeService = ThemeService.instance;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeService.getTextPrimaryColor())),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        readOnly: true,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C5CE7))),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getErrorColor())),
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF6C5CE7)),
          hintText: trParams('select_field', {'field': label}),
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: firstDate ?? DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (picked != null) {
            controller.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
          }
        },
      ),
    ],
  );
}

Widget _buildTimeField({
  required String label,
  required TextEditingController controller,
  required BuildContext context,
  required Color accentColor,
}) {
  final themeService = ThemeService.instance;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeService.getTextPrimaryColor())),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        readOnly: true,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: Icon(Icons.access_time, color: accentColor),
          hintText: trParams('select_field', {'field': label}),
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (picked != null) {
            controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          }
        },
      ),
    ],
  );
}

Widget _buildTextAreaField({
  required String label,
  required TextEditingController controller,
}) {
  final themeService = ThemeService.instance;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: themeService.getTextPrimaryColor())),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        maxLines: 4,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6C5CE7))),
          contentPadding: const EdgeInsets.all(16),
          hintText: trParams('enter_field', {'field': label}),
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
      ),
    ],
  );
}
