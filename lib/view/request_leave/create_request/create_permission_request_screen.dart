// File: lib/view/create_request/create_permit_request_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import '../../../services/theme_service.dart';

import '../request_controller.dart';

class CreatePermissionRequestScreen extends StatelessWidget {
  const CreatePermissionRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();
    final themeService = ThemeService.instance;
    final formKey = GlobalKey<FormState>();

    final purposeController = TextEditingController();
    final fromTimeController = TextEditingController();
    final toTimeController = TextEditingController();

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
          tr('create_permission_request'),
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
                  color: themeService.getActionColor('profile').withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeService.getActionColor('profile'),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.badge_outlined, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('permission_request'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: themeService.getActionColor('profile'),
                            ),
                          ),
                          Text(
                            tr('permission_request_description'),
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

              // Purpose Field
              _buildTextAreaField(
                label: tr('purpose'),
                controller: purposeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('please_provide_purpose');
                  }
                  if (value.length < 10) {
                    return tr('purpose_minimum_characters');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // From Time Field
              _buildTimeField(
                label: tr('from_time'),
                controller: fromTimeController,
                context: context,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('please_select_from_time');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // To Time Field
              _buildTimeField(
                label: tr('to_time'),
                controller: toTimeController,
                context: context,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('please_select_to_time');
                  }
                  if (fromTimeController.text.isNotEmpty && value.isNotEmpty) {
                    try {
                      final fromTime = _parseTime(fromTimeController.text);
                      final toTime = _parseTime(value);
                      if (fromTime != null && toTime != null) {
                        // Convert times to minutes for comparison
                        final fromMinutes = fromTime.hour * 60 + fromTime.minute;
                        final toMinutes = toTime.hour * 60 + toTime.minute;
                        if (toMinutes <= fromMinutes) {
                          return tr('to_time_after_from_time');
                        }
                      }
                    } catch (e) {
                      return tr('invalid_time_format');
                    }
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
                    if (formKey.currentState!.validate()) {
                      final success = await controller.createPermissionRequestWithData(
                        purpose: purposeController.text,
                        fromTime: fromTimeController.text,
                        toTime: toTimeController.text,
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
                    backgroundColor: themeService.getActionColor('profile'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    tr('submit_permission_request'),
                    style: TextStyle(
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

  Widget _buildTextField({
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
              borderSide: BorderSide(color: themeService.getActionColor('profile')),
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
              borderSide: BorderSide(color: themeService.getActionColor('profile')),
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


  Widget _buildTimeField({
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
              borderSide: BorderSide(color: themeService.getActionColor('profile')),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: themeService.getErrorColor()),
            ),
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: Icon(
              Icons.access_time,
              color: themeService.getTextSecondaryColor(),
            ),
            hintText: trParams('select_field', {'field': label}),
            hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
          ),
          onTap: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: themeService.isDarkMode 
                      ? ColorScheme.dark(
                          primary: themeService.getActionColor('profile'),
                          onPrimary: Colors.white,
                          surface: themeService.getCardColor(),
                          onSurface: themeService.getTextPrimaryColor(),
                        )
                      : ColorScheme.light(
                          primary: themeService.getActionColor('profile'),
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
              controller.text = picked.format(context);
            }
          },
        ),
      ],
    );
  }

  TimeOfDay? _parseTime(String timeString) {
    try {
      // Handle different time formats: "2:30 PM", "14:30", etc.
      timeString = timeString.trim();
      
      // Check if it's 12-hour format with AM/PM
      if (timeString.contains('AM') || timeString.contains('PM')) {
        final isAM = timeString.contains('AM');
        final timePart = timeString.replaceAll(RegExp(r'\s*(AM|PM)'), '');
        final parts = timePart.split(':');
        
        if (parts.length == 2) {
          int hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          
          // Convert to 24-hour format
          if (!isAM && hour != 12) hour += 12;
          if (isAM && hour == 12) hour = 0;
          
          return TimeOfDay(hour: hour, minute: minute);
        }
      } else {
        // 24-hour format
        final parts = timeString.split(':');
        if (parts.length == 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
}