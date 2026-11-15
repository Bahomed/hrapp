import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'portal_ui.dart';

/// Compensation for the signed-in user from `GET my/contract`:
/// contracts, earnings (+ total), GOSI, deductions (+ summary).
class CompensationController extends GetxController {
  final MyRepository _repo = MyRepository();

  final isLoading = true.obs;
  final errorMessage = RxnString();

  final contracts = <Map<String, dynamic>>[].obs;
  final earnings = <Map<String, dynamic>>[].obs;
  final deductions = <Map<String, dynamic>>[].obs;
  final gosi = <String, dynamic>{}.obs;
  final earningsSummary = <String, dynamic>{}.obs;
  final deductionsSummary = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final r = await _repo.contract();
    if (!r.ok) {
      errorMessage.value = r.displayMessage(tr('something_went_wrong', fallback: 'Something went wrong'));
      isLoading.value = false;
      return;
    }
    final body = r.json['data'] is Map ? PortalUi.map(r.json['data']) : r.json;

    final list = PortalUi.list(body['contracts']);
    // Current contract first.
    list.sort((a, b) => (PortalUi.truthy(b['current']) ? 1 : 0)
        .compareTo(PortalUi.truthy(a['current']) ? 1 : 0));
    contracts.assignAll(list);
    earnings.assignAll(PortalUi.list(body['earnings']));
    deductions.assignAll(PortalUi.list(body['deductions']));
    gosi.assignAll(PortalUi.map(body['gosi']));
    earningsSummary.assignAll(PortalUi.map(body['earnings_summary']));
    deductionsSummary.assignAll(PortalUi.map(body['deductions_summary']));
    isLoading.value = false;
  }

  // ── Totals (from the summaries, else summed from the lists) ───────────

  double get totalEarnings =>
      PortalUi.toDouble(earningsSummary['total']) ??
      earnings.fold<double>(0, (s, e) => s + (PortalUi.toDouble(e['amount']) ?? 0));

  double _sumDeductions(String key) =>
      deductions.fold<double>(0, (s, e) => s + (PortalUi.toDouble(e[key]) ?? 0));

  double get deductionsTotal =>
      PortalUi.toDouble(deductionsSummary['total']) ?? _sumDeductions('total');

  double get deductionsPaid =>
      PortalUi.toDouble(deductionsSummary['paid']) ?? _sumDeductions('paid');

  double get deductionsRemaining =>
      PortalUi.toDouble(deductionsSummary['remaining']) ?? _sumDeductions('remaining');
}
