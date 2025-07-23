// Updated RequestController with navigation to create screens

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/data/remote/response/base_response.dart';
import 'package:injazat_hr_app/services/theme_service.dart';
import 'package:injazat_hr_app/data/remote/response/leave_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/permission_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/loan_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/letter_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/request_summary_response.dart';
import 'package:injazat_hr_app/repository/requestrepository.dart';
import 'package:injazat_hr_app/view/request_leave/create_request/create_leave_request_screen.dart';
import 'package:injazat_hr_app/view/request_leave/create_request/create_permission_request_screen.dart';
import 'package:injazat_hr_app/view/request_leave/create_request/create_loan_request_screen.dart';
import 'package:injazat_hr_app/view/request_leave/create_request/create_letter_request_screen.dart';
import 'package:injazat_hr_app/view/request_leave/create_request/edit_letter_request_screen.dart';
import 'package:injazat_hr_app/view/request_leave/create_request/edit_loan_request_screen.dart';
import 'package:injazat_hr_app/view/request_leave/create_request/edit_permission_request_screen.dart';
import 'package:injazat_hr_app/view/request_leave/create_request/edit_leave_request_screen.dart';

class RequestController extends GetxController with GetTickerProviderStateMixin {
  final RequestRepository _requestRepository = RequestRepository();

  // Reactive variables
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = false.obs;
  
  // Original lists (all data from API)
  final RxList<LeaveRequest> _allLeaveRequests = <LeaveRequest>[].obs;
  final RxList<PermissionRequest> _allPermissionRequests = <PermissionRequest>[].obs;
  final RxList<LoanRequest> _allLoanRequests = <LoanRequest>[].obs;
  final RxList<LetterRequest> _allLetterRequests = <LetterRequest>[].obs;
  
  // Filtered lists (displayed to user)
  final RxList<LeaveRequest> leaveRequests = <LeaveRequest>[].obs;
  final RxList<PermissionRequest> permissionRequests = <PermissionRequest>[].obs;
  final RxList<LoanRequest> loanRequests = <LoanRequest>[].obs;
  final RxList<LetterRequest> letterRequests = <LetterRequest>[].obs;
  // Reactive variables for dynamic options
  final RxList<RequestTypeOption> leaveTypes = <RequestTypeOption>[].obs;
  final RxList<RequestTypeOption> loanTypes = <RequestTypeOption>[].obs;
  final RxList<RequestTypeOption> letterTypes = <RequestTypeOption>[].obs;
  final RxBool isLoadingTypes = false.obs; // Added missing variable
  
  // Pagination variables for year-based loading - separate for each request type
  final RxBool isLoadingMoreLeave = false.obs;
  final RxBool isLoadingMorePermission = false.obs;
  final RxBool isLoadingMoreLoan = false.obs;
  final RxBool isLoadingMoreLetter = false.obs;
  
  final RxList<int> loadedYearsLeave = <int>[].obs;
  final RxList<int> loadedYearsPermission = <int>[].obs;
  final RxList<int> loadedYearsLoan = <int>[].obs;
  final RxList<int> loadedYearsLetter = <int>[].obs;
  
  final RxBool hasMoreDataLeave = true.obs;
  final RxBool hasMoreDataPermission = true.obs;
  final RxBool hasMoreDataLoan = true.obs;
  final RxBool hasMoreDataLetter = true.obs;

  // Tab controller
  late TabController tabController;

