import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';

/// Holds `GET my/app-settings` (Settings › Mobile on the web) plus the few
/// access checks the home screen needs. Reloaded each time the home opens.
///
/// Fail-open: when a call fails everything stays visible, so the app is
/// never blocked by a settings outage.
class AppSettingsController extends GetxController {
  static AppSettingsController get to => Get.isRegistered<AppSettingsController>()
      ? Get.find<AppSettingsController>()
      : Get.put(AppSettingsController(), permanent: true);

  final MyRepository _my = MyRepository();

  /// `home_items` from the server. Missing key = show.
  final RxMap<String, bool> homeItems = <String, bool>{}.obs;
  final RxBool allowClockIn = true.obs;

  /// `GET tasks/count` answered 200 (403 = no tasks access).
  final RxBool hasTasksAccess = true.obs;

  /// `GET my/earned-leave-balance` → `enabled`.
  final RxBool earnedLeaveEnabled = true.obs;

  /// `GET my/approvals/counts`.
  final RxInt approvalsCount = 0.obs;
  final RxInt payrollsCount = 0.obs;
  final RxInt executionsCount = 0.obs;
  final RxInt finalSettlementsCount = 0.obs;

  /// `GET my/home` → `overtime_pending` (set by PortalHomeController).
  final RxInt overtimePendingCount = 0.obs;

  bool _loading = false;

  /// True unless Mobile Settings turned [key] off.
  bool isOn(String key) => homeItems[key] ?? true;

  int get notExecutedCount => executionsCount.value + finalSettlementsCount.value;

  /// Forget the previous user's values (this controller outlives logout).
  void reset() {
    homeItems.clear();
    allowClockIn.value = true;
    hasTasksAccess.value = true;
    earnedLeaveEnabled.value = true;
    approvalsCount.value = 0;
    payrollsCount.value = 0;
    executionsCount.value = 0;
    finalSettlementsCount.value = 0;
    overtimePendingCount.value = 0;
  }

  /// Settings first (they decide what else is needed), then only the checks
  /// for tiles that are on. Overtime pending comes from `my/home`
  /// (PortalHomeController), not a separate `assigned-overtime` call.
  Future<void> reload() async {
    if (_loading) return;
    _loading = true;
    try {
      await _loadSettings();
      await Future.wait([
        if (isOn('tasks')) _loadTasksAccess(),
        if (isOn('earned_leave_balance')) _loadEarnedLeave(),
        _loadApprovalCounts(), // tiles + profile menu badge
      ]);
    } finally {
      _loading = false;
    }
  }

  Future<void> _loadSettings() async {
    final r = await _my.appSettings();
    if (!r.ok) {
      homeItems.clear();
      allowClockIn.value = true;
      return;
    }
    final j = r.json;
    final items = <String, bool>{};
    final raw = j['home_items'];
    if (raw is Map) {
      raw.forEach((k, v) => items[k.toString()] = _bool(v, true));
    }
    homeItems.assignAll(items);
    allowClockIn.value = _bool(j['allow_clock_in'], true);
  }

  /// "My Tasks" shows only when `GET tasks/count` answers 200.
  /// A network failure (no status code) keeps it visible (fail-open).
  Future<void> _loadTasksAccess() async {
    final base = await Preferences().getWorkspaceUrl();
    final r = await ApiResult.guard(() => DioClient().dio.get(
        '$base$taskCountUrl',
        queryParameters: {'locale': ApiHelper.instance.getCurrentLocale()}));
    hasTasksAccess.value = r.statusCode == null || r.statusCode == 200;
  }

  Future<void> _loadEarnedLeave() async {
    final r = await _my.earnedLeaveBalance();
    earnedLeaveEnabled.value = r.ok ? _bool(r.json['enabled'], true) : true;
  }

  Future<void> _loadApprovalCounts() async {
    final r = await _my.approvalCounts();
    if (!r.ok) return;
    final j = r.json;
    approvalsCount.value = _int(j['approvals']);
    payrollsCount.value = _int(j['payrolls']);
    executionsCount.value = _int(j['executions']);
    finalSettlementsCount.value = _int(j['final_settlements']);
  }



  static bool _bool(dynamic v, bool fallback) {
    if (v == null) return fallback;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
    return fallback;
  }

  static int _int(dynamic v) =>
      v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
}
