import 'package:dio/dio.dart';

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';

/// Client for the new `/api/my/...` endpoints (signed-in user only; no
/// employee id is ever sent) and for `/api/assigned-overtime`.
///
/// Every method returns an [ApiResult] and never throws: check `ok`, then
/// read `json`; on failure show `displayMessage()` / `errorFor(field)`.
/// The `Authorization` header is added by AuthInterceptor.
class MyRepository {
  final Preferences _prefs = Preferences();
  Dio get _dio => DioClient().dio;

  Future<String> _url(String path) async =>
      '${await _prefs.getWorkspaceUrl()}$path';

  Map<String, dynamic> _q([Map<String, dynamic>? extra]) => {
        'locale': ApiHelper.instance.getCurrentLocale(),
        ...?extra,
      };

  Options get _opts => Options(headers: {
        'Accept': 'application/json',
        'Accept-Language': ApiHelper.instance.getCurrentLocale(),
      });

  Future<ApiResult> _get(String path, [Map<String, dynamic>? query]) async {
    final url = await _url(path);
    return ApiResult.guard(
        () => _dio.get(url, queryParameters: _q(query), options: _opts));
  }

  Future<ApiResult> _post(String path, [Map<String, dynamic>? data]) async {
    final url = await _url(path);
    return ApiResult.guard(() => _dio.post(url,
        data: data ?? <String, dynamic>{}, queryParameters: _q(), options: _opts));
  }

  Future<ApiResult> _postMultipart(String path, FormData form) async {
    final url = await _url(path);
    return ApiResult.guard(() => _dio.post(url,
        data: form,
        queryParameters: _q(),
        options: _opts.copyWith(contentType: Headers.multipartFormDataContentType)));
  }

  Future<ApiResult> _delete(String path) async {
    final url = await _url(path);
    return ApiResult.guard(
        () => _dio.delete(url, queryParameters: _q(), options: _opts));
  }

  // ── Home / settings ────────────────────────────────────────────────────
  Future<ApiResult> appSettings() => _get(myAppSettingsUrl);
  Future<ApiResult> home() => _get(myHomeUrl);

  // ── Balances / contract ────────────────────────────────────────────────
  Future<ApiResult> contract() => _get(myContractUrl);
  Future<ApiResult> leaves() => _get(myLeavesUrl);
  Future<ApiResult> earnedLeaveBalance() => _get(myEarnedLeaveBalanceUrl);

  // ── Requests ───────────────────────────────────────────────────────────
  Future<ApiResult> requestOptions() => _get(myRequestOptionsUrl);

  /// [from] / [to] as YYYY-MM-DD.
  Future<ApiResult> countDays(
          {required int leaveTypeId, required String from, required String to}) =>
      _get(myRequestCountDaysUrl,
          {'leave_type_id': leaveTypeId, 'from': from, 'to': to});

  Future<ApiResult> requests([Map<String, dynamic>? query]) =>
      _get(myRequestsUrl, query);
  Future<ApiResult> request(int id) => _get(myRequestUrl(id));
  Future<ApiResult> deleteRequest(int id) => _delete(myRequestUrl(id));
  Future<ApiResult> pending() => _get(myPendingUrl);

  /// `request_type` = Leave | Permit | Loan | Letter | MissingPunch plus its
  /// fields. [attachmentPath] is sent as the `attachment` file when given.
  Future<ApiResult> submitRequest(Map<String, dynamic> fields,
      {String? attachmentPath}) async {
    final map = <String, dynamic>{};
    fields.forEach((k, v) {
      if (v != null) map[k] = v is bool ? (v ? 1 : 0) : v.toString();
    });
    if (attachmentPath != null && attachmentPath.isNotEmpty) {
      map['attachment'] = await MultipartFile.fromFile(attachmentPath,
          filename: attachmentPath.split('/').last);
    }
    return _postMultipart(myRequestsUrl, FormData.fromMap(map));
  }

