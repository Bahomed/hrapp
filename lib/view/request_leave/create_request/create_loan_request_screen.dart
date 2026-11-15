// New loan request → POST my/requests (request_type = Loan):
// request_type_id, amount_required, no_of_payments,
// amount_per_pay (= amount / payments, 2 decimals), start_date_g, reason.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/saudi_riyal_display.dart';
import '../my_request_models.dart';
import '../request_controller.dart';
import 'request_form_widgets.dart';

class CreateLoanRequestScreen extends StatefulWidget {
  const CreateLoanRequestScreen({super.key});

  @override
  State<CreateLoanRequestScreen> createState() => _CreateLoanRequestScreenState();
}

class _CreateLoanRequestScreenState extends State<CreateLoanRequestScreen> {
  final controller = Get.find<RequestController>();
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final paymentsController = TextEditingController();
  final startDateController = TextEditingController();
  final reasonController = TextEditingController();
  MyNamedOption? loanType;
  DateTime? startDate;
  File? attachment;
  Map<String, List<String>> fieldErrors = const {};

  @override
  void dispose() {
    amountController.dispose();
    paymentsController.dispose();
    startDateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  String? _err(String field) => fieldErrors[field]?.firstOrNull;

  double? get _amount => double.tryParse(amountController.text.trim());
  int? get _payments => int.tryParse(paymentsController.text.trim());

  /// amount / payments rounded to 2 decimals (null until both are valid).
  double? get _perPay {
    final a = _amount;
    final p = _payments;
    if (a == null || p == null || p <= 0) return null;
    return double.parse((a / p).toStringAsFixed(2));
  }

  Future<void> _submit() async {
    setState(() => fieldErrors = const {});
    if (!formKey.currentState!.validate()) return;
    final r = await controller.submitMyRequest({
      'request_type': MyRequestType.loan,
      'request_type_id': loanType!.id,
      'amount_required': _amount,
      'no_of_payments': _payments,
      'amount_per_pay': _perPay!.toStringAsFixed(2),
      'start_date_g': toApiDate(startDate!),
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
    final color = themeService.getSuccessColor();

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
          tr('create_loan_request'),
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
                icon: Icons.account_balance_wallet,
                title: tr('loan_request'),
                subtitle: tr('loan_request_description'),
                color: color,
              ),
              const SizedBox(height: 24),
              Obx(() {
                final types = controller.options.value?.loanTypes ?? const <MyNamedOption>[];
                return RequestDropdownField<MyNamedOption>(
                  label: tr('loan_type'),
                  value: loanType == null ? null : types.firstWhereOrNull((t) => t == loanType),
                  items: types,
                  itemLabel: (t) => t.name,
                  isLoading: controller.isLoadingTypes.value,
                  color: color,
                  validator: (v) =>
                      v == null ? tr('please_select_loan_type') : _err('request_type_id'),
                  onChanged: (v) => setState(() => loanType = v),
                );
              }),
              const SizedBox(height: 20),
              RequestNumberField(
                label: tr('amount'),
                controller: amountController,
                color: color,
                decimal: true,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return tr('please_enter_loan_amount');
                  final a = double.tryParse(v.trim());
                  if (a == null || a <= 0) return tr('please_enter_valid_amount');
                  return _err('amount_required');
                },
              ),
              const SizedBox(height: 20),
              RequestNumberField(
                label: tr('number_of_payments'),
                controller: paymentsController,
                color: color,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return tr('please_enter_repayment_period');
                  final p = int.tryParse(v.trim());
                  if (p == null) return tr('please_enter_valid_number');
                  if (p < 1) return tr('repayment_period_minimum');
                  return _err('no_of_payments');
                },
              ),
              if (_perPay != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text('${tr('amount_per_payment')}: ',
                          style: TextStyle(
                              color: themeService.getTextPrimaryColor(),
                              fontWeight: FontWeight.w500)),
                      SaudiRiyalDisplay(
                        amount: _perPay,
                        style: TextStyle(color: color, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              RequestDateField(
                label: tr('start_date'),
                controller: startDateController,
                color: color,
                firstDate: controller.firstAllowedDate,
                validator: (v) =>
                    (v == null || v.isEmpty) ? tr('please_select_start_date') : _err('start_date_g'),
                onPicked: (d) => startDate = d,
              ),
              const SizedBox(height: 20),
              RequestTextAreaField(
                label: tr('reason'),
                controller: reasonController,
                color: color,
                validator: (_) => _err('reason'),
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
                    label: tr('submit_loan_request'),
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
