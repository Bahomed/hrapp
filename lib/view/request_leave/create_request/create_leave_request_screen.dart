// File: lib/view/request_leave/create_request/create_leave_request_screen.dart
//
// New leave request → POST my/requests (request_type = Leave).
// Leave types and balances come from GET my/requests/options; the number of
// days from GET my/requests/count-days whenever the type or dates change.

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../../services/theme_service.dart';
import '../my_request_models.dart';
import '../request_controller.dart';
import 'request_form_widgets.dart';

class CreateLeaveRequestScreen extends StatefulWidget {
  const CreateLeaveRequestScreen({super.key});

  @override
  State<CreateLeaveRequestScreen> createState() => _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState extends State<CreateLeaveRequestScreen> {
  final controller = Get.find<RequestController>();
  final formKey = GlobalKey<FormState>();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final reasonController = TextEditingController();

  MyLeaveType? leaveType;
  DateTime? startDate;
  DateTime? endDate;
  bool ticket = false;
  bool exitReentry = false;
  File? attachment;

  // count-days
  num? days;
  bool countingDays = false;
  String? daysError;
  int _countToken = 0;

  Map<String, List<String>> fieldErrors = const {};

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  String? _serverError(String field) {
    final l = fieldErrors[field];
    return (l == null || l.isEmpty) ? null : l.first;
  }

  /// GET my/requests/count-days when type + both dates are set.
  Future<void> _countDays() async {
    final t = leaveType;
    final s = startDate;
    final e = endDate;
    setState(() {
      days = null;
      daysError = null;
    });
    if (t == null || s == null || e == null || e.isBefore(s)) return;

    final token = ++_countToken;
    setState(() => countingDays = true);
    final r = await controller.countLeaveDays(leaveTypeId: t.id, from: s, to: e);
    if (!mounted || token != _countToken) return;
    setState(() {
      countingDays = false;
      if (r.ok) {
        final v = r.json['days'];
        days = v is num ? v : num.tryParse('$v');
        if (days == null) daysError = tr('could_not_count_days');
      } else {
        daysError = r.displayMessage(tr('could_not_count_days'));
      }
    });
  }

  /// Message when the days are over the balance and sending must be blocked.
  String? get _overLimitMessage {
    final t = leaveType;
    final d = days;
    if (t == null || d == null || !t.blocks(d)) return null;
    return trParams('leave_days_over_limit', {
      'days': formatNumber(d),
      'limit': formatNumber(t.limit),
    });
  }

  /// Sending is blocked while counting and when over the allowed days.
  bool get _blocked => countingDays || _overLimitMessage != null;

  Future<void> _submit() async {
    setState(() => fieldErrors = const {});
    if (!formKey.currentState!.validate()) return;
    final t = leaveType!;
    if (t.requiresAttachment && attachment == null) {
      Get.snackbar(tr('error'), tr('attachment_required_for_leave_type'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getErrorColor(),
          colorText: Colors.white);
      return;
    }
    if (countingDays) return;
    final blockMsg = _overLimitMessage ?? daysError;
    if (blockMsg != null || days == null) {
      Get.snackbar(tr('error'), blockMsg ?? tr('could_not_count_days'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: ThemeService.instance.getErrorColor(),
          colorText: Colors.white);
      return;
    }

    final r = await controller.submitMyRequest({
      'request_type': MyRequestType.leave,
      'request_type_id': t.id,
      'start_date_g': toApiDate(startDate!),
      'end_date_g': toApiDate(endDate!),
      'no_of_days': days,
      'remarks': reasonController.text.trim(),
      if (t.requiresTicket) 'ticket': ticket ? 1 : 0,
      if (t.requiresExitReentry) 'exit_reentry': exitReentry ? 1 : 0,
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
    final color = themeService.getActionColor('requests');

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
          tr('create_leave_request'),
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
                icon: Icons.calendar_today,
                title: tr('leave_request'),
                subtitle: tr('leave_request_description'),
                color: color,
              ),
              const SizedBox(height: 24),

              // Leave type (label shows the balance)
              Obx(() {
                final types = controller.options.value?.leaveTypes ?? const <MyLeaveType>[];
                return RequestDropdownField<MyLeaveType>(
                  label: tr('leave_type'),
                  value: leaveType == null
                      ? null
                      : types.firstWhereOrNull((t) => t.id == leaveType!.id),
                  items: types,
                  itemLabel: controller.leaveTypeLabel,
                  isLoading: controller.isLoadingTypes.value,
                  color: color,
                  validator: (v) =>
                      v == null ? tr('please_select_leave_type') : _serverError('request_type_id'),
                  onChanged: (v) {
                    setState(() {
                      leaveType = v;
                      ticket = false;
                      exitReentry = false;
                    });
                    _countDays();
                  },
                );
              }),

              const SizedBox(height: 20),

              RequestDateField(
                label: tr('start_date'),
                controller: startDateController,
                color: color,
                firstDate: controller.firstAllowedDate,
                validator: (v) => (v == null || v.isEmpty)
                    ? tr('please_select_start_date')
                    : _serverError('start_date_g'),
                onPicked: (d) {
                  startDate = d;
                  if (endDate != null && endDate!.isBefore(d)) {
                    endDate = null;
                    endDateController.clear();
                  }
                  _countDays();
                },
              ),

              const SizedBox(height: 20),

              RequestDateField(
                label: tr('end_date'),
                controller: endDateController,
                color: color,
                firstDate: startDate ?? controller.firstAllowedDate,
                validator: (v) {
                  if (v == null || v.isEmpty) return tr('please_select_end_date');
                  if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
                    return tr('end_date_after_start_date');
                  }
                  return _serverError('end_date_g');
                },
                onPicked: (d) {
                  endDate = d;
                  _countDays();
                },
              ),

              const SizedBox(height: 16),
              _buildDaysInfo(themeService, color),
              const SizedBox(height: 20),

              RequestTextAreaField(
                label: tr('reason'),
                controller: reasonController,
                color: color,
                validator: (_) => _serverError('remarks'),
              ),

              if (leaveType != null &&
                  (leaveType!.requiresTicket || leaveType!.requiresExitReentry)) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeService.getCardColor(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeService.getTextSecondaryColor().withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (leaveType!.requiresTicket)
                        _checkbox(tr('ticket'), ticket, (v) => setState(() => ticket = v), color),
                      if (leaveType!.requiresExitReentry)
                        _checkbox(tr('exit_reentry'), exitReentry,
                            (v) => setState(() => exitReentry = v), color),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              RequestAttachmentPicker(
                file: attachment,
                required: leaveType?.requiresAttachment ?? false,
                color: color,
                errorText: _serverError('attachment'),
                onChanged: (f) => setState(() => attachment = f),
              ),

              const SizedBox(height: 32),

              Obx(() => RequestSubmitButton(
                    label: tr('submit_leave_request'),
                    color: color,
                    loading: controller.isSubmitting.value,
                    onPressed: _blocked ? null : _submit,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _checkbox(String title, bool value, ValueChanged<bool> onChanged, Color color) {
    final themeService = ThemeService.instance;
    return CheckboxListTile(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      activeColor: color,
      checkColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  /// "3 days" (+ balance), a spinner while counting, or the block message.
  Widget _buildDaysInfo(ThemeService themeService, Color color) {
    if (countingDays) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
          const SizedBox(width: 10),
          Text(tr('counting_days'),
              style: TextStyle(color: themeService.getTextSecondaryColor())),
        ],
      );
    }
    final over = _overLimitMessage;
    final err = daysError;
    if (days == null && err == null) return const SizedBox.shrink();

    final isError = over != null || err != null;
    final c = isError ? themeService.getErrorColor() : color;
    final text = err ??
        over ??
        trParams('leave_days_count', {'days': formatNumber(days)}) +
            (leaveType?.available != null
                ? ' • ${trParams('days_available', {'days': formatNumber(leaveType!.available)})}'
                : '');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.event_available, color: c, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: c, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
