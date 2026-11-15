import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/compensation/portal_ui.dart';
import 'package:co.injazathr.injazathr/widgets/saudi_riyal_display.dart';
import 'assigned_overtime_controller.dart';
import 'overtime_history_screen.dart';

/// Overtime assigned by HR; the employee accepts or rejects it until its
/// last day. Home tile `my_overtime`.
class AssignedOvertimeScreen extends StatelessWidget {
  const AssignedOvertimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AssignedOvertimeController());
    final theme = PortalUi.theme;

    return Scaffold(
      backgroundColor: theme.getBackgroundColor(),
      appBar: PortalUi.appBar(
        context,
        tr('my_overtime'),
        actions: [
          IconButton(
            tooltip: tr('overtime_history'),
            icon: Icon(Icons.history, color: theme.getTextPrimaryColor()),
            onPressed: () => Get.to(() => const OvertimeHistoryScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          _filters(context, c),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) return PortalUi.loading();
              if (c.errorMessage.value != null) {
                return PortalUi.error(c.errorMessage.value!, c.load);
              }
              return RefreshIndicator(
                onRefresh: c.load,
                color: theme.getPrimaryColor(),
                child: c.items.isEmpty
                    ? PortalUi.empty(tr('no_assigned_overtime'))
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24)
                            .copyWith(bottom: 80),
                        itemCount: c.items.length,
                        itemBuilder: (_, i) => _OvertimeCard(item: c.items[i], controller: c),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context, AssignedOvertimeController c) {
    final theme = PortalUi.theme;
    return Container(
      color: theme.getCardColor(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Obx(() => Row(
              children: overtimeFilters.map((f) {
                final selected = c.filter.value == f;
                final badge = f == 'pending' && c.pendingCount.value > 0 ? c.pendingCount.value : 0;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    selected: selected,
                    onSelected: (_) => c.setFilter(f),
                    selectedColor: theme.getPrimaryColor(),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : theme.getTextPrimaryColor(),
                      fontWeight: FontWeight.w600,
                    ),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tr(f == 'accepted' ? 'overtime_accepted_status' : f)),
                        if (badge > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('$badge',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
      ),
    );
  }
}

String overtimeDates(Map<String, dynamic> item) {
  final from = PortalUi.text(item['from_date_display'], fallback: PortalUi.date(item['from_date']));
  final to = PortalUi.text(item['to_date_display'], fallback: PortalUi.date(item['to_date']));
  return from == to ? from : '$from  →  $to';
}

String overtimeTimes(Map<String, dynamic> item) {
  final start = PortalUi.text(item['start_time'], fallback: '');
  final end = PortalUi.text(item['end_time'], fallback: '');
  final hours = item['hours_per_day'];
  final parts = <String>[
    if (start.isNotEmpty || end.isNotEmpty) '$start - $end',
    if (hours != null) '${PortalUi.number(hours)} ${tr('hours_per_day')}',
  ];
  return parts.join(' • ');
}

class _OvertimeCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final AssignedOvertimeController controller;

  const _OvertimeCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = PortalUi.theme;
    final status = PortalUi.text(item['status'], fallback: '');
    final statusLabel = PortalUi.text(item['status_label'], fallback: tr(status, fallback: status));
    final canRespond = PortalUi.truthy(item['can_respond']);
    final id = PortalUi.toInt(item['id']);
    final notes = PortalUi.text(item['notes'], fallback: '');

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: id == null
          ? null
          : () => Get.to(() => AssignedOvertimeDetailScreen(id: id, initial: item)),
      child: PortalUi.card(
        borderColor: canRespond ? theme.getWarningColor() : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.more_time, color: theme.getPrimaryColor()),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    overtimeDates(item),
                    style: TextStyle(fontWeight: FontWeight.w700, color: theme.getTextPrimaryColor()),
                  ),
                ),
                if (statusLabel.isNotEmpty) PortalUi.chip(statusLabel, PortalUi.statusColor(status)),
              ],
            ),
            const SizedBox(height: 6),
            Text(overtimeTimes(item), style: TextStyle(color: theme.getTextSecondaryColor(), fontSize: 13)),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.getTextPrimaryColor(), fontSize: 13)),
            ],
            if (item['assigned_by'] != null) ...[
              const SizedBox(height: 6),
              Text(
                '${tr('assigned_by')}: ${PortalUi.text(item['assigned_by'])}',
                style: TextStyle(color: theme.getTextSecondaryColor(), fontSize: 12),
              ),
            ],
            if (canRespond && id != null) ...[
              const SizedBox(height: 12),
              OvertimeRespondButtons(id: id, controller: controller),
            ],
          ],
        ),
      ),
    );
  }
}

