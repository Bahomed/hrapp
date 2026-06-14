import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/data/remote/response/approval_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/employee_dropdown_response.dart';
import 'package:co.injazathr.injazathr/repository/requestrepository.dart';
import 'package:co.injazathr.injazathr/repository/employees_repository.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/widgets/saudi_riyal_display.dart';

class ApprovalController extends GetxController {
  final RequestRepository _requestRepository = RequestRepository();
  final EmployeesRepository _employeesRepository = EmployeesRepository();

  // Leave balances: employmentId → vacation_balance
  final RxMap<int, double> leaveBalances = <int, double>{}.obs;
  final RxSet<int> loadingBalances = <int>{}.obs;

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
  final RxList<ApprovalRequest> overtimeRequests = <ApprovalRequest>[].obs;

  // Filter configuration
  List<Map<String, dynamic>> get filters => [
    {'name': tr('all'), 'key': 'all', 'color': getFilterColor('all')},
    {'name': tr('leave'), 'key': 'Leave', 'color': getFilterColor('leave')},
    {'name': tr('permission'), 'key': 'Permit', 'color': getFilterColor('permission')},
    {'name': tr('loan'), 'key': 'Loan', 'color': getFilterColor('loan')},
    {'name': tr('letter'), 'key': 'Letter', 'color': getFilterColor('letter')},
    {'name': tr('overtime'), 'key': 'Overtime', 'color': getFilterColor('overtime')},
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
      permissionRequests.value = allRequests.where((r) => r.requestType == 'Permit').toList();
      loanRequests.value = allRequests.where((r) => r.requestType == 'Loan').toList();
      letterRequests.value = allRequests.where((r) => r.requestType == 'Letter').toList();
      overtimeRequests.value = allRequests.where((r) => r.requestType == 'Overtime').toList();
    } else {
      // Filter by specific request type
      leaveRequests.value = filter == 'Leave' ? allRequests.where((r) => r.requestType == 'Leave').toList() : [];
      permissionRequests.value = filter == 'Permit' ? allRequests.where((r) => r.requestType == 'Permit').toList() : [];
      loanRequests.value = filter == 'Loan' ? allRequests.where((r) => r.requestType == 'Loan').toList() : [];
      letterRequests.value = filter == 'Letter' ? allRequests.where((r) => r.requestType == 'Letter').toList() : [];
      overtimeRequests.value = filter == 'Overtime' ? allRequests.where((r) => r.requestType == 'Overtime').toList() : [];
    }

