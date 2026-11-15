import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/data/remote/response/my_approvals_models.dart';
import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/approval/approval_ui.dart';

/// My Approvals: requests waiting for my approval step.
///
/// Source: `GET my/approvals` (`approvals`, `payrolls`).
/// Act:    `POST my/approvals/steps/{stepId}` with `action` + optional `comments`.
class ApprovalController extends GetxController {
  final MyRepository _repo = MyRepository();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  final RxList<MyApprovalItem> allRequests = <MyApprovalItem>[].obs;
  final RxList<MyPayrollItem> payrolls = <MyPayrollItem>[].obs;

  /// Filter keys match [MyApprovalItem.typeKey].
  static const filterKeys = [
    'all', 'leave', 'permit', 'loan', 'letter', 'overtime', 'missingpunch',
  ];

  String filterLabel(String key) => key == 'all' ? tr('ap_all') : ApUi.typeLabel(key);

  @override
  void onInit() {
    super.onInit();
    loadPendingRequests();
  }

  Future<void> loadPendingRequests() async {
    isLoading.value = true;
    final r = await _repo.approvals();
    if (r.ok) {
      final data = MyApprovalsData.fromJson(r.json);
      allRequests.assignAll(data.approvals);
      payrolls.assignAll(data.payrolls);
      errorMessage.value = '';
    } else {
      // 404 / 403: nothing for me — show the server message, not a crash.
      allRequests.clear();
      payrolls.clear();
      errorMessage.value = r.displayMessage();
    }
    isLoading.value = false;
  }

  Future<void> refreshRequests() => loadPendingRequests();

  void changeFilter(String key) => selectedFilter.value = key;

  List<MyApprovalItem> get visibleRequests {
    final f = selectedFilter.value;
    if (f == 'all') return allRequests;
    return allRequests.where((r) => r.typeKey == f).toList();
  }

  int countFor(String key) => key == 'all'
      ? allRequests.length
      : allRequests.where((r) => r.typeKey == key).length;

  int get totalPendingCount => allRequests.length;

  /// Types present in the list (plus the standard ones), for the filter bar.
  List<String> get filters {
    final extra = allRequests
        .map((r) => r.typeKey)
        .where((k) => k.isNotEmpty && !filterKeys.contains(k))
        .toSet();
    return [...filterKeys, ...extra];
  }

  /// `GET my/approvals/{id}` — request details + steps + attachment.
  Future<(MyApprovalDetail?, String?)> loadDetail(int requestId,
      {MyApprovalItem? fallback}) async {
    final r = await _repo.approval(requestId);
    if (!r.ok) return (null, r.displayMessage());
    return (MyApprovalDetail.fromJson(r.json, fallback: fallback), null);
  }

  /// Resolves the step to act on: from the list item, else from the detail.
  Future<(int?, String?)> _resolveStepId(MyApprovalItem item) async {
    if (item.stepId != null) return (item.stepId, null);
    final (detail, err) = await loadDetail(item.id, fallback: item);
    if (detail == null) return (null, err);
    final id = detail.actionableStepId;
    return (id, id == null ? tr('ap_no_step') : null);
  }

  /// Approves / rejects the step. Returns the server answer (never throws).
  /// On success the request is removed from the list.
  Future<ApiResult> act(MyApprovalItem item, String action, String comments,
      {int? stepId}) async {
    int? sid = stepId;
    if (sid == null) {
      final (resolved, err) = await _resolveStepId(item);
      if (resolved == null) return ApiResult(ok: false, message: err ?? tr('ap_no_step'));
      sid = resolved;
    }
    final r = await _repo.actOnStep(sid, action: action, comments: comments);
    if (r.ok) {
      allRequests.removeWhere((e) => e.id == item.id);
    } else if (r.statusCode == 422 || r.statusCode == 404) {
      // Already done / no longer mine: refresh so the list matches the server.
      loadPendingRequests();
    }
    return r;
  }
}
