// New permit request → POST my/requests (request_type = Permit):
// permit_date, permit_from (HH:mm), permit_to (HH:mm), reason, attachment.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../../services/theme_service.dart';
import '../my_request_models.dart';
import '../request_controller.dart';
import 'request_form_widgets.dart';

class CreatePermissionRequestScreen extends StatefulWidget {
  const CreatePermissionRequestScreen({super.key});

  @override
  State<CreatePermissionRequestScreen> createState() => _CreatePermissionRequestScreenState();
}

class _CreatePermissionRequestScreenState extends State<CreatePermissionRequestScreen> {
  final controller = Get.find<RequestController>();
  final formKey = GlobalKey<FormState>();
  final reasonController = TextEditingController();
  final dateController = TextEditingController(text: toDisplayDate(DateTime.now()));
  final fromController = TextEditingController();
  final toController = TextEditingController();
  DateTime date = DateTime.now();
  File? attachment;
  Map<String, List<String>> fieldErrors = const {};

  @override
  void dispose() {
    reasonController.dispose();
    dateController.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  String? _err(String field) => fieldErrors[field]?.firstOrNull;

  int? _minutes(String hhmm) {
    final p = hhmm.split(':');
    if (p.length != 2) return null;
    final h = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    return (h == null || m == null) ? null : h * 60 + m;
  }

  Future<void> _submit() async {
    setState(() => fieldErrors = const {});
    if (!formKey.currentState!.validate()) return;
    final r = await controller.submitMyRequest({
      'request_type': MyRequestType.permit,
      'permit_date': toApiDate(date),
      'permit_from': fromController.text,
      'permit_to': toController.text,
      'reason': reasonController.text.trim(),
    }, attachmentPath: attachment?.path);
    if (!mounted) return;
    if (r.ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => fieldErrors = r.fieldErrors);
      formKey.currentState!.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;
    final color = themeService.getActionColor('profile');

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tr('create_permission_request'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RequestFormHeader(
                icon: Icons.badge_outlined,
                title: tr('permission_request'),
                subtitle: tr('permission_request_description'),
                color: color,
              ),
              const SizedBox(height: 24),
              RequestTextAreaField(
                label: tr('reason'),
                controller: reasonController,
                color: color,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? tr('please_enter_reason')
                    : _err('reason'),
              ),
              const SizedBox(height: 20),
              RequestDateField(
                label: tr('permit_date'),
                controller: dateController,
                color: color,
                firstDate: controller.firstAllowedDate,
                validator: (v) =>
                    (v == null || v.isEmpty) ? tr('please_select_date') : _err('permit_date'),
                onPicked: (d) => date = d,
              ),
              const SizedBox(height: 20),
              RequestTimeField(
                label: tr('from_time'),
                controller: fromController,
                color: color,
                validator: (v) =>
                    (v == null || v.isEmpty) ? tr('please_select_from_time') : _err('permit_from'),
              ),
              const SizedBox(height: 20),
              RequestTimeField(
                label: tr('to_time'),
                controller: toController,
                color: color,
                validator: (v) {
                  if (v == null || v.isEmpty) return tr('please_select_to_time');
                  final from = _minutes(fromController.text);
                  final to = _minutes(v);
                  if (from != null && to != null && to <= from) {
                    return tr('to_time_after_from_time');
                  }
                  return _err('permit_to');
                },
              ),
              const SizedBox(height: 20),
              RequestAttachmentPicker(
                file: attachment,
                color: color,
                errorText: _err('attachment'),
                onChanged: (f) => setState(() => attachment = f),
              ),
              const SizedBox(height: 32),
              Obx(() => RequestSubmitButton(
                    label: tr('submit_permission_request'),
                    color: color,
                    loading: controller.isSubmitting.value,
                    onPressed: _submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
