import 'package:get/get.dart';
import '../../repository/dashboardrepository.dart';
import '../../data/remote/response/unexecuted_requests_response.dart';

class UnexecutedRequestsController extends GetxController {
  final DashboardRepository repository = DashboardRepository();
  
  // Observable variables
  var isLoading = false.obs;
  var unexecutedRequestsTotal = 0.obs;
  var unexecutedRequests = <UnexecutedRequest>[].obs;
  var requestFiles = <String, List<Map<String, dynamic>>>{}.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUnexecutedRequests();
  }
  
  /// Load unexecuted requests from the repository
  Future<void> loadUnexecutedRequests() async {
    try {
      isLoading.value = true;

      final locale = Get.locale?.languageCode ?? 'en';
      final response = await repository.getUnexecutedRequests(locale: locale);

      unexecutedRequestsTotal.value = response.unexecutedRequestsTotal;
      unexecutedRequests.value = response.unexecutedRequests;
      
      // Process files if they exist in the response
      _processRequestFiles(response);

    } catch (e) {
      unexecutedRequestsTotal.value = 0;
      unexecutedRequests.value = [];
      
      // Show error message to user
      Get.snackbar(
        'Error',
        'Failed to load unexecuted requests. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Refresh the unexecuted requests data
  Future<void> refreshRequests() async {
    await loadUnexecutedRequests();
  }
  
  /// Process files from the response and organize them by request ID
  void _processRequestFiles(UnexecutedRequestsResponse response) {
    requestFiles.clear();
    
    // For now, this method is kept for future file handling
    // The current API response doesn't include files based on the provided JSON
    // This can be extended when file support is added to the API response
  }
  
  /// Get files for a specific request
  List<Map<String, dynamic>> getFilesForRequest(String requestId) {
    return requestFiles[requestId] ?? [];
  }
  
  /// Check if a request has files
  bool hasFiles(String requestId) {
    return requestFiles[requestId]?.isNotEmpty ?? false;
  }
  
  /// Download or view a file
  Future<void> handleFileAction(Map<String, dynamic> file) async {
    try {
      final fileName = file['name'] ?? file['file_name'] ?? 'Unknown';
      final fileUrl = file['url'] ?? file['file_url'] ?? file['path'];
      
      if (fileUrl == null) {
        Get.snackbar(
          'Error',
          'File URL not found',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      // Here you can implement file download/view logic
      // For now, just show the file info
      Get.snackbar(
        'File Info',
        'File: $fileName\nURL: $fileUrl',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      
      // TODO: Implement actual file download/view functionality
      // await _downloadFile(fileUrl, fileName);
      // or
      // await _openFileViewer(fileUrl);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to handle file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}