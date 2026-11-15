import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/attendance/attendance_detail_screen.dart';
import 'package:co.injazathr.injazathr/view/home_screen/app_settings_controller.dart';
import 'package:co.injazathr.injazathr/view/my_portal/leave_balance_screen.dart';
import 'package:co.injazathr.injazathr/view/my_portal/my_pending_requests_screen.dart';
import 'package:co.injazathr.injazathr/view/overtime/assigned_overtime_screen.dart';
import 'package:co.injazathr.injazathr/view/payroll/payroll_screen.dart';

/// `GET my/home` — the web My Portal home at a glance: today (leave or the
/// punches + on time / late / absent), overtime waiting for my answer, and the
/// KPI cards (leave balance, last payslip, this month's attendance, pending
/// requests). Hidden entirely when the call fails (the tiles below still work).
class PortalHomeController extends GetxController {
  static PortalHomeController get to => Get.isRegistered<PortalHomeController>()
      ? Get.find<PortalHomeController>()
      : Get.put(PortalHomeController(), permanent: true);

  final MyRepository _my = MyRepository();
  final Rxn<Map<String, dynamic>> data = Rxn<Map<String, dynamic>>();
  bool _loading = false;

  Future<void> reload() async {
    if (_loading) return;
    _loading = true;
    try {
      final r = await _my.home();
      if (r.ok) data.value = r.json;
    } finally {
      _loading = false;
    }
  }
}

class PortalHomeSummary extends StatelessWidget {
  const PortalHomeSummary({super.key});

