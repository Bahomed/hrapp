import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';

import 'leave_settlement_print.dart';

/// Leave settlement of a payment waiting for me (GET my/executions/{id}/settlement),
/// read only — as the web LeaveSettlementModal: employee, leave, Due To
/// Employee (benefits), Deductions, then Total Due − Total Owed = Final Amount.
/// Print = the web's printed form (HR018). Pops with 'pay' or 'return'.
class LeaveSettlementScreen extends StatelessWidget {
  final Map<String, dynamic> settlement;
  final String? reqNo;
  final bool canAct;

  const LeaveSettlementScreen({
    super.key,
    required this.settlement,
    this.reqNo,
    this.canAct = true,
  });

  static Map<String, dynamic> _m(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  static List<Map<String, dynamic>> _l(dynamic v) =>
      v is List ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList() : [];
  static double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;
  static String _n(dynamic v) {
    final x = (_d(v) * 100).round() / 100;
    return x == x.roundToDouble() ? x.toInt().toString() : '$x';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final s = settlement;
    final emp = _m(s['employee']);
    final lv = _m(s['leave']);
    final worked = _m(lv['worked']);
    final benefits = _l(s['benefits']);
    final deductions = _l(s['deductions']);
    final tot = LeaveSettlementPrint.totals(s);
    final warning = '${s['warning'] ?? ''}'.trim();
    final paid = s['paid'] == true;
    final rtl = getCurrentLanguage() == 'ar';
    final money = LeaveSettlementPrint.amount;
    final day = LeaveSettlementPrint.day;

    Widget section(String title, List<Widget> children) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.getCardColor(),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.getDividerColor()),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15, color: theme.getTextPrimaryColor())),
            const SizedBox(height: 10),
            ...children,
          ]),
        );

    Widget kv(String k, String v, {bool ltr = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                flex: 5,
                child: Text(k, style: TextStyle(fontSize: 13, color: theme.getTextSecondaryColor()))),
            Expanded(
              flex: 6,
              child: Text(v.isEmpty ? '—' : v,
                  textDirection: ltr ? TextDirection.ltr : null,
                  textAlign: rtl && ltr ? TextAlign.right : null,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: theme.getTextPrimaryColor())),
            ),
          ]),
        );

    Widget line(String title, String sub, String amount, {Color? color}) => Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.getDividerColor()))),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: TextStyle(fontWeight: FontWeight.w600, color: theme.getTextPrimaryColor())),
                if (sub.isNotEmpty)
                  Text(sub,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor())),
              ]),
            ),
            Text(amount,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: color ?? theme.getTextPrimaryColor())),
          ]),
        );

    Widget total(String k, double v, Color c, {bool big = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Expanded(
                child: Text(k,
                    style: TextStyle(
                        fontSize: big ? 16 : 14,
                        fontWeight: big ? FontWeight.w800 : FontWeight.w500,
                        color: theme.getTextPrimaryColor()))),
            Text(money(v),
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: big ? 20 : 15, fontWeight: FontWeight.w800, color: c)),
          ]),
        );

    return Scaffold(
      backgroundColor: theme.getPageBackgroundColor(),
      appBar: AppBar(
        title: Text(tr('ls_title')),
        actions: [
          IconButton(
            tooltip: tr('ls_print'),
            icon: const Icon(Icons.print_outlined),
            onPressed: () => LeaveSettlementPrint.printIt(s, rtl: rtl, reqNo: reqNo),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (warning.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.getWarningColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(Icons.warning_amber_rounded, color: theme.getWarningColor()),
                const SizedBox(width: 8),
                Expanded(child: Text(warning)),
              ]),
            ),
          section(tr('ls_employee'), [
            kv(tr('ls_emp_name'), '${emp['name'] ?? ''}'),
            kv(tr('ls_emp_no'), '${emp['employee_no'] ?? ''}', ltr: true),
            kv(tr('ls_department'), '${emp['department'] ?? ''}'),
            kv(tr('ls_position'), '${emp['position'] ?? ''}'),
            kv(tr('ls_hire_date'), day(emp['contract_start'] ?? emp['hire_date']), ltr: true),
          ]),
          section(tr('ls_leave'), [
            kv(tr('ls_leave_type'), '${lv['type'] ?? ''}'),
            kv(tr('ls_leave_date'), '${day(lv['from'])} – ${day(lv['to'])}', ltr: true),
            kv(tr('ls_days'), _n(lv['days'])),
            kv(tr('ls_period'), '${day(lv['work_from'])} – ${day(lv['work_to'])}', ltr: true),
            kv(tr('ls_period_worked'),
                '${worked['years'] ?? 0} ${tr('ls_y')} · ${worked['months'] ?? 0} ${tr('ls_m')} · ${worked['days'] ?? 0} ${tr('ls_d')}'),
            kv(tr('ls_days_granted'), _n(lv['grant_days'])),
            kv(tr('ls_vacation_due'), _n(lv['due_days'])),
            kv(tr('ls_basic_salary'), money(lv['monthly_salary']), ltr: true),
          ]),
          section(tr('ls_due_to_employee'), [
            if (benefits.isEmpty)
              Text('—', style: TextStyle(color: theme.getTextSecondaryColor()))
            else
              for (final b in benefits)
                line('${b['desc'] ?? ''}', '${day(b['from'])} – ${day(b['to'])}', money(b['due'])),
            const SizedBox(height: 6),
            total(tr('ls_total_due'), tot.entitlements, theme.getPrimaryColor()),
          ]),
          if (deductions.isNotEmpty)
            section(tr('ls_deductions'), [
              for (final d in deductions)
                line(
                  '${d['name'] ?? ''}',
                  '${tr('ls_amount')}: ${money(d['amount'])}',
                  money(d['to_be_paid']),
                  color: theme.getErrorColor(),
                ),
              const SizedBox(height: 6),
              total(tr('ls_total_owed'), tot.deductions, theme.getErrorColor()),
            ]),
          section(tr('ls_summary'), [
            total(tr('ls_total_due'), tot.entitlements, theme.getPrimaryColor()),
            total(tr('ls_total_owed'), tot.deductions, theme.getErrorColor()),
            Divider(color: theme.getDividerColor()),
            total(tr('ls_final_amount'), tot.net, theme.getSuccessColor(), big: true),
            if (paid)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('${tr('ls_paid_at')}: ${s['paid_at'] ?? ''}',
                    style: TextStyle(color: theme.getSuccessColor(), fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 80),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => LeaveSettlementPrint.printIt(s, rtl: rtl, reqNo: reqNo),
                icon: const Icon(Icons.print_outlined),
                label: Text(tr('ls_print')),
              ),
            ),
            if (canAct && !paid) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: theme.getErrorColor(),
                      side: BorderSide(color: theme.getErrorColor())),
                  onPressed: () => Get.back(result: 'return'),
                  child: FittedBox(child: Text(tr('ap_return_to_hr'), maxLines: 1)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: theme.getSuccessColor()),
                  onPressed: () => Get.back(result: 'pay'),
                  child: Text(tr('ap_pay')),
                ),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}
