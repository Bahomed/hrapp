import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/app_theme.dart';
import 'package:co.injazathr.injazathr/view/request_leave/request_controller.dart';
import 'package:co.injazathr.injazathr/view/request_leave/widgets/request_widgets.dart';
import 'package:co.injazathr.injazathr/view/request_leave/my_request_models.dart';
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
          onPressed: () => Navigator.of(context).pop(),
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
                _buildFilterButtons(context, controller),
                const SizedBox(height: 15),
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
          _buildMissingPunchRequestsTab(context, controller),
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
          final filterKey = filter['key'] as String;
          final filterColor = filter['color'] as Color;
          final isSelected = controller.selectedFilter.value == filterKey;

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeFilter(filterKey),
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
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: filterColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        controller.getFilterIcon(filterKey),
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
          Tab(text: '${tr('leave')} (${controller.leaveRequestCount})'),
          Tab(text: '${tr('permission')} (${controller.permissionRequestCount})'),
          Tab(text: '${tr('loan')} (${controller.loanRequestCount})'),
          Tab(text: '${tr('letter')} (${controller.letterRequestCount})'),
          Tab(text: '${tr('missing_punch')} (${controller.missingPunchRequestCount})'),
        ],
      )),
    );
  }

  Widget _buildLeaveRequestsTab(BuildContext context, RequestController controller) =>
      _buildMyRequestsTab(
        context: context,
        controller: controller,
        list: controller.leaveRequests,
        type: MyRequestType.leave,
        icon: Icons.calendar_today,
        title: tr('no_leave_requests'),
        subtitle: tr('no_leave_requests_subtitle'),
        buttonText: tr('create_leave_request'),
        color: AppTheme.getActionColor('requests'),
        onCreate: controller.createLeaveRequest,
      );

  Widget _buildPermitRequestsTab(BuildContext context, RequestController controller) =>
      _buildMyRequestsTab(
        context: context,
        controller: controller,
        list: controller.permissionRequests,
        type: MyRequestType.permit,
        icon: Icons.badge_outlined,
        title: tr('no_permit_requests'),
        subtitle: tr('no_permit_requests_subtitle'),
        buttonText: tr('create_permission_request'),
        color: AppTheme.getActionColor('profile'),
        onCreate: controller.createPermissionRequest,
      );

  Widget _buildLoanRequestsTab(BuildContext context, RequestController controller) =>
      _buildMyRequestsTab(
        context: context,
        controller: controller,
        list: controller.loanRequests,
        type: MyRequestType.loan,
        icon: Icons.account_balance_wallet,
        title: tr('no_loan_requests'),
        subtitle: tr('no_loan_requests_subtitle'),
        buttonText: tr('create_loan_request'),
        color: AppTheme.successColor,
        onCreate: controller.createLoanRequest,
      );

  Widget _buildLetterRequestsTab(BuildContext context, RequestController controller) =>
      _buildMyRequestsTab(
        context: context,
        controller: controller,
        list: controller.letterRequests,
        type: MyRequestType.letter,
        icon: Icons.description,
        title: tr('no_letter_requests'),
        subtitle: tr('no_letter_requests_subtitle'),
        buttonText: tr('create_letter_request'),
        color: ThemeService.instance.getActionColor('documents'),
        onCreate: controller.createLetterRequest,
      );

  Widget _buildMissingPunchRequestsTab(BuildContext context, RequestController controller) =>
      _buildMyRequestsTab(
        context: context,
        controller: controller,
        list: controller.missingPunchRequests,
        type: MyRequestType.missingPunch,
        icon: Icons.fingerprint,
        title: tr('no_missing_punch_requests'),
        subtitle: tr('no_missing_punch_requests_subtitle'),
        buttonText: tr('create_missing_punch_request'),
        color: const Color(0xFF6C5CE7),
        onCreate: controller.createMissingPunchRequest,
      );

  /// One tab fed by GET my/requests. The create button in the empty state is
  /// shown only when `types` (my/requests/options) allows [type].
  Widget _buildMyRequestsTab({
    required BuildContext context,
    required RequestController controller,
    required RxList<MyRequestItem> list,
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required Color color,
    required VoidCallback onCreate,
  }) {
    return Obx(() {
      if (controller.isLoading.value && list.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshRequests,
        color: Theme.of(context).primaryColor,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: list.isEmpty ? 1 : list.length,
          itemBuilder: (context, index) {
            if (list.isEmpty) {
              return _buildEmptyState(
                context: context,
                icon: icon,
                title: title,
                subtitle: subtitle,
                buttonText: buttonText,
                color: color,
                onTap: controller.isTypeAllowed(type) ? onCreate : null,
              );
            }
            return MyRequestCard(request: list[index]);
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
    required String buttonText,
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
                label:  Text(
                  buttonText,
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