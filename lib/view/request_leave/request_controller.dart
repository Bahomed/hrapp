// RequestController — "My Requests" (Task 5).
//
// Lists, options, day counts, creation and deletion go through the new
// `/api/my/requests...` endpoints (company's current rules). Editing a
// pending request still uses the old per-type update endpoints (the new API
// has no update call). Overtime is read-only history from the old
// `requests/overtime` endpoint: employees no longer request overtime.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:co.injazathr.injazathr/data/remote/response/base_response.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/data/remote/response/overtime_request_response.dart';
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/repository/requestrepository.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';
import 'package:co.injazathr.injazathr/view/request_leave/my_request_models.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/create_leave_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/create_permission_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/create_loan_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/create_letter_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/edit_letter_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/edit_loan_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/edit_permission_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/edit_leave_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/create_missing_punch_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/create_request/edit_missing_punch_request_screen.dart';
import 'package:co.injazathr.injazathr/view/request_detail/request_detail_screen.dart';

import '../../utils/translation_helper.dart';

/// Request type values used by `my/requests` (`request_type` / `types`).
class MyRequestType {
  static const leave = 'Leave';
  static const permit = 'Permit';
  static const loan = 'Loan';
  static const letter = 'Letter';
  static const missingPunch = 'MissingPunch';
}

class RequestController extends GetxController with GetTickerProviderStateMixin {
  final RequestRepository _requestRepository = RequestRepository();
  final MyRepository _my = MyRepository();

  // ── State ──────────────────────────────────────────────────────────────
  final RxString selectedFilter = 'all'.obs;
  final RxBool isLoading = false.obs; // list loading
  final RxBool isSubmitting = false.obs; // create / update / delete in flight

  /// Everything from GET my/requests.
  final RxList<MyRequestItem> _allRequests = <MyRequestItem>[].obs;

  /// `counts` from GET my/requests: all, for-approval, approved, rejected.
  final RxMap<String, int> statusCounts = <String, int>{}.obs;

  // Filtered per tab
  final RxList<MyRequestItem> leaveRequests = <MyRequestItem>[].obs;
  final RxList<MyRequestItem> permissionRequests = <MyRequestItem>[].obs;
  final RxList<MyRequestItem> loanRequests = <MyRequestItem>[].obs;
  final RxList<MyRequestItem> letterRequests = <MyRequestItem>[].obs;
  final RxList<MyRequestItem> missingPunchRequests = <MyRequestItem>[].obs;

  // Overtime: old history, read only.
  final RxList<OvertimeRequest> _allOvertimeRequests = <OvertimeRequest>[].obs;
  final RxList<OvertimeRequest> overtimeRequests = <OvertimeRequest>[].obs;
  final RxBool isLoadingOvertime = false.obs;
  final RxBool isLoadingMoreOvertime = false.obs;
  final RxList<int> loadedYearsOvertime = <int>[].obs;
  final RxBool hasMoreDataOvertime = true.obs;

  // Options (GET my/requests/options)
  final Rx<MyRequestOptions?> options = Rx<MyRequestOptions?>(null);
  final RxBool isLoadingTypes = false.obs;
  final RxString optionsError = ''.obs;

  /// Old-style option lists kept for the edit screens (built from options).
  final RxList<RequestTypeOption> leaveTypes = <RequestTypeOption>[].obs;
  final RxList<RequestTypeOption> loanTypes = <RequestTypeOption>[].obs;
  final RxList<RequestTypeOption> letterTypes = <RequestTypeOption>[].obs;

  final RxString allowBackdateRequest = 'N'.obs;

  late TabController tabController;

  List<Map<String, dynamic>> get filters => [
        {'name': _withCount(tr('all'), 'all'), 'key': 'all', 'color': getFilterColor('all')},
        {'name': _withCount(tr('approved'), 'approved'), 'key': 'approved', 'color': getFilterColor('approved')},
        {'name': _withCount(tr('rejected'), 'rejected'), 'key': 'rejected', 'color': getFilterColor('rejected')},
        {'name': _withCount(tr('for_approval'), 'for-approval'), 'key': 'for-approval', 'color': getFilterColor('pending')},
      ];

  String _withCount(String label, String key) {
    final c = statusCounts[key];
    return c == null ? label : '$label ($c)';
  }

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    loadAllRequests();
    loadRequestOptions();
    _loadAllowBackdateRequest();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> _loadAllowBackdateRequest() async {
    allowBackdateRequest.value = await Preferences().getAllowBackdateRequest();
  }

