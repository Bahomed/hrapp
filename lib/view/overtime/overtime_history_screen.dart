import 'package:flutter/material.dart';

import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/compensation/portal_ui.dart';
import 'assigned_overtime_controller.dart';

/// Read-only history of the old overtime requests. Employees can no longer
/// request overtime; HR assigns it instead (see AssignedOvertimeScreen).
class OvertimeHistoryScreen extends StatefulWidget {
  const OvertimeHistoryScreen({super.key});

  @override
  State<OvertimeHistoryScreen> createState() => _OvertimeHistoryScreenState();
}

class _OvertimeHistoryScreenState extends State<OvertimeHistoryScreen> {
  final _api = OvertimeHistoryApi();
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    final r = await _api.list();
    if (!mounted) return;
    setState(() {
      loading = false;
      if (r.ok) {
        final data = r.json['data'];
        items = data is Map ? PortalUi.list(data['data'] ?? data['items']) : PortalUi.list(data);
      } else {
        error = r.displayMessage(tr('something_went_wrong', fallback: 'Something went wrong'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = PortalUi.theme;
    Widget body;
    if (loading) {
      body = PortalUi.loading();
    } else if (error != null) {
      body = PortalUi.error(error!, _load);
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        color: theme.getPrimaryColor(),
        child: items.isEmpty
            ? PortalUi.empty(tr('no_overtime_history'))
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: ResponsiveUtils.responsivePadding(context, mobile: 16, tablet: 20, desktop: 24)
                    .copyWith(bottom: 80),
                itemCount: items.length,
                itemBuilder: (_, i) => _card(context, items[i]),
              ),
      );
    }
    return Scaffold(
      backgroundColor: theme.getBackgroundColor(),
      appBar: PortalUi.appBar(context, tr('overtime_history')),
      body: body,
    );
  }

  Widget _card(BuildContext context, Map<String, dynamic> it) {
    final theme = PortalUi.theme;
    final status = PortalUi.text(it['status'], fallback: '');
    final id = PortalUi.toInt(it['id']);
    final from = PortalUi.date(it['from_date']);
    final to = PortalUi.date(it['to_date']);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: id == null
          ? null
          : () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => _OvertimeHistoryDetailScreen(id: id, initial: it),
              )),
      child: PortalUi.card(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${PortalUi.text(it['request_number'], fallback: '${id ?? ''}')}',
                    style: TextStyle(fontWeight: FontWeight.w700, color: theme.getTextPrimaryColor()),
                  ),
                  const SizedBox(height: 4),
                  Text(from == to ? from : '$from  →  $to',
                      style: TextStyle(fontSize: 13, color: theme.getTextSecondaryColor())),
                  if (it['total_ot_hours'] != null)
                    Text('${PortalUi.number(it['total_ot_hours'])} ${tr('hours')}',
                        style: TextStyle(fontSize: 13, color: theme.getTextSecondaryColor())),
                ],
              ),
            ),
            if (status.isNotEmpty) PortalUi.chip(tr(status, fallback: status), PortalUi.statusColor(status)),
          ],
        ),
      ),
    );
  }
}

class _OvertimeHistoryDetailScreen extends StatefulWidget {
  final int id;
  final Map<String, dynamic> initial;

  const _OvertimeHistoryDetailScreen({required this.id, required this.initial});

  @override
  State<_OvertimeHistoryDetailScreen> createState() => _OvertimeHistoryDetailScreenState();
}

class _OvertimeHistoryDetailScreenState extends State<_OvertimeHistoryDetailScreen> {
  final _api = OvertimeHistoryApi();
  late Map<String, dynamic> item = widget.initial;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await _api.detail(widget.id);
    if (!mounted) return;
    setState(() {
      if (r.ok) {
        final data = r.json['data'];
        if (data is Map) item = PortalUi.map(data);
        error = null;
      } else {
        error = r.displayMessage(tr('something_went_wrong', fallback: 'Something went wrong'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = PortalUi.theme;
    final status = PortalUi.text(item['status'], fallback: '');
    return Scaffold(
      backgroundColor: theme.getBackgroundColor(),
      appBar: PortalUi.appBar(context, tr('overtime_details')),
      body: RefreshIndicator(
        onRefresh: _load,
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
                children: [
                  PortalUi.row(context, tr('request_number', fallback: '#'),
                      PortalUi.text(item['request_number'])),
                  PortalUi.row(context, tr('status'), tr(status, fallback: PortalUi.text(status)),
                      valueColor: PortalUi.statusColor(status)),
                  PortalUi.row(context, tr('from_date'), PortalUi.date(item['from_date'])),
                  PortalUi.row(context, tr('to_date'), PortalUi.date(item['to_date'])),
                  PortalUi.row(context, tr('hours'), PortalUi.number(item['total_ot_hours'])),
                  PortalUi.row(context, tr('reason', fallback: 'Reason'), PortalUi.text(item['reason'])),
                  PortalUi.row(context, tr('submitted_date', fallback: 'Submitted'),
                      PortalUi.date(item['submitted_date'])),
                  if (item['approved_by'] != null)
                    PortalUi.row(context, tr('approved_by', fallback: 'Approved by'),
                        PortalUi.text(item['approved_by'])),
                  if (item['approved_date'] != null)
                    PortalUi.row(context, tr('approved_date', fallback: 'Approved on'),
                        PortalUi.date(item['approved_date'])),
                  if (PortalUi.text(item['rejected_reason'], fallback: '').isNotEmpty)
                    PortalUi.row(context, tr('rejected_reason', fallback: 'Rejection reason'),
                        PortalUi.text(item['rejected_reason'])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
