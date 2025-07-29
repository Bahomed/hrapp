import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/data/remote/response/approval_request_response.dart';
import 'package:injazat_hr_app/repository/requestrepository.dart';
import 'package:injazat_hr_app/services/theme_service.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';

class ApprovalController extends GetxController {
  final RequestRepository _requestRepository = RequestRepository();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxString selectedFilter = 'all'.obs;

  // All requests from API
  final RxList<ApprovalRequest> allRequests = <ApprovalRequest>[].obs;
  
  // Filtered lists for display by request type
  final RxList<ApprovalRequest> leaveRequests = <ApprovalRequest>[].obs;
  final RxList<ApprovalRequest> permissionRequests = <ApprovalRequest>[].obs;
  final RxList<ApprovalRequest> loanRequests = <ApprovalRequest>[].obs;
  final RxList<ApprovalRequest> letterRequests = <ApprovalRequest>[].obs;

  // Filter configuration
  List<Map<String, dynamic>> get filters => [
    {'name': tr('all'), 'key': 'all', 'color': getFilterColor('all')},
    {'name': tr('leave'), 'key': 'Leave', 'color': getFilterColor('leave')},
    {'name': tr('permission'), 'key': 'Permission', 'color': getFilterColor('permission')},
    {'name': tr('loan'), 'key': 'Loan', 'color': getFilterColor('loan')},
    {'name': tr('letter'), 'key': 'Letter', 'color': getFilterColor('letter')},
  ];

  @override
  void onInit() {
    super.onInit();
    loadPendingRequests();
  }

  // Load all pending requests for approval
  Future<void> loadPendingRequests() async {
    try {
      isLoading.value = true;
      final response = await _requestRepository.getDashboardEmployeeRequests();

      if (response.statusCode == 200) {
        allRequests.value = response.userRequests;
        _applyCurrentFilter();
      } else {
        _showErrorSnackbar('Failed to load pending requests: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading pending requests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filter methods
  void changeFilter(String filterKey) {
    selectedFilter.value = filterKey;
    _applyCurrentFilter();
  }

  void _applyCurrentFilter() {
    final filter = selectedFilter.value;
    
    if (filter == 'all') {
      // Separate all requests by type
      leaveRequests.value = allRequests.where((r) => r.requestType == 'Leave').toList();
      permissionRequests.value = allRequests.where((r) => r.requestType == 'Permission').toList();
      loanRequests.value = allRequests.where((r) => r.requestType == 'Loan').toList();
      letterRequests.value = allRequests.where((r) => r.requestType == 'Letter').toList();
    } else {
      // Filter by specific request type
      leaveRequests.value = filter == 'Leave' ? allRequests.where((r) => r.requestType == 'Leave').toList() : [];
      permissionRequests.value = filter == 'Permission' ? allRequests.where((r) => r.requestType == 'Permission').toList() : [];
      loanRequests.value = filter == 'Loan' ? allRequests.where((r) => r.requestType == 'Loan').toList() : [];
      letterRequests.value = filter == 'Letter' ? allRequests.where((r) => r.requestType == 'Letter').toList() : [];
    }
  }

  // Approve request
  Future<void> approveRequest(ApprovalRequest request) async {
    await _updateRequestStatus(request, 'approved');
  }

  // Reject request
  Future<void> rejectRequest(ApprovalRequest request) async {
    await _updateRequestStatus(request, 'rejected');
  }

  // Generic method to update request status
  Future<void> _updateRequestStatus(ApprovalRequest request, String status) async {
    try {
      isLoading.value = true;
      
      final response = await _requestRepository.updateRequestStatus(
        requestId: request.id,
        status: status,
      );

      if (response.success) {
        Get.snackbar(
          tr('success'),
          'Request ${status.toLowerCase()} successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Remove from local list and refresh
        allRequests.removeWhere((r) => r.id == request.id);
        _applyCurrentFilter();
      } else {
        _showErrorSnackbar('Failed to update request: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error updating request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Show approval confirmation dialog
  void showApprovalDialog(ApprovalRequest request) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr('approval')),
        content: Text('Approve ${request.requestType.toLowerCase()} request for ${request.employeeName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(tr('cancel'), style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              approveRequest(request);
            },
            child: Text(tr('approved'), style: TextStyle(color: ThemeService.instance.getSuccessColor())),
          ),
        ],
      ),
    );
  }

  // Show rejection confirmation dialog
  void showRejectionDialog(ApprovalRequest request) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reject Request'),
        content: Text('Reject ${request.requestType.toLowerCase()} request for ${request.employeeName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(tr('cancel'), style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              rejectRequest(request);
            },
            child: Text(tr('rejected'), style: TextStyle(color: ThemeService.instance.getErrorColor())),
          ),
        ],
      ),
    );
  }

  // View request details
  void viewRequestDetails(ApprovalRequest request) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${request.requestType} Request Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Employee', request.employeeName),
              _buildDetailRow('Employee No', request.employeeNo),
              _buildDetailRow('Request Type', request.requestType),
              if (request.leaveType != null) _buildDetailRow('Leave Type', request.leaveType!),
              _buildDetailRow('Request Date', request.requestDateG),
              _buildDetailRow('Request Number', request.requestNumber),
              if (request.positionName != null) _buildDetailRow('Position', request.positionName!),
              if (request.departmentName != null) _buildDetailRow('Department', request.departmentName!),
              if (request.nationality != null) _buildDetailRow('Nationality', request.nationality!),
              _buildDetailRow('Status', request.requestStatus),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(tr('close')),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              showRejectionDialog(request);
            },
            child: Text(tr('rejected'), style: TextStyle(color: ThemeService.instance.getErrorColor())),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              showApprovalDialog(request);
            },
            child: Text(tr('approved'), style: TextStyle(color: ThemeService.instance.getSuccessColor())),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: ThemeService.instance.getTextPrimaryColor(),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Refresh all data
  Future<void> refreshRequests() async {
    await loadPendingRequests();
  }

  // Helper methods
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

  Color getFilterColor(String filter) {
    final themeService = ThemeService.instance;
    switch (filter.toLowerCase()) {
      case 'all':
        return themeService.getActionColor('requests');
      case 'leave':
        return themeService.getActionColor('schedule');
      case 'permission':
        return themeService.getActionColor('profile');
      case 'loan':
        return themeService.getSuccessColor();
      case 'letter':
        return themeService.getActionColor('documents');
      default:
        return themeService.getTextSecondaryColor();
    }
  }

  IconData getFilterIcon(String filterKey) {
    switch (filterKey.toLowerCase()) {
      case 'all':
        return Icons.list;
      case 'leave':
        return Icons.calendar_today;
      case 'permission':
        return Icons.badge_outlined;
      case 'loan':
        return Icons.account_balance_wallet;
      case 'letter':
        return Icons.description;
      default:
        return Icons.circle;
    }
  }

  // Get counts for each request type
  int get leaveRequestCount => leaveRequests.length;
  int get permissionRequestCount => permissionRequests.length;
  int get loanRequestCount => loanRequests.length;
  int get letterRequestCount => letterRequests.length;

  int get totalPendingCount => allRequests.length;
  
  // Get request type display name
  String getRequestTypeDisplayName(String requestType) {
    switch (requestType) {
      case 'Leave':
        return tr('leave_request');
      case 'Permission':
        return tr('permission_request');
      case 'Loan':
        return tr('loan_request');
      case 'Letter':
        return tr('letter_request');
      default:
        return requestType;
    }
  }
}