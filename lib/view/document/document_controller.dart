// File: lib/view/document/document_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/remote/response/document_response.dart';
import '../../repository/documentrepository.dart';
import 'document_widgets.dart';
import 'document_upload_screen.dart';
import '../../utils/app_theme.dart';

class DocumentController extends GetxController with GetTickerProviderStateMixin {
  final DocumentRepository _documentRepository = DocumentRepository();

  // Reactive variables
  final RxString selectedFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxBool isGridView = false.obs;
  final RxList<DocumentResponseData> documents = <DocumentResponseData>[].obs;
  final Rx<DocumentSummaryResponseData?> documentSummary = Rx<DocumentSummaryResponseData?>(null);
  final RxList<DocumentCategoryData> availableCategories = <DocumentCategoryData>[].obs;

  // Tab controller
  late TabController tabController;

  // Filter configuration
  List<Map<String, dynamic>> get filters => [
    {'name': 'All', 'key': 'all', 'color': getFilterColor('all')},
    {'name': 'Active', 'key': 'active', 'color': getFilterColor('active')},
    {'name': 'Expired', 'key': 'expired', 'color': getFilterColor('expired')},

  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 6, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Load all data concurrently to improve performance
    await Future.wait([
      loadDocuments(),
      loadDocumentSummary(),
      loadAvailableCategories(),
    ]);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Load methods
  Future<void> loadDocuments() async {
    try {
      isLoading.value = true;

      DocumentResponse response;

      // Apply status filter
      if (selectedFilter.value != 'All') {
        response = await _documentRepository.getDocumentsByStatus(selectedFilter.value.toLowerCase());
      } else {
        response = await _documentRepository.getAllDocuments();
      }

      if (response.success) {
        List<DocumentResponseData> filteredDocuments = response.data;

        // Apply search filter
        if (searchQuery.value.isNotEmpty) {
          final query = searchQuery.value.toLowerCase();
          filteredDocuments = filteredDocuments.where((doc) =>
          doc.name.toLowerCase().contains(query) ||
              doc.description.toLowerCase().contains(query)
          ).toList();
        }

        documents.value = filteredDocuments;
      } else {
        _showErrorSnackbar('Failed to load documents', response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Error loading documents', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDocumentSummary() async {
    try {
      final response = await _documentRepository.getDocumentSummary();
      if (response.success) {
        documentSummary.value = response.data;
      }
    } catch (e) {
      // Error loading document summary: $e
    }
  }

  Future<void> loadAvailableCategories() async {
    if (isCategoriesLoading.value) return; // Prevent duplicate calls
    
    try {
      isCategoriesLoading.value = true;
      final response = await _documentRepository.getAvailableCategories();
      if (response.success) {
        availableCategories.value = response.data;
        print('Categories loaded successfully: ${availableCategories.length} categories');
      } else {
        print('Failed to load categories: ${response.message}');
      }
    } catch (e) {
      print('Error loading available categories: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // Filter methods
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    loadDocuments();
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    loadDocuments();
  }

  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  IconData getFilterIcon(String filterName) {
    switch (filterName) {
      case 'All':
        return Icons.list;
      case 'Active':
        return Icons.check_circle;
      case 'Expired':
        return Icons.access_time;
      case 'Pending':
        return Icons.schedule;
      default:
        return Icons.circle;
    }
  }

  // Category filtering
  Future<void> filterByCategory(String category) async {
    try {
      isLoading.value = true;
      final response = await _documentRepository.getDocumentsByCategory(category);
      if (response.success) {
        documents.value = response.data;
      } else {
        _showErrorSnackbar('Failed to filter documents', response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Error filtering documents', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Filter by category ID
  Future<void> filterByCategoryId(int categoryId) async {
    try {
      isLoading.value = true;
      final response = await _documentRepository.getDocumentsByCategory(categoryId.toString());
      if (response.success) {
        documents.value = response.data;
      } else {
        _showErrorSnackbar('Failed to filter documents', response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Error filtering documents', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void loadAllDocuments() {
    selectedFilter.value = 'All';
    searchQuery.value = '';
    loadDocuments();
  }

  // Document actions
  void viewDocumentDetails(DocumentResponseData document) {
    Get.bottomSheet(
      DocumentDetailBottomSheet(document: document),
      isScrollControlled: true,
    );
  }


  // Document action methods
  Future<void> downloadDocument(DocumentResponseData document) async {
    if (document.downloadUrl == null || document.downloadUrl!.isEmpty) {
      _showErrorSnackbar('Download failed', 'Download URL not available');
      return;
    }

    try {
      // Show loading
      _showLoadingSnackbar('Downloading ${document.name}...');
      
      // Get the file extension from the URL or use the file type
      String fileName = document.name;
      String fileExtension = '';
      
      if (document.fileType != null) {
        fileExtension = '.${document.fileType!.toLowerCase()}';
      } else {
        // Try to get extension from URL
        final uri = Uri.parse(document.downloadUrl!);
        final path = uri.path;
        if (path.contains('.')) {
          fileExtension = path.substring(path.lastIndexOf('.'));
        } else {
          fileExtension = '.pdf'; // Default to PDF
        }
      }
      
      // Clean filename and add extension
      fileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      if (!fileName.endsWith(fileExtension)) {
        fileName += fileExtension;
      }

      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      // Download the file
      final dio = Dio();
      await dio.download(
        document.downloadUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );

      // Open the downloaded file
      final result = await OpenFile.open(filePath);
      
      if (result.type == ResultType.done) {
        _showSuccessSnackbar('Document opened successfully');
      } else {
        _showErrorSnackbar('Open failed', result.message);
      }
      
    } catch (e) {
      _showErrorSnackbar('Download failed', e.toString());
    }
  }

  void shareDocument(DocumentResponseData document) {
    if (document.downloadUrl == null || document.downloadUrl!.isEmpty) {
      _showErrorSnackbar('Share failed', 'Download URL not available');
      return;
    }

    // Directly share the file
    _shareDocumentFile(document);
  }


  // Share actual document file
  Future<void> _shareDocumentFile(DocumentResponseData document) async {
    try {
      _showLoadingSnackbar('Preparing document for sharing...');
      
      // Get the file extension
      String fileExtension = '';
      if (document.fileType != null) {
        fileExtension = '.${document.fileType!.toLowerCase()}';
      } else {
        final uri = Uri.parse(document.downloadUrl!);
        final path = uri.path;
        if (path.contains('.')) {
          fileExtension = path.substring(path.lastIndexOf('.'));
        } else {
          fileExtension = '.pdf';
        }
      }
      
      // Clean filename
      String fileName = document.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      if (!fileName.endsWith(fileExtension)) {
        fileName += fileExtension;
      }

      // Get temporary directory for sharing
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/share_$fileName';

      // Download the file
      final dio = Dio();
      await dio.download(document.downloadUrl!, filePath);

      // Create XFile for sharing
      final xFile = XFile(filePath);
      
      // Share the file with text
      final shareText = '''📄 ${document.name}

📁 Category: ${document.category}
📅 Uploaded: ${document.uploadedDate}

Shared via HR Management System''';

      await Share.shareXFiles(
        [xFile],
        text: shareText,
        subject: 'Document: ${document.name}',
      );
      
      _showSuccessSnackbar('Document file shared successfully!');
      
    } catch (e) {
      _showErrorSnackbar('Share failed', e.toString());
    }
  }


  void uploadNewDocument() async {
    final result = await Get.to(() => const DocumentUploadScreen());
    
    // If upload was successful, refresh documents
    if (result == true) {
      await refreshDocuments();
    }
  }

  // Refresh method
  Future<void> refreshDocuments() async {
    try {
      // Refresh all data concurrently
      await Future.wait([
        _refreshDocumentsData(),
        loadDocumentSummary(),
        loadAvailableCategories(),
      ]);
    } catch (e) {
      _showErrorSnackbar('Refresh failed', e.toString());
    }
  }

  Future<void> _refreshDocumentsData() async {
    final response = await _documentRepository.refreshDocuments();
    if (response.success) {
      documents.value = response.data;
    } else {
      _showErrorSnackbar('Refresh failed', response.message);
    }
  }

  // Helper methods for categories
  Color getCategoryColor(String category) {
    // Use hash of category name to consistently assign colors
    final hash = category.toLowerCase().hashCode;
    return AppTheme.documentColors[hash.abs() % AppTheme.documentColors.length];
  }

  // Snackbar helper methods
  void _showLoadingSnackbar(String message) {
    Get.snackbar(
      'Loading',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.successColor,
      colorText: Colors.white,
    );
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.errorColor,
      colorText: Colors.white,
    );
  }

  // Get filter color
  Color getFilterColor(String filter) {
    return AppTheme.getFilterColor(filter);
  }
}