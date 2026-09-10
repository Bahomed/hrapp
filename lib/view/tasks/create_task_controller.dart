import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/remote/response/task_models.dart';
import '../../repository/task_repository.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';

/// Drives the "Create Task" flow: pick a type → search an employee →
/// optional title/description → submit. Mirrors NewChatController's
/// debounced server-side search (never load the full employee list).
class CreateTaskController extends GetxController {
  final TaskRepository _repo = TaskRepository();
  final ThemeService _theme = ThemeService.instance;

  final RxBool loadingTypes = true.obs;
  final RxList<TaskType> types = <TaskType>[].obs;
  final Rxn<TaskType> selectedType = Rxn<TaskType>();

  final RxString query = ''.obs;
  final RxBool searching = false.obs;
  final RxList<TaskEmployee> results = <TaskEmployee>[].obs;
  final Rxn<TaskEmployee> selectedEmployee = Rxn<TaskEmployee>();

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  final RxBool submitting = false.obs;

  Timer? _debounce;

  bool get canSubmit =>
      selectedType.value != null &&
      selectedEmployee.value != null &&
      !submitting.value;

  @override
  void onInit() {
    super.onInit();
    _loadTypes();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    titleCtrl.dispose();
    descCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadTypes() async {
    try {
      loadingTypes.value = true;
      types.value = await _repo.getTypes();
    } catch (e) {
      _snack(tr('error'), e.toString());
    } finally {
      loadingTypes.value = false;
    }
  }

  void selectType(TaskType t) => selectedType.value = t;

  void onQueryChanged(String q) {
    query.value = q;
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      results.clear();
      searching.value = false;
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        searching.value = true;
        results.value = await _repo.searchEmployees(q.trim());
      } catch (_) {
        results.clear();
      } finally {
        searching.value = false;
      }
    });
  }

  void selectEmployee(TaskEmployee e) {
    selectedEmployee.value = e;
    query.value = '';
    results.clear();
  }

  void clearEmployee() {
    selectedEmployee.value = null;
    query.value = '';
    results.clear();
  }

  Future<void> submit() async {
    final type = selectedType.value;
    final emp = selectedEmployee.value;
    if (type == null || emp == null) {
      _snack(tr('error'), tr('select_type_and_employee'));
      return;
    }
    if (submitting.value) return;
    try {
      submitting.value = true;
      await _repo.createTask(
        taskType: type.code,
        employeeId: emp.id,
        title: titleCtrl.text,
        description: descCtrl.text,
      );
      Get.back(result: true);
      Get.snackbar(
        tr('success'),
        tr('task_created'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _theme.getSuccessColor(),
        colorText: Colors.white,
      );
    } catch (e) {
      _snack(tr('error'), e.toString());
    } finally {
      submitting.value = false;
    }
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _theme.getErrorColor(),
      colorText: Colors.white,
    );
  }
}
