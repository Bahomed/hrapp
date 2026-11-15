import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/data/remote/response/my_approvals_models.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/view/approval/approval_controller.dart';
import 'package:co.injazathr.injazathr/view/approval/approval_ui.dart';

/// My Approvals (home key `awaiting_approval`). [requestId] opens one request
/// directly (from a push notification).
class ApprovalScreen extends StatefulWidget {
  final int? requestId;
  const ApprovalScreen({super.key, this.requestId});

  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  late final ApprovalController controller;
  ThemeService get theme => ThemeService.instance;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ApprovalController());
    if (widget.requestId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final item = controller.allRequests.firstWhereOrNull((r) => r.id == widget.requestId);
        _openDetails(widget.requestId!, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          tr('ap_approvals'),
          style: TextStyle(color: theme.getTextPrimaryColor(), fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.getSurfaceColor(),
        elevation: 0,
        iconTheme: IconThemeData(color: theme.getTextPrimaryColor()),
        actions: [
          Obx(() => Badge(
                label: Text('${controller.totalPendingCount}'),
                isLabelVisible: controller.totalPendingCount > 0,
                child: IconButton(
                  onPressed: controller.isLoading.value ? null : controller.refreshRequests,
                  icon: controller.isLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: theme.getTextPrimaryColor()),
                        )
                      : const Icon(Icons.refresh),
                ),
              )),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.allRequests.isEmpty &&
                  controller.payrolls.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: theme.getActionColor('requests')),
                );
              }
              final visible = controller.visibleRequests;
              final showPayrolls =
                  controller.selectedFilter.value == 'all' && controller.payrolls.isNotEmpty;

              if (visible.isEmpty && !showPayrolls) {
                return RefreshIndicator(
                  onRefresh: controller.refreshRequests,
                  child: ApUi.emptyState(
                    icon: controller.errorMessage.value.isNotEmpty
                        ? Icons.info_outline
                        : Icons.check_circle_outline,
                    title: controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : tr('ap_no_pending'),
                    subtitle: controller.errorMessage.value.isNotEmpty
                        ? null
                        : tr('ap_all_processed'),
                    onRefresh: controller.refreshRequests,
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshRequests,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: ResponsiveUtils.responsiveHorizontalPadding(
                          context, mobile: 16, tablet: 20, desktop: 24)
                      .add(const EdgeInsets.only(top: 16, bottom: 32)),
                  children: [
                    if (controller.selectedFilter.value == 'all') ...[
                      _buildSummaryCards(),
                      const SizedBox(height: 20),
                    ],
                    ...visible.map(_buildRequestCard),
                    if (showPayrolls) ...[
                      const SizedBox(height: 8),
                      _sectionHeader(tr('ap_payrolls'), controller.payrolls.length,
                          ApUi.typeColor('payroll')),
                      _payrollNote(),
                      ...controller.payrolls.map(_buildPayrollCard),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Filters / summary ───────────────────────────────────────────────

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.getSurfaceColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: controller.filters.map((key) {
                final selected = controller.selectedFilter.value == key;
                final color = ApUi.typeColor(key);
                final count = controller.countFor(key);
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: GestureDetector(
                    onTap: () => controller.changeFilter(key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? color : color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        count > 0 ? '${controller.filterLabel(key)} ($count)' : controller.filterLabel(key),
                        style: TextStyle(
                          color: selected ? Colors.white : color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final keys = ApprovalController.filterKeys.where((k) => k != 'all').toList();
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: keys.map((k) {
        final color = ApUi.typeColor(k);
        return GestureDetector(
          onTap: () => controller.changeFilter(k),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: ApUi.card(color),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(ApUi.typeIcon(k), color: color, size: 22),
                const SizedBox(height: 4),
                Text('${controller.countFor(k)}',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                Text(ApUi.typeLabel(k),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: theme.getTextSecondaryColor())),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionHeader(String title, int count, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.getTextPrimaryColor())),
            const SizedBox(width: 8),
            ApUi.chip('$count', color),
          ],
        ),
      );

  Widget _payrollNote() => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.getWarningColor().withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.getWarningColor().withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.getWarningColor(), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(tr('ap_payroll_web_note'),
                  style: TextStyle(fontSize: 13, color: theme.getTextPrimaryColor())),
            ),
          ],
        ),
      );

  // ── Cards ───────────────────────────────────────────────────────────

  List<Widget> _typeInfo(MyApprovalItem r) {
    final w = <Widget>[];
    if (r.subType != null) w.add(ApUi.infoRow(tr('ap_type'), r.subType));
    switch (r.typeKey) {
      case 'leave':
        w.add(ApUi.infoRow(tr('ap_from'), ApUi.date(r.startDate)));
        w.add(ApUi.infoRow(tr('ap_to'), ApUi.date(r.endDate)));
        w.add(ApUi.infoRow(tr('ap_days'), r.noOfDays == null ? null : ApUi.fmtNum(r.noOfDays)));
        break;
      case 'loan':
        w.add(ApUi.amountRow(tr('ap_amount'), r.amount));
        w.add(ApUi.infoRow(tr('ap_installments'), r.installments?.toString()));
        w.add(ApUi.infoRow(tr('ap_start_date'), ApUi.date(r.startDate)));
        break;
      case 'permit':
        w.add(ApUi.infoRow(tr('ap_date'), ApUi.date(r.startDate)));
        if (r.fromTime != null) {
          w.add(ApUi.infoRow(
              tr('ap_time'), '${ApUi.time(r.fromTime)} - ${ApUi.time(r.toTime)}'));
        }
        break;
      case 'overtime':
        w.add(ApUi.infoRow(tr('ap_from'), ApUi.date(r.startDate)));
        w.add(ApUi.infoRow(tr('ap_to'), ApUi.date(r.endDate)));
        w.add(ApUi.infoRow(tr('ap_hours'), r.hours == null ? null : ApUi.fmtNum(r.hours),
            valueColor: ApUi.typeColor('overtime')));
        break;
      case 'missingpunch':
        w.add(ApUi.infoRow(tr('ap_date'), ApUi.date(r.startDate)));
        w.add(ApUi.infoRow(tr('ap_check_in'), ApUi.time(r.fromTime)));
        w.add(ApUi.infoRow(tr('ap_check_out'), ApUi.time(r.toTime)));
        break;
      default:
        if (r.startDate != null) w.add(ApUi.infoRow(tr('ap_date'), ApUi.date(r.startDate)));
        w.add(ApUi.amountRow(tr('ap_amount'), r.amount));
    }
    return w;
  }

  Widget _buildRequestCard(MyApprovalItem r) {
    final color = ApUi.typeColor(r.typeKey);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ApUi.card(color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(ApUi.typeIcon(r.typeKey), color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.employee.name.isNotEmpty ? r.employee.name : ApUi.typeLabel(r.type),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.getTextPrimaryColor()),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        ApUi.typeLabel(r.type),
                        if (r.requestNumber != null) '#${r.requestNumber}',
                        if (r.employee.no != null) r.employee.no!,
                      ].join(' · '),
                      style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor()),
                    ),
                  ],
                ),
              ),
              ApUi.chip(r.level ?? tr('ap_for_approval'), theme.getWarningColor()),
            ],
          ),
          const SizedBox(height: 12),
          ..._typeInfo(r),
          ApUi.infoRow(tr('ap_request_date'), ApUi.date(r.requestDate)),
          if (r.remarks != null)
            Text('${tr('ap_remarks')}: ${r.remarks}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: theme.getTextSecondaryColor())),
          if (r.attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            _attachments(r.attachments),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ApUi.actionButton(tr('ap_view_details'), theme.getTextSecondaryColor(),
                    () => _openDetails(r.id, r)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ApUi.actionButton(
                    tr('ap_reject'), theme.getErrorColor(), () => _reject(r)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ApUi.actionButton(
                    tr('ap_approve'), theme.getSuccessColor(), () => _approve(r),
                    filled: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollCard(MyPayrollItem p) {
    final color = ApUi.typeColor('payroll');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: ApUi.card(color),
      child: InkWell(
        onTap: () => ApUi.showDataSheet(tr('ap_payrolls'), p.raw),
        child: Row(
          children: [
            Icon(ApUi.typeIcon('payroll'), color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title.isNotEmpty ? p.title : '${tr('ap_payrolls')} #${p.id ?? ''}',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: theme.getTextPrimaryColor())),
                  const SizedBox(height: 4),
                  ApUi.infoRow(tr('ap_employees_count'), p.employeesCount?.toString()),
                  ApUi.amountRow(tr('ap_total'), p.total),
                ],
              ),
            ),
            ApUi.chip(p.level ?? tr('ap_read_only'), color),
          ],
        ),
      ),
    );
  }

  Widget _attachments(List<String> urls) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: urls.map((url) {
          final name = url.split('/').last.split('?').first;
          final c = theme.getActionColor('requests');
          return GestureDetector(
            onTap: () => ApUi.openAttachment(url, context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_file, size: 14, color: c),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: c)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );

  // ── Actions ─────────────────────────────────────────────────────────

  Future<bool> _approve(MyApprovalItem r, {int? stepId}) async {
    final res = await ApUi.textActionDialog(
      title: tr('ap_approve_title'),
      message: '${r.employee.name} · ${ApUi.typeLabel(r.type)}',
      label: tr('ap_comments'),
      confirmText: tr('ap_approve'),
      confirmColor: theme.getSuccessColor(),
      errorField: 'comments',
      onSubmit: (c) => controller.act(r, 'approved', c, stepId: stepId),
    );
    if (res != null) ApUi.ok(res.message);
    return res != null;
  }

  Future<bool> _reject(MyApprovalItem r, {int? stepId}) async {
    final res = await ApUi.textActionDialog(
      title: tr('ap_reject_title'),
      message: '${r.employee.name} · ${ApUi.typeLabel(r.type)}',
      label: tr('ap_comments'),
      confirmText: tr('ap_reject'),
      confirmColor: theme.getErrorColor(),
      errorField: 'comments',
      onSubmit: (c) => controller.act(r, 'rejected', c, stepId: stepId),
    );
    if (res != null) ApUi.ok(res.message);
    return res != null;
  }

  /// Details sheet: `GET my/approvals/{id}` with steps + attachments.
  Future<void> _openDetails(int requestId, MyApprovalItem? item) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    final (detail, err) = await controller.loadDetail(requestId, fallback: item);
    Get.back();
    if (detail == null) {
      ApUi.fail(err ?? tr('ap_request_not_found'));
      return;
    }
    final r = detail.request.id == 0 && item != null ? item : detail.request;
    final stepId = detail.actionableStepId;
    final color = ApUi.typeColor(r.typeKey);

    await Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scroll) => Container(
          decoration: BoxDecoration(
            color: theme.getSurfaceColor(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.getDividerColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        ApUi.avatar(r.employee.avatar, r.employee.name, color, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.employee.name,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: theme.getTextPrimaryColor())),
                              if (r.employee.no != null)
                                Text('${tr('ap_employee_no')}: ${r.employee.no}',
                                    style: TextStyle(
                                        fontSize: 12, color: theme.getTextSecondaryColor())),
                            ],
                          ),
                        ),
                        ApUi.chip(ApUi.typeLabel(r.type), color),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ApUi.infoRow(tr('ap_request_no'), r.requestNumber),
                    ApUi.infoRow(tr('ap_request_date'), ApUi.date(r.requestDate)),
                    ..._typeInfo(r),
                    if (r.remarks != null) ApUi.infoRow(tr('ap_remarks'), r.remarks),
                    if (detail.attachments.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(tr('ap_attachments'),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: theme.getTextPrimaryColor())),
                      const SizedBox(height: 8),
                      _attachments(detail.attachments),
                    ],
                    if (detail.steps.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(tr('ap_steps'),
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: theme.getTextPrimaryColor())),
                      const SizedBox(height: 8),
                      ...detail.steps.map(_stepTile),
                    ],
                  ],
                ),
              ),
              if (stepId != null)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ApUi.actionButton(tr('ap_reject'), theme.getErrorColor(),
                              () async {
                            if (await _reject(r, stepId: stepId)) Get.back();
                          }),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ApUi.actionButton(tr('ap_approve'), theme.getSuccessColor(),
                              () async {
                            if (await _approve(r, stepId: stepId)) Get.back();
                          }, filled: true),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _stepTile(MyApprovalStep s) {
    final st = (s.status ?? '').toLowerCase();
    final color = st.contains('reject')
        ? theme.getErrorColor()
        : st.contains('approv') && !st.contains('for')
            ? theme.getSuccessColor()
            : theme.getWarningColor();
    final icon = st.contains('reject')
        ? Icons.cancel
        : st.contains('approv') && !st.contains('for')
            ? Icons.check_circle
            : Icons.hourglass_top;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [s.level, s.approver].whereType<String>().join(' · '),
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: theme.getTextPrimaryColor()),
                ),
                if (s.status != null)
                  Text(s.status!, style: TextStyle(fontSize: 12, color: color)),
                if (s.actedAt != null)
                  Text(ApUi.dateTime(s.actedAt),
                      style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor())),
                if (s.comments != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(s.comments!,
                        style: TextStyle(fontSize: 13, color: theme.getTextPrimaryColor())),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
