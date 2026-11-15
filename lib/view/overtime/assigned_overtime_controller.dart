import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/compensation/portal_ui.dart';

/// Filters of `GET assigned-overtime?status=`.
const overtimeFilters = ['all', 'pending', 'accepted', 'rejected'];

/// Assigned overtime (HR assigns; the employee accepts or rejects).
/// Only accepted overtime is counted and paid.
class AssignedOvertimeController extends GetxController {
  final MyRepository _repo = MyRepository();

  final filter = 'all'.obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final items = <Map<String, dynamic>>[].obs;
  final pendingCount = 0.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  void setFilter(String f) {
    if (filter.value == f) return;
    filter.value = f;
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    final r = await _repo.assignedOvertime(status: filter.value);
    if (!r.ok) {
      errorMessage.value = r.displayMessage(tr('something_went_wrong', fallback: 'Something went wrong'));
      items.clear();
      isLoading.value = false;
      return;
    }
    final data = r.json['data'];
    final body = data is Map ? PortalUi.map(data) : r.json;
    final list = data is List ? PortalUi.list(data) : PortalUi.list(body['items']);
    // Pending first (the server already does this; keep it stable here too).
    list.sort((a, b) => (a['status'] == 'pending' ? 0 : 1).compareTo(b['status'] == 'pending' ? 0 : 1));
    items.assignAll(list);
    pendingCount.value = PortalUi.toInt(body['pending_count']) ??
        list.where((e) => e['status'] == 'pending').length;
    isLoading.value = false;
  }

  Future<ApiResult> detail(int id) => _repo.assignedOvertimeDetail(id);

  /// Accept ([accept] = true) or reject. Returns the result so the caller can
  /// show the message; the list is reloaded on success.
  Future<ApiResult> respond(int id, {required bool accept, String? note}) async {
    isSubmitting.value = true;
    final r = accept
        ? await _repo.acceptOvertime(id, note: note)
        : await _repo.rejectOvertime(id, note: note);
    isSubmitting.value = false;
    if (r.ok) await load();
    return r;
  }
}

/// Read-only history of the old overtime REQUESTS
/// (`GET requests/overtime`, `GET requests/overtime/{id}`).
/// Employees can no longer create overtime requests.
class OvertimeHistoryApi {
  static const _path = '/api/requests/overtime';
  final Preferences _prefs = Preferences();

  Future<ApiResult> _get(String path) async {
    final url = '${await _prefs.getWorkspaceUrl()}$path';
    final locale = ApiHelper.instance.getCurrentLocale();
    return ApiResult.guard(() => DioClient().dio.get(
          url,
          queryParameters: {'locale': locale},
          options: Options(headers: {'Accept': 'application/json', 'Accept-Language': locale}),
        ));
  }

  Future<ApiResult> list() => _get(_path);
  Future<ApiResult> detail(int id) => _get('$_path/$id');
}
