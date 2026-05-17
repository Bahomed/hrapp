import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/data/remote/response/permission_request_response.dart';
import '../../../services/theme_service.dart';

import '../request_controller.dart';

class EditPermissionRequestScreen extends StatelessWidget {
  final PermissionRequest request;

  const EditPermissionRequestScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();
    final themeService = ThemeService.instance;
    final formKey = GlobalKey<FormState>();

    final purposeController = TextEditingController(text: request.purpose);
    final dateController = TextEditingController(text: request.date);
    final fromTimeController = TextEditingController(text: request.fromTime);
    final toTimeController = TextEditingController(text: request.toTime);
    final selectedFiles = <File>[].obs;

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
          tr('edit_permission_request'),
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
                      child: Icon(Icons.edit, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('edit_permission_request'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: themeService.getActionColor('profile'),
                            ),
                          ),
                          Text(
                            tr('edit_permission_request_description'),
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

              // Request ID Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeService.getCardColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: themeService.getTextSecondaryColor(), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${tr('request_id')}: #${request.requestNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status, themeService),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        switch (request.status.toLowerCase()) {
                          'approved' => tr(request.status),
                          'rejected' => tr(request.status),
                          'pending' || 'for-approval' => tr('for_approval'),
                          _ => tr(request.status),
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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
              ),

              const SizedBox(height: 20),

              // Date Field
              _buildDateField(
                label: tr('permit_date'),
                controller: dateController,
                context: context,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('please_select_date');
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

              const SizedBox(height: 20),

              // Attachments
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('attachments'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeService.getTextPrimaryColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (selectedFiles.isNotEmpty) ...[
                    ...selectedFiles.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: themeService.getCardColor(),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: themeService.getActionColor('profile').withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, size: 18, color: themeService.getActionColor('profile')),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                file.path.split('/').last,
                                style: TextStyle(fontSize: 13, color: themeService.getTextPrimaryColor()),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 18, color: themeService.getErrorColor()),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => selectedFiles.removeAt(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                  if (selectedFiles.length < 3)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final remaining = 3 - selectedFiles.length;
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                        allowMultiple: remaining > 1,
                      );
                      if (result != null) {
                        final files = result.files
                            .where((f) => f.path != null && (f.size ?? 0) <= 5 * 1024 * 1024)
                            .map((f) => File(f.path!))
                            .take(remaining)
                            .toList();
                        final rejected = result.files.where((f) => f.path != null && (f.size ?? 0) > 5 * 1024 * 1024).length;
                        if (rejected > 0) {
                          Get.snackbar(
                            tr('error'),
                            '$rejected ${tr('file_size_exceeded')}',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: ThemeService.instance.getErrorColor(),
                            colorText: Colors.white,
                          );
                        }
                        selectedFiles.addAll(files);
                      }
                    },
                    icon: Icon(Icons.upload_file, color: themeService.getActionColor('profile')),
                    label: Text(
                      tr('upload_attachment'),
                      style: TextStyle(color: themeService.getActionColor('profile')),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: themeService.getActionColor('profile')),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              )),

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
                      // Normalize DD-MM-YYYY to YYYY-MM-DD if needed
                      String dateValue = dateController.text;
                      if (dateValue.contains('-')) {
                        final parts = dateValue.split('-');
                        if (parts.length == 3 && parts[0].length == 2) {
                          dateValue = '${parts[2]}-${parts[1]}-${parts[0]}';
                        }
                      }
                      final success = await controller.updatePermissionRequestWithData(
                        id: request.id,
                        purpose: purposeController.text,
                        date: dateValue,
                        fromTime: fromTimeController.text,
                        toTime: toTimeController.text,
                        attachments: selectedFiles.isEmpty ? null : selectedFiles.toList(),
                      );
                      
                      if (success) {
                        await Future.delayed(const Duration(milliseconds: 1500));
                        
                        if (context.mounted) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
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
                    tr('update_permission_request'),
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

  Color _getStatusColor(String status, ThemeService themeService) {
    switch (status.toLowerCase()) {
      case 'approved':
        return themeService.getSuccessColor();
      case 'rejected':
        return themeService.getErrorColor();
      case 'pending':
      case 'for-approval':
        return themeService.getWarningColor();
      default:
        return themeService.getTextSecondaryColor();
    }
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
              borderSide: BorderSide(color: themeService.getActionColor('profile')),
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
            hintText: trParams('select_field', {'field': label}),
            hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
          ),
          onTap: () async {
            final today = DateTime.now();
            DateTime initialDate = today;
            if (controller.text.isNotEmpty) {
              try {
                // Try ISO format YYYY-MM-DD
                initialDate = DateTime.parse(controller.text);
              } catch (_) {
                try {
                  // Try DD-MM-YYYY format from API
                  final parts = controller.text.split('-');
                  if (parts.length == 3) {
                    initialDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                  }
                } catch (_) {}
              }
            }
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
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
              controller.text =
                  '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
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
        // 24-hour format (HH:mm or HH:mm:ss)
        final parts = timeString.split(':');
        if (parts.length >= 2) {
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