import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.injazatsoftware.injazathr/utils/translation_helper.dart';
import '../../repository/employee_requests_repository.dart';

class EmployeeRequestsController extends GetxController {
  final EmployeeRequestsRepository _repository = EmployeeRequestsRepository();

  // Store the employee ID
  int? _employeeId;

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<Map<String, dynamic>> requests = <Map<String, dynamic>>[].obs;
  final RxString selectedTypeFilter = 'all'.obs;
  final RxString selectedStatusFilter = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt totalRequests = 0.obs;

  // Controllers
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Timer? _searchDebounce;

  // Filter options
  List<Map<String, dynamic>> get typeFilters => [
    {'key': 'all', 'name': tr('all'), 'color': Colors.grey},
    {'key': 'Leave', 'name': tr('leave'), 'color': const Color(0xFF42A5F5)},
    {'key': 'Permission', 'name': tr('permission'), 'color': const Color(0xFF66BB6A)},
    {'key': 'Loan', 'name': tr('loan'), 'color': const Color(0xFFFF7043)},
    {'key': 'Letter', 'name': tr('letter'), 'color': const Color(0xFFAB47BC)},
  ];

  List<Map<String, dynamic>> get statusFilters => [
    {'key': 'all', 'name': tr('all'), 'color': Colors.grey},
    {'key': 'Approved', 'name': tr('approved'), 'color': const Color(0xFF4CAF50)},
    {'key': 'Rejected', 'name': tr('rejected'), 'color': const Color(0xFFF44336)},
    {'key': 'For Approval', 'name': tr('for_approval'), 'color': const Color(0xFFFF9800)},
  ];

  @override
  void onInit() {
    super.onInit();
    _setupScrollListener();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value && hasMoreData.value) {
          loadMoreRequests();
        }
      }
    });
  }

  // Load employee requests
  Future<void> loadEmployeeRequests(int employeeId, {bool refresh = false}) async {
    try {
      // Store the employee ID for later use
      _employeeId = employeeId;
      
      if (refresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      isLoading.value = true;

      final response = await _repository.getEmployeeRequests(
        employeeId,
        selectedFilterType: selectedTypeFilter.value == 'all' ? null : selectedTypeFilter.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        status: selectedStatusFilter.value == 'all' ? null : selectedStatusFilter.value,
        page: currentPage.value,
      );

      final List<dynamic> requestsData = response['data']['data'] ?? [];
      final List<Map<String, dynamic>> newRequests = requestsData
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (refresh || currentPage.value == 1) {
        requests.clear();
      }

      requests.addAll(newRequests);
      totalRequests.value = response['data']['total'] ?? 0;
      hasMoreData.value = response['data']['next_page_url'] != null;

    } catch (e) {
      _showErrorSnackbar('Error loading employee requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more requests for pagination
  Future<void> loadMoreRequests() async {
    if (isLoadingMore.value || !hasMoreData.value || _employeeId == null) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      await loadEmployeeRequests(_employeeId!);
    } catch (e) {
      currentPage.value--;
      _showErrorSnackbar('Error loading more requests: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  // Filter methods
  void setTypeFilter(String filterKey) {
    selectedTypeFilter.value = filterKey;
    _applyFilters();
  }

  void setStatusFilter(String filterKey) {
    selectedStatusFilter.value = filterKey;
    _applyFilters();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    
    // Debounce the search to avoid too many API calls
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (_employeeId != null) {
      loadEmployeeRequests(_employeeId!, refresh: true);
    }
  }

  // Clear filters
  void clearFilters() {
    // Cancel any pending search debounce
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    
    selectedTypeFilter.value = 'all';
    selectedStatusFilter.value = 'all';
    searchQuery.value = '';
    searchController.clear();
    _applyFilters();
  }

  // Refresh data
  Future<void> refreshData() async {
    if (_employeeId != null) {
      await loadEmployeeRequests(_employeeId!, refresh: true);
    }
  }

  // Helper methods
  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return '0xFF4CAF50';
      case 'rejected':
        return '0xFFF44336';
      case 'for approval':
      case 'pending':
        return '0xFFFF9800';
      default:
        return '0xFF757575';
    }
  }

  String getRequestTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'leave':
        return '0xFF42A5F5';
      case 'permission':
        return '0xFF66BB6A';
      case 'loan':
        return '0xFFFF7043';
      case 'letter':
        return '0xFFAB47BC';
      default:
        return '0xFF757575';
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return tr('n_a');
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return tr('n_a');
    }
  }

  // Snackbar helpers
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF44336),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}