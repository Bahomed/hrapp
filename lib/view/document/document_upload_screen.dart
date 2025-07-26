import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/input_widgets.dart';
import 'package:injazat_hr_app/utils/responsive_utils.dart';
import '../../services/theme_service.dart';
import 'document_upload_controller.dart';

class DocumentUploadScreen extends StatelessWidget {
  const DocumentUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DocumentUploadController());
    final themeService = ThemeService.instance;

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
          tr('upload_document'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: ResponsiveUtils.responsivePadding(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(context, themeService),

                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 3)),

                // Form Fields Container
                _buildFormContainer(context, controller, themeService),

                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 3)),

                // Upload Progress (if uploading)
                Obx(() => controller.isUploading.value
                    ? _buildUploadProgress(context, controller, themeService)
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ThemeService themeService) {
    return Container(
      padding: ResponsiveUtils.responsivePadding(
          context,
          mobile: 20,
          tablet: 24,
          desktop: 28
      ),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeService.isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: themeService.isDarkMode
              ? themeService.getDividerColor().withValues(alpha: 0.2)
              : themeService.getDividerColor().withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeService.getPrimaryColor().withValues(alpha: 0.15),
                  themeService.getPrimaryColor().withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeService.getPrimaryColor().withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              color: themeService.getPrimaryColor(),
              size: ResponsiveUtils.responsiveIconSize(
                  context,
                  mobile: 28,
                  tablet: 32,
                  desktop: 36
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.responsiveWidth(context, 4)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('upload_new_document'),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        mobile: 18,
                        tablet: 20,
                        desktop: 22
                    ),
                    fontWeight: FontWeight.w700,
                    color: themeService.getTextPrimaryColor(),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 0.5)),
                Text(
                  tr('fill_form_upload_document'),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16
                    ),
                    color: themeService.getTextSecondaryColor(),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContainer(BuildContext context, DocumentUploadController controller, ThemeService themeService) {
    return Container(
      padding: ResponsiveUtils.responsivePadding(
          context,
          mobile: 20,
          tablet: 24,
          desktop: 28
      ),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeService.isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: themeService.isDarkMode
              ? themeService.getDividerColor().withValues(alpha: 0.2)
              : themeService.getDividerColor().withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Title
          Text(
            tr('document_details'),
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20
              ),
              fontWeight: FontWeight.w700,
              color: themeService.getTextPrimaryColor(),
              letterSpacing: -0.2,
            ),
          ),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Document Name
          _buildThemedInputField(
            context,
            controller: controller.documentNoController,
            label: tr('document_no'),
            hint: tr('enter_document_no'),
            icon: Icons.description_outlined,
            isRequired: true,
            themeService: themeService,
          ),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Category Dropdown
          Obx(() => _buildThemedDropdownField(
            context,
            label: tr('document_type'),
            value: controller.selectedCategory.value.isEmpty
                ? null
                : controller.selectedCategory.value,
            items: controller.availableCategories,
            onChanged: (value) => controller.selectedCategory.value = value ?? '',
            icon: Icons.category_outlined,
            hint: tr('select_document_type'),
            isRequired: true,
            themeService: themeService,
          )),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Date Issued
          Obx(() => _buildThemedDateField(
            context,
            label: tr('date_issued'),
            selectedDate: controller.dateIssued.value,
            onDateSelected: (date) => controller.dateIssued.value = date,
            icon: Icons.calendar_today_outlined,
            hint: tr('select_issue_date'),
            isRequired: false,
            lastDate: DateTime.now(),
            themeService: themeService,
          )),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Date Expire
          Obx(() => _buildThemedDateField(
            context,
            label: tr('date_expire'),
            selectedDate: controller.dateExpire.value,
            onDateSelected: (date) => controller.dateExpire.value = date,
            icon: Icons.event_outlined,
            hint: tr('select_expiry_date'),
            isRequired: false,
            firstDate: DateTime.now(),
            themeService: themeService,
          )),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Remarks
          _buildThemedInputField(
            context,
            controller: controller.remarksController,
            label: tr('remarks'),
            hint: tr('enter_remarks'),
            icon: Icons.note_outlined,
            isRequired: false,
            maxLines: 3,
            themeService: themeService,
          ),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // File Upload
          Obx(() => _buildThemedFileUploadField(
            context,
            label: tr('select_document_file'),
            fileName: controller.selectedFileName.value,
            onTap: controller.pickFile,
            icon: Icons.attach_file_outlined,
            isRequired: true,
            themeService: themeService,
          )),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 4)),

          // Upload Button
          Obx(() => _buildThemedUploadButton(
              context,
              controller,
              themeService
          )),
        ],
      ),
    );
  }

  Widget _buildThemedInputField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required String hint,
        required IconData icon,
        required bool isRequired,
        required ThemeService themeService,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: themeService.getPrimaryColor(),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: themeService.getErrorColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeService.getTextSecondaryColor(),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: themeService.isDarkMode
                ? themeService.getBackgroundColor()
                : themeService.getBackgroundColor().withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeService.getDividerColor(),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeService.getDividerColor(),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeService.getPrimaryColor(),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeService.getErrorColor(),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontWeight: FontWeight.w500,
          ),
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildThemedDropdownField(
      BuildContext context, {
        required String label,
        required String? value,
        required List<String> items,
        required ValueChanged<String?> onChanged,
        required IconData icon,
        required String hint,
        required bool isRequired,
        required ThemeService themeService,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: themeService.getPrimaryColor(),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: themeService.getErrorColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeService.getTextSecondaryColor(),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: themeService.isDarkMode
                ? themeService.getBackgroundColor()
                : themeService.getBackgroundColor().withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeService.getDividerColor(),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeService.getDividerColor(),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: themeService.getPrimaryColor(),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: themeService.getCardColor(),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: themeService.getTextPrimaryColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          validator: isRequired ? (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          } : null,
        ),
      ],
    );
  }

  Widget _buildThemedDateField(
      BuildContext context, {
        required String label,
        required DateTime? selectedDate,
        required ValueChanged<DateTime?> onDateSelected,
        required IconData icon,
        required String hint,
        required bool isRequired,
        required ThemeService themeService,
        DateTime? firstDate,
        DateTime? lastDate,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: themeService.getPrimaryColor(),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: themeService.getErrorColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(1900),
              lastDate: lastDate ?? DateTime(2100),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
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
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: themeService.isDarkMode
                  ? themeService.getBackgroundColor()
                  : themeService.getBackgroundColor().withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeService.getDividerColor(),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : hint,
                    style: TextStyle(
                      color: selectedDate != null
                          ? themeService.getTextPrimaryColor()
                          : themeService.getTextSecondaryColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: themeService.getPrimaryColor(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemedFileUploadField(
      BuildContext context, {
        required String label,
        required String fileName,
        required VoidCallback onTap,
        required IconData icon,
        required bool isRequired,
        required ThemeService themeService,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: themeService.getPrimaryColor(),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: themeService.getErrorColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fileName.isNotEmpty
                  ? themeService.getSuccessColor().withValues(alpha: 0.1)
                  : themeService.isDarkMode
                  ? themeService.getBackgroundColor()
                  : themeService.getBackgroundColor().withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: fileName.isNotEmpty
                    ? themeService.getSuccessColor()
                    : themeService.getDividerColor(),
                width: fileName.isNotEmpty ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: fileName.isNotEmpty
                        ? themeService.getSuccessColor().withValues(alpha: 0.2)
                        : themeService.getPrimaryColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    fileName.isNotEmpty ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                    color: fileName.isNotEmpty
                        ? themeService.getSuccessColor()
                        : themeService.getPrimaryColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  fileName.isNotEmpty ? fileName : tr('tap_to_select_file'),
                  style: TextStyle(
                    color: fileName.isNotEmpty
                        ? themeService.getSuccessColor()
                        : themeService.getTextSecondaryColor(),
                    fontWeight: fileName.isNotEmpty ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (fileName.isEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    tr('pdf_doc_supported_formats'),
                    style: TextStyle(
                      color: themeService.getTextSecondaryColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemedUploadButton(
      BuildContext context,
      DocumentUploadController controller,
      ThemeService themeService
      ) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.responsiveHeight(context, 7),
      child: ElevatedButton(
        onPressed: controller.isUploading.value
            ? null
            : controller.uploadDocument,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeService.getPrimaryColor(),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: themeService.getPrimaryColor().withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: themeService.getTextSecondaryColor(),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: controller.isUploading.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              tr('uploading'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              tr('upload_document'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress(
      BuildContext context,
      DocumentUploadController controller,
      ThemeService themeService
      ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeService.getPrimaryColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeService.getPrimaryColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.cloud_upload,
                  color: themeService.getPrimaryColor(),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                tr('uploading_document'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            backgroundColor: themeService.getDividerColor(),
            valueColor: AlwaysStoppedAnimation<Color>(
              themeService.getPrimaryColor(),
            ),
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          Text(
            tr('please_wait_upload'),
            style: TextStyle(
              fontSize: 13,
              color: themeService.getTextSecondaryColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}