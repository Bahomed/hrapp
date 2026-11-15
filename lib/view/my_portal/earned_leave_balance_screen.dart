import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/compensation/portal_ui.dart';

/// Days earned by working a public holiday (PH) or a day off (PD)
/// (`GET my/earned-leave-balance`).
class EarnedLeaveBalanceController extends GetxController {
  final MyRepository _repo = MyRepository();

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final enabled = true.obs;
  final activeDays = RxnInt();
  final ph = <String, dynamic>{}.obs;
  final pd = <String, dynamic>{}.obs;
  final credits = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final r = await _repo.earnedLeaveBalance();
    if (!r.ok) {
      errorMessage.value = r.displayMessage(tr('something_went_wrong', fallback: 'Something went wrong'));
      isLoading.value = false;
      return;
    }
    final body = r.json['data'] is Map ? PortalUi.map(r.json['data']) : r.json;
    enabled.value = body['enabled'] == null || PortalUi.truthy(body['enabled']);
    activeDays.value = PortalUi.toInt(body['active_days']);
    final balance = PortalUi.map(body['balance']);
    ph.assignAll(PortalUi.map(balance['ph']));
    pd.assignAll(PortalUi.map(balance['pd']));
    credits.assignAll(PortalUi.list(body['credits']));
    isLoading.value = false;
  }
}

class EarnedLeaveBalanceScreen extends StatelessWidget {
  const EarnedLeaveBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(EarnedLeaveBalanceController());
    final theme = PortalUi.theme;

    return Scaffold(
      backgroundColor: theme.getBackgroundColor(),
      appBar: PortalUi.appBar(context, tr('earned_leave_balance')),
      body: Obx(() {
        if (c.isLoading.value) return PortalUi.loading();
        if (c.errorMessage.value != null) {
          return PortalUi.error(c.errorMessage.value!, c.load);
        }
        if (!c.enabled.value) {
          return RefreshIndicator(
            onRefresh: c.load,
            child: PortalUi.message(
              icon: Icons.event_busy,
              text: tr('earned_leave_not_enabled'),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: c.load,
          color: theme.getPrimaryColor(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24),
            children: [
              _balanceCard(context, tr('earned_ph'), tr('earned_ph_hint'), Icons.celebration, c.ph),
              _balanceCard(context, tr('earned_pd'), tr('earned_pd_hint'), Icons.weekend, c.pd),
              if (c.activeDays.value != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    trParams('earned_credits_valid_for', {'days': '${c.activeDays.value}'}),
                    style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor()),
                  ),
                ),
              PortalUi.sectionTitle(context, tr('earned_credits')),
              if (c.credits.isEmpty)
                SizedBox(height: 200, child: PortalUi.empty(tr('no_earned_credits')))
              else
                ...c.credits.map((cr) => _creditCard(context, cr)),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _balanceCard(BuildContext context, String title, String hint, IconData icon, Map<String, dynamic> b) {
    final theme = PortalUi.theme;
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
                child: Icon(icon, color: theme.getPrimaryColor()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                        fontWeight: FontWeight.w600,
                        color: theme.getTextPrimaryColor(),
                      ),
                    ),
                    Text(hint, style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor())),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: PortalUi.stat(context, tr('earned_days'), PortalUi.number(b['earned'], fallback: '0'), theme.getPrimaryColor())),
              const SizedBox(width: 8),
              Expanded(child: PortalUi.stat(context, tr('used_days'), PortalUi.number(b['used'], fallback: '0'), theme.getErrorColor())),
              const SizedBox(width: 8),
              Expanded(child: PortalUi.stat(context, tr('available_days'), PortalUi.number(b['available'], fallback: '0'), theme.getSuccessColor())),
            ],
          ),
        ],
      ),
    );
  }

  Widget _creditCard(BuildContext context, Map<String, dynamic> cr) {
    final theme = PortalUi.theme;
    final ph = PortalUi.toDouble(cr['ph']) ?? 0;
    final pd = PortalUi.toDouble(cr['pd']) ?? 0;
    return PortalUi.card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: 18, color: theme.getPrimaryColor()),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  PortalUi.date(cr['date']),
                  style: TextStyle(fontWeight: FontWeight.w600, color: theme.getTextPrimaryColor()),
                ),
              ),
              if (ph > 0) ...[PortalUi.chip('PH ${PortalUi.number(ph)}', theme.getPrimaryColor()), const SizedBox(width: 6)],
              if (pd > 0) PortalUi.chip('PD ${PortalUi.number(pd)}', theme.getSuccessColor()),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${tr('expires_on')}: ${PortalUi.date(cr['expires'])}',
            style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor()),
          ),
        ],
      ),
    );
  }
}
