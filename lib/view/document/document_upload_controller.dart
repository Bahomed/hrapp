import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/remote/response/document_response.dart';
import '../../repository/documentrepository.dart';
import '../../utils/translation_helper.dart';

class DocumentUploadController extends GetxController {
  final DocumentRepository _documentRepository = DocumentRepository();
  
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Text controllers
  final TextEditingController documentNoController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  
  // Reactive variables
  final RxString selectedCategory = ''.obs;
  final RxList<String> availableCategories = <String>[].obs;
  final Rx<DateTime?> dateIssued = Rx<DateTime?>(null);
  final Rx<DateTime?> dateExpire = Rx<DateTime?>(null);
  final RxString selectedFileName = ''.obs;
  final RxBool isUploading = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxBool isPickingFile = false.obs;
  
  // File handling
  File? selectedFile;
  PlatformFile? platformFile;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    documentNoController.dispose();
    remarksController.dispose();
    super.onClose();
  }

  /// Load available document categories
  Future<void> loadCategories() async {
    try {
      isCategoriesLoading.value = true;
      
      final response = await _documentRepository.getAvailableCategories();
      if (response.success) {
        // Extract category names from the response
        final categories = response.data.map((category) => category.documentName).toList();
        availableCategories.assignAll(categories);
        
        print('Categories loaded: ${availableCategories.length}');
      } else {
        _showErrorSnackbar(tr('error'), tr('failed_to_load_categories'));
      }
    } catch (e) {
      _showErrorSnackbar(tr('error'), tr('error_loading_categories'));
      print('Error loading categories: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  /// Pick file for upload
  Future<void> pickFile() async {
    try {
      // Set flag to prevent dashboard API calls during file picking
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
        
        // Check file size (limit to 10MB)
        if (selectedFile!.lengthSync() > 10 * 1024 * 1024) {
          _showErrorSnackbar(tr('error'), tr('file_too_large'));
          _clearSelectedFile();
          return;
        }
        
        _showSuccessSnackbar(tr('file_selected'), platformFile!.name);
      }
    } catch (e) {
      _showErrorSnackbar(tr('error'), tr('error_selecting_file'));
      print('Error picking file: $e');
    } finally {
      // Reset flag after file picking is done
      Future.delayed(const Duration(milliseconds: 500), () {
        isPickingFile.value = false;
      });
    }
  }

  /// Clear selected file
  void _clearSelectedFile() {
    selectedFile = null;
    platformFile = null;
    selectedFileName.value = '';
  }

  /// Validate form
  bool _validateForm() {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (selectedCategory.value.isEmpty) {
      _showErrorSnackbar(tr('validation_error'), tr('please_select_category'));
      return false;
    }

    if (selectedFile == null) {
      _showErrorSnackbar(tr('validation_error'), tr('please_select_file'));
      return false;
    }

    return true;
  }

  /// Upload document
  Future<void> uploadDocument() async {
    if (!_validateForm()) {
      return;
    }

    try {
      isUploading.value = true;

      // Find the category ID
      final categoryResponse = await _documentRepository.getAvailableCategories();
      int? categoryId;
      
      if (categoryResponse.success) {
        final categoryData = categoryResponse.data.firstWhereOrNull(
          (cat) => cat.documentName == selectedCategory.value,
        );
        categoryId = categoryData?.id;
      }

      if (categoryId == null) {
        _showErrorSnackbar(tr('error'), tr('invalid_category_selected'));
        return;
      }

      // Prepare upload request
      final uploadRequest = DocumentUploadRequest(
        docId: categoryId,
        name: documentNoController.text.trim(),
        notes: remarksController.text.trim().isNotEmpty 
            ? remarksController.text.trim() 
            : null,
        dateIssuedG: dateIssued.value != null 
            ? _formatDate(dateIssued.value!) 
            : null,
        dateExpireG: dateExpire.value != null 
            ? _formatDate(dateExpire.value!) 
            : null,
        docNo: documentNoController.text.trim().isNotEmpty 
            ? documentNoController.text.trim() 
            : null,
        category: selectedCategory.value,
        type: selectedCategory.value, // Use category as type
        remarks: remarksController.text.trim().isNotEmpty 
            ? remarksController.text.trim() 
            : null
      );

      // Upload the document
       final response = await _documentRepository.uploadDocument(
         uploadRequest,
         selectedFile!,
      );

      if (response.success) {
        // Reset form first
        _resetForm();

        // Navigate back immediately without snackbar
        Get.back(result: true);
        
        // Show success message after navigation
        Future.delayed(const Duration(milliseconds: 100), () {
          _showSuccessSnackbar(tr('success'), tr('document_uploaded_successfully'));
        });
      } else {
         _showErrorSnackbar(tr('upload_failed'), response.message);
       }
    } catch (e) {
      _showErrorSnackbar(tr('upload_failed'), tr('error_uploading_document'));
      print('Error uploading document: $e');
    } finally {
      isUploading.value = false;
    }
  }

  /// Reset form
  void _resetForm() {
    formKey.currentState?.reset();
    documentNoController.clear();
    remarksController.clear();
    selectedCategory.value = '';
    dateIssued.value = null;
    dateExpire.value = null;
    _clearSelectedFile();
  }

  /// Format date for API
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Snackbar helper methods
  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF4CAF50),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}