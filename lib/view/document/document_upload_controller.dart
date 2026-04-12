import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/remote/response/document_response.dart';
import '../../repository/documentrepository.dart';
import '../../utils/translation_helper.dart';

void _showSnackbar(String message, {bool isError = true}) {
  final context = Get.context;
  if (context == null) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

class DocumentUploadController extends GetxController {
  final DocumentRepository _documentRepository = DocumentRepository();

  /// Pass an existing document to pre-fill the form (renew flow)
  final DocumentResponseData? renewDocument;

  DocumentUploadController({this.renewDocument});

  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController documentNoController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  // Document types
  final RxList<DocumentTypeItem> documentTypes = <DocumentTypeItem>[].obs;
  final Rxn<DocumentTypeItem> selectedDocumentType = Rxn<DocumentTypeItem>();
  final RxBool isDocumentTypesLoading = false.obs;

  // Countries
  final RxList<DropdownItem> countries = <DropdownItem>[].obs;
  final Rxn<DropdownItem> selectedCountry = Rxn<DropdownItem>();
  final RxBool isCountriesLoading = false.obs;

  // Cities
  final RxList<DropdownItem> cities = <DropdownItem>[].obs;
  final Rxn<DropdownItem> selectedCity = Rxn<DropdownItem>();
  final RxBool isCitiesLoading = false.obs;

  // Dates
  final Rx<DateTime?> dateIssued = Rx<DateTime?>(null);
  final Rx<DateTime?> dateExpire = Rx<DateTime?>(null);

  // File handling
  final RxString selectedFileName = ''.obs;
  final RxBool isUploading = false.obs;
  final RxBool isPickingFile = false.obs;

  // Inline field validation errors
  final RxString documentTypeError = ''.obs;
  final RxString fileError = ''.obs;

  File? selectedFile;
  PlatformFile? platformFile;

  /// True when opened in renew mode
  bool get isRenewMode => renewDocument != null;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  @override
  void onClose() {
    documentNoController.dispose();
    remarksController.dispose();
    super.onClose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([loadDocumentTypes(), loadCountries()]);
    if (isRenewMode) _preFillFromDocument(renewDocument!);
  }

  /// Pre-fill form fields from an existing document (renew flow)
  Future<void> _preFillFromDocument(DocumentResponseData doc) async {
    // Doc number
    if (doc.docNo != null && doc.docNo!.isNotEmpty) {
      documentNoController.text = doc.docNo!;
    }

    // Match document type by category name (case-insensitive)
    final matchedType = documentTypes.firstWhereOrNull(
      (t) => t.text.toLowerCase() == doc.category.toLowerCase(),
    );
    if (matchedType != null) selectedDocumentType.value = matchedType;

    // Match country by name
    if (doc.country != null && doc.country!.isNotEmpty) {
      final matchedCountry = countries.firstWhereOrNull(
        (c) => c.text.toLowerCase() == doc.country!.toLowerCase(),
      );
      if (matchedCountry != null) {
        // This also loads cities for the country
        await onCountryChanged(matchedCountry);
      }
    }
  }

  /// Load document types from API
  Future<void> loadDocumentTypes() async {
    try {
      isDocumentTypesLoading.value = true;
      final response = await _documentRepository.getDocumentTypes();
      if (response.success) {
        documentTypes.assignAll(response.data);
      } else {
        _showSnackbar(tr('failed_to_load_document_types'));
      }
    } catch (e) {
      _showSnackbar(tr('error_loading_document_types'));
    } finally {
      isDocumentTypesLoading.value = false;
    }
  }

  /// Load countries from API
  Future<void> loadCountries() async {
    try {
      isCountriesLoading.value = true;
      final response = await _documentRepository.getCountries();
      if (response.success) {
        countries.assignAll(response.data);
      }
    } catch (e) {
      // silently fail — country is optional
    } finally {
      isCountriesLoading.value = false;
    }
  }

  /// Called when user picks a country — loads cities for that country
  Future<void> onCountryChanged(DropdownItem? country) async {
    selectedCountry.value = country;
    selectedCity.value = null;
    cities.clear();

    if (country == null) return;

    try {
      isCitiesLoading.value = true;
      final response = await _documentRepository.getCities(countryId: country.value);
      if (response.success) {
        cities.assignAll(response.data);
      }
    } catch (e) {
      // silently fail
    } finally {
      isCitiesLoading.value = false;
    }
  }

  /// Pick file for upload
  Future<void> pickFile() async {
    try {
      isPickingFile.value = true;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        platformFile = result.files.first;
        selectedFile = File(platformFile!.path!);
        selectedFileName.value = platformFile!.name;

        if (selectedFile!.lengthSync() > 10 * 1024 * 1024) {
          _showSnackbar(tr('file_too_large'));
          _clearSelectedFile();
          return;
        }

        fileError.value = '';
      }
    } catch (e) {
      _showSnackbar(tr('error_selecting_file'));
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isPickingFile.value = false;
      });
    }
  }

  void _clearSelectedFile() {
    selectedFile = null;
    platformFile = null;
    selectedFileName.value = '';
  }

  bool _validateForm() {
    bool valid = true;

    if (!formKey.currentState!.validate()) valid = false;

    if (selectedDocumentType.value == null) {
      documentTypeError.value = tr('please_select_document_type');
      valid = false;
    } else {
      documentTypeError.value = '';
    }

    if (selectedFile == null) {
      fileError.value = tr('please_select_file');
      valid = false;
    } else {
      fileError.value = '';
    }

    return valid;
  }

  /// Upload document
  Future<void> uploadDocument() async {
    if (!_validateForm()) return;

    try {
      isUploading.value = true;

      final uploadRequest = DocumentUploadRequest(
        docId: selectedDocumentType.value!.value,
        name: documentNoController.text.trim(),
        notes: remarksController.text.trim().isNotEmpty ? remarksController.text.trim() : null,
        dateIssuedG: dateIssued.value != null ? _formatDate(dateIssued.value!) : null,
        dateExpireG: dateExpire.value != null ? _formatDate(dateExpire.value!) : null,
        docNo: documentNoController.text.trim().isNotEmpty ? documentNoController.text.trim() : null,
        category: selectedDocumentType.value!.text,
        type: selectedDocumentType.value!.text,
        remarks: remarksController.text.trim().isNotEmpty ? remarksController.text.trim() : null,
        countryId: selectedCountry.value?.value,
        cityId: selectedCity.value?.value,
      );

      final response = await _documentRepository.uploadDocument(uploadRequest, selectedFile!);

      if (response.success) {
        _showSnackbar(tr('document_uploaded_successfully'), isError: false);
        _resetForm();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: true);
      } else {
        _showSnackbar(response.message);
      }
    } catch (e) {
      _showSnackbar(tr('error_uploading_document'));
    } finally {
      isUploading.value = false;
    }
  }

  void _resetForm() {
    formKey.currentState?.reset();
    documentNoController.clear();
    remarksController.clear();
    selectedDocumentType.value = null;
    selectedCountry.value = null;
    selectedCity.value = null;
    cities.clear();
    dateIssued.value = null;
    dateExpire.value = null;
    _clearSelectedFile();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

}
