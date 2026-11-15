import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/data/remote/response/my_approvals_models.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/api_result.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/approval/approval_ui.dart';

import 'unexecuted_requests_controller.dart';

/// Finance: pay or return loans, leave settlements and final settlements
/// (home key `not_executed`).
import 'settlement_print_screen.dart';
import 'leave_settlement_screen.dart';

class UnexecutedRequestsScreen extends StatelessWidget {
  const UnexecutedRequestsScreen({super.key});

  ThemeService get theme => ThemeService.instance;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(UnexecutedRequestsController());

    return Scaffold(
      backgroundColor: theme.getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          tr('ap_finance'),
          style: TextStyle(color: theme.getTextPrimaryColor(), fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.getSurfaceColor(),
        elevation: 0,
        iconTheme: IconThemeData(color: theme.getTextPrimaryColor()),
        actions: [
          Obx(() => IconButton(
                onPressed: c.isLoading.value ? null : c.loadUnexecutedRequests,
                icon: c.isLoading.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: theme.getTextPrimaryColor()),
                      )
                    : const Icon(Icons.refresh),
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.total == 0 && c.errorMessage.isEmpty) {
          return Center(
              child: CircularProgressIndicator(color: theme.getActionColor('requests')));
        }
        if (c.errorMessage.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: c.refreshRequests,
            child: ApUi.emptyState(
              icon: c.notResponsible.value ? Icons.lock_outline : Icons.error_outline,
              title: c.errorMessage.value,
              onRefresh: c.refreshRequests,
            ),
          );
        }
        return Column(
          children: [
            _tabs(c),
            Expanded(
              child: RefreshIndicator(
                onRefresh: c.refreshRequests,
                child: c.tab.value == 0 ? _executionsList(c, context) : _finalList(c, context),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _tabs(UnexecutedRequestsController c) {
    Widget tab(int i, String label, int count, IconData icon) {
      final selected = c.tab.value == i;
      final color = theme.getActionColor('requests');
      return Expanded(
        child: GestureDetector(
          onTap: () => c.tab.value = i,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? color : color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: selected ? Colors.white : color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: selected ? Colors.white : color)),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Badge(
                    label: Text('$count'),
                    backgroundColor: selected ? Colors.white : theme.getErrorColor(),
                    textColor: selected ? color : Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: theme.getSurfaceColor(),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          tab(0, tr('ap_executions'), c.executions.length, Icons.account_balance_wallet_outlined),
          const SizedBox(width: 10),
          tab(1, tr('ap_final_settlements'), c.finalSettlements.length, Icons.logout),
        ],
      ),
    );
  }

  Widget _empty(UnexecutedRequestsController c) => ApUi.emptyState(
        icon: Icons.check_circle_outline,
        title: tr('ap_no_payments'),
        onRefresh: c.refreshRequests,
      );

  // ── Executions ──────────────────────────────────────────────────────

  Widget _executionsList(UnexecutedRequestsController c, BuildContext context) {
    if (c.executions.isEmpty) return _empty(c);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: c.executions.map((e) => _executionCard(c, e, context)).toList(),
    );
  }

  Widget _executionCard(UnexecutedRequestsController c, MyExecutionItem e, BuildContext context) {
    final color = e.isLoan ? ApUi.typeColor('loan') : ApUi.typeColor('leave');
    final kindLabel = e.isLoan ? tr('ap_loan') : tr('ap_leave_settlement');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ApUi.card(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _employeeHeader(e.employee, color, kindLabel),
          const SizedBox(height: 12),
          ApUi.infoRow(tr('ap_type'),
              [e.type, e.subType].whereType<String>().where((s) => s.isNotEmpty).join(' · ')),
          ApUi.amountRow(tr('ap_amount'), e.amount),
          if (e.loan != null) ...[
            ApUi.infoRow(tr('ap_installments'), e.loan!.noOfPayments?.toString()),
            ApUi.infoRow(tr('ap_start_date'), ApUi.date(e.loan!.startDate)),
          ],
          ApUi.infoRow(tr('ap_task_date'), ApUi.date(e.taskDate)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (e.isLeaveSettlement) ...[
                Expanded(
                  child: ApUi.actionButton(tr('ap_view_settlement'),
                      theme.getTextSecondaryColor(), () => _viewSettlement(c, e)),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: ApUi.actionButton(
                    tr('ap_return_to_hr'), theme.getErrorColor(), () => _returnExecution(c, e)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ApUi.actionButton(tr('ap_pay'), theme.getSuccessColor(),
                    () => e.isLoan ? _payLoan(c, e, context) : _paySettlement(c, e),
                    filled: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _employeeHeader(MyEmployee emp, Color color, String chip) => Row(
        children: [
          ApUi.avatar(emp.avatar, emp.name, color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emp.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.getTextPrimaryColor())),
                if (emp.no != null)
                  Text('${tr('ap_employee_no')}: ${emp.no}',
                      style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor())),
              ],
            ),
          ),
          ApUi.chip(chip, color),
        ],
      );

  Future<void> _returnExecution(UnexecutedRequestsController c, MyExecutionItem e) async {
    final r = await ApUi.textActionDialog(
      title: tr('ap_return_to_hr'),
      message: '${e.employee.name} · ${e.type}',
      label: tr('ap_reason'),
      confirmText: tr('ap_return_to_hr'),
      confirmColor: theme.getErrorColor(),
      required: true,
      onSubmit: (reason) => c.returnExecution(e, reason),
    );
    if (r != null) ApUi.ok(r.message);
  }

  Future<void> _paySettlement(UnexecutedRequestsController c, MyExecutionItem e) async {
    final r = await ApUi.confirmActionDialog(
      title: tr('ap_pay'),
      message: '${tr('ap_pay_settlement_confirm')}\n${e.employee.name}',
      confirmText: tr('ap_pay'),
      confirmColor: theme.getSuccessColor(),
      onConfirm: () => c.payExecution(e),
    );
    if (r != null) ApUi.ok(r.message);
  }

  Future<void> _viewSettlement(UnexecutedRequestsController c, MyExecutionItem e) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    final r = await c.loadSettlement(e);
    Get.back();
    if (!r.ok) {
      ApUi.fail(r.displayMessage());
      return;
    }
    final body = unwrapData(r.json);
    final settlement = body['settlement'] is Map
        ? Map<String, dynamic>.from(body['settlement'] as Map)
        : body;
    final action = await Get.to<String>(() => LeaveSettlementScreen(
          settlement: settlement,
          reqNo: e.raw['request_number']?.toString(),
        ));
    if (action == 'pay') {
      _paySettlement(c, e);
    } else if (action == 'return') {
      _returnExecution(c, e);
    }
  }

  /// Editable loan form prefilled from `loan`, sent to `POST my/executions/{id}`.
  Future<void> _payLoan(UnexecutedRequestsController c, MyExecutionItem e, BuildContext context) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final loan = e.loan;

    final amountCtrl = TextEditingController(
        text: ApUi.fmtNum(loan?.amountRequired ?? e.amount).replaceAll('-', ''));
    final instCtrl = TextEditingController(text: '${loan?.noOfPayments ?? 1}');
    final notesCtrl = TextEditingController();
    DateTime start = DateTime.tryParse(loan?.startDate ?? '') ?? todayDate;
    if (start.isBefore(todayDate)) start = todayDate;

    Map<String, String> errors = {};
    String? general;
    bool busy = false;

    final result = await Get.bottomSheet<ApiResult>(
      StatefulBuilder(builder: (ctx, setState) {
        final amount = double.tryParse(amountCtrl.text.replaceAll(',', ''));
        final inst = int.tryParse(instCtrl.text);
        final per = (amount != null && inst != null && inst > 0) ? amount / inst : null;

        Future<void> submit() async {
          final errs = <String, String>{};
          if (amount == null || amount <= 0) errs['tot_amt_tobe_paid'] = tr('ap_amount_invalid');
          if (inst == null || inst < 1) errs['no_of_installment'] = tr('ap_installments_invalid');
          if (start.isBefore(todayDate)) errs['deduction_startdate_g'] = tr('ap_date_before_today');
          if (notesCtrl.text.length > 500) errs['notes'] = tr('ap_max_500');
          if (errs.isNotEmpty) {
            setState(() => errors = errs);
            return;
          }
          setState(() {
            busy = true;
            errors = {};
            general = null;
          });
          final r = await c.payExecution(e, {
            'tot_amt_tobe_paid': amount!.toStringAsFixed(2),
            'no_of_installment': inst,
            'deduction_startdate_g': ApUi.apiDate(start),
            if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
          });
          if (r.ok) {
            Get.back(result: r);
          } else {
            setState(() {
              busy = false;
              errors = {
                for (final f in r.fieldErrors.entries)
                  if (f.value.isNotEmpty) f.key: f.value.first,
              };
              general = r.message.isNotEmpty ? r.message : (errors.isEmpty ? r.displayMessage() : null);
            });
          }
        }

        InputDecoration deco(String label, String field, {String? suffix}) => InputDecoration(
              labelText: label,
              errorText: errors[field],
              errorMaxLines: 3,
              suffixText: suffix,
              border: const OutlineInputBorder(),
            );

        return Container(
          decoration: BoxDecoration(
            color: theme.getSurfaceColor(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(tr('ap_pay_loan'),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.getTextPrimaryColor())),
                  const SizedBox(height: 4),
                  Text(
                      [e.employee.name, e.subType].whereType<String>().join(' · '),
                      style: TextStyle(color: theme.getTextSecondaryColor())),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountCtrl,
                    enabled: !busy,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: deco(tr('ap_total_to_pay'), 'tot_amt_tobe_paid'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: instCtrl,
                    enabled: !busy,
                    keyboardType: TextInputType.number,
                    decoration: deco(tr('ap_no_of_installments'), 'no_of_installment'),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (per != null) ...[
                    const SizedBox(height: 6),
                    ApUi.amountRow(tr('ap_installment_amount'), double.parse(per.toStringAsFixed(2))),
                  ],
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: busy
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: start,
                              firstDate: todayDate,
                              lastDate: DateTime(today.year + 5),
                            );
                            if (picked != null) setState(() => start = picked);
                          },
                    child: InputDecorator(
                      decoration: deco(tr('ap_deduction_start'), 'deduction_startdate_g')
                          .copyWith(suffixIcon: const Icon(Icons.calendar_today, size: 18)),
                      child: Text(ApUi.date(ApUi.apiDate(start)),
                          style: TextStyle(color: theme.getTextPrimaryColor())),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    enabled: !busy,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: deco(tr('ap_notes'), 'notes'),
                  ),
                  if (general != null) ...[
                    const SizedBox(height: 4),
                    Text(general!, style: TextStyle(color: theme.getErrorColor())),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: busy ? null : () => Get.back(),
                          child: Text(tr('ap_cancel')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: busy ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.getSuccessColor(),
                            foregroundColor: Colors.white,
                          ),
                          child: busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : Text(tr('ap_pay')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
    if (result != null) ApUi.ok(result.message);
  }

  // ── Final settlements ───────────────────────────────────────────────

  Widget _finalList(UnexecutedRequestsController c, BuildContext context) {
    if (c.finalSettlements.isEmpty) return _empty(c);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: c.finalSettlements.map((f) => _finalCard(c, f)).toList(),
    );
  }

  Widget _finalCard(UnexecutedRequestsController c, MyFinalSettlementItem f) {
    final color = theme.getActionColor('payroll');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ApUi.card(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _employeeHeader(f.employee, color, tr('ap_final_settlement')),
          const SizedBox(height: 12),
          ApUi.infoRow(tr('ap_type'), f.type),
          ApUi.infoRow(tr('ap_last_day'), ApUi.date(f.lastDay)),
          ApUi.amountRow(tr('ap_amount'), f.amount),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ApUi.actionButton(tr('ap_print'), theme.getTextSecondaryColor(),
                    () => _print(c, f)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ApUi.actionButton(tr('ap_return_to_hr'), theme.getErrorColor(), () async {
                  final r = await ApUi.textActionDialog(
                    title: tr('ap_return_to_hr'),
                    message: f.employee.name,
                    label: tr('ap_reason'),
                    confirmText: tr('ap_return_to_hr'),
                    confirmColor: theme.getErrorColor(),
                    required: true,
                    onSubmit: (reason) => c.returnFinalSettlement(f, reason),
                  );
                  if (r != null) ApUi.ok(r.message);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ApUi.actionButton(tr('ap_pay'), theme.getSuccessColor(), () async {
                  final r = await ApUi.confirmActionDialog(
                    title: tr('ap_pay'),
                    message: '${tr('ap_pay_final_confirm')}\n${f.employee.name}',
                    confirmText: tr('ap_pay'),
                    confirmColor: theme.getSuccessColor(),
                    onConfirm: () => c.payFinalSettlement(f),
                  );
                  if (r != null) ApUi.ok(r.message);
                }, filled: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Final settlement print: an HTML page shown in a web view (slip / full).
  Future<void> _print(UnexecutedRequestsController c, MyFinalSettlementItem f) async {
    await Get.to(() => SettlementPrintScreen(
          taskId: f.taskId,
          title: tr('fs_print_title'),
        ));
  }

}