  // Filter configuration
  List<Map<String, dynamic>> get filters => [
    {'name': 'All', 'color': getFilterColor('all')},
    {'name': 'Approved', 'color': getFilterColor('approved')},
    {'name': 'Rejected', 'color': getFilterColor('rejected')},
    {'name': 'For-Approval', 'color': getFilterColor('pending')},
  ];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 4, vsync: this);
    initializePagination();
    loadAllRequests();
    loadAllRequestTypes(); // Load types on init

  }
  
  // Initialize pagination with current year - separate for each request type
  void initializePagination() {
    final currentYear = DateTime.now().year;
    
    loadedYearsLeave.clear();
    loadedYearsLeave.add(currentYear);
    hasMoreDataLeave.value = true;
    
    loadedYearsPermission.clear();
    loadedYearsPermission.add(currentYear);
    hasMoreDataPermission.value = true;
    
    loadedYearsLoan.clear();
    loadedYearsLoan.add(currentYear);
    hasMoreDataLoan.value = true;
    
    loadedYearsLetter.clear();
    loadedYearsLetter.add(currentYear);
    hasMoreDataLetter.value = true;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Load all requests
  void loadAllRequests() {
    loadLeaveRequests();
    loadPermissionRequests();
    loadLoanRequests();
    loadLetterRequests();
  }
 // Load all request types from API
  Future<void> loadAllRequestTypes() async {
    try {
      isLoadingTypes.value = true;
      await Future.wait([
        loadLeaveTypes(),
        loadLoanTypes(),
        loadLetterTypes(),
      ]);
    } finally {
      isLoadingTypes.value = false;
    }
  }
    // Load methods for request types
  Future<void> loadLeaveTypes() async {
    try {
      final response = await _requestRepository.getLeaveTypes();
      if (response.success) {
        leaveTypes.value = response.data;
      } else {
        _showErrorSnackbar('Failed to load leave types: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading leave types: $e');
    }
  }

  Future<void> loadLoanTypes() async {
    try {
      final response = await _requestRepository.getLoanTypes();
      if (response.success) {
        loanTypes.value = response.data;
      } else {
        _showErrorSnackbar('Failed to load loan types: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading loan types: $e');
    }
  }

  Future<void> loadLetterTypes() async {
    try {
      final response = await _requestRepository.getLetterTypes();
      if (response.success) {
        letterTypes.value = response.data;
      } else {
        _showErrorSnackbar('Failed to load letter types: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading letter types: $e');
    }
  }


  // Load methods with API calls - now populates both _all and filtered lists
  Future<void> loadLeaveRequests() async {
    try {
      isLoading.value = true;
      print('[RequestController] Loading leave requests for current year');
      
      final response = await _requestRepository.getLeaveRequests(
        status: null, // Load all data, filter client-side
        year: DateTime.now().year,
      );

      print('[RequestController] Leave requests response - Success: ${response.success}');
      print('[RequestController] Leave requests response - Message: ${response.message}');
      print('[RequestController] Leave requests response - Data count: ${response.data?.length ?? 0}');

      if (response.success) {
        _allLeaveRequests.value = response.data; // Store all data
        _filterLeaveRequests(); // Apply current filter
        print('[RequestController] Leave requests loaded successfully: ${_allLeaveRequests.length} total, ${leaveRequests.length} filtered');
      } else {
        print('[RequestController] Failed to load leave requests: ${response.message}');
        _showErrorSnackbar('Failed to load leave requests: ${response.message}');
      }
    } catch (e) {
      print('[RequestController] Error loading leave requests: $e');
      _showErrorSnackbar('Error loading leave requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPermissionRequests() async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.getPermissionRequests(
        status: null, // Load all data, filter client-side
        year: DateTime.now().year,
      );

      if (response.success) {
        _allPermissionRequests.value = response.data; // Store all data
        _filterPermissionRequests(); // Apply current filter
      } else {
        _showErrorSnackbar('Failed to load permission requests: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading permission requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLoanRequests() async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.getLoanRequests(
        status: null, // Load all data, filter client-side
        year: DateTime.now().year,
      );

      if (response.success) {
        _allLoanRequests.value = response.data; // Store all data
        _filterLoanRequests(); // Apply current filter
      } else {
        _showErrorSnackbar('Failed to load loan requests: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading loan requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLetterRequests() async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.getLetterRequests(
        status: null, // Load all data, filter client-side
        year: DateTime.now().year,
      );

      if (response.success) {
        _allLetterRequests.value = response.data; // Store all data
        _filterLetterRequests(); // Apply current filter
      } else {
        _showErrorSnackbar('Failed to load letter requests: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading letter requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter methods - now using client-side filtering
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    // Filter existing data instead of calling API
    _filterAllRequests();
  }
  
  // Client-side filtering methods
  void _filterAllRequests() {
    _filterLeaveRequests();
    _filterPermissionRequests();
    _filterLoanRequests();
    _filterLetterRequests();
  }
  
  void _filterLeaveRequests() {
    if (selectedFilter.value == 'All') {
      leaveRequests.value = List.from(_allLeaveRequests);
    } else {
      leaveRequests.value = _allLeaveRequests.where((request) {
        return request.status.toLowerCase() == selectedFilter.value.toLowerCase();
      }).toList();
    }
  }
  
  void _filterPermissionRequests() {
    if (selectedFilter.value == 'All') {
      permissionRequests.value = List.from(_allPermissionRequests);
    } else {
      permissionRequests.value = _allPermissionRequests.where((request) {
        return request.status?.toLowerCase() == selectedFilter.value.toLowerCase();
      }).toList();
    }
  }
  
  void _filterLoanRequests() {
    if (selectedFilter.value == 'All') {
      loanRequests.value = List.from(_allLoanRequests);
    } else {
      loanRequests.value = _allLoanRequests.where((request) {
        return request.status?.toLowerCase() == selectedFilter.value.toLowerCase();
      }).toList();
    }
  }
  
  void _filterLetterRequests() {
    if (selectedFilter.value == 'All') {
      letterRequests.value = List.from(_allLetterRequests);
    } else {
      letterRequests.value = _allLetterRequests.where((request) {
        return request.status?.toLowerCase() == selectedFilter.value.toLowerCase();
      }).toList();
    }
  }

  IconData getFilterIcon(String filterName) {
    switch (filterName) {
      case 'All':
        return Icons.list;
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'For-Approval':
        return Icons.schedule;
      default:
        return Icons.circle;
    }
  }

  // Request creation methods
  void showRequestTypeDialog() {
    final themeService = Get.find<ThemeService>();
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: themeService.getSurfaceColor(),
=======
          color: themeService.getCardColor(),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Create New Request',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 20),
            _buildRequestTypeOption(
              icon: Icons.calendar_today,
              title: 'Leave Request',
              subtitle: 'Request time off work',
              color: themeService.getActionColor('requests'),
              onTap: () {
                Get.back();
                createLeaveRequest();
              },
            ),
            const SizedBox(height: 12),
            _buildRequestTypeOption(
              icon: Icons.badge_outlined,
              title: 'Permission Request',
              subtitle: 'Request work permissions',
              color: themeService.getActionColor('profile'),
              onTap: () {
                Get.back();
                createPermissionRequest();
              },
            ),
            const SizedBox(height: 12),
            _buildRequestTypeOption(
              icon: Icons.account_balance_wallet,
              title: 'Loan Request',
              subtitle: 'Request financial loan',
              color: themeService.getSuccessColor(),
              onTap: () {
                Get.back();
                createLoanRequest();
              },
            ),
            const SizedBox(height: 12),
            _buildRequestTypeOption(
              icon: Icons.description,
              title: 'Letter Request',
              subtitle: 'Request official documents',
              color: themeService.getActionColor('documents'),
              onTap: () {
                Get.back();
                createLetterRequest();
              },
            ),
            const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeService = Get.find<ThemeService>();
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeService.getTextPrimaryColor(),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeService.getTextSecondaryColor(),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: themeService.getTextSecondaryColor().withValues(alpha: 0.6), size: 16),
          ],
        ),
      ),
    );
  }

  // Navigation methods - now navigate to actual screens
  void createLeaveRequest() {
    Get.to(() => const CreateLeaveRequestScreen());
  }

  void createPermissionRequest() {
    Get.to(() => const CreatePermissionRequestScreen());
  }

  void createLoanRequest() {
    Get.to(() => const CreateLoanRequestScreen());
  }

  void createLetterRequest() {
    Get.to(() => const CreateLetterRequestScreen());
  }

  // Leave request actions with improved error handling
  void editLeaveRequest(LeaveRequest request) {
    Get.to(() => EditLeaveRequestScreen(request: request));
  }

  void deleteLeaveRequest(LeaveRequest request) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this leave request?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _deleteLeaveRequest(request.id);
            },
            child: Text('Delete', style: TextStyle(color: ThemeService.instance.getErrorColor())),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLeaveRequest(int id) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.deleteLeaveRequest(id);

      if (response.success) {
        Get.snackbar(
          'Deleted',
          'Request deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
        );
        loadLeaveRequests();
      } else {
        _showErrorSnackbar('Failed to delete request: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error deleting request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewLeaveRequestDetails(LeaveRequest request) {
    Get.snackbar(
      'View Details',
      'View: ${request.reason}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getTextSecondaryColor(),
      colorText: Colors.white,
    );
    // TODO: Navigate to details screen
  }

  // Permission request actions
  void editPermissionRequest(PermissionRequest request) {
    Get.to(() => EditPermissionRequestScreen(request: request));
  }

  void deletePermissionRequest(PermissionRequest request) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Permission Request'),
        content: const Text('Are you sure you want to delete this permission request?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _deletePermissionRequest(request.id);
            },
            child: Text('Delete', style: TextStyle(color: ThemeService.instance.getErrorColor())),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePermissionRequest(int id) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.deletePermissionRequest(id);

      if (response.success) {
        Get.snackbar(
          'Deleted',
          'Permission request deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
        );
        loadPermissionRequests();
      } else {
        _showErrorSnackbar('Failed to delete permission request: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error deleting permission request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewPermissionDetails(PermissionRequest request) {
    Get.snackbar(
      'View Permission Details',
      'View: ${request.purpose}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getTextSecondaryColor(),
      colorText: Colors.white,
    );
  }

  // Loan request actions
  void editLoanRequest(LoanRequest request) {
    Get.to(() => EditLoanRequestScreen(request: request));
  }

  void deleteLoanRequest(LoanRequest request) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Loan Request'),
        content: const Text('Are you sure you want to delete this loan request?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _deleteLoanRequest(request.id);
            },
            child: Text('Delete', style: TextStyle(color: ThemeService.instance.getErrorColor())),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLoanRequest(int id) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.deleteLoanRequest(id);

      if (response.success) {
        Get.snackbar(
          'Deleted',
          'Loan request deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
        );
        loadLoanRequests();
      } else {
        _showErrorSnackbar('Failed to delete loan request: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error deleting loan request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewLoanDetails(LoanRequest request) {
    Get.snackbar(
      'View Loan Details',
      'View: ${request.loanType}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getTextSecondaryColor(),
      colorText: Colors.white,
    );
  }

  // Letter request actions
  void editLetterRequest(LetterRequest request) {
    Get.to(() => EditLetterRequestScreen(request: request));
  }

  void deleteLetterRequest(LetterRequest request) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Letter Request'),
        content: const Text('Are you sure you want to delete this letter request?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _deleteLetterRequest(request.id);
            },
            child: Text('Delete', style: TextStyle(color: ThemeService.instance.getErrorColor())),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteLetterRequest(int id) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.deleteLetterRequest(id);

      if (response.success) {
        Get.snackbar(
          'Deleted',
          'Letter request deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
        );
        loadLetterRequests();
      } else {
        _showErrorSnackbar('Failed to delete letter request: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error deleting letter request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewLetterDetails(LetterRequest request) {
    Get.snackbar(
      'View Letter Details',
      'View: ${request.reason}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getTextSecondaryColor(),
      colorText: Colors.white,
    );
  }

  Future<void> downloadLetter(LetterRequest request) async {
    Get.snackbar(
      'Downloading',
      'Downloading ${request.reason}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getActionColor('requests'),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );

    try {
      isLoading.value = true;
      final response = await _requestRepository.downloadLetter(request.id);

      if (response.success && response.data != null) {
        Get.snackbar(
          'Success',
          'Letter downloaded: ${response.data!.filename}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
        );
        // TODO: Handle file download with response.data.downloadUrl
      } else {
        _showErrorSnackbar('Failed to download letter: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error downloading letter: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // API methods that actually call the repository
  Future<bool> createLeaveRequestWithData({
    required String startDate,
    required String endDate,
    required int leaveTypeId, // Changed to ID
    required String reason,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.createLeaveRequest(
        startDate: startDate,
        endDate: endDate,
        leaveTypeId: leaveTypeId, // Pass ID instead of name
        reason: reason,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Leave request created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLeaveRequests(); // Refresh the list
        return true;
      } else {
        _showErrorSnackbar('Failed to create leave request: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error creating leave request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  Future<bool> createPermissionRequestWithData({
    required String purpose,
    required String fromTime,
    required String toTime,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.createPermissionRequest(
        purpose: purpose,
        fromTime: fromTime,
        toTime: toTime,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Permission request created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadPermissionRequests();
        return true;
      } else {
        _showErrorSnackbar('Failed to create permission request: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error creating permission request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createLoanRequestWithData({
    required int loanTypeId,
    required String purpose,
    required double amount,
    required int repaymentMonths,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.createLoanRequest(
        loanTypeId: loanTypeId,
        purpose: purpose,
        amount: amount,
        repaymentMonths: repaymentMonths,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Loan request created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLoanRequests();
        return true;
      } else {
        _showErrorSnackbar('Failed to create loan request: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error creating loan request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateLoanRequestWithData({
    required int id,
    required int loanTypeId,
    required String purpose,
    required double amount,
    required int repaymentMonths,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.updateLoanRequest(
        id: id,
        loanTypeId: loanTypeId,
        purpose: purpose,
        amount: amount,
        repaymentMonths: repaymentMonths,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Loan request updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLoanRequests();
        return true;
      } else {
        _showErrorSnackbar('Failed to update loan request: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error updating loan request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createLetterRequestWithData({
    required String reason,
    required int letterTypeId,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.createLetterRequest(
        reason: reason,
        letterTypeId: letterTypeId,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Letter request created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLetterRequests();
        return true;
      } else {
        _showErrorSnackbar('Failed to create letter request: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error creating letter request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateLetterRequestWithData({
    required int id,
    required String reason,
    required int letterTypeId,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.updateLetterRequest(
        id: id,
        reason: reason,
        letterTypeId: letterTypeId,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Letter request updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLetterRequests();
        return true;
      } else {
        _showErrorSnackbar('Failed to update letter request: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error updating letter request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateLeaveRequestWithData({
    required int id,
    required String startDate,
    required String endDate,
    required int leaveTypeId,
    required String reason,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.updateLeaveRequest(
        id: id,
        startDate: startDate,
        endDate: endDate,
        leaveType: leaveTypeId,
        reason: reason,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Leave request updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLeaveRequests();
        return true;
      } else {
        _showErrorSnackbar('Failed to update leave request: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error updating leave request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePermissionRequestWithData({
    required int id,
    required String purpose,
    required String fromTime,
    required String toTime,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.updatePermissionRequest(
        id: id,
        purpose: purpose,
        fromTime: fromTime,
        toTime: toTime,
      );

      if (response.success) {
        Get.snackbar(
          'Success',
          'Permission request updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadPermissionRequests();
        return true;
      } else {
        _showErrorSnackbar('Failed to update permission request: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('Error updating permission request: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh method
  Future<void> refreshRequests() async {
  //  await loadAllRequests();
  }

  // Helper method for error messages
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getErrorColor(),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Method to get request count for each type
  int get leaveRequestCount => leaveRequests.length;
  int get permissionRequestCount => permissionRequests.length;
  int get loanRequestCount => loanRequests.length;
  int get letterRequestCount => letterRequests.length;

  // Method to get total request count
  int get totalRequestCount =>
      leaveRequestCount + permissionRequestCount + loanRequestCount + letterRequestCount;

  // Method to get filter color
  Color getFilterColor(String filter) {
    final themeService = ThemeService.instance;
    switch (filter.toLowerCase()) {
      case 'all':
        return themeService.getActionColor('requests');
      case 'approved':
        return themeService.getSuccessColor();
      case 'rejected':
        return themeService.getErrorColor();
      case 'pending':
        return themeService.getWarningColor();
      default:
        return themeService.getTextSecondaryColor();
    }
  }
  
  // Load more methods for pagination - separate for each request type
  Future<void> loadMoreLeaveRequests() async {
    if (isLoadingMoreLeave.value || !hasMoreDataLeave.value) return;
    
    try {
      isLoadingMoreLeave.value = true;
      
      // Ensure loadedYearsLeave is not empty before accessing .last
      if (loadedYearsLeave.isEmpty) {
        loadedYearsLeave.add(DateTime.now().year);
      }
      
      final nextYear = loadedYearsLeave.last - 1;
      loadedYearsLeave.add(nextYear);
      
      final response = await _requestRepository.getLeaveRequests(
        status: null, // Load all data, filter client-side
        year: nextYear,
      );

      if (response.success) {
        // Add new data to _all list and refilter
        final currentAllData = List<LeaveRequest>.from(_allLeaveRequests);
        final newData = response.data;
        
        final combinedAllData = [...currentAllData, ...newData];
        _allLeaveRequests.value = combinedAllData;
        _filterLeaveRequests(); // Apply current filter
        
        // Stop loading more after 3 years or if no more data
       //  if (newData.isEmpty) {
         //  hasMoreDataLeave.value = false;
      //  }
      } else {
        _showErrorSnackbar('Failed to load more leave requests: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading more leave requests: $e');
    } finally {
      isLoadingMoreLeave.value = false;
    }
  }

  Future<void> loadMorePermissionRequests() async {
    if (isLoadingMorePermission.value || !hasMoreDataPermission.value) return;
    
    try {
      isLoadingMorePermission.value = true;
      
      // Ensure loadedYearsPermission is not empty before accessing .last
      if (loadedYearsPermission.isEmpty) {
        loadedYearsPermission.add(DateTime.now().year);
      }
      
      final nextYear = loadedYearsPermission.last - 1;
      loadedYearsPermission.add(nextYear);
      
      final response = await _requestRepository.getPermissionRequests(
        status: null, // Load all data, filter client-side
        year: nextYear,
      );

      if (response.success) {
        final currentAllData = List<PermissionRequest>.from(_allPermissionRequests);
        final newData = response.data;
        
        final combinedAllData = [...currentAllData, ...newData];
        _allPermissionRequests.value = combinedAllData;
        _filterPermissionRequests(); // Apply current filter
        
        // Stop loading more after 3 years or if no more data
       // if (newData.isEmpty) {
       //   hasMoreDataPermission.value = false;
        //}
      } else {
        _showErrorSnackbar('Failed to load more permission requests: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading more permission requests: $e');
    } finally {
      isLoadingMorePermission.value = false;
    }
  }

  Future<void> loadMoreLoanRequests() async {
    if (isLoadingMoreLoan.value || !hasMoreDataLoan.value) return;
    
    try {
      isLoadingMoreLoan.value = true;
      
      // Ensure loadedYearsLoan is not empty before accessing .last
      if (loadedYearsLoan.isEmpty) {
        loadedYearsLoan.add(DateTime.now().year);
      }
      
      final nextYear = loadedYearsLoan.last - 1;
      loadedYearsLoan.add(nextYear);
      
      final response = await _requestRepository.getLoanRequests(
        status: null, // Load all data, filter client-side
        year: nextYear,
      );

      if (response.success) {
        final currentAllData = List<LoanRequest>.from(_allLoanRequests);
        final newData = response.data;
        
        final combinedAllData = [...currentAllData, ...newData];
        _allLoanRequests.value = combinedAllData;
        _filterLoanRequests(); // Apply current filter
        
        // Stop loading more after 3 years or if no more data
       // if (loadedYearsLoan.length >= 3 || newData.isEmpty) {
         // hasMoreDataLoan.value = false;
        //}
      } else {
        _showErrorSnackbar('Failed to load more loan requests: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading more loan requests: $e');
    } finally {
      isLoadingMoreLoan.value = false;
    }
  }

  Future<void> loadMoreLetterRequests() async {
    if (isLoadingMoreLetter.value || !hasMoreDataLetter.value) return;
    
    try {
      isLoadingMoreLetter.value = true;
      
      // Ensure loadedYearsLetter is not empty before accessing .last
      if (loadedYearsLetter.isEmpty) {
        loadedYearsLetter.add(DateTime.now().year);
      }
      
      final nextYear = loadedYearsLetter.last - 1;
      loadedYearsLetter.add(nextYear);
      
      final response = await _requestRepository.getLetterRequests(
        status: null, // Load all data, filter client-side
        year: nextYear,
      );

      if (response.success) {
        final currentAllData = List<LetterRequest>.from(_allLetterRequests);
        final newData = response.data;
        
        final combinedAllData = [...currentAllData, ...newData];
        _allLetterRequests.value = combinedAllData;
        _filterLetterRequests(); // Apply current filter
        
        // Stop loading more after 3 years or if no more data
       // if (loadedYearsLetter.length >= 3 || newData.isEmpty) {
         // hasMoreDataLetter.value = false;
        //}
      } else {
        _showErrorSnackbar('Failed to load more letter requests: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading more letter requests: $e');
    } finally {
      isLoadingMoreLetter.value = false;
    }
  }
}