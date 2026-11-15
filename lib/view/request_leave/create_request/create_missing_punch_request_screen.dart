// New missing punch request → POST my/requests (request_type = MissingPunch):
// start_date_g (the day), permit_from (in time), permit_to (out time), reason.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../../services/theme_service.dart';
import '../my_request_models.dart';
import '../request_controller.dart';
import 'request_form_widgets.dart';

class CreateMissingPunchRequestScreen extends StatefulWidget {
  const CreateMissingPunchRequestScreen({super.key});

  @override
  State<CreateMissingPunchRequestScreen> createState() =>
      _CreateMissingPunchRequestScreenState();
}

class _CreateMissingPunchRequestScreenState extends State<CreateMissingPunchRequestScreen> {
  static const _color = Color(0xFF6C5CE7);

  final controller = Get.find<RequestController>();
  final formKey = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final inController = TextEditingController();
  final outController = TextEditingController();
  final reasonController = TextEditingController();
  DateTime? date;
  File? attachment;
  Map<String, List<String>> fieldErrors = const {};

  @override
  void dispose() {
    dateController.dispose();
    inController.dispose();
    outController.dispose();
    reasonController.dispose();
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
    FocusScope.of(context).unfocus();
    final r = await controller.submitMyRequest({
      'request_type': MyRequestType.missingPunch,
      'start_date_g': toApiDate(date!),
      if (inController.text.isNotEmpty) 'permit_from': inController.text,
      if (outController.text.isNotEmpty) 'permit_to': outController.text,
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
          tr('create_missing_punch_request'),
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
                icon: Icons.fingerprint,
                title: tr('missing_punch_request'),
                subtitle: tr('missing_punch_request_description'),
                color: _color,
              ),
              const SizedBox(height: 24),
              RequestDateField(
                label: tr('date'),
                controller: dateController,
                color: _color,
                firstDate: controller.firstAllowedDate,
                lastDate: DateTime.now(),
                validator: (v) =>
                    (v == null || v.isEmpty) ? tr('please_select_date') : _err('start_date_g'),
                onPicked: (d) => date = d,
              ),
              const SizedBox(height: 20),
              RequestTimeField(
                label: tr('check_in'),
                controller: inController,
                color: _color,
                validator: (v) {
                  if ((v == null || v.isEmpty) && outController.text.isEmpty) {
                    return tr('enter_check_in_or_out');
                  }
                  return _err('permit_from');
                },
              ),
              const SizedBox(height: 20),
              RequestTimeField(
                label: tr('check_out'),
                controller: outController,
                color: _color,
                validator: (v) {
                  if (v == null || v.isEmpty) return _err('permit_to');
                  final i = _minutes(inController.text);
                  final o = _minutes(v);
                  if (i != null && o != null && o <= i) return tr('to_time_after_from_time');
                  return _err('permit_to');
                },
              ),
              const SizedBox(height: 20),
              RequestTextAreaField(
                label: tr('reason'),
                controller: reasonController,
                color: _color,
                validator: (_) => _err('reason'),
              ),
              const SizedBox(height: 20),
              RequestAttachmentPicker(
                file: attachment,
                color: _color,
                errorText: _err('attachment'),
                onChanged: (f) => setState(() => attachment = f),
              ),
              const SizedBox(height: 32),
              Obx(() => RequestSubmitButton(
                    label: tr('submit_missing_punch_request'),
                    color: _color,
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
