// File: lib/view/request_leave/widgets/request_widgets.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/data/remote/response/leave_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/permission_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/loan_request_response.dart';
import 'package:injazat_hr_app/data/remote/response/letter_request_response.dart';
import 'package:injazat_hr_app/utils/screen_themes.dart';
import '../../../services/theme_service.dart';

import '../request_controller.dart'; // Fixed import

// Enum for request status if not defined elsewhere
enum RequestStatus { forApproval, approved, rejected }

// Extension to get status from string
extension RequestStatusExtension on String {
  RequestStatus get toRequestStatus {
    switch (toLowerCase()) {
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
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
        text = 'Approved';
        icon = Icons.check_circle_outline;
        break;
      case RequestStatus.rejected:
        backgroundColor = themeService.getErrorColor().withValues(alpha: 0.1);
        textColor = themeService.getErrorColor();
        text = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
      case RequestStatus.forApproval:
        backgroundColor = themeService.getWarningColor().withValues(alpha: 0.1);
        textColor = themeService.getWarningColor();
        text = 'For Approval';
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
      Text(
      '${request.startDate} - ${request.endDate}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ThemeService.instance.getTextPrimaryColor(),
        ),
      ),
      const SizedBox(width: 12),
      RequestTag(
        text: '${request.days} days',
        textColor: ThemeService.instance.getWarningColor(),
        backgroundColor:
        ThemeService.instance.getWarningColor().withOpacity(0.1),
      ),

            ],
          ),


          const SizedBox(height: 12),

          // Tags Row
          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Leave Type: ',
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
                  text: 'Reason: ',
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

          const SizedBox(height: 16), // Changed from 20 to 16 for consistent spacing

          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submitted: ${_formatDate(request.submittedDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeService.instance.getTextSecondaryColor(),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (request.status.toLowerCase() == 'approved' && request.approvedDate != null)
                    Text(
                      'Approved: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getSuccessColor(),
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
                  ] else ...[
                    RequestActionButton(
                      icon: Icons.visibility_outlined,
                      color: ThemeService.instance.getTextSecondaryColor(),
                      onTap: () => controller.viewLeaveRequestDetails(request),
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
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Purpose: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ThemeService.instance.getTextPrimaryColor(),
                        ),
                      ),
                      TextSpan(
                        text: request.purpose,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400, // lighter for content
                          color: ThemeService.instance.getTextPrimaryColor(),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ],
          ),
          const SizedBox(height: 12),


          const SizedBox(height: 16),
          Row(
            children: [
              RequestTag(
                text: request.fromTime,
                textColor: ThemeService.instance.getActionColor('profile'),
                backgroundColor: ThemeService.instance.getActionColor('profile').withValues(alpha: 0.1),
              ),
              const SizedBox(width: 12),
              RequestTag(
                text: request.toTime,
                textColor: ThemeService.instance.getWarningColor(),
                backgroundColor: ThemeService.instance.getWarningColor().withValues(alpha: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submitted: ${_formatDate(request.submittedDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeService.instance.getTextSecondaryColor(),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (request.status.toLowerCase() == 'approved' && request.approvedDate != null)
                    Text(
                      'Approved: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getSuccessColor(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Loan Type: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ThemeService.instance.getTextPrimaryColor(),
                        ),
                      ),
                      TextSpan(
                        text: request.loanType,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: ThemeService.instance.getTextPrimaryColor(),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ],
          ),
          const SizedBox(height: 12),
          // Purpose
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Purpose: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
                TextSpan(
                  text: request.purpose,
                  style: TextStyle(
                    fontSize: 16,
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
            children: [
              RequestTag(
                text: request.amount,
                textColor: ThemeService.instance.getSuccessColor(),
                backgroundColor: ThemeService.instance.getSuccessColor().withValues(alpha: 0.1),
              ),
              const SizedBox(width: 12),
              RequestTag(
                text: '${request.repaymentMonths} months',
                textColor: ThemeService.instance.getWarningColor(),
                backgroundColor: ThemeService.instance.getWarningColor().withValues(alpha: 0.1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submitted: ${_formatDate(request.submittedDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeService.instance.getTextSecondaryColor(),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (request.status.toLowerCase() == 'approved' && request.approvedDate != null)
                    Text(
                      'Approved: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getSuccessColor(),
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
                      onTap: () => controller.editLoanRequest(request),
                    ),
                    const SizedBox(width: 8),
                    RequestActionButton(
                      icon: Icons.delete_outline,
                      color: ThemeService.instance.getErrorColor(),
                      onTap: () => controller.deleteLoanRequest(request),
                    ),
                  ] else ...[
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
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Letter Type: ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ThemeService.instance.getTextPrimaryColor(),
                        ),
                      ),
                      TextSpan(
                        text: request.letterType,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: ThemeService.instance.getTextPrimaryColor(),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Reason: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
                TextSpan(
                  text: request.reason,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: ThemeService.instance.getTextPrimaryColor(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submitted: ${_formatDate(request.createdAt)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeService.instance.getTextSecondaryColor(),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (request.status.toLowerCase() == 'approved' && request.approvedDate != null)
                    Text(
                      'Approved: ${_formatDate(request.approvedDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getSuccessColor(),
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
                    RequestActionButton(
                      icon: Icons.visibility_outlined,
                      color: ThemeService.instance.getTextSecondaryColor(),
                      onTap: () => controller.viewLetterDetails(request),
                    ),
                    if (request.status.toLowerCase() == 'approved')
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
                    'Loading...',
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
                        'Load More',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: themeService.getSilver(),
                        ),
                      ),
                      if (loadedYears.isNotEmpty)
                        Text(
                          'Load ${loadedYears.last - 1}',
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
              label: Text(
                'Create New Request',
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