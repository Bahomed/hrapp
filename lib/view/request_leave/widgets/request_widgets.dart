// File: lib/view/request_leave/widgets/request_widgets.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/data/remote/response/overtime_request_response.dart';
import 'package:co.injazathr.injazathr/view/request_leave/my_request_models.dart';
import 'package:co.injazathr.injazathr/utils/screen_themes.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import '../../../services/theme_service.dart';
import '../../../widgets/saudi_riyal_display.dart';

import '../request_controller.dart'; // Fixed import

// Enum for request status if not defined elsewhere
enum RequestStatus { forApproval, approved, rejected, generated, executed, approvedUnexecuted }

// Extension to get status from string
extension RequestStatusExtension on String {
  RequestStatus get toRequestStatus {
    switch (toLowerCase()) {
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      case 'generated':
        return RequestStatus.generated;
      case 'executed':
        return RequestStatus.executed;
      case 'approved_unexecuted':
        return RequestStatus.approvedUnexecuted;
      case 'for-approval':
      default:
        return RequestStatus.forApproval;
    }
  }

  toStringAsFixed(int i) {}
}

class RequestStatusChip extends StatelessWidget {
  final String statusString;

  const RequestStatusChip({super.key, required this.statusString});

  RequestStatus get status => statusString.toRequestStatus;

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case RequestStatus.approved:
        backgroundColor = themeService.getSuccessColor().withValues(alpha: 0.1);
        textColor = themeService.getSuccessColor();
        text = tr('approved');
        icon = Icons.check_circle_outline;
        break;
      case RequestStatus.rejected:
        backgroundColor = themeService.getErrorColor().withValues(alpha: 0.1);
        textColor = themeService.getErrorColor();
        text = tr('rejected');
        icon = Icons.cancel_outlined;
        break;
      case RequestStatus.generated:
        backgroundColor = themeService.getSuccessColor().withValues(alpha: 0.1);
        textColor = themeService.getSuccessColor();
        text = tr('generated');
        icon = Icons.description_outlined;
        break;
      case RequestStatus.executed:
        backgroundColor = themeService.getActionColor('profile').withValues(alpha: 0.1);
        textColor = themeService.getActionColor('profile');
        text = tr('executed');
        icon = Icons.done_all_outlined;
        break;
      case RequestStatus.approvedUnexecuted:
        backgroundColor = themeService.getWarningColor().withValues(alpha: 0.1);
        textColor = themeService.getWarningColor();
        text = '${tr('approved')} - ${tr('un_executed')}';
        icon = Icons.pending_outlined;
        break;
      case RequestStatus.forApproval:
        backgroundColor = themeService.getWarningColor().withValues(alpha: 0.1);
        textColor = themeService.getWarningColor();
        text = tr('for_approval');
        icon = Icons.access_time;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class RequestTag extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backgroundColor;

