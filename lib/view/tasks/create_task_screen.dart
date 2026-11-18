import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'create_task_controller.dart';
import 'package:co.injazathr.injazathr/widgets/searchable_dropdown.dart';

/// Create a manual task: type picker → debounced employee search → optional
/// title/description → submit. A 422 from the API surfaces as a snackbar.
class CreateTaskScreen extends StatelessWidget {
  const CreateTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final c = Get.put(CreateTaskController());

    return Scaffold(
      backgroundColor: theme.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: theme.getSurfaceColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr('create_task'),
          style: TextStyle(
            color: theme.getTextPrimaryColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Label(text: tr('task_type')),
            const SizedBox(height: 6),
            _TypeField(controller: c, theme: theme),
            const SizedBox(height: 18),
            _Label(text: tr('employee')),
            const SizedBox(height: 6),
            _EmployeeField(controller: c, theme: theme),
            const SizedBox(height: 18),
            _Label(text: '${tr('title')} (${tr('optional')})'),
            const SizedBox(height: 6),
            _PlainField(
              controller: c.titleCtrl,
              hint: tr('title'),
              theme: theme,
            ),
            const SizedBox(height: 18),
            _Label(text: '${tr('description')} (${tr('optional')})'),
            const SizedBox(height: 6),
            _PlainField(
              controller: c.descCtrl,
              hint: tr('description'),
              theme: theme,
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 28),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: c.canSubmit ? c.submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.getPrimaryColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: c.submitting.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            tr('create_task'),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _TypeField extends StatelessWidget {
  final CreateTaskController controller;
  final ThemeService theme;
  const _TypeField({required this.controller, required this.theme});

  Future<void> _openPicker(BuildContext context) async {
    if (controller.loadingTypes.value || controller.types.isEmpty) return;
    final picked = await showSearchablePicker(
      context: context,
      title: tr('select_task_type'),
      items: controller.types.toList(),
      itemLabel: (t) => t.name,
      selected: controller.selectedType.value,
      isSelected: (a, b) => a.code == b.code,
    );
    if (picked != null) controller.selectType(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedType.value;
      return InkWell(
        onTap: () => _openPicker(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: theme.getCardColor(),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: theme.getDividerColor()),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected?.name ?? tr('select_task_type'),
                  style: TextStyle(
                    fontSize: 14,
                    color: selected == null
                        ? theme.getTextSecondaryColor()
                        : theme.getTextPrimaryColor(),
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: theme.getTextSecondaryColor()),
            ],
          ),
        ),
      );
    });
  }
}

class _EmployeeField extends StatelessWidget {
  final CreateTaskController controller;
  final ThemeService theme;
  const _EmployeeField({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _content(context));
  }

  Widget _content(BuildContext context) {
    final locale = getCurrentLanguage();
    final selected = controller.selectedEmployee.value;

    if (selected != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.getCardColor(),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.getPrimaryColor()),
        ),
        child: Row(
          children: [
            Icon(Icons.person, size: 18, color: theme.getPrimaryColor()),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected.displayName(locale),
                style: TextStyle(
                  fontSize: 13.5,
                  color: theme.getTextPrimaryColor(),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 18, color: theme.getTextSecondaryColor()),
              onPressed: controller.clearEmployee,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        TextField(
          onChanged: controller.onQueryChanged,
          style: TextStyle(fontSize: 14, color: theme.getTextPrimaryColor()),
          decoration: InputDecoration(
            hintText: tr('search_employee'),
            hintStyle: TextStyle(
                fontSize: 13.5, color: theme.getTextSecondaryColor()),
            prefixIcon: Icon(Icons.search, color: theme.getTextSecondaryColor()),
            suffixIcon: controller.searching.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.getDividerColor()),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.getDividerColor()),
            ),
          ),
        ),
        if (controller.results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: theme.getCardColor(),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.getDividerColor()),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: controller.results.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: theme.getDividerColor()),
              itemBuilder: (_, i) {
                final e = controller.results[i];
                return ListTile(
                  dense: true,
                  title: Text(
                    e.displayName(locale),
                    style: TextStyle(
                        fontSize: 13, color: theme.getTextPrimaryColor()),
                  ),
                  subtitle: (e.email ?? '').isEmpty
                      ? null
                      : Text(e.email!,
                          style: TextStyle(
                              fontSize: 11,
                              color: theme.getTextSecondaryColor())),
                  onTap: () => controller.selectEmployee(e),
                );
              },
            ),
          ),
        if (controller.query.value.trim().isNotEmpty &&
            !controller.searching.value &&
            controller.results.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                tr('no_employees_found'),
                style: TextStyle(
                    fontSize: 12, color: theme.getTextSecondaryColor()),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlainField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ThemeService theme;
  final int minLines;
  final int maxLines;

  const _PlainField({
    required this.controller,
    required this.hint,
    required this.theme,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: TextStyle(fontSize: 14, color: theme.getTextPrimaryColor()),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(fontSize: 13.5, color: theme.getTextSecondaryColor()),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.getDividerColor()),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.getDividerColor()),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: theme.getTextSecondaryColor(),
      ),
    );
  }
}