/// Accept / Reject buttons; each asks for an optional note (max 1000).
class OvertimeRespondButtons extends StatelessWidget {
  final int id;
  final AssignedOvertimeController controller;
  final VoidCallback? onDone;

  const OvertimeRespondButtons({super.key, required this.id, required this.controller, this.onDone});

  @override
  Widget build(BuildContext context) {
    final theme = PortalUi.theme;
    return Obx(() {
      final busy = controller.isSubmitting.value;
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: busy ? null : () => _respond(context, accept: false),
              icon: const Icon(Icons.close),
              label: Text(tr('reject')),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.getErrorColor(),
                side: BorderSide(color: theme.getErrorColor()),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: busy ? null : () => _respond(context, accept: true),
              icon: const Icon(Icons.check),
              label: Text(tr('accept_overtime')),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.getSuccessColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _respond(BuildContext context, {required bool accept}) async {
    final note = await _askNote(context, accept: accept);
    if (note == null) return; // cancelled
    final r = await controller.respond(id, accept: accept, note: note);
    final theme = PortalUi.theme;
    Get.snackbar(
      r.ok ? tr('success') : tr('error'),
      r.ok
          ? r.displayMessage(tr(accept ? 'overtime_accepted_msg' : 'overtime_rejected_msg'))
          : r.allErrors(tr('something_went_wrong', fallback: 'Something went wrong')),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: r.ok ? theme.getSuccessColor() : theme.getErrorColor(),
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
    if (r.ok) onDone?.call();
  }

  /// Returns the note ('' when left empty) or null when cancelled.
  Future<String?> _askNote(BuildContext context, {required bool accept}) {
    final theme = PortalUi.theme;
    final ctrl = TextEditingController();
    return Get.bottomSheet<String>(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.getCardColor(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  tr(accept ? 'accept_overtime_title' : 'reject_overtime_title'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: theme.getTextPrimaryColor(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  maxLength: 1000,
                  maxLines: 4,
                  minLines: 2,
                  decoration: InputDecoration(
                    labelText: tr('note_optional'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(tr('cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: ctrl.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accept ? theme.getSuccessColor() : theme.getErrorColor(),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(tr(accept ? 'accept_overtime' : 'reject')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

/// Details of one assigned overtime (`GET assigned-overtime/{id}`), with the
/// per-day check-in / check-out and paid minutes.
class AssignedOvertimeDetailScreen extends StatefulWidget {
  final int id;
  final Map<String, dynamic>? initial;

  const AssignedOvertimeDetailScreen({super.key, required this.id, this.initial});

  @override
  State<AssignedOvertimeDetailScreen> createState() => _AssignedOvertimeDetailScreenState();
}

class _AssignedOvertimeDetailScreenState extends State<AssignedOvertimeDetailScreen> {
  final controller = Get.find<AssignedOvertimeController>();
  Map<String, dynamic>? item;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    item = widget.initial;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final r = await controller.detail(widget.id);
    if (!mounted) return;
    setState(() {
      loading = false;
      if (r.ok) {
        final data = r.json['data'];
        item = data is Map ? PortalUi.map(data) : r.json;
      } else {
        error = r.displayMessage(tr('something_went_wrong', fallback: 'Something went wrong'));
      }
    });
  }

  String _minutes(dynamic v) {
    final m = PortalUi.toInt(v) ?? PortalUi.toDouble(v)?.round();
    if (m == null) return '-';
    final h = m ~/ 60, mm = m % 60;
    return h > 0 ? '${h}h ${mm.toString().padLeft(2, '0')}m' : '${mm}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = PortalUi.theme;
    final it = item;
    Widget body;
    if (loading && it == null) {
      body = PortalUi.loading();
    } else if (error != null && it == null) {
      body = PortalUi.error(error!, _load);
    } else {
      final i = it!;
      final status = PortalUi.text(i['status'], fallback: '');
      final canRespond = PortalUi.truthy(i['can_respond']);
      final days = PortalUi.list(i['days']);
      body = RefreshIndicator(
        onRefresh: _load,
        color: theme.getPrimaryColor(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24),
          children: [
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(error!, style: TextStyle(color: theme.getErrorColor())),
              ),
            PortalUi.card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          overtimeDates(i),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.getTextPrimaryColor(),
                          ),
                        ),
                      ),
                      PortalUi.chip(
                        PortalUi.text(i['status_label'], fallback: tr(status, fallback: status)),
                        PortalUi.statusColor(status),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  PortalUi.row(context, tr('start_time'), PortalUi.text(i['start_time'])),
                  PortalUi.row(context, tr('end_time'), PortalUi.text(i['end_time'])),
                  PortalUi.row(context, tr('hours_per_day'), PortalUi.number(i['hours_per_day'])),
                  PortalUi.row(context, tr('assigned_by'), PortalUi.text(i['assigned_by'])),
                  PortalUi.row(context, tr('assigned_at'), PortalUi.date(i['assigned_at'])),
                  if (i['responded_at'] != null)
                    PortalUi.row(context, tr('responded_at'), PortalUi.date(i['responded_at'])),
                  if (PortalUi.text(i['notes'], fallback: '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(tr('notes'), style: TextStyle(color: theme.getTextSecondaryColor(), fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(PortalUi.text(i['notes']), style: TextStyle(color: theme.getTextPrimaryColor())),
                  ],
                  if (PortalUi.text(i['response_note'], fallback: '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(tr('your_note'), style: TextStyle(color: theme.getTextSecondaryColor(), fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(PortalUi.text(i['response_note']), style: TextStyle(color: theme.getTextPrimaryColor())),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                tr('only_accepted_overtime_paid'),
                style: TextStyle(fontSize: 12, color: theme.getTextSecondaryColor()),
              ),
            ),
            if (canRespond)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: OvertimeRespondButtons(id: widget.id, controller: controller, onDone: _load),
              ),
            if (days.isNotEmpty) ...[
              PortalUi.sectionTitle(context, tr('overtime_days')),
              ...days.map((d) => PortalUi.card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PortalUi.text(d['date_display'], fallback: PortalUi.date(d['date'])),
                          style: TextStyle(fontWeight: FontWeight.w700, color: theme.getTextPrimaryColor()),
                        ),
                        const Divider(height: 16),
                        PortalUi.row(context, tr('check_in'), PortalUi.text(d['check_in'])),
                        PortalUi.row(context, tr('check_out'), PortalUi.text(d['check_out'])),
                        PortalUi.row(context, tr('worked_time'), _minutes(d['worked_minutes'])),
                        PortalUi.row(context, tr('paid_time'), _minutes(d['paid_minutes'])),
                        if ((PortalUi.toDouble(d['extra_approved_minutes']) ?? 0) > 0)
                          PortalUi.row(context, tr('extra_approved_time'), _minutes(d['extra_approved_minutes'])),
                        if (PortalUi.toDouble(d['amount']) != null)
                          PortalUi.row(
                            context,
                            tr('amount'),
                            '',
                            valueWidget: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: SaudiRiyalDisplay(
                                amount: PortalUi.toDouble(d['amount']),
                                style: TextStyle(fontWeight: FontWeight.w600, color: theme.getSuccessColor()),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 80),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.getBackgroundColor(),
      appBar: PortalUi.appBar(context, tr('overtime_details')),
      body: body,
    );
  }
}
