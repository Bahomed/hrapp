import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/view/request_leave/widgets/request_widgets.dart';
import 'package:co.injazathr.injazathr/view/request_leave/loan_details_screen.dart';
import 'request_detail_controller.dart';

class RequestDetailScreen extends StatelessWidget {
  final int requestId;
  final String? requestType;

  const RequestDetailScreen({
    super.key,
    required this.requestId,
    this.requestType,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      RequestDetailController(requestId: requestId, requestType: requestType),
      tag: requestId.toString(),
    );
    final theme = ThemeService.instance;

    return Scaffold(
      backgroundColor: theme.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: theme.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr('request_details'),
          style: TextStyle(
            color: theme.getTextPrimaryColor(),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() => controller.isLoading.value
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.refresh, color: theme.getTextPrimaryColor()),
                  onPressed: controller.refresh,
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.getActionColor('requests'),
            ),
          );
        }

        if (controller.error.value != null) {
          return _buildError(controller, theme);
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: theme.getActionColor('requests'),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(controller, theme),
                const SizedBox(height: 16),
                _buildTypeSpecificDetails(controller, theme),
                if (controller.detectedType.value == RequestDetailType.letter &&
                    controller.letterDetail != null) ...[
                  const SizedBox(height: 12),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isDownloading.value
                          ? null
                          : controller.downloadLetter,
                      icon: controller.isDownloading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download_outlined, color: Colors.white),
                      label: Text(
                        tr('download_letter'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.getActionColor('documents'),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  )),
                ],
                if (controller.detectedType.value == RequestDetailType.loan &&
                    controller.loanDetail != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.to(
                        () => LoanDetailsScreen(request: controller.loanDetail!),
                      ),
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(tr('view_loan_details')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.getSuccessColor(),
                        side: BorderSide(color: theme.getSuccessColor()),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildDatesCard(controller, theme),
                if (controller.rejectedReason?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  _buildRejectionReasonCard(controller, theme),
                ],
                if (controller.attachments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildAttachmentsCard(controller, theme),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildError(RequestDetailController controller, ThemeService theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.getErrorColor()),
            const SizedBox(height: 16),
            Text(
              controller.error.value ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.getTextSecondaryColor(), fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(tr('retry'), style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.getActionColor('requests'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(RequestDetailController controller, ThemeService theme) {
    final typeLabel = _typeLabel(controller.detectedType.value);
    final typeIcon = _typeIcon(controller.detectedType.value);
    final typeColor = _typeColor(controller.detectedType.value, theme);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: typeColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: TextStyle(
                    color: theme.getTextSecondaryColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tr('request_number')} ${controller.requestNumber}',
                  style: TextStyle(
                    color: theme.getTextPrimaryColor(),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          RequestStatusChip(statusString: controller.status),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificDetails(RequestDetailController controller, ThemeService theme) {
    switch (controller.detectedType.value) {
      case RequestDetailType.leave:
        return _buildLeaveDetails(controller, theme);
      case RequestDetailType.permit:
        return _buildPermitDetails(controller, theme);
      case RequestDetailType.loan:
        return _buildLoanDetails(controller, theme);
      case RequestDetailType.letter:
        return _buildLetterDetails(controller, theme);
      case RequestDetailType.unknown:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLeaveDetails(RequestDetailController controller, ThemeService theme) {
    final req = controller.leaveDetail!;
    return _buildInfoCard(theme, tr('leave_details'), Icons.calendar_today, [
      _infoRow(theme, tr('leave_type'), req.leaveType),
      _infoRow(theme, tr('start_date'), _formatDate(req.startDate)),
      _infoRow(theme, tr('end_date'), _formatDate(req.endDate)),
      _infoRow(theme, tr('days'), req.days.toString()),
      if (req.reason.isNotEmpty) _infoRow(theme, tr('reason'), req.reason),
      _infoRow(theme, tr('ticket'), req.ticket ? tr('yes') : tr('no')),
      _infoRow(theme, tr('exit_permit'), req.exitPermit ? tr('yes') : tr('no')),
    ]);
  }

  Widget _buildPermitDetails(RequestDetailController controller, ThemeService theme) {
    final req = controller.permitDetail!;
    return _buildInfoCard(theme, tr('permission_details'), Icons.badge_outlined, [
      if (req.title?.isNotEmpty == true) _infoRow(theme, tr('title'), req.title!),
      if (req.permitType?.isNotEmpty == true) _infoRow(theme, tr('type'), req.permitType!),
      _infoRow(theme, tr('purpose'), req.purpose),
      if (req.duration?.isNotEmpty == true) _infoRow(theme, tr('duration'), req.duration!),
      if (req.date.isNotEmpty) _infoRow(theme, tr('date'), _formatDate(req.date)),
      if (req.fromTime.isNotEmpty) _infoRow(theme, tr('from_time'), _formatTime(req.fromTime)),
      if (req.toTime.isNotEmpty) _infoRow(theme, tr('to_time'), _formatTime(req.toTime)),
    ]);
  }

  Widget _buildLoanDetails(RequestDetailController controller, ThemeService theme) {
    final req = controller.loanDetail!;
    return _buildInfoCard(theme, tr('loan_details'), Icons.account_balance_wallet, [
      _infoRow(theme, tr('loan_type'), req.loanType),
      _infoRow(theme, tr('purpose'), req.purpose),
      _infoRow(theme, tr('amount'), req.amount),
      _infoRow(theme, tr('repayment_months'), req.repaymentMonths.toString()),
      if (req.startDate?.isNotEmpty == true) _infoRow(theme, tr('start_date'), _formatDate(req.startDate!)),
      if (req.executedAmount?.isNotEmpty == true)
        _infoRow(theme, tr('executed_amount'), req.executedAmount!),
      if (req.executedInstallments != null)
        _infoRow(theme, tr('repayment_period'), req.executedInstallments.toString()),
    ]);
  }

  Widget _buildLetterDetails(RequestDetailController controller, ThemeService theme) {
    final req = controller.letterDetail!;
    return _buildInfoCard(theme, tr('letter_details'), Icons.description, [
      _infoRow(theme, tr('letter_type'), req.letterType),
      if (req.reason.isNotEmpty) _infoRow(theme, tr('reason'), req.reason),
    ]);
  }

  Widget _buildDatesCard(RequestDetailController controller, ThemeService theme) {
    return _buildInfoCard(theme, tr('dates'), Icons.schedule, [
      _infoRow(theme, tr('submitted_date'), _formatDate(controller.submittedDate)),
      if (controller.approvedDate?.isNotEmpty == true)
        _infoRow(theme, tr('approved_date'), _formatDate(controller.approvedDate!)),
      if (controller.executedDate?.isNotEmpty == true)
        _infoRow(theme, tr('executed_date'), _formatDate(controller.executedDate!)),
    ]);
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      return '$day/$month/${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  String _formatTime(String timeString) {
    if (timeString.isEmpty) return '';
    try {
      final parts = timeString.trim().split(':');
      if (parts.length < 2) return timeString;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return timeString;
    }
  }

  Widget _buildRejectionReasonCard(RequestDetailController controller, ThemeService theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.getErrorColor().withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.getErrorColor().withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel_outlined, color: theme.getErrorColor(), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('rejection_reason'),
                  style: TextStyle(
                    color: theme.getErrorColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.rejectedReason!,
                  style: TextStyle(
                    color: theme.getTextPrimaryColor(),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentsCard(RequestDetailController controller, ThemeService theme) {
    return _buildInfoCard(
      theme,
      tr('attachments'),
      Icons.attach_file,
      controller.attachments
          .map((a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file_outlined,
                        size: 16, color: theme.getTextSecondaryColor()),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.name,
                        style: TextStyle(
                          color: theme.getTextPrimaryColor(),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildInfoCard(ThemeService theme, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(icon, size: 18, color: theme.getPrimaryColor()),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: theme.getTextPrimaryColor(),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.getDividerColor(), height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(ThemeService theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: theme.getTextSecondaryColor(),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: TextStyle(
                color: theme.getTextPrimaryColor(),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(RequestDetailType type) {
    switch (type) {
      case RequestDetailType.leave:
        return tr('leave_request');
      case RequestDetailType.permit:
        return tr('permission_request');
      case RequestDetailType.loan:
        return tr('loan_request');
      case RequestDetailType.letter:
        return tr('letter_request');
      case RequestDetailType.unknown:
        return tr('request_details');
    }
  }

  IconData _typeIcon(RequestDetailType type) {
    switch (type) {
      case RequestDetailType.leave:
        return Icons.calendar_today;
      case RequestDetailType.permit:
        return Icons.badge_outlined;
      case RequestDetailType.loan:
        return Icons.account_balance_wallet;
      case RequestDetailType.letter:
        return Icons.description;
      case RequestDetailType.unknown:
        return Icons.assignment_outlined;
    }
  }

  Color _typeColor(RequestDetailType type, ThemeService theme) {
    switch (type) {
      case RequestDetailType.leave:
        return theme.getActionColor('requests');
      case RequestDetailType.permit:
        return theme.getActionColor('profile');
      case RequestDetailType.loan:
        return theme.getSuccessColor();
      case RequestDetailType.letter:
        return theme.getActionColor('documents');
      case RequestDetailType.unknown:
        return theme.getPrimaryColor();
    }
  }
}
