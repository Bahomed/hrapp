import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import '../../data/remote/response/document_response.dart';
import '../../services/theme_service.dart';
import 'document_upload_controller.dart';

class DocumentUploadScreen extends StatelessWidget {
  /// Pass an existing document to open the screen in renew mode
  final DocumentResponseData? renewDocument;

  const DocumentUploadScreen({super.key, this.renewDocument});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DocumentUploadController(renewDocument: renewDocument));
    final themeService = ThemeService.instance;

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
          renewDocument != null ? tr('renew_document') : tr('upload_document'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: ResponsiveUtils.responsivePadding(
            context,
            mobile: 16,
            tablet: 20,
            desktop: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context, themeService),
              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 3)),
              _buildFormContainer(context, controller, themeService),
              SizedBox(height: ResponsiveUtils.responsiveHeight(context, 3)),
              Obx(() => controller.isUploading.value
                  ? _buildUploadProgress(context, themeService)
                  : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeaderCard(BuildContext context, ThemeService themeService) {
    return Container(
      padding: ResponsiveUtils.responsivePadding(context, mobile: 20, tablet: 24, desktop: 28),
      decoration: _cardDecoration(themeService),
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
              border: Border.all(color: themeService.getPrimaryColor().withValues(alpha: 0.2)),
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              color: themeService.getPrimaryColor(),
              size: ResponsiveUtils.responsiveIconSize(context, mobile: 28, tablet: 32, desktop: 36),
            ),
          ),
          SizedBox(width: ResponsiveUtils.responsiveWidth(context, 4)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  renewDocument != null ? tr('renew_document') : tr('upload_new_document'),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 18, tablet: 20, desktop: 22),
                    fontWeight: FontWeight.w700,
                    color: themeService.getTextPrimaryColor(),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.responsiveHeight(context, 0.5)),
                Text(
                  renewDocument != null
                      ? '${renewDocument!.name} — ${tr('upload_new_version')}'
                      : tr('fill_form_upload_document'),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
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

  // ─── Form container ─────────────────────────────────────────────────────────

  Widget _buildFormContainer(
    BuildContext context,
    DocumentUploadController controller,
    ThemeService themeService,
  ) {
    return Container(
      padding: ResponsiveUtils.responsivePadding(context, mobile: 20, tablet: 24, desktop: 28),
      decoration: _cardDecoration(themeService),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('document_details'),
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
              fontWeight: FontWeight.w700,
              color: themeService.getTextPrimaryColor(),
              letterSpacing: -0.2,
            ),
          ),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Document Type — searchable
          Obx(() {
            final _ = controller.documentTypes.length;
            final selectedType = controller.selectedDocumentType.value;
            final error = controller.documentTypeError.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchablePickerField(
                  context,
                  label: tr('document_type'),
                  selectedText: selectedType?.text,
                  isLoading: controller.isDocumentTypesLoading.value,
                  isRequired: true,
                  icon: Icons.category_outlined,
                  hint: tr('select_document_type'),
                  enabled: true,
                  hasError: error.isNotEmpty,
                  themeService: themeService,
                  onTap: () => _openSearchPicker(
                    context,
                    title: tr('document_type'),
                    items: controller.documentTypes.toList(),
                    itemText: (item) => item.text,
                    selectedItem: controller.selectedDocumentType.value,
                    onSelected: (item) {
                      controller.selectedDocumentType.value = item;
                      controller.documentTypeError.value = '';
                    },
                    themeService: themeService,
                  ),
                  onClear: () => controller.selectedDocumentType.value = null,
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
                    child: Text(
                      error,
                      style: TextStyle(color: themeService.getErrorColor(), fontSize: 12),
                    ),
                  ),
              ],
            );
          }),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Document No
          _buildInputField(
            context,
            controller: controller.documentNoController,
            label: tr('document_no'),
            hint: tr('enter_document_no'),
            icon: Icons.numbers_outlined,
            isRequired: false,
            themeService: themeService,
          ),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Date Issued
          Obx(() => _buildDateField(
            context,
            label: tr('date_issued'),
            selectedDate: controller.dateIssued.value,
            onDateSelected: (d) => controller.dateIssued.value = d,
            icon: Icons.calendar_today_outlined,
            hint: tr('select_issue_date'),
            lastDate: DateTime.now(),
            themeService: themeService,
          )),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Date Expire
          Obx(() => _buildDateField(
            context,
            label: tr('date_expire'),
            selectedDate: controller.dateExpire.value,
            onDateSelected: (d) => controller.dateExpire.value = d,
            icon: Icons.event_outlined,
            hint: tr('select_expiry_date'),
            firstDate: DateTime.now(),
            themeService: themeService,
          )),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Country — searchable
          Obx(() {
            final _ = controller.countries.length;
            final selectedCountry = controller.selectedCountry.value;
            return _buildSearchablePickerField(
              context,
              label: tr('country'),
              selectedText: selectedCountry?.text,
              isLoading: controller.isCountriesLoading.value,
              isRequired: false,
              icon: Icons.flag_outlined,
              hint: tr('select_country'),
              enabled: true,
              themeService: themeService,
              onTap: () => _openSearchPicker(
                context,
                title: tr('country'),
                items: controller.countries.toList(), // fresh at tap time
                itemText: (item) => item.text,
                selectedItem: controller.selectedCountry.value,
                onSelected: (item) => controller.onCountryChanged(item),
                themeService: themeService,
              ),
              onClear: () => controller.onCountryChanged(null),
            );
          }),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // City — searchable (disabled until country chosen)
          Obx(() {
            final _ = controller.cities.length; // track so Obx rebuilds when cities load
            final selectedCountry = controller.selectedCountry.value;
            final selectedCity = controller.selectedCity.value;
            final isLoading = controller.isCitiesLoading.value;
            return _buildSearchablePickerField(
              context,
              label: tr('city'),
              selectedText: selectedCity?.text,
              isLoading: isLoading,
              isRequired: false,
              icon: Icons.location_city_outlined,
              hint: selectedCountry == null
                  ? tr('select_country_first')
                  : tr('select_city'),
              enabled: selectedCountry != null && !isLoading,
              themeService: themeService,
              onTap: () => _openSearchPicker(
                context,
                title: tr('city'),
                items: controller.cities.toList(), // fresh at tap time
                itemText: (item) => item.text,
                selectedItem: controller.selectedCity.value,
                onSelected: (item) => controller.selectedCity.value = item,
                themeService: themeService,
              ),
              onClear: () => controller.selectedCity.value = null,
            );
          }),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Remarks
          _buildInputField(
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
          Obx(() {
            final fileError = controller.fileError.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFileUploadField(
                  context,
                  fileName: controller.selectedFileName.value,
                  hasError: fileError.isNotEmpty,
                  onTap: controller.pickFile,
                  themeService: themeService,
                ),
                if (fileError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
                    child: Text(
                      fileError,
                      style: TextStyle(color: themeService.getErrorColor(), fontSize: 12),
                    ),
                  ),
              ],
            );
          }),

          SizedBox(height: ResponsiveUtils.responsiveHeight(context, 2.5)),

          // Upload Button
          Obx(() => _buildUploadButton(context, controller, themeService)),
        ],
      ),
    );
  }

  // ─── Searchable picker field (display) ──────────────────────────────────────

  Widget _buildSearchablePickerField(
    BuildContext context, {
    required String label,
    required String? selectedText,
    required bool isLoading,
    required bool isRequired,
    required IconData icon,
    required String hint,
    required bool enabled,
    required ThemeService themeService,
    required VoidCallback onTap,
    required VoidCallback onClear,
    bool hasError = false,
  }) {
    final hasValue = selectedText != null && selectedText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: themeService.getPrimaryColor()),
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
              Text('*', style: TextStyle(color: themeService.getErrorColor(), fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: (enabled && !isLoading) ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: !enabled
                  ? themeService.getDividerColor().withValues(alpha: 0.2)
                  : themeService.isDarkMode
                      ? themeService.getBackgroundColor()
                      : themeService.getBackgroundColor().withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? themeService.getErrorColor()
                    : hasValue
                        ? themeService.getPrimaryColor().withValues(alpha: 0.6)
                        : themeService.getDividerColor(),
                width: hasError || hasValue ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: themeService.getPrimaryColor()),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    hint,
                    style: TextStyle(color: themeService.getTextSecondaryColor(), fontSize: 14),
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      hasValue ? selectedText! : hint,
                      style: TextStyle(
                        color: hasValue
                            ? themeService.getTextPrimaryColor()
                            : themeService.getTextSecondaryColor(),
                        fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (hasValue)
                    GestureDetector(
                      onTap: onClear,
                      child: Icon(Icons.close, size: 18, color: themeService.getTextSecondaryColor()),
                    )
                  else
                    Icon(
                      Icons.search,
                      size: 18,
                      color: enabled ? themeService.getPrimaryColor() : themeService.getDividerColor(),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Searchable bottom sheet ─────────────────────────────────────────────────

  void _openSearchPicker<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required String Function(T) itemText,
    required T? selectedItem,
    required ValueChanged<T?> onSelected,
    required ThemeService themeService,
  }) {
    Get.bottomSheet(
      _SearchPickerSheet<T>(
        title: title,
        items: items,
        itemText: itemText,
        selectedItem: selectedItem,
        onSelected: onSelected,
        themeService: themeService,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─── Input field ─────────────────────────────────────────────────────────────

  Widget _buildInputField(
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
            Icon(icon, size: 16, color: themeService.getPrimaryColor()),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextPrimaryColor())),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text('*', style: TextStyle(color: themeService.getErrorColor(), fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: themeService.getTextSecondaryColor(), fontWeight: FontWeight.w400),
            filled: true,
            fillColor: themeService.isDarkMode
                ? themeService.getBackgroundColor()
                : themeService.getBackgroundColor().withValues(alpha: 0.5),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeService.getDividerColor())),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeService.getDividerColor())),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeService.getPrimaryColor(), width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeService.getErrorColor())),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(color: themeService.getTextPrimaryColor(), fontWeight: FontWeight.w500),
          validator: isRequired
              ? (v) => (v == null || v.isEmpty) ? '$label is required' : null
              : null,
        ),
      ],
    );
  }

  // ─── Date field ──────────────────────────────────────────────────────────────

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
    required IconData icon,
    required String hint,
    required ThemeService themeService,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: themeService.getPrimaryColor()),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextPrimaryColor())),
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
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: themeService.getPrimaryColor(),
                    onPrimary: Colors.white,
                    surface: themeService.getCardColor(),
                    onSurface: themeService.getTextPrimaryColor(),
                  ),
                ),
                child: child!,
              ),
            );
            if (date != null) onDateSelected(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: themeService.isDarkMode
                  ? themeService.getBackgroundColor()
                  : themeService.getBackgroundColor().withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeService.getDividerColor()),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : hint,
                    style: TextStyle(
                      color: selectedDate != null
                          ? themeService.getTextPrimaryColor()
                          : themeService.getTextSecondaryColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today, size: 18, color: themeService.getPrimaryColor()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── File upload field ───────────────────────────────────────────────────────

  Widget _buildFileUploadField(
    BuildContext context, {
    required String fileName,
    required VoidCallback onTap,
    required ThemeService themeService,
    bool hasError = false,
  }) {
    final hasFile = fileName.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file_outlined, size: 16, color: themeService.getPrimaryColor()),
            const SizedBox(width: 8),
            Text(tr('select_document_file'),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: themeService.getTextPrimaryColor())),
            const SizedBox(width: 4),
            Text('*', style: TextStyle(color: themeService.getErrorColor(), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasFile
                  ? themeService.getSuccessColor().withValues(alpha: 0.1)
                  : themeService.isDarkMode
                      ? themeService.getBackgroundColor()
                      : themeService.getBackgroundColor().withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? themeService.getErrorColor()
                    : hasFile
                        ? themeService.getSuccessColor()
                        : themeService.getDividerColor(),
                width: hasFile || hasError ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasFile
                        ? themeService.getSuccessColor().withValues(alpha: 0.2)
                        : themeService.getPrimaryColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasFile ? Icons.check_circle_outline : Icons.cloud_upload_outlined,
                    color: hasFile ? themeService.getSuccessColor() : themeService.getPrimaryColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hasFile ? fileName : tr('tap_to_select_file'),
                  style: TextStyle(
                    color: hasFile ? themeService.getSuccessColor() : themeService.getTextSecondaryColor(),
                    fontWeight: hasFile ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!hasFile) ...[
                  const SizedBox(height: 4),
                  Text(
                    tr('pdf_doc_supported_formats'),
                    style: TextStyle(
                        color: themeService.getTextSecondaryColor(), fontSize: 12, fontWeight: FontWeight.w400),
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

  // ─── Upload button ───────────────────────────────────────────────────────────

  Widget _buildUploadButton(
    BuildContext context,
    DocumentUploadController controller,
    ThemeService themeService,
  ) {
    return SizedBox(
      width: double.infinity,
      height: ResponsiveUtils.responsiveHeight(context, 7),
      child: ElevatedButton(
        onPressed: controller.isUploading.value ? null : controller.uploadDocument,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeService.getPrimaryColor(),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          disabledBackgroundColor: themeService.getTextSecondaryColor(),
        ),
        child: controller.isUploading.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Text(tr('uploading'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(tr('upload_document'),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
      ),
    );
  }

  // ─── Upload progress ─────────────────────────────────────────────────────────

  Widget _buildUploadProgress(BuildContext context, ThemeService themeService) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeService.getPrimaryColor().withValues(alpha: 0.3)),
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
                child: Icon(Icons.cloud_upload, color: themeService.getPrimaryColor(), size: 16),
              ),
              const SizedBox(width: 12),
              Text(tr('uploading_document'),
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: themeService.getTextPrimaryColor())),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            backgroundColor: themeService.getDividerColor(),
            valueColor: AlwaysStoppedAnimation(themeService.getPrimaryColor()),
            minHeight: 4,
          ),
          const SizedBox(height: 8),
          Text(tr('please_wait_upload'),
              style: TextStyle(
                  fontSize: 13, color: themeService.getTextSecondaryColor(), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration(ThemeService themeService) {
    return BoxDecoration(
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
      ),
    );
  }
}

// ─── Searchable picker bottom sheet ──────────────────────────────────────────

class _SearchPickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemText;
  final T? selectedItem;
  final ValueChanged<T?> onSelected;
  final ThemeService themeService;

  const _SearchPickerSheet({
    required this.title,
    required this.items,
    required this.itemText,
    required this.selectedItem,
    required this.onSelected,
    required this.themeService,
  });

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  late List<T> _filtered;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.items);
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? List.from(widget.items)
          : widget.items
              .where((item) => widget.itemText(item).toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ts = widget.themeService;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: ts.getSurfaceColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ts.getDividerColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ts.getTextPrimaryColor(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: tr('search'),
                hintStyle: TextStyle(color: ts.getTextSecondaryColor()),
                prefixIcon: Icon(Icons.search, color: ts.getPrimaryColor()),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: ts.getTextSecondaryColor()),
                        onPressed: () {
                          _searchCtrl.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: ts.isDarkMode
                    ? ts.getBackgroundColor()
                    : ts.getBackgroundColor().withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ts.getDividerColor()),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ts.getDividerColor()),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ts.getPrimaryColor(), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: ts.getTextPrimaryColor()),
            ),
          ),
          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filtered.length} ${tr('results')}',
                style: TextStyle(fontSize: 12, color: ts.getTextSecondaryColor()),
              ),
            ),
          ),

          const Divider(height: 1),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: ts.getDividerColor()),
                        const SizedBox(height: 12),
                        Text(
                          tr('no_results_found'),
                          style: TextStyle(color: ts.getTextSecondaryColor(), fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      final label = widget.itemText(item);
                      final isSelected = widget.selectedItem != null &&
                          widget.itemText(widget.selectedItem!) == label;

                      return InkWell(
                        onTap: () {
                          widget.onSelected(item);
                          Get.back();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? ts.getPrimaryColor().withValues(alpha: 0.08)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isSelected
                                        ? ts.getPrimaryColor()
                                        : ts.getTextPrimaryColor(),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle, size: 20, color: ts.getPrimaryColor()),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