  static Map<String, dynamic> _m(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  static num _n(dynamic v) => v is num ? v : num.tryParse('${v ?? ''}') ?? 0;
  static String _num(dynamic v) {
    final n = _n(v);
    return n == n.roundToDouble() ? n.toInt().toString() : n.toStringAsFixed(2);
  }

  /// YYYY-MM-DD → DD-MM-YYYY.
  static String _date(dynamic v) {
    final s = '${v ?? ''}';
    final p = s.split(' ').first.split('-');
    return p.length == 3 ? '${p[2]}-${p[1]}-${p[0]}' : s;
  }

  /// `202611` → `11-2026`.
  static String _month(dynamic v) {
    final s = '${v ?? ''}';
    return s.length == 6 ? '${s.substring(4)}-${s.substring(0, 4)}' : s;
  }

  @override
  Widget build(BuildContext context) {
    final c = PortalHomeController.to;
    final settings = AppSettingsController.to;
    final theme = ThemeService.instance;

    return Obx(() {
      final d = c.data.value;
      settings.homeItems.length; // rebuild when Mobile Settings change
      if (d == null) return const SizedBox.shrink();

      final today = _m(d['today']);
      final leave = today['leave'] is Map ? _m(today['leave']) : null;
      final punches = today['punches'] is List ? today['punches'] as List : const [];
      final punch = punches.isNotEmpty ? _m(punches.first) : null;
      final otPending = _n(d['overtime_pending']).toInt();
      final balance = d['leave_balance'] is Map ? _m(d['leave_balance']) : null;
      final payslip = d['last_payslip'] is Map ? _m(d['last_payslip']) : null;
      final month = _m(d['month_attendance']);
      final requests = _m(d['requests']);

      // Same order as the web: leave → no punch → absent → late → on time.
      late final String statusText;
      late final Color statusColor;
      if (leave != null) {
        statusText = tr('mp_on_leave_short');
        statusColor = theme.getPrimaryColor();
      } else if (punch == null) {
        statusText = tr('mp_no_punch_short');
        statusColor = theme.getTextSecondaryColor();
      } else if (punch['absent'] == true) {
        statusText = tr('mp_absent');
        statusColor = theme.getErrorColor();
      } else if (_n(punch['late_minutes']) > 0) {
        statusText = trParams('mp_late', {'n': _num(punch['late_minutes'])});
        statusColor = theme.getWarningColor();
      } else {
        statusText = tr('mp_on_time');
        statusColor = theme.getSuccessColor();
      }

      final cards = <Widget>[
        if (balance != null && settings.isOn('leave_balance'))
          _kpi(
            icon: Icons.flight_takeoff_outlined,
            color: const Color(0xFF0369A1),
            title: tr('mp_leave_balance'),
            value: '${_num(balance['available'])} ${tr('mp_days')}',
            sub: '${tr('mp_used')}: ${_num(balance['used'])}',
            onTap: () => Get.to(() => const LeaveBalanceScreen()),
          ),
        if (settings.isOn('payroll'))
          _kpi(
            icon: Icons.receipt_long_outlined,
            color: const Color(0xFF15803D),
            title: tr('mp_last_payslip'),
            value: payslip != null ? _num(payslip['net']) : '—',
            sub: payslip != null ? _month(payslip['month']) : tr('mp_no_payslip'),
            onTap: () => Get.to(() => const PayrollScreen()),
          ),
        if (settings.isOn('attendance'))
          _kpi(
            icon: Icons.event_available_outlined,
            color: const Color(0xFF7C3AED),
            title: tr('mp_this_month'),
            value: '${_num(month['worked'])} ${tr('mp_days_worked')}',
            sub: '${trParams('mp_late_days_n', {'n': _num(month['late_days'])})} · '
                '${trParams('mp_absent_days_n', {'n': _num(month['absent'])})}',
            onTap: () => Get.to(() => const AttendanceDetailScreen()),
          ),
        if (settings.isOn('requests'))
          _kpi(
            icon: Icons.hourglass_top_outlined,
            color: const Color(0xFFB45309),
            title: tr('mp_pending_requests'),
            value: _num(requests['count']),
            sub: tr('mp_waiting_approval'),
            onTap: () => Get.to(() => const MyPendingRequestsScreen()),
          ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Today
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _box(theme),
            child: Row(
              children: [
                Icon(Icons.today_outlined, color: theme.getPrimaryColor()),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tr('mp_today')} · ${_date(today['date'])}',
                        style: TextStyle(
                            fontSize: 12, color: theme.getTextSecondaryColor()),
                      ),
                      const SizedBox(height: 4),
                      if (leave != null)
                        Text(
                          '${trParams('mp_on_leave', {'name': '${leave['name'] ?? ''}'})}\n'
                          '${_date(leave['from'])} – ${_date(leave['to'])}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.getTextPrimaryColor()),
                        )
                      else
                        Row(children: [
                          _punch(theme, tr('mp_check_in'), punch?['check_in']),
                          const SizedBox(width: 18),
                          _punch(theme, tr('mp_check_out'), punch?['check_out']),
                        ]),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // Overtime waiting for my answer
          if (otPending > 0 && settings.isOn('my_overtime')) ...[
            const SizedBox(height: 10),
            Material(
              color: theme.getWarningColor().withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Get.to(() => const AssignedOvertimeScreen())
                    ?.then((_) => c.reload()),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Icon(Icons.more_time, color: theme.getWarningColor()),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trParams('mp_overtime_pending', {'n': '$otPending'}),
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.getTextPrimaryColor()),
                      ),
                    ),
                    Text(tr('mp_answer'),
                        style: TextStyle(
                            color: theme.getWarningColor(),
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
          ],

          if (cards.isNotEmpty) ...[
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
              children: cards,
            ),
          ],
        ],
      );
    });
  }

  BoxDecoration _box(ThemeService theme) => BoxDecoration(
        color: theme.getCardColor(),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.getDividerColor()),
      );

  Widget _punch(ThemeService theme, String label, dynamic time) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: theme.getTextSecondaryColor())),
          Text(
            (time == null || '$time'.isEmpty) ? '--:--' : '$time',
            textDirection: TextDirection.ltr,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.getTextPrimaryColor()),
          ),
        ],
      );

  Widget _kpi({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String sub,
    required VoidCallback onTap,
  }) {
    final theme = ThemeService.instance;
    return Material(
      color: theme.getCardColor(),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.getDividerColor()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12, color: theme.getTextSecondaryColor())),
                ),
              ]),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: theme.getTextPrimaryColor())),
              Text(sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11, color: theme.getTextSecondaryColor())),
            ],
          ),
        ),
      ),
    );
  }
}