  bool get canBackdate => allowBackdateRequest.value == 'Y';

  DateTime get firstAllowedDate =>
      canBackdate ? DateTime(DateTime.now().year - 5) : DateTime.now();

  // ── Loading ────────────────────────────────────────────────────────────
  void loadAllRequests() {
    loadMyRequests();
  }

  Future<void> refreshRequests() async {
    await Future.wait([loadMyRequests(), loadRequestOptions()]);
  }

  /// GET my/requests → all request types + status counts.
  Future<void> loadMyRequests() async {
    isLoading.value = true;
    try {
      final r = await _my.requests();
      if (!r.ok) {
        _showErrorSnackbar(r.displayMessage(tr('failed_to_load_requests')));
        return;
      }
      final json = r.json;
      _allRequests.value = extractList(json, const ['requests', 'data'])
          .map(MyRequestItem.fromJson)
          .toList();
      final counts = <String, int>{};
      final rawCounts = json['counts'];
      if (rawCounts is Map) {
        rawCounts.forEach((k, v) {
          final n = v is num ? v.toInt() : int.tryParse('$v');
          if (n != null) counts[k.toString()] = n;
        });
      }
      statusCounts.value = counts;
      _applyFilter();
    } finally {
      isLoading.value = false;
    }
  }

  /// GET my/requests/options → allowed types and leave/loan/letter types.
  Future<void> loadRequestOptions() async {
    isLoadingTypes.value = true;
    optionsError.value = '';
    try {
      final r = await _my.requestOptions();
      if (!r.ok) {
        optionsError.value = r.displayMessage(tr('failed_to_load_request_options'));
        return;
      }
      final o = MyRequestOptions.fromJson(r.json);
      options.value = o;
      // Old-style lists for the edit screens. ticket_exit_permit is no
      // longer sent by the server, so it is never 'Y' here.
      leaveTypes.value = o.leaveTypes
          .map((t) => RequestTypeOption(
                id: t.id,
                name: t.name,
                ticketExitPermit: 'N',
                leaveDuration: t.maxDays?.toInt() ?? 0,
                notAllowedToIncreaseFromLeaveDuration: 'N',
              ))
          .toList();
      loanTypes.value = o.loanTypes
          .map((t) => RequestTypeOption(
              id: t.id, name: t.name, ticketExitPermit: 'N', leaveDuration: 0,
              notAllowedToIncreaseFromLeaveDuration: 'N'))
          .toList();
      letterTypes.value = o.letterTypes
          .map((t) => RequestTypeOption(
              id: t.id, name: t.name, ticketExitPermit: 'N', leaveDuration: 0,
              notAllowedToIncreaseFromLeaveDuration: 'N'))
          .toList();
    } finally {
      isLoadingTypes.value = false;
    }
  }

  /// Old overtime history (read only).
  Future<void> loadOvertimeRequests() async {
    isLoadingOvertime.value = true;
    loadedYearsOvertime
      ..clear()
      ..add(DateTime.now().year);
    hasMoreDataOvertime.value = true;
    try {
      final response = await _requestRepository.getOvertimeRequests(year: DateTime.now().year);
      if (response.success) {
        _allOvertimeRequests.value = response.data;
        _filterOvertime();
      }
    } catch (_) {
      // History only: stay quiet, the tab shows its empty state.
    } finally {
      isLoadingOvertime.value = false;
    }
  }

