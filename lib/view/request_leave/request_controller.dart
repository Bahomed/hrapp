// Updated RequestController with navigation to create screens

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:co.injazathr.injazathr/data/remote/response/base_response.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/data/remote/response/leave_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/permission_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/loan_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/letter_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/request_summary_response.dart';
import 'package:co.injazathr.injazathr/repository/requestrepository.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/create_leave_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/create_permission_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/create_loan_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/create_letter_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/edit_letter_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/edit_loan_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/edit_permission_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/edit_leave_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/loan_details_screen.dart';

import '../../utils/translation_helper.dart';

class RequestController extends GetxController with GetTickerProviderStateMixin {
  final RequestRepository _requestRepository = RequestRepository();

  // Reactive variables
  final RxString selectedFilter = 'all'.obs;
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
    {'name': tr('all'), 'key': 'all', 'color': getFilterColor('all')},
    {'name': tr('approved'), 'key': 'Approved', 'color': getFilterColor('approved')},
    {'name': tr('rejected'), 'key': 'Rejected', 'color': getFilterColor('rejected')},
    {'name': tr('for_approval'), 'key': 'For-Approval', 'color': getFilterColor('pending')},
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
        _showErrorSnackbar('${tr('failed_to_load_leave_types')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_leave_types')}: $e');
    }
  }

  Future<void> loadLoanTypes() async {
    try {
      final response = await _requestRepository.getLoanTypes();
      if (response.success) {
        loanTypes.value = response.data;
      } else {
        _showErrorSnackbar('${tr('failed_to_load_loan_types')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_loan_types')}: $e');
    }
  }

  Future<void> loadLetterTypes() async {
    try {
      final response = await _requestRepository.getLetterTypes();
      if (response.success) {
        letterTypes.value = response.data;
      } else {
        _showErrorSnackbar('${tr('failed_to_load_letter_types')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_letter_types')}: $e');
    }
  }


  // Load methods with API calls - now populates both _all and filtered lists
  Future<void> loadLeaveRequests() async {
    try {
      isLoading.value = true;

      final response = await _requestRepository.getLeaveRequests(
        status: null, // Load all data, filter client-side
        year: DateTime.now().year,
      );


      if (response.success) {
        _allLeaveRequests.value = response.data; // Store all data
        _filterLeaveRequests(); // Apply current filter
      } else {
        _showErrorSnackbar('${tr('failed_to_load_leave_requests')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_leave_requests')}: $e');
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
        _showErrorSnackbar('${tr('failed_to_load_permission_requests')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_permission_requests')}: $e');
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
        _showErrorSnackbar('${tr('failed_to_load_loan_requests')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_loan_requests')}: $e');
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
        _showErrorSnackbar('${tr('failed_to_load_letter_requests')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_letter_requests')}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter methods - now using client-side filtering
  void changeFilter(String filterKey) {
    selectedFilter.value = filterKey;
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
    if (selectedFilter.value == 'all') {
      leaveRequests.value = List.from(_allLeaveRequests);
    } else {
      final statusToFilter = selectedFilter.value;
      leaveRequests.value = _allLeaveRequests.where((request) {
        return request.status.toLowerCase() == statusToFilter.toLowerCase();
      }).toList();
    }
  }

  void _filterPermissionRequests() {
    if (selectedFilter.value == 'all') {
      permissionRequests.value = List.from(_allPermissionRequests);
    } else {
      final statusToFilter = selectedFilter.value == 'for-approval' ? 'pending' : selectedFilter.value;
      permissionRequests.value = _allPermissionRequests.where((request) {
        return request.status?.toLowerCase() == statusToFilter.toLowerCase();
      }).toList();
    }
  }

  void _filterLoanRequests() {
    if (selectedFilter.value == 'all') {
      loanRequests.value = List.from(_allLoanRequests);
    } else {
      final statusToFilter = selectedFilter.value == 'for-approval' ? 'pending' : selectedFilter.value;
      loanRequests.value = _allLoanRequests.where((request) {
        return request.status?.toLowerCase() == statusToFilter.toLowerCase();
      }).toList();
    }
  }

  void _filterLetterRequests() {
    if (selectedFilter.value == 'all') {
      letterRequests.value = List.from(_allLetterRequests);
    } else {
      final statusToFilter = selectedFilter.value == 'for-approval' ? 'pending' : selectedFilter.value;
      letterRequests.value = _allLetterRequests.where((request) {
        return request.status?.toLowerCase() == statusToFilter.toLowerCase();
      }).toList();
    }
  }

  IconData getFilterIcon(String filterKey) {
    switch (filterKey) {
      case 'all':
        return Icons.list;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'for-approval':
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
          color: themeService.getSurfaceColor(),
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
              tr('create_new_request'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 20),
            _buildRequestTypeOption(
              icon: Icons.calendar_today,
              title: tr('leave_request'),
              subtitle: tr('request_time_off_work'),
              color: themeService.getActionColor('requests'),
              onTap: () {
                Get.back();
                createLeaveRequest();
              },
            ),
            const SizedBox(height: 12),
            _buildRequestTypeOption(
              icon: Icons.badge_outlined,
              title: tr('permission_request'),
              subtitle: tr('request_work_permissions'),
              color: themeService.getActionColor('profile'),
              onTap: () {
                Get.back();
                createPermissionRequest();
              },
            ),
            const SizedBox(height: 12),
            _buildRequestTypeOption(
              icon: Icons.account_balance_wallet,
              title: tr('loan_request'),
              subtitle: tr('request_financial_loan'),
              color: themeService.getSuccessColor(),
              onTap: () {
                Get.back();
                createLoanRequest();
              },
            ),
            const SizedBox(height: 12),
            _buildRequestTypeOption(
              icon: Icons.description,
              title: tr('letter_request'),
              subtitle: tr('request_official_documents'),
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
        title: Text(tr('delete_request')),
        content: Text(tr('confirm_delete_leave_request')),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(tr('cancel'), style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _deleteLeaveRequest(request.id);
            },
            child: Text(tr('delete'), style: TextStyle(color: ThemeService.instance.getErrorColor())),
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
          tr('deleted'),
          tr('request_deleted_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
        );
        loadLeaveRequests();
      } else {
        _showErrorSnackbar('${tr('failed_to_delete_request')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_deleting_request')}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewLeaveRequestDetails(LeaveRequest request) {
    Get.snackbar(
      tr('view_details'),
      '${tr('view_leave_request')}: ${request.reason}',
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
        title: Text(tr('delete_permission_request')),
        content: Text(tr('confirm_delete_permission_request')),
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
          tr('deleted'),
          tr('permission_request_deleted_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
        );
        loadPermissionRequests();
      } else {
        _showErrorSnackbar('${tr('failed_to_delete_permission_request')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_deleting_permission_request')}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewPermissionDetails(PermissionRequest request) {
    Get.snackbar(
      tr('view_permission_details'),
      '${tr('view_permission')}: ${request.purpose}',
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
        title: Text(tr('delete_loan_request')),
        content: Text(tr('confirm_delete_loan_request')),
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
          tr('deleted'),
          tr('loan_request_deleted_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
        );
        loadLoanRequests();
      } else {
        _showErrorSnackbar('${tr('failed_to_delete_loan_request')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_deleting_loan_request')}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewLoanDetails(LoanRequest request) {
    Get.to(() => LoanDetailsScreen(request: request));
  }

  // Letter request actions
  void editLetterRequest(LetterRequest request) {
    Get.to(() => EditLetterRequestScreen(request: request));
  }

  void deleteLetterRequest(LetterRequest request) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr('delete_letter_request')),
        content: Text(tr('confirm_delete_letter_request')),
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
          tr('deleted'),
          tr('letter_request_deleted_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
        );
        loadLetterRequests();
      } else {
        _showErrorSnackbar('${tr('failed_to_delete_letter_request')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_deleting_letter_request')}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void viewLetterDetails(LetterRequest request) {
    Get.snackbar(
      tr('view_letter_details'),
      '${tr('view_letter')}: ${request.reason}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getTextSecondaryColor(),
      colorText: Colors.white,
    );
  }

  Future<void> downloadLetter(LetterRequest request) async {
    Get.snackbar(
      tr('downloading_letter'),
      '${tr('downloading_letter')} ${request.reason}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getActionColor('requests'),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );

    try {
      isLoading.value = true;
      final response = await _requestRepository.downloadLetter(request.id);

      if (response.success && response.data != null) {
        final downloadUrl = response.data!.downloadUrl;
        final filename = response.data!.filename;

        if (downloadUrl.isEmpty) {
          _showErrorSnackbar('${tr('failed_to_download_letter')}: Download URL not available');
          return;
        }

        // Get the file extension from the filename or URL
        String fileExtension = '';

        if (filename.contains('.')) {
          fileExtension = filename.substring(filename.lastIndexOf('.'));
        } else {
          // Try to get extension from URL
          final uri = Uri.parse(downloadUrl);
          final path = uri.path;
          if (path.contains('.')) {
            fileExtension = path.substring(path.lastIndexOf('.'));
          } else {
            fileExtension = '.pdf'; // Default to PDF
          }
        }

        // Clean filename and add extension
        String cleanFilename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        if (!cleanFilename.endsWith(fileExtension)) {
          cleanFilename += fileExtension;
        }

        // Get the app's document directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$cleanFilename';

        // Download the file
        final dio = Dio();
        await dio.download(
          downloadUrl,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              // Progress tracking can be added here if needed
              // final progress = (received / total * 100).toStringAsFixed(0);
            }
          },
        );

        // Open the downloaded file
        final result = await OpenFile.open(filePath);

        if (result.type == ResultType.done) {
          Get.snackbar(
            tr('success'),
            '${tr('letter_downloaded')}: $cleanFilename',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: ThemeService.instance.getSuccessColor(),
            colorText: Colors.white,
          );
        } else {
          _showErrorSnackbar('${tr('failed_to_open_letter')}: ${result.message}');
        }
      } else {
        _showErrorSnackbar('${tr('failed_to_download_letter')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_downloading_letter')}: $e');
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
          tr('success'),
          tr('leave_request_created_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLeaveRequests(); // Refresh the list
        return true;
      } else {
        _showErrorSnackbar('${tr('failed_to_create_leave_request')}: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_creating_leave_request')}: $e');
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
          tr('success'),
          tr('permission_request_created_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadPermissionRequests();
        return true;
      } else {
        _showErrorSnackbar('${tr('failed_to_create_permission_request')}: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_creating_permission_request')}: $e');
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
    String? startDate,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.createLoanRequest(
        loanTypeId: loanTypeId,
        purpose: purpose,
        amount: amount,
        repaymentMonths: repaymentMonths,
        startDate: startDate,
      );

      if (response.success) {
        Get.snackbar(
          tr('success'),
          tr('loan_request_created_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLoanRequests();
        return true;
      } else {
        _showErrorSnackbar('${tr('failed_to_create_loan_request')}: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_creating_loan_request')}: $e');
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
    String? startDate,
  }) async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.updateLoanRequest(
        id: id,
        loanTypeId: loanTypeId,
        purpose: purpose,
        amount: amount,
        repaymentMonths: repaymentMonths,
        startDate: startDate,
      );

      if (response.success) {
        Get.snackbar(
          tr('success'),
          tr('loan_request_updated_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLoanRequests();
        return true;
      } else {
        _showErrorSnackbar('${tr('failed_to_update_loan_request')}: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_updating_loan_request')}: $e');
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
          tr('success'),
          tr('letter_request_created_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLetterRequests();
        return true;
      } else {
        _showErrorSnackbar('${tr('failed_to_create_letter_request')}: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_creating_letter_request')}: $e');
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
          tr('success'),
          tr('letter_request_updated_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLetterRequests();
        return true;
      } else {
        _showErrorSnackbar('${tr('failed_to_update_letter_request')}: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_updating_letter_request')}: $e');
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
          tr('success'),
          tr('leave_request_updated_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadLeaveRequests();
        return true;
      } else {
        _showErrorSnackbar('${tr('failed_to_update_leave_request')}: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_updating_leave_request')}: $e');
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
          tr('success'),
          tr('permission_request_updated_successfully'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        loadPermissionRequests();
        return true;
      } else {
        _showErrorSnackbar('${tr('failed_to_update_permission_request')}: ${response.message}');
        return false;
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_updating_permission_request')}: $e');
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
      tr('error'),
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
        _showErrorSnackbar('${tr('failed_to_load_more_leave_requests')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_more_leave_requests')}: $e');
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
        _showErrorSnackbar('${tr('failed_to_load_more_permission_requests')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_more_permission_requests')}: $e');
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
        _showErrorSnackbar('${tr('failed_to_load_more_loan_requests')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_more_loan_requests')}: $e');
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
        _showErrorSnackbar('${tr('failed_to_load_more_letter_requests')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_loading_more_letter_requests')}: $e');
    } finally {
      isLoadingMoreLetter.value = false;
    }
  }
}