    // Fetch leave balances for all visible leave requests
    for (final r in leaveRequests) {
      _fetchLeaveBalanceIfNeeded(r.employmentId);
    }
  }

  void _fetchLeaveBalanceIfNeeded(int employmentId) {
    if (leaveBalances.containsKey(employmentId)) return;
    if (loadingBalances.contains(employmentId)) return;
    loadingBalances.add(employmentId);
    _employeesRepository.getLeaveBalance(employmentId).then((response) {
      leaveBalances[employmentId] = response.vacationBalance;
    }).catchError((_) {
      // silently ignore — balance just won't show
    }).whenComplete(() {
      loadingBalances.remove(employmentId);
    });
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
          response.message,
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
    if (request.requestType.toLowerCase() == 'leave') {
      _showLeaveApprovalDialog(request);
    } else {
      _showSimpleApprovalDialog(request);
    }
  }

  // Show enhanced approval dialog for leave requests
  void _showLeaveApprovalDialog(ApprovalRequest request) {
    final TextEditingController remarksController = TextEditingController();
    final TextEditingController searchController = TextEditingController();

    // State lives in the method closure — stable across StatefulBuilder rebuilds
    List<EmployeeDropdownItem> employees = [];
    EmployeeDropdownItem? selectedEmployee;
    bool isLoadingEmployees = true;
    bool isDropdownOpen = false;
    List<EmployeeDropdownItem> filteredEmployees = [];
    bool _loadStarted = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          if (!_loadStarted) {
            _loadStarted = true;
            _requestRepository.getEmployeesDropdown().then((response) {
              if (response.statusCode == 200) {
                employees = response.data;
                filteredEmployees = List.from(response.data);
              }
              isLoadingEmployees = false;
              setDialogState(() {});
            }).catchError((_) {
              isLoadingEmployees = false;
              setDialogState(() {});
            });
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(tr('approval')),
            content: SizedBox(
              width: Get.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tr('approve')} ${tr('leave_request')} ${tr('for')}:'),
                    const SizedBox(height: 8),
                    Text(request.employeeName,
                        style: TextStyle(fontWeight: FontWeight.w600,
                            color: ThemeService.instance.getTextPrimaryColor())),
                    const SizedBox(height: 20),
                    Text(tr('replacement_employee'),
                        style: TextStyle(fontWeight: FontWeight.w600,
                            color: ThemeService.instance.getTextPrimaryColor())),
                    const SizedBox(height: 8),
                    if (isLoadingEmployees)
                      const Center(child: CircularProgressIndicator())
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => setDialogState(() => isDropdownOpen = !isDropdownOpen),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: ThemeService.instance.getDividerColor()),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedEmployee?.employeeName ?? tr('select_replacement'),
                                      style: TextStyle(
                                        color: selectedEmployee != null
                                            ? ThemeService.instance.getTextPrimaryColor()
                                            : ThemeService.instance.getTextSecondaryColor(),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: ThemeService.instance.getTextSecondaryColor()),
                                ],
                              ),
                            ),
                          ),
                          if (isDropdownOpen)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                border: Border.all(color: ThemeService.instance.getDividerColor()),
                                borderRadius: BorderRadius.circular(8),
                                color: ThemeService.instance.getCardColor(),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        hintText: tr('search'),
                                        prefixIcon: const Icon(Icons.search),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(6)),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        isDense: true,
                                      ),
                                      onChanged: (query) => setDialogState(() {
                                        filteredEmployees = query.isEmpty
                                            ? employees
                                            : employees
                                                .where((e) => e.employeeName
                                                    .toLowerCase()
                                                    .contains(query.toLowerCase()))
                                                .toList();
                                      }),
                                    ),
                                  ),
                                  Flexible(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: filteredEmployees.length,
                                      itemBuilder: (_, index) {
                                        final emp = filteredEmployees[index];
                                        return ListTile(
                                          dense: true,
                                          title: Text(emp.employeeName,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: ThemeService.instance.getTextPrimaryColor())),
                                          onTap: () => setDialogState(() {
                                            selectedEmployee = emp;
                                            isDropdownOpen = false;
                                            searchController.clear();
                                            filteredEmployees = employees;
                                          }),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Text('${tr('remarks')} (${tr('optional')})',
                        style: TextStyle(fontWeight: FontWeight.w600,
                            color: ThemeService.instance.getTextPrimaryColor())),
                    const SizedBox(height: 8),
                    TextField(
                      controller: remarksController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: tr('enter_remarks'),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                child: Text(tr('cancel'),
                    style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
              ),
              TextButton(
                onPressed: () {
                  final empId = selectedEmployee?.id;
                  final remarks = remarksController.text.trim();
                  Navigator.of(context, rootNavigator: true).pop();
                  _approveLeaveRequest(request, empId, remarks);
                },
                child: Text(tr('approved'),
                    style: TextStyle(color: ThemeService.instance.getSuccessColor())),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  // Show simple approval dialog for non-leave requests (with remarks only)
  void _showSimpleApprovalDialog(ApprovalRequest request) {
    final TextEditingController remarksController = TextEditingController();

    Get.dialog(
      Builder(builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr('approval')),
        content: SizedBox(
          width: Get.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Approve ${request.requestType.toLowerCase()} request for ${request.employeeName}?'),
                const SizedBox(height: 20),
                Text(
                  '${tr('remarks')} (${tr('optional')})',
                  style: TextStyle(fontWeight: FontWeight.w600,
                      color: ThemeService.instance.getTextPrimaryColor()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: tr('enter_remarks'),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(tr('cancel'), style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
          ),
          TextButton(
            onPressed: () {
              final remarks = remarksController.text.trim();
              Navigator.of(context, rootNavigator: true).pop();
              _approveOtherRequest(request, remarks);
            },
            child: Text(tr('approved'), style: TextStyle(color: ThemeService.instance.getSuccessColor())),
          ),
        ],
      )),
      barrierDismissible: false,
    );
  }

  // Show rejection confirmation dialog with remarks
  void showRejectionDialog(ApprovalRequest request) {
    final TextEditingController remarksController = TextEditingController();

    Get.dialog(
      Builder(builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tr('reject_request')),
        content: SizedBox(
          width: Get.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reject ${request.requestType.toLowerCase()} request for ${request.employeeName}?'),
                const SizedBox(height: 20),
                Text(
                  '${tr('remarks')} (${tr('optional')})',
                  style: TextStyle(fontWeight: FontWeight.w600,
                      color: ThemeService.instance.getTextPrimaryColor()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: remarksController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    hintText: tr('enter_remarks'),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(tr('cancel'), style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
          ),
          TextButton(
            onPressed: () {
              final remarks = remarksController.text.trim();
              Navigator.of(context, rootNavigator: true).pop();
              _rejectRequestWithRemarks(request, remarks);
            },
            child: Text(tr('reject'), style: TextStyle(color: ThemeService.instance.getErrorColor())),
          ),
        ],
      )),
      barrierDismissible: false,
    );
  }

  // View request details
  void viewRequestDetails(ApprovalRequest request) {
    if (request.requestType == 'Leave') {
      _fetchLeaveBalanceIfNeeded(request.employmentId);
    }
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ThemeService.instance.getSurfaceColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemeService.instance.getDividerColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request.requestType} ${tr('request_details')}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: ThemeService.instance.getTextPrimaryColor(),
                        ),
                      ),
                      Text(
                        request.employeeName,
                        style: TextStyle(
                          fontSize: 16,
                          color: ThemeService.instance.getTextSecondaryColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRequestStatusChip(request.requestStatus),
              ],
            ),

            const SizedBox(height: 30),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    // Leave Balance (only for leave requests)
                    if (request.requestType == 'Leave')
                      Obx(() {
                        final isLoadingBal = loadingBalances.contains(request.employmentId);
                        final balance = leaveBalances[request.employmentId];
                        if (isLoadingBal) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                const SizedBox(width: 8),
                                Text(tr('loading'), style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
                              ],
                            ),
                          );
                        }
                        if (balance == null) return const SizedBox.shrink();
                        final display = balance % 1 == 0 ? balance.toInt().toString() : balance.toStringAsFixed(2);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: ThemeService.instance.getActionColor('leave').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: ThemeService.instance.getActionColor('leave').withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, size: 16, color: ThemeService.instance.getActionColor('leave')),
                              const SizedBox(width: 8),
                              Text(
                                '${tr('leave_balance')}: $display ${tr('days')}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: ThemeService.instance.getActionColor('leave'),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    // Combined Request Information Section
                    _buildCombinedRequestSection(request),
                    // Previous Approvers Section
                    if (request.prevApprovers.isNotEmpty) ...[
                      _buildPrevApproversSection(request.prevApprovers),
                      const SizedBox(height: 24),
                    ],
                    // Employee Information Section
                    _buildSection(
                      tr('employee_information'),
                      [
                        _buildDetailRow(tr('#_name'), request.employeeName),
                        if (request.positionName != null) _buildDetailRow(tr('position'), request.positionName!),
                        if (request.departmentName != null) _buildDetailRow(tr('department'), request.departmentName!),
                        if (request.sectionName != null) _buildDetailRow(tr('section'), request.sectionName!),
                        if (request.nationality != null) _buildDetailRow(tr('nationality'), request.nationality!),
                      ],
                    ),


                  ],
                ),
              ),
            ),

            // Action Buttons
            const SizedBox(height: 20),
            Builder(builder: (ctx) => _buildActionButtons(request, ctx)),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildRequestStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = ThemeService.instance.getSuccessColor().withOpacity(0.1);
        textColor = ThemeService.instance.getSuccessColor();
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
      case 'for approval':
      case 'for-approval':
        backgroundColor = ThemeService.instance.getWarningColor().withOpacity(0.1);
        textColor = ThemeService.instance.getWarningColor();
        icon = Icons.schedule;
        break;
      case 'rejected':
        backgroundColor = ThemeService.instance.getErrorColor().withOpacity(0.1);
        textColor = ThemeService.instance.getErrorColor();
        icon = Icons.cancel_outlined;
        break;
      default:
        backgroundColor = ThemeService.instance.getTextSecondaryColor().withOpacity(0.1);
        textColor = ThemeService.instance.getTextSecondaryColor();
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            switch (status.toLowerCase()) {
              'for-approval' || 'for approval' || 'pending' => tr('for_approval'),
              'approved' => tr('approved'),
              'rejected' => tr('rejected'),
              _ => status,
            },
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeService.instance.getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeService.instance.getDividerColor(),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeService.instance.getTextPrimaryColor(),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Build combined request section (combines general info and specific details)
  Widget _buildCombinedRequestSection(ApprovalRequest request) {
    List<Widget> allDetails = [
      // General request information
      _buildDetailRow(tr('req#'), request.requestNumber),
      _buildDetailRow(tr('submitted'), _formatDateTime(request.requestDateG)),
    //  _buildDetailRow(tr('status'), request.requestStatus),
     // if (request.addBy != null && request.addBy!.isNotEmpty) _buildDetailRow(tr('added_by'), request.addBy!),
      ///if (request.requestBcs != null && request.requestBcs!.trim().isNotEmpty) _buildDetailRow(tr('approved_by'), request.requestBcs!.trim()),
    ];

    // Add request-specific details based on type
    switch (request.requestType.toLowerCase()) {
      case 'leave':
        if (request.leaveType != null) allDetails.add(_buildDetailRow(tr('type'), request.leaveType!));
        if (request.leaveStartDate != null) allDetails.add(_buildDetailRow(tr('start_date'), _formatDateTime(request.leaveStartDate!)));
        if (request.leaveEndDate != null) allDetails.add(_buildDetailRow(tr('end_date'), _formatDateTime(request.leaveEndDate!)));
        if (request.days != null && request.days! > 0) allDetails.add(_buildDetailRow(tr('days'), '${request.days}'));
        if (request.reason != null && request.reason!.isNotEmpty) allDetails.add(_buildDetailRow(tr('reason'), request.reason!));
        break;
      
      case 'loan':
        if (request.leaveType != null) allDetails.add(_buildDetailRow(tr('loan_type'), request.leaveType!));
        if (request.loanAmount != null && request.loanAmount != '0' && request.loanAmount != '0.00') {
          allDetails.add(_buildDetailRowWithWidget(
            tr('loan_amount'), 
            SaudiRiyalDisplay(
              amount: double.tryParse(request.loanAmount!) ?? 0.0,
              style: TextStyle(
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ));
        }
        if (request.loanRepaymentMonths != null && request.loanRepaymentMonths! > 0) {
          allDetails.add(_buildDetailRow(tr('instalment'), '${request.loanRepaymentMonths} ${tr('months')}'));
        }
        if (request.reason != null && request.reason!.isNotEmpty) allDetails.add(_buildDetailRow(tr('reason'), request.reason!));
        break;
      
      case 'permission':
      case 'permit':
        if (request.leaveType != null) allDetails.add(_buildDetailRow(tr('permission_type'), request.leaveType!));
        if (request.permitDate != null) allDetails.add(_buildDetailRow(tr('date'), _formatDateTime(request.permitDate!)));
        if (request.permitFrom != null && request.permitFrom!.isNotEmpty) allDetails.add(_buildDetailRow(tr('time'), '${ _formatTimeDisplay(request.permitFrom!)} ${tr('to')} ${ _formatTimeDisplay(request.permitTo ?? "")}'));
        if (request.reason != null && request.reason!.isNotEmpty) allDetails.add(_buildDetailRow(tr('reason'), request.reason!));
        break;
      
      case 'letter':
        if (request.leaveType != null) allDetails.add(_buildDetailRow(tr('letter_type'), request.leaveType!));
        if (request.reason != null && request.reason!.isNotEmpty) allDetails.add(_buildDetailRow(tr('reason'), request.reason!));
        break;

      case 'overtime':
        if (request.fromDate != null && request.fromDate!.isNotEmpty) allDetails.add(_buildDetailRow(tr('from_date'), _formatDateTime(request.fromDate!)));
        if (request.toDate != null && request.toDate!.isNotEmpty) allDetails.add(_buildDetailRow(tr('to_date'), _formatDateTime(request.toDate!)));
        if (request.totalOtHours != null) {
          final hoursDisplay = request.totalOtHours! % 1 == 0
              ? '${request.totalOtHours!.toInt()} ${tr('hrs')}'
              : '${request.totalOtHours!.toStringAsFixed(2)} ${tr('hrs')}';
          allDetails.add(_buildDetailRow(tr('total_ot_hours'), hoursDisplay));
        }
        if (request.reason != null && request.reason!.isNotEmpty) allDetails.add(_buildDetailRow(tr('reason'), request.reason!));
        break;
    }

    return Column(
      children: [
        _buildSection(
          tr('request_information'),
          allDetails,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPrevApproversSection(List<PrevApprover> approvers) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeService.instance.getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.instance.getDividerColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('previous_approvers'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ThemeService.instance.getTextPrimaryColor(),
            ),
          ),
          const SizedBox(height: 16),
          ...approvers.map((approver) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ThemeService.instance.getSuccessColor().withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${approver.level}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ThemeService.instance.getSuccessColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.check_circle, size: 16, color: ThemeService.instance.getSuccessColor()),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        approver.name,
                        style: TextStyle(
                          color: ThemeService.instance.getTextPrimaryColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ApprovalRequest request, BuildContext sheetContext) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await Future.delayed(const Duration(milliseconds: 300));
                  showRejectionDialog(request);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ThemeService.instance.getErrorColor()),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined, color: ThemeService.instance.getErrorColor()),
                    const SizedBox(width: 8),
                    Text(
                      tr('reject'),
                      style: TextStyle(
                        color: ThemeService.instance.getErrorColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await Future.delayed(const Duration(milliseconds: 300));
                  showApprovalDialog(request);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeService.instance.getSuccessColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      tr('approve'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(sheetContext).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: ThemeService.instance.getTextSecondaryColor()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              tr('close'),
              style: TextStyle(
                color: ThemeService.instance.getTextSecondaryColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build request-specific details section based on request type
  Widget _buildRequestSpecificSection(ApprovalRequest request) {
    List<Widget> specificDetails = [];

    switch (request.requestType.toLowerCase()) {
      case 'leave':
        specificDetails = [
          if (request.leaveStartDate != null) _buildDetailRow(tr('leave_start_date'), _formatDateTime(request.leaveStartDate!)),
          if (request.leaveEndDate != null) _buildDetailRow(tr('leave_end_date'), _formatDateTime(request.leaveEndDate!)),
          if (request.days != null && request.days! > 0) _buildDetailRow(tr('days'), '${request.days}'),
          if (request.reason != null && request.reason!.isNotEmpty) _buildDetailRow(tr('reason'), request.reason!),
        ];
        break;
      
      case 'loan':
        specificDetails = [
          if (request.loanAmount != null && request.loanAmount != '0' && request.loanAmount != '0.00') 
            _buildDetailRow(tr('loan_amount'), '${request.loanAmount} ${tr('sar')}'),
          if (request.loanRepaymentMonths != null && request.loanRepaymentMonths! > 0) 
            _buildDetailRow(tr('installment'), '${request.loanRepaymentMonths} ${tr('months')}'),
          if (request.reason != null && request.reason!.isNotEmpty) _buildDetailRow(tr('reason'), request.reason!),
        ];
        break;
      
      case 'permission':
      case 'permit':
        specificDetails = [
          if (request.permitDate != null) _buildDetailRow(tr('date'), _formatDateTime(request.permitDate!)),
          if (request.permitFrom != null && request.permitFrom!.isNotEmpty) _buildDetailRow(tr('time'),  _formatTimeDisplay(request.permitFrom!)),
          if (request.reason != null && request.reason!.isNotEmpty) _buildDetailRow(tr('reason'), request.reason!),
        ];
        break;
    }

    // Only show section if there are specific details to display
    if (specificDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSection(
      '${request.requestType} ${tr('specific_details')}',
      specificDetails,
    );
  }

  // Format datetime string for display
  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeString; // Return original string if parsing fails
    }
  }


  String _formatTimeDisplay(String timeString) {
    try {
      // Handle different time formats and remove seconds
      timeString = timeString.trim();

      // If it contains AM/PM (12-hour format)
      if (timeString.contains('AM') || timeString.contains('PM')) {
        final isAM = timeString.contains('AM');
        final timePart = timeString.replaceAll(RegExp(r'\s*(AM|PM)'), '');
        final parts = timePart.split(':');

        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          // Format as HH:MM AM/PM without seconds
          final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final formattedMinute = minute.toString().padLeft(2, '0');
          return '$formattedHour:$formattedMinute ${isAM ? 'AM' : 'PM'}';
        }
      } else {
        // 24-hour format or contains seconds
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          // Format as HH:MM in 24-hour format without seconds
          final formattedHour = hour.toString().padLeft(2, '0');
          final formattedMinute = minute.toString().padLeft(2, '0');
          return '$formattedHour:$formattedMinute';
        }
      }

      // If parsing fails, return original string
      return timeString;
    } catch (e) {
      // Return original string if any error occurs
      return timeString;
    }
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

  Widget _buildDetailRowWithWidget(String label, Widget valueWidget) {
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
            child: valueWidget,
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
      case 'overtime':
        return const Color(0xFFFF6B35);
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
      case 'overtime':
        return Icons.access_time_filled;
      default:
        return Icons.circle;
    }
  }

  // Get counts for each request type
  int get leaveRequestCount => leaveRequests.length;
  int get permissionRequestCount => permissionRequests.length;
  int get loanRequestCount => loanRequests.length;
  int get letterRequestCount => letterRequests.length;
  int get overtimeRequestCount => overtimeRequests.length;

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
      case 'Overtime':
        return tr('overtime_request');
      default:
        return requestType;
    }
  }

  // Load employees for dropdown
  Future<void> _loadEmployees(RxList<EmployeeDropdownItem> employees, RxBool isLoadingEmployees) async {
    try {
      isLoadingEmployees.value = true;
      final response = await _requestRepository.getEmployeesDropdown();
      
      if (response.statusCode == 200) {
        employees.value = response.data;
      } else {
        _showErrorSnackbar('Failed to load employees: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error loading employees: $e');
    } finally {
      isLoadingEmployees.value = false;
    }
  }

  // Approve leave request with employee and remarks
  Future<void> _approveLeaveRequest(ApprovalRequest request, int? replacementEmployeeId, String remarks) async {
    try {
      isLoading.value = true;

      final response = await _requestRepository.updateRequestStatus(
        requestId: request.id,
        status: 'approved',
        stepId: request.stepId,
        replacementEmployeeId: replacementEmployeeId,
        remarks: remarks.isNotEmpty ? remarks : null,
      );

      if (response.success) {
        Get.snackbar(
          tr('success'),
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Remove from local list and refresh
        allRequests.removeWhere((r) => r.id == request.id);
        _applyCurrentFilter();
      } else {
        _showErrorSnackbar('Failed to approve request: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error approving request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Approve other requests (Permission, Loan, Letter) with remarks only
  Future<void> _approveOtherRequest(ApprovalRequest request, String remarks) async {
    try {
      isLoading.value = true;

      final response = await _requestRepository.updateRequestStatus(
        requestId: request.id,
        status: 'approved',
        stepId: request.stepId,
        remarks: remarks.isNotEmpty ? remarks : null,
      );

      if (response.success) {
        Get.snackbar(
          tr('success'),
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Remove from local list and refresh
        allRequests.removeWhere((r) => r.id == request.id);
        _applyCurrentFilter();
      } else {
        _showErrorSnackbar('Failed to approve request: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error approving request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Reject request with remarks
  Future<void> _rejectRequestWithRemarks(ApprovalRequest request, String remarks) async {
    try {
      isLoading.value = true;

      final response = await _requestRepository.updateRequestStatus(
        requestId: request.id,
        status: 'rejected',
        stepId: request.stepId,
        remarks: remarks.isNotEmpty ? remarks : null,
      );

      if (response.success) {
        Get.snackbar(
          tr('success'),
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getSuccessColor(),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Remove from local list and refresh
        allRequests.removeWhere((r) => r.id == request.id);
        _applyCurrentFilter();
      } else {
        _showErrorSnackbar('Failed to reject request: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Error rejecting request: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Build searchable dropdown for employees
  Widget _buildSearchableDropdown(RxList<EmployeeDropdownItem> employees, Rx<EmployeeDropdownItem?> selectedEmployee) {
    final TextEditingController searchController = TextEditingController();
    final RxList<EmployeeDropdownItem> filteredEmployees = <EmployeeDropdownItem>[].obs;
    final RxBool isDropdownOpen = false.obs;

    // Initialize filtered list
    filteredEmployees.value = employees;

    void filterEmployees(String query) {
      if (query.isEmpty) {
        filteredEmployees.value = employees;
      } else {
        filteredEmployees.value = employees
            .where((employee) => 
                employee.employeeName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field that looks like a dropdown
        GestureDetector(
          onTap: () {
            isDropdownOpen.value = !isDropdownOpen.value;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ThemeService.instance.getDividerColor()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                    selectedEmployee.value?.employeeName ?? tr('select_replacement'),
                    style: TextStyle(
                      color: selectedEmployee.value != null 
                          ? ThemeService.instance.getTextPrimaryColor()
                          : ThemeService.instance.getTextSecondaryColor(),
                    ),
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: ThemeService.instance.getTextSecondaryColor(),
                ),
              ],
            ),
          ),
        ),
        
        // Dropdown list
        Obx(() => isDropdownOpen.value
            ? Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: ThemeService.instance.getDividerColor()),
                  borderRadius: BorderRadius.circular(8),
                  color: ThemeService.instance.getCardColor(),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search field
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: tr('search'),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        onChanged: filterEmployees,
                      ),
                    ),
                    
                    // Employee list
                    Flexible(
                      child: Obx(() => ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = filteredEmployees[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              employee.employeeName,
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeService.instance.getTextPrimaryColor(),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              selectedEmployee.value = employee;
                              isDropdownOpen.value = false;
                              searchController.clear();
                              filteredEmployees.value = employees;
                            },
                          );
                        },
                      )),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
        ),
      ],
    );
  }
}