  Future<void> loadMoreOvertimeRequests() async {
    if (isLoadingMoreOvertime.value || !hasMoreDataOvertime.value) return;
    try {
      isLoadingMoreOvertime.value = true;
      if (loadedYearsOvertime.isEmpty) loadedYearsOvertime.add(DateTime.now().year);
      final nextYear = loadedYearsOvertime.last - 1;
      loadedYearsOvertime.add(nextYear);
      final response = await _requestRepository.getOvertimeRequests(year: nextYear);
      if (response.success) {
        _allOvertimeRequests.value = [..._allOvertimeRequests, ...response.data];
        _filterOvertime();
        if (nextYear <= DateTime.now().year - 5) hasMoreDataOvertime.value = false;
      } else {
        _showErrorSnackbar(response.message);
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoadingMoreOvertime.value = false;
    }
  }

  // ── Filtering ──────────────────────────────────────────────────────────
  void changeFilter(String filterKey) {
    selectedFilter.value = filterKey;
    _applyFilter();
  }

  bool _matches(String status) {
    final f = selectedFilter.value.toLowerCase();
    if (f == 'all') return true;
    return status.toLowerCase() == f;
  }

  void _applyFilter() {
    List<MyRequestItem> of(String typeKey) => _allRequests
        .where((r) => r.typeKey == typeKey && _matches(r.status))
        .toList();
    leaveRequests.value = of('leave');
    permissionRequests.value = [...of('permit'), ...of('permission')];
    loanRequests.value = of('loan');
    letterRequests.value = of('letter');
    missingPunchRequests.value = of('missingpunch');
    _filterOvertime();
  }

  void _filterOvertime() {
    overtimeRequests.value =
        _allOvertimeRequests.where((r) => _matches(r.status)).toList();
  }

  IconData getFilterIcon(String filterKey) {
    switch (filterKey) {
      case 'all':
        return Icons.list;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'for-approval':
        return Icons.schedule;
      default:
        return Icons.circle;
    }
  }

  // ── Counts per tab ─────────────────────────────────────────────────────
  int get leaveRequestCount => leaveRequests.length;
  int get permissionRequestCount => permissionRequests.length;
  int get loanRequestCount => loanRequests.length;
  int get letterRequestCount => letterRequests.length;
  int get overtimeRequestCount => overtimeRequests.length;
  int get missingPunchRequestCount => missingPunchRequests.length;

  Color getFilterColor(String filter) {
    final themeService = ThemeService.instance;
    switch (filter.toLowerCase()) {
      case 'all':
        return themeService.getActionColor('requests');
      case 'approved':
        return themeService.getSuccessColor();
      case 'rejected':
        return themeService.getErrorColor();
      case 'pending':
        return themeService.getWarningColor();
      default:
        return themeService.getTextSecondaryColor();
    }
  }

  // ── Create ─────────────────────────────────────────────────────────────
  /// True when `types` from my/requests/options allows [type]. While the
  /// options are not loaded nothing is offered.
  bool isTypeAllowed(String type) => options.value?.allows(type) ?? false;

  void showRequestTypeDialog() {
    final themeService = Get.find<ThemeService>();
    if (options.value == null) {
      if (isLoadingTypes.value) {
        _showErrorSnackbar(tr('loading'));
      } else {
        _showErrorSnackbar(optionsError.value.isNotEmpty
            ? optionsError.value
            : tr('failed_to_load_request_options'));
        loadRequestOptions();
      }
      return;
    }

    final entries = <Widget>[];
    void add(String type, IconData icon, String title, String subtitle, Color color,
        VoidCallback open) {
      if (!isTypeAllowed(type)) return;
      if (entries.isNotEmpty) entries.add(const SizedBox(height: 12));
      entries.add(_buildRequestTypeOption(
        icon: icon,
        title: title,
        subtitle: subtitle,
        color: color,
        onTap: () {
          Get.back();
          open();
        },
      ));
    }

    add(MyRequestType.leave, Icons.calendar_today, tr('leave_request'),
        tr('request_time_off_work'), themeService.getActionColor('requests'), createLeaveRequest);
    add(MyRequestType.permit, Icons.badge_outlined, tr('permission_request'),
        tr('request_work_permissions'), themeService.getActionColor('profile'), createPermissionRequest);
    add(MyRequestType.loan, Icons.account_balance_wallet, tr('loan_request'),
        tr('request_financial_loan'), themeService.getSuccessColor(), createLoanRequest);
    add(MyRequestType.letter, Icons.description, tr('letter_request'),
        tr('request_official_documents'), themeService.getActionColor('documents'), createLetterRequest);
    add(MyRequestType.missingPunch, Icons.fingerprint, tr('missing_punch_request'),
        tr('missing_punch_request_description'), const Color(0xFF6C5CE7), createMissingPunchRequest);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: themeService.getSurfaceColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tr('create_new_request'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
              const SizedBox(height: 20),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    tr('no_request_types_allowed'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: themeService.getTextSecondaryColor()),
                  ),
                )
              else
                ...entries,
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestTypeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeService = Get.find<ThemeService>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeService.getTextPrimaryColor(),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeService.getTextSecondaryColor(),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: themeService.getTextSecondaryColor().withValues(alpha: 0.6), size: 16),
          ],
        ),
      ),
    );
  }

  void createLeaveRequest() => Get.to(() => const CreateLeaveRequestScreen());
  void createPermissionRequest() => Get.to(() => const CreatePermissionRequestScreen());
  void createLoanRequest() => Get.to(() => const CreateLoanRequestScreen());
  void createLetterRequest() => Get.to(() => const CreateLetterRequestScreen());
  void createMissingPunchRequest() => Get.to(() => const CreateMissingPunchRequestScreen());

  /// "Annual Leave (1.93 days available)" / "(up to 5 days)" / name.
  String leaveTypeLabel(MyLeaveType t) {
    if (t.available != null) {
      return trParams('leave_label_available',
          {'name': t.name, 'days': formatNumber(t.available)});
    }
    if (t.maxDays != null) {
      return trParams('leave_label_up_to', {'name': t.name, 'days': formatNumber(t.maxDays)});
    }
    return t.name;
  }

  /// GET my/requests/count-days. Returns the result (ok / json['days']).
  Future<ApiResult> countLeaveDays({
    required int leaveTypeId,
    required DateTime from,
    required DateTime to,
  }) =>
      _my.countDays(leaveTypeId: leaveTypeId, from: toApiDate(from), to: toApiDate(to));

  /// POST my/requests (multipart). [fields] must include `request_type`.
  /// Returns the result so the form can show field errors under its fields.
  /// On success shows the server message and reloads the list.
  Future<ApiResult> submitMyRequest(Map<String, dynamic> fields, {String? attachmentPath}) async {
    isSubmitting.value = true;
    try {
      final r = await _my.submitRequest(fields, attachmentPath: attachmentPath);
      if (r.ok) {
        _showSuccess(r.displayMessage(tr('request_submitted_successfully')));
        loadMyRequests();
      } else {
        _showErrorSnackbar(r.allErrors(tr('failed_to_submit_request')));
      }
      return r;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── View / delete / edit ───────────────────────────────────────────────
  void openDetails(MyRequestItem item) {
    Get.to(() => RequestDetailScreen(requestId: item.id, requestType: item.type));
  }

  void confirmDelete(MyRequestItem item, {VoidCallback? onDeleted}) {
    Get.dialog(
      Builder(
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(tr('delete_request')),
          content: Text(tr('confirm_delete_request')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('cancel'),
                  style: TextStyle(color: ThemeService.instance.getTextSecondaryColor())),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final ok = await deleteMyRequest(item.id);
                if (ok) onDeleted?.call();
              },
              child: Text(tr('delete'),
                  style: TextStyle(color: ThemeService.instance.getErrorColor())),
            ),
          ],
        ),
      ),
    );
  }

  /// DELETE my/requests/{id}.
  Future<bool> deleteMyRequest(int id) async {
    isSubmitting.value = true;
    try {
      final r = await _my.deleteRequest(id);
      if (r.ok) {
        _showSuccess(r.displayMessage(tr('request_deleted_successfully')));
        await loadMyRequests();
        return true;
      }
      _showErrorSnackbar(r.displayMessage(tr('failed_to_delete_request')));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Edit a pending request: loads the full record from the old per-type
  /// endpoint and opens the existing edit screen (the new API has no update).
  Future<void> editMyRequest(MyRequestItem item) async {
    isSubmitting.value = true;
    try {
      switch (item.typeKey) {
        case 'leave':
          final res = await _requestRepository.getLeaveRequestDetails(item.id);
          if (res.success && res.data != null) {
            Get.to(() => EditLeaveRequestScreen(request: res.data!));
            return;
          }
          _showErrorSnackbar(res.message);
          return;
        case 'permit':
        case 'permission':
          final res = await _requestRepository.getPermissionRequestDetails(item.id);
          if (res.success && res.data != null) {
            Get.to(() => EditPermissionRequestScreen(request: res.data!));
            return;
          }
          _showErrorSnackbar(res.message);
          return;
        case 'loan':
          final res = await _requestRepository.getLoanRequestById(item.id);
          if (res.success && res.data != null) {
            Get.to(() => EditLoanRequestScreen(request: res.data!));
            return;
          }
          _showErrorSnackbar(res.message);
          return;
        case 'letter':
          final res = await _requestRepository.getLetterRequestDetails(item.id);
          if (res.success && res.data != null) {
            Get.to(() => EditLetterRequestScreen(request: res.data!));
            return;
          }
          _showErrorSnackbar(res.message);
          return;
        case 'missingpunch':
          final res = await _requestRepository.getMissingPunchRequestDetails(item.id);
          if (res.success && res.data != null) {
            Get.to(() => EditMissingPunchRequestScreen(request: res.data!));
            return;
          }
          _showErrorSnackbar(res.message);
          return;
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Letter download (approved / generated letters) ─────────────────────
  Future<void> downloadLetter(int requestId) async {
    Get.snackbar(
      tr('downloading_letter'),
      '${tr('downloading_letter')}...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getActionColor('requests'),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );

    try {
      isSubmitting.value = true;
      final response = await _requestRepository.downloadLetter(requestId);

      if (response.success && response.data != null) {
        final downloadUrl = response.data!.downloadUrl;
        final filename = response.data!.filename;
        if (downloadUrl.isEmpty) {
          _showErrorSnackbar(tr('failed_to_download_letter'));
          return;
        }

        String fileExtension;
        if (filename.contains('.')) {
          fileExtension = filename.substring(filename.lastIndexOf('.'));
        } else {
          final path = Uri.parse(downloadUrl).path;
          fileExtension = path.contains('.') ? path.substring(path.lastIndexOf('.')) : '.pdf';
        }
        String cleanFilename = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
        if (!cleanFilename.endsWith(fileExtension)) cleanFilename += fileExtension;

        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$cleanFilename';
        await Dio().download(downloadUrl, filePath);

        final result = await OpenFile.open(filePath);
        if (result.type == ResultType.done) {
          _showSuccess('${tr('letter_downloaded')}: $cleanFilename');
        } else {
          _showErrorSnackbar('${tr('failed_to_open_letter')}: ${result.message}');
        }
      } else {
        _showErrorSnackbar('${tr('failed_to_download_letter')}: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('${tr('error_downloading_letter')}: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── Updates (old per-type endpoints, used by the edit screens) ─────────
  Future<bool> _runUpdate(Future<BaseResponse> Function() call, String successKey) async {
    try {
      isLoading.value = true;
      final response = await call();
      if (response.success) {
        _showSuccess(tr(successKey));
        loadMyRequests();
        return true;
      }
      _showErrorSnackbar(response.message);
      return false;
    } catch (e) {
      _showErrorSnackbar(e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateLeaveRequestWithData({
    required int id,
    required String startDate,
    required String endDate,
    required int leaveTypeId,
    required String reason,
    bool ticket = false,
    bool exitPermit = false,
    List<File>? attachments,
  }) =>
      _runUpdate(
          () => _requestRepository.updateLeaveRequest(
                id: id,
                startDate: startDate,
                endDate: endDate,
                leaveType: leaveTypeId,
                reason: reason,
                ticket: ticket,
                exitPermit: exitPermit,
                attachments: attachments,
              ),
          'leave_request_updated_successfully');

  Future<bool> updatePermissionRequestWithData({
    required int id,
    required String purpose,
    required String date,
    required String fromTime,
    required String toTime,
    List<File>? attachments,
  }) =>
      _runUpdate(
          () => _requestRepository.updatePermissionRequest(
                id: id,
                purpose: purpose,
                date: date,
                fromTime: fromTime,
                toTime: toTime,
                attachments: attachments,
              ),
          'permission_request_updated_successfully');

  Future<bool> updateLoanRequestWithData({
    required int id,
    required int loanTypeId,
    required String purpose,
    required double amount,
    required int repaymentMonths,
    String? startDate,
  }) =>
      _runUpdate(
          () => _requestRepository.updateLoanRequest(
                id: id,
                loanTypeId: loanTypeId,
                purpose: purpose,
                amount: amount,
                repaymentMonths: repaymentMonths,
                startDate: startDate,
              ),
          'loan_request_updated_successfully');

  Future<bool> updateLetterRequestWithData({
    required int id,
    required String reason,
    required int letterTypeId,
  }) =>
      _runUpdate(
          () => _requestRepository.updateLetterRequest(
                id: id,
                reason: reason,
                letterTypeId: letterTypeId,
              ),
          'letter_request_updated_successfully');

  Future<bool> updateMissingPunchRequestWithData({
    required int id,
    required String date,
    String? checkIn,
    String? checkOut,
    String? reason,
  }) =>
      _runUpdate(
          () => _requestRepository.updateMissingPunchRequest(
                id: id,
                date: date,
                checkIn: checkIn,
                checkOut: checkOut,
                reason: reason,
              ),
          'missing_punch_request_updated_successfully');

  // ── Feedback ───────────────────────────────────────────────────────────
  void _showErrorSnackbar(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: ThemeService.instance.getErrorColor(),
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      tr('success'),
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: ThemeService.instance.getSuccessColor(),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}
