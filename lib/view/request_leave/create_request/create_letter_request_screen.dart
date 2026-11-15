// New letter request → POST my/requests (request_type = Letter):
// request_type_id (letter type id), reason.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../../services/theme_service.dart';
import '../my_request_models.dart';
import '../request_controller.dart';
import 'request_form_widgets.dart';

class CreateLetterRequestScreen extends StatefulWidget {
  const CreateLetterRequestScreen({super.key});

  @override
  State<CreateLetterRequestScreen> createState() => _CreateLetterRequestScreenState();
}

class _CreateLetterRequestScreenState extends State<CreateLetterRequestScreen> {
  final controller = Get.find<RequestController>();
  final formKey = GlobalKey<FormState>();
  final reasonController = TextEditingController();
  MyNamedOption? letterType;
  File? attachment;
  Map<String, List<String>> fieldErrors = const {};

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  String? _err(String field) => fieldErrors[field]?.firstOrNull;

  Future<void> _submit() async {
    setState(() => fieldErrors = const {});
    if (!formKey.currentState!.validate()) return;
    final r = await controller.submitMyRequest({
      'request_type': MyRequestType.letter,
      'request_type_id': letterType!.id,
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
    final color = themeService.getActionColor('documents');

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
          tr('create_letter_request'),
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
                icon: Icons.description,
                title: tr('letter_request'),
                subtitle: tr('letter_request_description'),
                color: color,
              ),
              const SizedBox(height: 24),
              Obx(() {
                final types = controller.options.value?.letterTypes ?? const <MyNamedOption>[];
                return RequestDropdownField<MyNamedOption>(
                  label: tr('letter_type'),
                  value: letterType == null ? null : types.firstWhereOrNull((t) => t == letterType),
                  items: types,
                  itemLabel: (t) => t.name,
                  isLoading: controller.isLoadingTypes.value,
                  color: color,
                  validator: (v) =>
                      v == null ? tr('please_select_letter_type') : _err('request_type_id'),
                  onChanged: (v) => setState(() => letterType = v),
                );
              }),
              const SizedBox(height: 20),
              RequestTextAreaField(
                label: tr('reason'),
                controller: reasonController,
                color: color,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? tr('please_enter_reason')
                    : _err('reason'),
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
                    label: tr('submit_letter_request'),
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
