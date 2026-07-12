// File: lib/view/request_leave/widgets/request_widgets.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:co.injazathr.injazathr/data/remote/response/leave_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/permission_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/loan_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/letter_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/overtime_request_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/missing_punch_request_response.dart';
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

class LeaveRequestCard extends StatelessWidget {
  final LeaveRequest request;

  const LeaveRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();

    return ScreenThemes.buildRequestCard(
      context: context,
      status: request.status,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${request.leaveType} #${request.requestNumber}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
              ),
              RequestTag(
                text: '${request.days} ${tr('days')}',
                textColor: ThemeService.instance.getWarningColor(),
                backgroundColor:
                    ThemeService.instance.getWarningColor().withValues(alpha: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${request.startDate} ${tr('to')} ${request.endDate}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ThemeService.instance.getTextSecondaryColor(),
            ),
          ),


          const SizedBox(height: 12),

          // Tags Row
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${tr('leave_type')}: ',
                      style: TextStyle(
                        color: ThemeService.instance.getTextPrimaryColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: request.leaveType,
                      style: TextStyle(
                        color: ThemeService.instance.getActionColor('requests'),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
          const SizedBox(height: 12),

          // Reason
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

          // Attachments from API
          if (request.attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAttachmentChips(
              request.attachments.map((a) => a.path).where((p) => p.isNotEmpty).toList(),
            ),
          ],

          // Pending with info (for-approval only)
          if (request.status.toLowerCase() == 'for-approval' &&
              (request.currentLevel != null || request.pendingWith != null)) ...[
            const SizedBox(height: 8),
            _buildPendingInfo(request.currentLevel, request.pendingWith),
          ],

          const SizedBox(height: 12),

          // Bottom Row
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
                  if (request.status.toLowerCase() == 'approved_unexecuted' && request.approvedDate != null)
                    Text(
                    '${tr('approved')}: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getWarningColor(),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (request.status.toLowerCase() == 'executed' && request.approvedDate != null)
                    Text(
                      '${tr('approved')}: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getSuccessColor(),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (request.status.toLowerCase() == 'executed' && request.executedDate != null)
                    Text(
                      '${tr('executed')}: ${_formatDate(request.executedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getActionColor('profile'),
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
              Row(
                children: [
                  if (request.status.toLowerCase() == 'for-approval') ...[
                    RequestActionButton(
                      icon: Icons.edit_outlined,
                      color: ThemeService.instance.getActionColor('requests'),
                      onTap: () => controller.editLeaveRequest(request),
                    ),
                    const SizedBox(width: 8),
                    RequestActionButton(
                      icon: Icons.delete_outline,
                      color: ThemeService.instance.getErrorColor(),
                      onTap: () => controller.deleteLeaveRequest(request),
                    ),
                  ]
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class PermissionRequestCard extends StatelessWidget {
  final PermissionRequest request;

  const PermissionRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();

    return ScreenThemes.buildRequestCard(
      context: context,
      status: request.status ?? 'pending',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${tr('permission_request')} #${request.requestNumber}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${tr('purpose')}: ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
                TextSpan(
                  text: request.purpose,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),


          const SizedBox(height: 16),
          Row(
            children: [
              RequestTag(
                text: '${tr('from')} ${_formatTimeDisplay(request.fromTime)}',
                textColor: ThemeService.instance.getActionColor('profile'),
                backgroundColor: ThemeService.instance.getActionColor('profile').withValues(alpha: 0.1),
              ),
              const SizedBox(width: 12),
              RequestTag(
                text: '${tr('to')} ${_formatTimeDisplay(request.toTime)}',
                textColor: ThemeService.instance.getWarningColor(),
                backgroundColor: ThemeService.instance.getWarningColor().withValues(alpha: 0.1),
              ),
            ],
          ),
          // Attachments from API
          if (request.attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAttachmentChips(request.attachments),
          ],

          // Pending with info (for-approval only)
          if (request.status.toLowerCase() == 'for-approval' &&
              (request.currentLevel != null || request.pendingWith != null)) ...[
            const SizedBox(height: 8),
            _buildPendingInfo(request.currentLevel, request.pendingWith),
          ],

          const SizedBox(height: 12),
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
                  if (request.status.toLowerCase() == 'executed' && request.approvedDate != null)
                    Text(
                      '${tr('approved')}: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getSuccessColor(),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (request.status.toLowerCase() == 'executed' && request.executedDate != null)
                    Text(
                      '${tr('executed')}: ${_formatDate(request.executedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getActionColor('profile'),
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
              Row(
                children: [
                  if (request.status.toLowerCase() == 'for-approval') ...[
                    RequestActionButton(
                      icon: Icons.edit_outlined,
                      color: ThemeService.instance.getActionColor('requests'),
                      onTap: () => controller.editPermissionRequest(request),
                    ),
                    const SizedBox(width: 8),
                    RequestActionButton(
                      icon: Icons.delete_outline,
                      color: ThemeService.instance.getErrorColor(),
                      onTap: () => controller.deletePermissionRequest(request),
                    ),
                  ] else ...[
                    RequestActionButton(
                      icon: Icons.visibility_outlined,
                      color: ThemeService.instance.getTextSecondaryColor(),
                      onTap: () => controller.viewPermissionDetails(request),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoanRequestCard extends StatelessWidget {
  final LoanRequest request;

  const LoanRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();

    return ScreenThemes.buildRequestCard(
      context: context,
      status: request.status ?? 'pending',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Loan Type
          Text(
            '${request.loanType} #${request.requestNumber}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ThemeService.instance.getTextPrimaryColor(),
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: ThemeService.instance.getTextSecondaryColor().withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),

          // Requested Details Section
          Row(
            children: [
              Icon(
                Icons.request_quote_outlined,
                size: 16,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
              const SizedBox(width: 6),
              Text(
                tr('requested'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.getTextSecondaryColor(),
                ),
              ),
            ],
          ),
           // Purpose
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${tr('purpose')}: ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
                TextSpan(
                  text: request.purpose,
                  style: TextStyle(
                    fontSize: 13,
                    color: ThemeService.instance.getTextSecondaryColor(),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ThemeService.instance.getSuccessColor().withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ThemeService.instance.getSuccessColor().withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('amount'),
                        style: TextStyle(
                          fontSize: 11,
                          color: ThemeService.instance.getSuccessColor().withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SaudiRiyalDisplay(
                        customText: '${double.tryParse(request.amount) ?? 0.0}',
                        style: TextStyle(
                          color: ThemeService.instance.getSuccessColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ThemeService.instance.getWarningColor().withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ThemeService.instance.getWarningColor().withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('instalment'),
                        style: TextStyle(
                          fontSize: 11,
                          color: ThemeService.instance.getWarningColor().withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.repaymentMonths} ${tr('months')}',
                        style: TextStyle(
                          color: ThemeService.instance.getWarningColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (request.startDate != null && request.startDate!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ThemeService.instance.getActionColor('requests').withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: ThemeService.instance.getActionColor('requests'),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${tr('repayment_start_date')}: ',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: ThemeService.instance.getTextPrimaryColor(),
                    ),
                  ),
                  Text(
                    _formatDate(request.startDate!),
                    style: TextStyle(
                      fontSize: 13,
                      color: ThemeService.instance.getActionColor('requests'),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

         

          // Executed Details Section (if executed)
          if (request.status.toLowerCase() == 'executed' &&
              (request.executedAmount != null || request.executedInstallments != null ||
               (request.executedDeductionStartDate != null && request.executedDeductionStartDate!.isNotEmpty))) ...[
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: ThemeService.instance.getTextSecondaryColor().withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: ThemeService.instance.getActionColor('profile'),
                ),
                const SizedBox(width: 6),
                Text(
                  tr('executed'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeService.instance.getActionColor('profile'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (request.executedAmount != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: ThemeService.instance.getActionColor('profile').withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ThemeService.instance.getActionColor('profile').withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('executed_amount'),
                            style: TextStyle(
                              fontSize: 11,
                              color: ThemeService.instance.getActionColor('profile').withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SaudiRiyalDisplay(
                            customText: '${double.tryParse(request.executedAmount!) ?? 0.0}',
                            style: TextStyle(
                              color: ThemeService.instance.getActionColor('profile'),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (request.executedAmount != null && request.executedInstallments != null)
                  const SizedBox(width: 10),
                if (request.executedInstallments != null)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: ThemeService.instance.getActionColor('profile').withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ThemeService.instance.getActionColor('profile').withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('executed_installments'),
                            style: TextStyle(
                              fontSize: 11,
                              color: ThemeService.instance.getActionColor('profile').withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${request.executedInstallments} ${tr('months')}',
                            style: TextStyle(
                              color: ThemeService.instance.getActionColor('profile'),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (request.status.toLowerCase() == 'executed' &&
                request.executedDeductionStartDate != null &&
                request.executedDeductionStartDate!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ThemeService.instance.getActionColor('profile').withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${tr('deduction_start_date')}: ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ThemeService.instance.getTextPrimaryColor(),
                      ),
                    ),
                    Text(
                      _formatDate(request.executedDeductionStartDate!),
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          // Pending with info (for-approval only)
          if (request.status.toLowerCase() == 'for-approval' &&
              (request.currentLevel != null || request.pendingWith != null)) ...[
            const SizedBox(height: 10),
            _buildPendingInfo(request.currentLevel, request.pendingWith),
          ],

          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: ThemeService.instance.getTextSecondaryColor().withValues(alpha: 0.1),
          ),
          const SizedBox(height: 14),
          // Timeline Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineItem(
                      label: tr('submitted'),
                      date: _formatDate(request.submittedDate),
                      color: ThemeService.instance.getTextSecondaryColor(),
                      isLast: !(
                        (request.status.toLowerCase() == 'approved' && request.approvedDate != null) ||
                        (request.status.toLowerCase() == 'approved_unexecuted' && request.approvedDate != null) ||
                        (request.status.toLowerCase() == 'executed' && request.approvedDate != null) ||
                        (request.status.toLowerCase() == 'rejected' && request.approvedDate != null)
                      ),
                    ),
                    if (request.status.toLowerCase() == 'approved' && request.approvedDate != null)
                      _buildTimelineItem(
                        label: tr('approved'),
                        date: _formatDate(request.approvedDate!),
                        color: ThemeService.instance.getSuccessColor(),
                        isLast: true,
                      ),
                    if (request.status.toLowerCase() == 'approved_unexecuted' && request.approvedDate != null)
                      _buildTimelineItem(
                        label: tr('approved'),
                        date: _formatDate(request.approvedDate!),
                        color: ThemeService.instance.getWarningColor(),
                        isLast: true,
                      ),
                    if (request.status.toLowerCase() == 'executed' && request.approvedDate != null)
                      _buildTimelineItem(
                        label: tr('approved'),
                        date: _formatDate(request.approvedDate!),
                        color: ThemeService.instance.getSuccessColor(),
                        isLast: false,
                      ),
                    if (request.status.toLowerCase() == 'executed' && request.executedDate != null)
                      _buildTimelineItem(
                        label: tr('executed'),
                        date: _formatDate(request.executedDate!),
                        color: ThemeService.instance.getActionColor('profile'),
                        isLast: !(request.executedDeductionStartDate != null && request.executedDeductionStartDate!.isNotEmpty),
                      ),
                    
                    if (request.status.toLowerCase() == 'rejected' && request.approvedDate != null)
                      _buildTimelineItem(
                        label: tr('rejected'),
                        date: _formatDate(request.approvedDate!),
                        color: ThemeService.instance.getErrorColor(),
                        isLast: true,
                      ),
                  ],
                ),
              ),
              // Action Buttons
              Row(
                children: [
                  if (request.status.toLowerCase() == 'for-approval') ...[
                    RequestActionButton(
                      icon: Icons.edit_outlined,
                      color: ThemeService.instance.getActionColor('requests'),
                      onTap: () => controller.editLoanRequest(request),
                    ),
                    const SizedBox(width: 8),
                    RequestActionButton(
                      icon: Icons.delete_outline,
                      color: ThemeService.instance.getErrorColor(),
                      onTap: () => controller.deleteLoanRequest(request),
                    ),
                  ] else ...[
                    if (request.executedDeductionId != null)
                      RequestActionButton(
                        icon: Icons.visibility_outlined,
                        color: ThemeService.instance.getTextSecondaryColor(),
                        onTap: () => controller.viewLoanDetails(request),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LetterRequestCard extends StatelessWidget {
  final LetterRequest request;

  const LetterRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();

    return ScreenThemes.buildRequestCard(
      context: context,
      status: request.status ?? 'pending',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${request.letterType} #${request.requestNumber}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${tr('reason')}: ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
                TextSpan(
                  text: request.reason,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
              ],
            ),
          ),

          // Pending with info (for-approval only)
          if (request.status.toLowerCase() == 'for-approval' &&
              (request.currentLevel != null || request.pendingWith != null)) ...[
            const SizedBox(height: 10),
            _buildPendingInfo(request.currentLevel, request.pendingWith),
          ],

          const SizedBox(height: 12),
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
                  if (request.status.toLowerCase() == 'generated' && request.approvedDate != null)
                    Text(
                      '${tr('generated')}: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getSuccessColor(),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (request.status.toLowerCase() == 'executed' && request.approvedDate != null)
                    Text(
                      '${tr('approved')}: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getSuccessColor(),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (request.status.toLowerCase() == 'executed' && request.executedDate != null)
                    Text(
                      '${tr('executed')}: ${_formatDate(request.executedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getActionColor('profile'),
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
              Row(
                children: [
                  if (request.status.toLowerCase() == 'for-approval') ...[
                    RequestActionButton(
                      icon: Icons.edit_outlined,
                      color: ThemeService.instance.getActionColor('requests'),
                      onTap: () => controller.editLetterRequest(request),
                    ),
                    const SizedBox(width: 8),
                    RequestActionButton(
                      icon: Icons.delete_outline,
                      color: ThemeService.instance.getErrorColor(),
                      onTap: () => controller.deleteLetterRequest(request),
                    ),
                  ] else ...[
                    // RequestActionButton(
                    //   icon: Icons.visibility_outlined,
                    //   color: ThemeService.instance.getTextSecondaryColor(),
                    //   onTap: () => controller.viewLetterDetails(request),
                    // ),
                    if (request.status.toLowerCase() == 'approved' || request.status.toLowerCase() == 'generated')
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: RequestActionButton(
                          icon: Icons.download_outlined,
                          color: ThemeService.instance.getActionColor('requests'),
                          onTap: () => controller.downloadLetter(request),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OvertimeRequestCard extends StatelessWidget {
  final OvertimeRequest request;

  const OvertimeRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();
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
              Row(
                children: [
                  if (request.status.toLowerCase() == 'for-approval') ...[
                    RequestActionButton(
                      icon: Icons.edit_outlined,
                      color: overtimeColor,
                      onTap: () => controller.editOvertimeRequest(request),
                    ),
                    const SizedBox(width: 8),
                    RequestActionButton(
                      icon: Icons.delete_outline,
                      color: ThemeService.instance.getErrorColor(),
                      onTap: () => controller.deleteOvertimeRequest(request),
                    ),
                  ],
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

// Helper functions
Widget _buildTimelineItem({
  required String label,
  required String date,
  required Color color,
  required bool isLast,
}) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator (dot and line)
        Column(
          children: [
            // Dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            // Connecting line (if not last item)
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  color: ThemeService.instance.getTextSecondaryColor().withValues(alpha: 0.2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 15,
                    color: ThemeService.instance.getTextPrimaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatDate(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return dateString;
  }
}

int _calculateDays(String startDateString, String endDateString) {
  try {
    final startDate = DateTime.parse(startDateString);
    final endDate = DateTime.parse(endDateString);
    return endDate.difference(startDate).inDays + 1;
  } catch (e) {
    return 1;
  }
}

String _formatTimeDisplay(String timeString) {
  try {
    // Handle different time formats and remove seconds
    timeString = timeString.trim();
    
    // If it contains AM/PM (12-hour format)
    if (timeString.contains('AM') || timeString.contains('PM')) {
      final isAM = timeString.contains('AM');
      final timePart = timeString.replaceAll(RegExp(r'\s*(AM|PM)'), '');
      final parts = timePart.split(':');
      
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        // Format as HH:MM AM/PM without seconds
        final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final formattedMinute = minute.toString().padLeft(2, '0');
        return '$formattedHour:$formattedMinute ${isAM ? 'AM' : 'PM'}';
      }
    } else {
      // 24-hour format or contains seconds
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        // Format as HH:MM in 24-hour format without seconds
        final formattedHour = hour.toString().padLeft(2, '0');
        final formattedMinute = minute.toString().padLeft(2, '0');
        return '$formattedHour:$formattedMinute';
      }
    }
    
    // If parsing fails, return original string
    return timeString;
  } catch (e) {
    // Return original string if any error occurs
    return timeString;
  }
}

// ================ PENDING INFO WIDGET ================

Widget _buildPendingInfo(int? level, String? pendingWith) {
  final themeService = ThemeService.instance;
  final parts = <String>[];
  if (level != null) parts.add('Level $level');
  if (pendingWith != null && pendingWith.isNotEmpty) parts.add(pendingWith);
  final label = parts.join(' • ');

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: themeService.getWarningColor().withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: themeService.getWarningColor().withValues(alpha: 0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.person_outline, size: 14, color: themeService.getWarningColor()),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            '${tr('pending_with')}: $label',
            style: TextStyle(
              fontSize: 12,
              color: themeService.getWarningColor(),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

// ================ ATTACHMENT CHIPS WIDGET ================

Widget _buildAttachmentChips(List<String> urls) {
  if (urls.isEmpty) return const SizedBox.shrink();
  return Wrap(
    spacing: 8,
    runSpacing: 6,
    children: urls.map((url) {
      final isImage = url.toLowerCase().contains('.jpg') ||
          url.toLowerCase().contains('.jpeg') ||
          url.toLowerCase().contains('.png');
      final label = url.split('/').last;
      final displayLabel = label.length > 22 ? '${label.substring(0, 22)}...' : label;
      return GestureDetector(
        onTap: () => _openAttachmentFile(url),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: ThemeService.instance.getActionColor('requests').withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ThemeService.instance.getActionColor('requests').withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isImage ? Icons.image_outlined : Icons.attach_file,
                size: 14,
                color: ThemeService.instance.getActionColor('requests'),
              ),
              const SizedBox(width: 4),
              Text(
                displayLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: ThemeService.instance.getActionColor('requests'),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}

void _openAttachmentFile(String url) {
  final lower = url.toLowerCase();
  final isPdf = lower.contains('.pdf');
  if (isPdf) {
    _downloadAndOpenAttachmentPdf(url);
    return;
  }
  final isImage = lower.contains('.jpg') || lower.contains('.jpeg') || lower.contains('.png');
  final context = Get.context;
  if (context == null) return;
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Center(
            child: isImage
                ? InteractiveViewer(
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator(color: Colors.white)),
                      errorBuilder: (_, __, ___) =>
                          const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 64)),
                    ),
                  )
                : const Center(child: Icon(Icons.insert_drive_file, color: Colors.white, size: 64)),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _downloadAndOpenAttachmentPdf(String url) async {
  try {
    final fileName = url.split('/').last.split('?').first;
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName';
    if (!File(filePath).existsSync()) {
      await Dio().download(url, filePath);
    }
    await OpenFile.open(filePath);
  } catch (_) {}
}

// ================ MISSING PUNCH REQUEST CARD ================

class MissingPunchRequestCard extends StatelessWidget {
  final MissingPunchRequest request;

  const MissingPunchRequestCard({super.key, required this.request});

  static const _missingPunchColor = Color(0xFF6C5CE7);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();

    return ScreenThemes.buildRequestCard(
      context: context,
      status: request.status,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${tr('missing_punch')} #${request.requestNumber}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
              ),
              RequestTag(
                text: _formatDate(request.date),
                textColor: _missingPunchColor,
                backgroundColor: _missingPunchColor.withValues(alpha: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (request.checkIn != null && request.checkIn!.isNotEmpty) ...[
                RequestTag(
                  text: '${tr('check_in')}: ${_formatTimeDisplay(request.checkIn!)}',
                  textColor: ThemeService.instance.getSuccessColor(),
                  backgroundColor: ThemeService.instance.getSuccessColor().withValues(alpha: 0.1),
                ),
                const SizedBox(width: 8),
              ],
              if (request.checkOut != null && request.checkOut!.isNotEmpty)
                RequestTag(
                  text: '${tr('check_out')}: ${_formatTimeDisplay(request.checkOut!)}',
                  textColor: ThemeService.instance.getWarningColor(),
                  backgroundColor: ThemeService.instance.getWarningColor().withValues(alpha: 0.1),
                ),
            ],
          ),
          if (request.reason != null && request.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
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
                      color: ThemeService.instance.getTextPrimaryColor(),
                    ),
                  ),
                  TextSpan(
                    text: request.reason,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeService.instance.getTextSecondaryColor(),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                    ),
                  ),
                  if (request.status.toLowerCase() == 'approved' && request.approvedDate != null)
                    Text(
                      '${tr('approved')}: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(fontSize: 14, color: ThemeService.instance.getSuccessColor()),
                    ),
                  if (request.status.toLowerCase() == 'rejected' && request.approvedDate != null)
                    Text(
                      '${tr('rejected')}: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(fontSize: 14, color: ThemeService.instance.getErrorColor()),
                    ),
                ],
              ),
              Row(
                children: [
                  if (request.status.toLowerCase() == 'for-approval') ...[
                    RequestActionButton(
                      icon: Icons.edit_outlined,
                      color: _missingPunchColor,
                      onTap: () => controller.editMissingPunchRequest(request),
                    ),
                    const SizedBox(width: 8),
                    RequestActionButton(
                      icon: Icons.delete_outline,
                      color: ThemeService.instance.getErrorColor(),
                      onTap: () => controller.deleteMissingPunchRequest(request),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTimeDisplay(String timeString) {
    if (timeString.isEmpty) return '';
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
    } catch (_) {}
    return timeString;
  }
}