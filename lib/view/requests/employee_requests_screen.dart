import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../services/theme_service.dart';
import '../../utils/responsive_utils.dart';
import 'employee_requests_controller.dart';

class EmployeeRequestsScreen extends StatelessWidget {
  final int employeeId;
  
  const EmployeeRequestsScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmployeeRequestsController());
    final themeService = ThemeService.instance;
    
    // Load employee requests data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadEmployeeRequests(employeeId, refresh: true);
    });

    return Scaffold(
      backgroundColor: themeService.getBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr('employee_requests'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: themeService.getTextPrimaryColor()),
            onPressed: () => controller.refreshData(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          _buildFiltersSection(context, controller, themeService),
          
          // Requests Table
          Expanded(
            child: _buildRequestsTable(context, controller, themeService),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context, EmployeeRequestsController controller, ThemeService themeService) {
    return Container(
      color: themeService.getCardColor(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: themeService.getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeService.getDividerColor()),
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              decoration: InputDecoration(
                hintText: tr('search_by_request_number'),
                hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
                prefixIcon: Icon(Icons.search, color: themeService.getTextSecondaryColor()),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: TextStyle(color: themeService.getTextPrimaryColor()),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Type Filters
          Row(
            children: [
              Text(
                tr('type') + ':',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 35,
                  child: Obx(() => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.typeFilters.length,
                    itemBuilder: (context, index) {
                      final filter = controller.typeFilters[index];
                      final isSelected = controller.selectedTypeFilter.value == filter['key'];
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Obx(() {
                          final isSelectedNow = controller.selectedTypeFilter.value == filter['key'];
                          return GestureDetector(
                            onTap: () {
                              print('Tapping filter: ${filter['key']}');
                              controller.setTypeFilter(filter['key']);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelectedNow ? filter['color'] : themeService.getBackgroundColor(),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: filter['color'],
                                  width: isSelectedNow ? 0 : 1,
                                ),
                              ),
                              child: Text(
                                filter['name'],
                                style: TextStyle(
                                  color: isSelectedNow ? Colors.white : filter['color'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  )),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Status Filters
          Row(
            children: [
              Text(
                tr('status') + ':',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 35,
                  child: Obx(() => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.statusFilters.length,
                    itemBuilder: (context, index) {
                      final filter = controller.statusFilters[index];
                      final isSelected = controller.selectedStatusFilter.value == filter['key'];
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Obx(() {
                          final isSelectedNow = controller.selectedStatusFilter.value == filter['key'];
                          return GestureDetector(
                            onTap: () {
                              print('Tapping status filter: ${filter['key']}');
                              controller.setStatusFilter(filter['key']);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelectedNow ? filter['color'] : themeService.getBackgroundColor(),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: filter['color'],
                                  width: isSelectedNow ? 0 : 1,
                                ),
                              ),
                              child: Text(
                                filter['name'],
                                style: TextStyle(
                                  color: isSelectedNow ? Colors.white : filter['color'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsTable(BuildContext context, EmployeeRequestsController controller, ThemeService themeService) {
    return Obx(() {
      if (controller.isLoading.value && controller.requests.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: themeService.getPrimaryColor(),
          ),
        );
      }

      if (controller.requests.isEmpty) {
        return _buildEmptyState(themeService);
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: themeService.getPrimaryColor(),
        child: Column(
          children: [
            // Table Header
            Container(
              color: themeService.getCardColor(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    '${tr('showing')} ${controller.requests.length} ${tr('of')} ${controller.totalRequests.value} ${tr('requests')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeService.getTextSecondaryColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (controller.selectedTypeFilter.value != 'all' || controller.selectedStatusFilter.value != 'all' || controller.searchQuery.value.isNotEmpty)
                    TextButton(
                      onPressed: controller.clearFilters,
                      child: Text(
                        tr('clear_filters'),
                        style: TextStyle(
                          color: themeService.getPrimaryColor(),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Table Content
            Expanded(
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.requests.length + (controller.hasMoreData.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= controller.requests.length) {
                    return _buildLoadMoreIndicator(controller, themeService);
                  }
                  
                  final request = controller.requests[index];
                  return _buildRequestCard(context, request, controller, themeService);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request, EmployeeRequestsController controller, ThemeService themeService) {
    final requestType = request['request_type'] ?? '';
    final status = request['request_status'] ?? '';
    final requestNumber = request['request_number']?.toString() ?? '';
    final leaveType = request['leave_type'] ?? '';
    final requestDate = controller.formatDate(request['request_date_g']);
    final startDate = controller.formatDate(request['start_date_g']);
    final noOfDays = request['no_of_days']?.toString() ?? '';
    final requestBcs = request['request_bcs'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: themeService.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Request Number
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(int.parse(controller.getRequestTypeColor(requestType))).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Color(int.parse(controller.getRequestTypeColor(requestType))),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${tr('req#')} $requestNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(int.parse(controller.getRequestTypeColor(requestType))),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(int.parse(controller.getStatusColor(status))),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Request Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(tr('type'), requestType, themeService),
                      const SizedBox(height: 6),
                      _buildDetailRow(tr('leave_type'), leaveType, themeService),
                      const SizedBox(height: 6),
                      _buildDetailRow(tr('request_date'), requestDate, themeService),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(tr('start_date'), startDate, themeService),
                      const SizedBox(height: 6),
                      _buildDetailRow(tr('days'), noOfDays, themeService),
                      const SizedBox(height: 6),
                      _buildDetailRow(tr('approved_by'), requestBcs, themeService),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeService themeService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: themeService.getTextSecondaryColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isNotEmpty ? value : tr('n_a'),
          style: TextStyle(
            fontSize: 13,
            color: themeService.getTextPrimaryColor(),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator(EmployeeRequestsController controller, ThemeService themeService) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(
              color: themeService.getPrimaryColor(),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildEmptyState(ThemeService themeService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: themeService.getTextSecondaryColor(),
          ),
          const SizedBox(height: 16),
          Text(
            tr('no_requests_found'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeService.getTextPrimaryColor(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('no_employee_requests_message'),
            style: TextStyle(
              fontSize: 14,
              color: themeService.getTextSecondaryColor(),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}