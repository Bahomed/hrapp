import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/my_approvals_models.dart';
import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/approval/approval_ui.dart';

/// Finance: payments waiting for me (home key `not_executed`).
///
/// Source: `GET my/approvals` → `executions` (loan / leave settlement) and
/// `final_settlements`. Only users set in Settings › Task Responsibility see
/// them; everyone else gets 404, shown as a message.
///
/// These tasks are paid / returned only through `my/executions/...` and
/// `my/final-settlements/...` — never through `tasks/{id}/status`.
class UnexecutedRequestsController extends GetxController {
  final MyRepository _repo = MyRepository();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final notResponsible = false.obs;

  final executions = <MyExecutionItem>[].obs;
  final finalSettlements = <MyFinalSettlementItem>[].obs;

  /// 0 = executions, 1 = final settlements.
  final tab = 0.obs;

  int get total => executions.length + finalSettlements.length;

  @override
  void onInit() {
    super.onInit();
    loadUnexecutedRequests();
  }

  Future<void> loadUnexecutedRequests() async {
    isLoading.value = true;
    final r = await _repo.approvals();
    if (r.ok) {
      final data = MyApprovalsData.fromJson(r.json);
      executions.assignAll(data.executions);
      finalSettlements.assignAll(data.finalSettlements);
      errorMessage.value = '';
      notResponsible.value = false;
      if (executions.isEmpty && finalSettlements.isNotEmpty) tab.value = 1;
    } else {
      executions.clear();
      finalSettlements.clear();
      notResponsible.value = r.statusCode == 404 || r.statusCode == 403;
      errorMessage.value = notResponsible.value && r.message.isEmpty
          ? tr('ap_not_responsible')
          : r.displayMessage();
    }
    isLoading.value = false;
  }

  Future<void> refreshRequests() => loadUnexecutedRequests();

  // ── Executions ──────────────────────────────────────────────────────

  /// Loan: `tot_amt_tobe_paid`, `no_of_installment`, `deduction_startdate_g`,
  /// `notes`. Leave settlement: no fields.
  Future<ApiResult> payExecution(MyExecutionItem item,
      [Map<String, dynamic>? fields]) async {
    final r = await _repo.payExecution(item.id, fields);
    if (r.ok) executions.removeWhere((e) => e.id == item.id);
    return r;
  }

  Future<ApiResult> returnExecution(MyExecutionItem item, String reason) async {
    final r = await _repo.returnExecution(item.id, reason);
    if (r.ok) executions.removeWhere((e) => e.id == item.id);
    return r;
  }

  Future<ApiResult> loadSettlement(MyExecutionItem item) =>
      _repo.executionSettlement(item.id);

  // ── Final settlements ───────────────────────────────────────────────

  Future<ApiResult> payFinalSettlement(MyFinalSettlementItem item) async {
    final r = await _repo.payFinalSettlement(item.taskId);
    if (r.ok) finalSettlements.removeWhere((e) => e.taskId == item.taskId);
    return r;
  }

  Future<ApiResult> returnFinalSettlement(MyFinalSettlementItem item, String reason) async {
    final r = await _repo.returnFinalSettlement(item.taskId, reason);
    if (r.ok) finalSettlements.removeWhere((e) => e.taskId == item.taskId);
    return r;
  }

  /// `GET my/final-settlements/{task_id}/print`. The response format is not
  /// documented, so it is fetched as bytes and handled by content type:
  /// PDF / HTML → saved and opened; JSON with `pdf_base64` / `url` / `html`
  /// → opened; any other JSON → shown as a data sheet.
  ///
  /// [onLoaded] runs once the download finished (before anything is opened),
  /// so the caller can close its loading indicator.
  Future<void> printFinalSettlement(MyFinalSettlementItem item,
      {void Function()? onLoaded}) async {
    final prefs = Preferences();
    final url = '${await prefs.getWorkspaceUrl()}${myFinalSettlementPrintUrl(item.taskId)}';
    final locale = ApiHelper.instance.getCurrentLocale();
    Response<List<int>> res;
    try {
      res = await DioClient().dio.get<List<int>>(
            url,
            queryParameters: {'locale': locale},
            options: Options(
              responseType: ResponseType.bytes,
              headers: {'Accept': 'application/pdf, text/html, application/json', 'Accept-Language': locale},
            ),
          );
    } on DioException catch (e) {
      onLoaded?.call();
      final body = e.response?.data;
      if (body is List<int>) {
        ApUi.fail(ApiResult.fromResponse(Response(
          requestOptions: e.requestOptions,
          statusCode: e.response?.statusCode,
          data: utf8.decode(body, allowMalformed: true),
        )).displayMessage());
      } else {
        ApUi.fail(ApiResult.fromException(e).displayMessage());
      }
      return;
    }

    onLoaded?.call();
    final bytes = res.data ?? const <int>[];
    final type = (res.headers.value(Headers.contentTypeHeader) ?? '').toLowerCase();
    final base = 'final_settlement_${item.taskId}';

    if (type.contains('pdf')) {
      await ApUi.openBytes(bytes, '$base.pdf');
      return;
    }
    final text = utf8.decode(bytes, allowMalformed: true);
    if (type.contains('html') || text.trimLeft().startsWith('<')) {
      await ApUi.openBytes(utf8.encode(text), '$base.html');
      return;
    }

    final r = ApiResult.fromResponse(Response(
      requestOptions: res.requestOptions,
      statusCode: res.statusCode,
      data: text,
    ));
    if (!r.ok) {
      ApUi.fail(r.displayMessage());
      return;
    }
    final j = unwrapData(r.json);
    final pdf = j['pdf_base64'] ?? j['pdf'] ?? j['base64'];
    if (pdf is String && pdf.isNotEmpty) {
      try {
        final fname = (j['filename'] ?? '$base.pdf').toString();
        await ApUi.openBytes(base64Decode(pdf.split(',').last), fname);
        return;
      } catch (_) {}
    }
    final html = j['html'];
    if (html is String && html.isNotEmpty) {
      await ApUi.openBytes(utf8.encode(html), '$base.html');
      return;
    }
    final link = j['url'] ?? j['print_url'] ?? j['file_url'];
    if (link is String && link.startsWith('http') && Get.context != null) {
      await ApUi.openAttachment(link, Get.context!);
      return;
    }
    ApUi.showDataSheet(tr('ap_final_settlement'), j);
  }
}
