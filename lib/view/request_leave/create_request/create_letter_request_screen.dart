// File: lib/view/request_leave/create_request/create_letter_request_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/data/remote/response/base_response.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import '../../../services/theme_service.dart';

import '../request_controller.dart';



class CreateLetterRequestScreen extends StatelessWidget {
  const CreateLetterRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();
    final themeService = ThemeService.instance;
    final formKey = GlobalKey<FormState>();

    final reasonController = TextEditingController();
    final selectedLetterType = Rx<RequestTypeOption?>(null);

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr('create_letter_request'),
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
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeService.getActionColor('documents').withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeService.getActionColor('documents'),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.description, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('letter_request'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: themeService.getActionColor('documents'),
                            ),
                          ),
                          Text(
                            tr('letter_request_description'),
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

              // Letter Type Dropdown with API data
              _buildApiDropdownField(
                label: tr('letter_type'),
                selectedValue: selectedLetterType,
                options: controller.letterTypes,
                isLoading: controller.isLoadingTypes,
                validator: (value) {
                  if (value == null) {
                    return tr('please_select_letter_type');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Reason Field
              _buildTextAreaField(
                label: tr('reason'),
                controller: reasonController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('please_provide_reason');
                  }
                  if (value.length < 10) {
                    return tr('reason_minimum_characters');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                    if (formKey.currentState!.validate() && selectedLetterType.value != null) {
                      final success = await controller.createLetterRequestWithData(
                        reason: reasonController.text,
                        letterTypeId: selectedLetterType.value!.id,
                      );
                      
                      // Only navigate if request was successful
                      if (success) {
                        // Small delay to show success message then navigate back
                        await Future.delayed(const Duration(milliseconds: 1500));
                        
                        // Try multiple navigation methods
                        if (context.mounted) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            // Fallback: Use Get navigation
                            Get.back();
                          }
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeService.getActionColor('documents'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: themeService.getSilver())
                      : Text(
                    tr('submit_letter_request'),
                    style: TextStyle(
                      color: themeService.getSilver(),
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

// Shared Widget Helper Functions
Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
}) {
  final themeService = ThemeService.instance;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getActionColor('documents')),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getErrorColor()),
          ),
          contentPadding: const EdgeInsets.all(16),
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
      ),
    ],
  );
}

Widget _buildTextAreaField({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator,
}) {
  final themeService = ThemeService.instance;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        maxLines: 4,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getActionColor('documents')),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getErrorColor()),
          ),
          contentPadding: const EdgeInsets.all(16),
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
      ),
    ],
  );
}

// Helper widget for API-driven dropdowns
Widget _buildApiDropdownField({
  required String label,
  required Rx<RequestTypeOption?> selectedValue,
  required RxList<RequestTypeOption> options,
  required RxBool isLoading,
  String? Function(RequestTypeOption?)? validator,
}) {
  final themeService = ThemeService.instance;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      const SizedBox(height: 8),
      Obx(() => DropdownButtonFormField<RequestTypeOption>(
        value: selectedValue.value,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getActionColor('documents')),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getErrorColor()),
          ),
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: isLoading.value
              ? SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(themeService.getActionColor('documents')),
              ),
            ),
          )
              : null,
        ),
        hint: Text(
          trParams('select_field', {'field': label}),
          style: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        dropdownColor: themeService.getCardColor(),
        items: options.map((RequestTypeOption option) {
          return DropdownMenuItem<RequestTypeOption>(
            value: option,
            child: Text(
              option.name,
              style: TextStyle(color: themeService.getTextPrimaryColor()),
            ),
          );
        }).toList(),
        onChanged: isLoading.value
            ? null
            : (RequestTypeOption? value) {
          selectedValue.value = value;
        },
      )),
    ],
  );
}

Widget _buildDropdownField({
  required String label,
  required TextEditingController controller,
  required List<String> items,
  String? Function(String?)? validator,
}) {
  final themeService = ThemeService.instance;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getActionColor('documents')),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getErrorColor()),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        hint: Text(
          trParams('select_field', {'field': label}),
          style: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        dropdownColor: themeService.getCardColor(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(color: themeService.getTextPrimaryColor()),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          controller.text = value ?? '';
        },
      ),
    ],
  );
}

Widget _buildDateField({
  required String label,
  required TextEditingController controller,
  required BuildContext context,
  String? Function(String?)? validator,
}) {
  final themeService = ThemeService.instance;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        readOnly: true,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getActionColor('documents')),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getErrorColor()),
          ),
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: themeService.getTextSecondaryColor(),
          ),
          hintText: 'Select $label',
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: themeService.isDarkMode 
                    ? ColorScheme.dark(
                        primary: themeService.getActionColor('documents'),
                        onPrimary: Colors.white,
                        surface: themeService.getCardColor(),
                        onSurface: themeService.getTextPrimaryColor(),
                      )
                    : ColorScheme.light(
                        primary: themeService.getActionColor('documents'),
                        onPrimary: Colors.white,
                        surface: themeService.getCardColor(),
                        onSurface: themeService.getTextPrimaryColor(),
                      ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            controller.text = picked.toIso8601String().split('T')[0];
          }
        },
      ),
    ],
  );
}