  // ── Approvals ──────────────────────────────────────────────────────────
  /// `{ approvals, executions, payrolls, final_settlements }`
  Future<ApiResult> approvals() => _get(myApprovalsUrl);
  Future<ApiResult> approvalCounts() => _get(myApprovalCountsUrl);
  Future<ApiResult> approval(int requestId) => _get(myApprovalUrl(requestId));

  /// [action] = `approved` | `rejected`; [comments] max 500.
  Future<ApiResult> actOnStep(int stepId,
          {required String action, String? comments}) =>
      _post(myApprovalStepUrl(stepId), {
        'action': action,
        if (comments != null && comments.trim().isNotEmpty)
          'comments': comments.trim(),
      });

  // ── Finance: executions (loan / leave settlement) ─────────────────────
  Future<ApiResult> execution(int id) => _get(myExecutionUrl(id));
  Future<ApiResult> executionSettlement(int id) =>
      _get(myExecutionSettlementUrl(id));

  /// Loan: optional `tot_amt_tobe_paid`, `no_of_installment`,
  /// `deduction_startdate_g` (YYYY-MM-DD), `notes`. Leave settlement: no fields.
  Future<ApiResult> payExecution(int id, [Map<String, dynamic>? fields]) =>
      _post(myExecutionUrl(id), fields);
  Future<ApiResult> returnExecution(int id, String reason) =>
      _post(myExecutionReturnUrl(id), {'reason': reason});

  // ── Finance: final settlements ─────────────────────────────────────────
  Future<ApiResult> finalSettlementPrint(int taskId) =>
      _get(myFinalSettlementPrintUrl(taskId));
  Future<ApiResult> payFinalSettlement(int taskId) =>
      _post(myFinalSettlementPayUrl(taskId));
  Future<ApiResult> returnFinalSettlement(int taskId, String reason) =>
      _post(myFinalSettlementReturnUrl(taskId), {'reason': reason});

  // ── Documents ──────────────────────────────────────────────────────────
  /// Fields: `doc_id`, `doc_no`, `country_id`, `city_issued`,
  /// `dateissued_g`, `dateexpire_g`; [filePath] sent as `file`.
  Future<ApiResult> renewDocument(int id, Map<String, dynamic> fields,
      {String? filePath}) async {
    final map = <String, dynamic>{};
    fields.forEach((k, v) {
      if (v != null && v.toString().isNotEmpty) map[k] = v.toString();
    });
    if (filePath != null && filePath.isNotEmpty) {
      map['file'] = await MultipartFile.fromFile(filePath,
          filename: filePath.split('/').last);
    }
    return _postMultipart(myDocumentRenewUrl(id), FormData.fromMap(map));
  }

  // ── Notifications ──────────────────────────────────────────────────────
  /// Downloads a broadcast attachment as bytes.
  Future<ApiResult> notificationAttachment(int id) async {
    final url = await _url(myNotificationAttachmentUrl(id));
    return ApiResult.guard(() => _dio.get(url,
        queryParameters: _q(),
        options: _opts.copyWith(responseType: ResponseType.bytes)));
  }

  // ── Assigned overtime ──────────────────────────────────────────────────
  /// [status] = pending | accepted | rejected | all.
  /// `{ success, data: { pending_count, items: [...] } }`
  Future<ApiResult> assignedOvertime({String status = 'all'}) =>
      _get(assignedOvertimeUrl, {'status': status});
  Future<ApiResult> assignedOvertimeDetail(int id) =>
      _get(assignedOvertimeDetailUrl(id));
  Future<ApiResult> acceptOvertime(int id, {String? note}) =>
      _post(assignedOvertimeAcceptUrl(id),
          {if (note != null && note.trim().isNotEmpty) 'note': note.trim()});
  Future<ApiResult> rejectOvertime(int id, {String? note}) =>
      _post(assignedOvertimeRejectUrl(id),
          {if (note != null && note.trim().isNotEmpty) 'note': note.trim()});
}
