import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/compensation/portal_ui.dart';

/// Leave balances per type + leave history (`GET my/leaves`).
class LeaveBalanceController extends GetxController {
  final MyRepository _repo = MyRepository();

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final balances = <Map<String, dynamic>>[].obs;
  final leaves = <Map<String, dynamic>>[].obs;

  /// `on_leave` may be a flag or an object describing the current leave.
  final onLeave = Rxn<dynamic>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final r = await _repo.leaves();
    if (!r.ok) {
      errorMessage.value = r.displayMessage(tr('something_went_wrong', fallback: 'Something went wrong'));
      isLoading.value = false;
      return;
    }
    final body = r.json['data'] is Map ? PortalUi.map(r.json['data']) : r.json;
    balances.assignAll(PortalUi.list(body['balances']));
    leaves.assignAll(PortalUi.list(body['leaves']));
    onLeave.value = body['on_leave'];
    isLoading.value = false;
  }
}

class LeaveBalanceScreen extends StatelessWidget {
  const LeaveBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LeaveBalanceController());
    final theme = PortalUi.theme;

    return Scaffold(
      backgroundColor: theme.getBackgroundColor(),
      appBar: PortalUi.appBar(context, tr('leave_balance')),
      body: Obx(() {
        if (c.isLoading.value) return PortalUi.loading();
        if (c.errorMessage.value != null) {
          return PortalUi.error(c.errorMessage.value!, c.load);
        }
        return RefreshIndicator(
          onRefresh: c.load,
          color: theme.getPrimaryColor(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24),
            children: [
              if (_isOnLeave(c.onLeave.value)) _onLeaveBanner(context, c.onLeave.value),
              PortalUi.sectionTitle(context, tr('leave_balances')),
              if (c.balances.isEmpty)
                SizedBox(height: 200, child: PortalUi.empty(tr('no_leave_balances')))
              else
                ...c.balances.map((b) => _balanceCard(context, b)),
              const SizedBox(height: 8),
              PortalUi.sectionTitle(context, tr('leave_history')),
              if (c.leaves.isEmpty)
                SizedBox(height: 200, child: PortalUi.empty(tr('no_leave_history')))
              else
                ...c.leaves.map((l) => _historyCard(context, l)),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  bool _isOnLeave(dynamic v) => v is Map ? v.isNotEmpty : PortalUi.truthy(v);

  Widget _onLeaveBanner(BuildContext context, dynamic v) {
    final theme = PortalUi.theme;
    final m = PortalUi.map(v);
    final name = PortalUi.text(m['name'] ?? m['type'] ?? m['leave_type'], fallback: '');
    final to = m['to'] ?? m['end_date'] ?? m['end'];
    final details = [
      if (name.isNotEmpty) name,
      if (to != null) '${tr('until')} ${PortalUi.date(to)}',
    ].join(' • ');
    return PortalUi.card(
      borderColor: theme.getWarningColor(),
      child: Row(
        children: [
          Icon(Icons.beach_access, color: theme.getWarningColor()),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('you_are_on_leave'),
                  style: TextStyle(fontWeight: FontWeight.w700, color: theme.getTextPrimaryColor()),
                ),
                if (details.isNotEmpty)
                  Text(details, style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceCard(BuildContext context, Map<String, dynamic> b) {
    final theme = PortalUi.theme;
    final annual = b['annual'];
    return PortalUi.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.getPrimaryColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.event_available, color: theme.getPrimaryColor()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PortalUi.text(b['name']),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                        fontWeight: FontWeight.w600,
                        color: theme.getTextPrimaryColor(),
                      ),
                    ),
                    if (annual != null)
                      Text(
                        '${tr('annual_days')}: ${PortalUi.number(annual)}',
                        style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor()),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: PortalUi.stat(context, tr('entitlement'), PortalUi.number(b['entitlement']), theme.getPrimaryColor())),
              const SizedBox(width: 8),
              Expanded(child: PortalUi.stat(context, tr('used_days'), PortalUi.number(b['used']), theme.getErrorColor())),
              const SizedBox(width: 8),
              Expanded(child: PortalUi.stat(context, tr('available_days'), PortalUi.number(b['available']), theme.getSuccessColor())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyCard(BuildContext context, Map<String, dynamic> l) {
    final theme = PortalUi.theme;
    final status = PortalUi.text(l['display_status'] ?? l['status'], fallback: '');
    final from = l['start_date'] ?? l['from'] ?? l['start'];
    final to = l['end_date'] ?? l['to'] ?? l['end'];
    // my/leaves history: requested / used days, return-to-work date.
    final days = l['requested'] ?? l['no_of_days'] ?? l['days'];
    final used = l['used'];
    final back = l['return'] ?? l['return_date'];
    return PortalUi.card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PortalUi.text(l['leave_type'] ?? l['type'] ?? l['name']),
                  style: TextStyle(fontWeight: FontWeight.w600, color: theme.getTextPrimaryColor()),
                ),
                const SizedBox(height: 4),
                Text(
                  '${PortalUi.date(from)}  →  ${PortalUi.date(to)}',
                  style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor()),
                ),
                if (days != null)
                  Text(
                    '${tr('lv_requested')}: ${PortalUi.number(days)} ${tr('days')}'
                    '${used != null ? '  ·  ${tr('lv_used')}: ${PortalUi.number(used)}' : ''}',
                    style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor()),
                  ),
                if (back != null && '$back'.isNotEmpty)
                  Text(
                    '${tr('lv_returned_on')}: ${PortalUi.date(back)}',
                    style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor()),
                  ),
              ],
            ),
          ),
          if (status.isNotEmpty) PortalUi.chip(tr('lv_status_$status', fallback: status), PortalUi.statusColor(status)),
        ],
      ),
    );
  }
}
