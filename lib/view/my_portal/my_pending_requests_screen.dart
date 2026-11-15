// "My Pending Requests" — GET my/pending: my requests still waiting, with the
// approval level and who they are waiting for (web user menu equivalent).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/repository/my_repository.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/request_detail/request_detail_screen.dart';
import 'package:co.injazathr.injazathr/view/request_leave/my_request_models.dart';
import 'package:co.injazathr.injazathr/view/request_leave/widgets/request_widgets.dart';

class MyPendingRequestsController extends GetxController {
  final MyRepository _my = MyRepository();

  final isLoading = true.obs;
  final error = RxnString();
  final items = <MyPendingItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final r = await _my.pending();
      if (!r.ok) {
        error.value = r.displayMessage(tr('failed_to_load_requests'));
        return;
      }
      items.value = extractList(r.json, const ['requests', 'pending', 'items', 'data'])
          .map(MyPendingItem.fromJson)
          .toList();
    } finally {
      isLoading.value = false;
    }
  }
}

class MyPendingRequestsScreen extends StatelessWidget {
  const MyPendingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MyPendingRequestsController());
    final theme = ThemeService.instance;

    return Scaffold(
      backgroundColor: theme.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: theme.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.getTextPrimaryColor()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tr('my_pending_requests'),
          style: TextStyle(
            color: theme.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.items.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: theme.getActionColor('requests')),
          );
        }
        return RefreshIndicator(
          onRefresh: c.load,
          color: theme.getActionColor('requests'),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              if (c.error.value != null)
                _message(theme, Icons.error_outline, c.error.value!, theme.getErrorColor())
              else if (c.items.isEmpty)
                _message(theme, Icons.inbox_outlined, tr('no_pending_requests'),
                    theme.getTextSecondaryColor())
              else
                ...c.items.map((i) => _PendingCard(item: i)),
            ],
          ),
        );
      }),
    );
  }

  Widget _message(ThemeService theme, IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: color.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: theme.getTextPrimaryColor()),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final MyPendingItem item;
  const _PendingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final r = item.request;
    final start = displayFromApi(r.startDate);
    final end = displayFromApi(r.endDate);
    final dates = start.isEmpty ? '' : (end.isEmpty || end == start ? start : '$start ${tr('to')} $end');
    final waiting = [
      if (item.level != null) '${tr('level')} ${item.level}',
      if (item.approver != null) item.approver!,
    ].join(' • ');

    return GestureDetector(
      onTap: () => Get.to(() => RequestDetailScreen(requestId: r.id, requestType: r.type)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.getCardColor(),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.requestNumber.isEmpty ? r.title : '${r.title} #${r.requestNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.getTextPrimaryColor(),
                    ),
                  ),
                ),
                RequestStatusChip(statusString: r.displayStatus.isEmpty ? 'for-approval' : r.displayStatus),
              ],
            ),
            if (r.subType != null && r.subType != r.type) ...[
              const SizedBox(height: 4),
              Text(r.type, style: TextStyle(color: theme.getTextSecondaryColor(), fontSize: 13)),
            ],
            if (dates.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(dates,
                  style: TextStyle(
                      color: theme.getTextSecondaryColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
            if (waiting.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.getWarningColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.getWarningColor().withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, size: 14, color: theme.getWarningColor()),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '${tr('pending_with')}: $waiting',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.getWarningColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (r.requestDate != null) ...[
              const SizedBox(height: 10),
              Text(
                '${tr('submitted')}: ${displayFromApi(r.requestDate)}',
                style: TextStyle(fontSize: 13, color: theme.getTextSecondaryColor()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
