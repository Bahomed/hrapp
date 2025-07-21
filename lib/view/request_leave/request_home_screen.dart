
// File: lib/view/request_home/request_home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/app_theme.dart';
import 'package:injazat_hr_app/view/request_leave/request_controller.dart';
import 'package:injazat_hr_app/view/request_leave/widgets/request_widgets.dart';
import '../../services/theme_service.dart';

class RequestHomeScreen extends StatelessWidget {
  const RequestHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RequestController());
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr('requests'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Container(
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // Filter Buttons
                _buildFilterButtons(context, controller),
                const SizedBox(height: 15),
                // Tab Bar
               _buildTabBar(context, controller),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildLeaveRequestsTab(context, controller),
          _buildPermitRequestsTab(context, controller),
          _buildLoanRequestsTab(context, controller),
          _buildLetterRequestsTab(context, controller),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: controller.showRequestTypeDialog,
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            icon: const Icon(Icons.add, color: Colors.white, size: 24),
            label: Text(
              tr('create_request'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons(BuildContext context, RequestController controller) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
        children: controller.filters.map((filter) {
          final filterName = filter['name'] as String;
          final filterColor = filter['color'] as Color;
          final isSelected = controller.selectedFilter.value == filterName;

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeFilter(filterName),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? filterColor : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? filterColor : Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: filterColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        controller.getFilterIcon(filterName),
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        filterName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : filterColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildTabBar(BuildContext context, RequestController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Obx(() => TabBar(
        controller: controller.tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        isScrollable: true,
        tabs: [
          Tab(
            text: 'Leave (${controller.leaveRequestCount})',
          ),
          Tab(
            text: 'Permission (${controller.permissionRequestCount})',
          ),
          Tab(
            text: 'Loan (${controller.loanRequestCount})',
          ),
          Tab(
            text: 'Letter (${controller.letterRequestCount})',
          ),
        ],
      )),
    );
  }

  Widget _buildLeaveRequestsTab(BuildContext context, RequestController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        );
      }

      if (controller.leaveRequests.isEmpty) {
        return _buildEmptyState(
          context: context,
          icon: Icons.calendar_today,
          title: 'No Leave Requests',
          subtitle: 'You haven\'t made any leave requests yet.',
          color: AppTheme.getActionColor('requests'),
          onTap: controller.createLeaveRequest,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshRequests,
        color: Theme.of(context).primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: controller.leaveRequests.length + (controller.hasMoreDataLeave.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.leaveRequests.length) {
              return LoadMoreButton(
                onPressed: controller.loadMoreLeaveRequests,
                isLoading: controller.isLoadingMoreLeave.value,
                loadedYears: controller.loadedYearsLeave,
              );
            }
            final request = controller.leaveRequests[index];
            return LeaveRequestCard(request: request);
          },
        ),
      );
    });
  }

  Widget _buildPermitRequestsTab(BuildContext context, RequestController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        );
      }

      if (controller.permissionRequests.isEmpty) {
        return _buildEmptyState(
          context: context,
          icon: Icons.badge_outlined,
          title: 'No Permit Requests',
          subtitle: 'You haven\'t made any permit requests yet.',
          color: AppTheme.getActionColor('profile'),
          onTap: controller.createPermissionRequest,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshRequests,
        color: Theme.of(context).primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: controller.permissionRequests.length + (controller.hasMoreDataPermission.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.permissionRequests.length) {
              return LoadMoreButton(
                onPressed: controller.loadMorePermissionRequests,
                isLoading: controller.isLoadingMorePermission.value,
                loadedYears: controller.loadedYearsPermission,
              );
            }
            final request = controller.permissionRequests[index];
            return PermissionRequestCard(request: request);
          },
        ),
      );
    });
  }

  Widget _buildLoanRequestsTab(BuildContext context, RequestController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        );
      }

      if (controller.loanRequests.isEmpty) {
        return _buildEmptyState(
          context: context,
          icon: Icons.account_balance_wallet,
          title: 'No Loan Requests',
          subtitle: 'You haven\'t made any loan requests yet.',
          color: AppTheme.successColor,
          onTap: controller.createLoanRequest,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshRequests,
        color: Theme.of(context).primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: controller.loanRequests.length + (controller.hasMoreDataLoan.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.loanRequests.length) {
              return LoadMoreButton(
                onPressed: controller.loadMoreLoanRequests,
                isLoading: controller.isLoadingMoreLoan.value,
                loadedYears: controller.loadedYearsLoan,
              );
            }
            final request = controller.loanRequests[index];
            return LoanRequestCard(request: request);
          },
        ),
      );
    });
  }

  Widget _buildLetterRequestsTab(BuildContext context, RequestController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        );
      }

      if (controller.letterRequests.isEmpty) {
        return _buildEmptyState(
          context: context,
          icon: Icons.description,
          title: 'No Letter Requests',
          subtitle: 'You haven\'t made any letter requests yet.',
          color: ThemeService.instance.getActionColor('documents'),
          onTap: controller.createLetterRequest,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshRequests,
        color: Theme.of(context).primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: controller.letterRequests.length + (controller.hasMoreDataLetter.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.letterRequests.length) {
              return LoadMoreButton(
                onPressed: controller.loadMoreLetterRequests,
                isLoading: controller.isLoadingMoreLetter.value,
                loadedYears: controller.loadedYearsLetter,
              );
            }
            final request = controller.letterRequests[index];
            return LetterRequestCard(request: request);
          },
        ),
      );
    });
  }

  Widget _buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    final themeService = ThemeService.instance;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: color.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: ThemeService.instance.getTextPrimaryColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (onTap != null)
              ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Create Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}