  const RequestTag({
    super.key,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class RequestActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const RequestActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}


/// Old overtime request (history only: employees no longer request overtime).
class OvertimeRequestCard extends StatelessWidget {
  final OvertimeRequest request;

  const OvertimeRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    const overtimeColor = Color(0xFFFF6B35);

    return ScreenThemes.buildRequestCard(
      context: context,
      status: request.status,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${tr('overtime')} #${request.requestNumber}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
              ),
              RequestTag(
                text: '${request.totalOtHours} ${tr('hrs')}',
                textColor: overtimeColor,
                backgroundColor: overtimeColor.withValues(alpha: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatDate(request.fromDate)} ${tr('to')} ${_formatDate(request.toDate)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ThemeService.instance.getTextSecondaryColor(),
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${tr('reason')}: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
                TextSpan(
                  text: request.reason,
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeService.instance.getTextSecondaryColor(),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tr('submitted')}: ${_formatDate(request.submittedDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeService.instance.getTextSecondaryColor(),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (request.status.toLowerCase() == 'approved' && request.approvedDate != null)
                    Text(
                      '${tr('approved')}: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getSuccessColor(),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (request.status.toLowerCase() == 'rejected' && request.approvedDate != null)
                    Text(
                      '${tr('rejected')}: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getErrorColor(),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      // Try ISO format first (YYYY-MM-DD)
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (_) {
      // Already in DD-MM-YYYY or other display format — return as-is
      return dateString;
    }
  }
}


class LoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final List<int> loadedYears;

  const LoadMoreButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.loadedYears,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeService.getActionColor('requests'),
          foregroundColor: themeService.getSilver(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(themeService.getSilver()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tr('loading'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeService.getSilver(),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.expand_more,
                    color: themeService.getSilver(),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        tr('load_more'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeService.getSilver(),
                        ),
                      ),
                      if (loadedYears.isNotEmpty)
                        Text(
                          '${tr('load')} ${loadedYears.last - 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeService.getSilver().withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class EmptyRequestState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? color;

  const EmptyRequestState({
    super.key,
    required this.message,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();
    final themeService = ThemeService.instance;
    final emptyStateColor = color ?? themeService.getTextSecondaryColor();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: emptyStateColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 64,
                color: emptyStateColor.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: themeService.getTextPrimaryColor(),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: controller.showRequestTypeDialog,
              icon: Icon(Icons.add, color: themeService.getSilver()),
              label: Text(tr('create_new_request'),
                style: TextStyle(
                  color: themeService.getSilver(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color ?? themeService.getActionColor('requests'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================ MY REQUEST CARD (GET my/requests) ================

/// One request from `GET my/requests`, in the same card style as before.
/// Tap = details (GET my/requests/{id}); delete only when `can_delete`.
class MyRequestCard extends StatelessWidget {
  final MyRequestItem request;

  const MyRequestCard({super.key, required this.request});

  Color _typeColor(ThemeService t) {
    switch (request.typeKey) {
      case 'leave':
        return t.getActionColor('requests');
      case 'permit':
      case 'permission':
        return t.getActionColor('profile');
      case 'loan':
        return t.getSuccessColor();
      case 'letter':
        return t.getActionColor('documents');
      case 'missingpunch':
        return const Color(0xFF6C5CE7);
      default:
        return t.getActionColor('requests');
    }
  }

  String _typeLabel() {
    switch (request.typeKey) {
      case 'leave':
        return tr('leave_type');
      case 'permit':
      case 'permission':
        return tr('permission');
      case 'loan':
        return tr('loan_type');
      case 'letter':
        return tr('letter_type');
      case 'missingpunch':
        return tr('missing_punch');
      default:
        return tr('type');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();
    final theme = ThemeService.instance;
    final color = _typeColor(theme);
    final status = request.status.toLowerCase();

    final String? tag = request.noOfDays != null
        ? '${formatNumber(request.noOfDays)} ${tr('days')}'
        : null;

    final start = displayFromApi(request.startDate);
    final end = displayFromApi(request.endDate);
    final dateLine = start.isEmpty
        ? ''
        : (end.isEmpty || end == start ? start : '$start ${tr('to')} $end');

    final canDownloadLetter =
        request.typeKey == 'letter' && (status == 'approved' || status == 'generated');
    final canEdit = request.canDelete && status == 'for-approval';

    return GestureDetector(
      onTap: () => controller.openDetails(request),
      child: ScreenThemes.buildRequestCard(
        context: context,
        status: request.displayStatus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.requestNumber.isEmpty
                        ? request.title
                        : '${request.title} #${request.requestNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.getTextPrimaryColor(),
                    ),
                  ),
                ),
                if (tag != null)
                  RequestTag(
                    text: tag,
                    textColor: theme.getWarningColor(),
                    backgroundColor: theme.getWarningColor().withValues(alpha: 0.1),
                  )
                else if (request.amountRequired != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.getSuccessColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SaudiRiyalDisplay(
                      amount: request.amountRequired,
                      style: TextStyle(
                        color: theme.getSuccessColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (dateLine.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                dateLine,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.getTextSecondaryColor(),
                ),
              ),
            ],
            if (request.subType?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${_typeLabel()}: ',
                      style: TextStyle(
                        color: theme.getTextPrimaryColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: request.subType,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (request.remarks?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${tr('reason')}: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.getTextPrimaryColor(),
                      ),
                    ),
                    TextSpan(
                      text: request.remarks,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.getTextSecondaryColor(),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.requestDate == null
                        ? ''
                        : '${tr('submitted')}: ${displayFromApi(request.requestDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.getTextSecondaryColor(),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (canEdit) ...[
                      RequestActionButton(
                        icon: Icons.edit_outlined,
                        color: theme.getActionColor('requests'),
                        onTap: () => controller.editMyRequest(request),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (request.canDelete) ...[
                      RequestActionButton(
                        icon: Icons.delete_outline,
                        color: theme.getErrorColor(),
                        onTap: () => controller.confirmDelete(request),
                      ),
                    ],
                    if (canDownloadLetter) ...[
                      const SizedBox(width: 8),
                      RequestActionButton(
                        icon: Icons.download_outlined,
                        color: theme.getActionColor('requests'),
                        onTap: () => controller.downloadLetter(request.id),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
