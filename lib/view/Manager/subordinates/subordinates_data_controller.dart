import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/data/remote/response/employees_response.dart';
import 'package:co.injazathr.injazathr/repository/employees_repository.dart';

class SubordinatesDataController extends GetxController {
  final EmployeesRepository repository = EmployeesRepository();
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  var employees = <Employee>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var currentPage = 1.obs;
  var totalEmployees = 0.obs;
  var fromRecord = 0.obs;
  var toRecord = 0.obs;
  var hasMorePages = true.obs;
  var isLoadingMore = false.obs;
  var searchQuery = ''.obs;
  var isSearching = false.obs;
  
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchEmployees({int page = 1, String? search}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await repository.getEmployees(page: page, search: search ?? searchQuery.value);
      
      employees.value = response.employees.data;
      totalEmployees.value = response.employees.total;
      fromRecord.value = response.employees.from;
      toRecord.value = response.employees.to;
      currentPage.value = response.employees.currentPage;
      hasMorePages.value = currentPage.value < response.employees.lastPage;
      
      // Debug: Print first employee image data
      if (employees.isNotEmpty) {
      }
      
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToPage(int page) async {
    await fetchEmployees(page: page, search: searchQuery.value);
  }

  Future<void> refreshEmployees() async {
    await fetchEmployees(page: currentPage.value, search: searchQuery.value);
  }

  void onSearchChanged(String value) {
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();
    
    // If search is empty, search immediately
    if (value.isEmpty) {
      searchQuery.value = '';
      currentPage.value = 1;
      _performSearch('');
      return;
    }
    
    // Set up debounce for non-empty search
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (value == searchController.text) { // Only search if text hasn't changed
        searchQuery.value = value;
        currentPage.value = 1;
        _performSearch(value);
      }
    });
  }

  Future<void> _performSearch(String searchTerm) async {
    // Prevent multiple simultaneous search requests
    if (isSearching.value) return;
    
    try {
      isSearching.value = true;
      await fetchEmployees(page: 1, search: searchTerm);
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    _performSearch('');
  }
}