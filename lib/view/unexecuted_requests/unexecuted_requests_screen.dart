import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import '../../data/remote/response/unexecuted_requests_response.dart';
import 'unexecuted_requests_controller.dart';

class UnexecutedRequestsScreen extends StatelessWidget {
  const UnexecutedRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UnexecutedRequestsController controller = Get.put(UnexecutedRequestsController());
    final ThemeService themeService = Get.find<ThemeService>();
    
    return Scaffold(
      backgroundColor: themeService.getBackgroundColor(),
      appBar: AppBar(
        title: Text(
          tr('un_executed'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: themeService.getSurfaceColor(),
        elevation: 0,
        iconTheme: IconThemeData(color: themeService.getTextPrimaryColor()),
        actions: [
          Obx(() => IconButton(
            onPressed: controller.isLoading.value ? null : controller.loadUnexecutedRequests,
            icon: controller.isLoading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: themeService.getTextPrimaryColor(),
                    ),
                  )
                : const Icon(Icons.refresh),
          )),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Summary Header
          _buildSummaryHeader(controller, themeService, context),
          
          // Content
          Expanded(
            child: Obx(() {
              if (controller.unexecutedRequests.isEmpty) {
                return _buildEmptyState(themeService, context, controller);
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await controller.loadUnexecutedRequests();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: ResponsiveUtils.responsiveHorizontalPadding(
                      context, mobile: 16, tablet: 20, desktop: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
                          context, mobile: 16, tablet: 20, desktop: 24)),
                      
                      // Requests List
                      ...controller.unexecutedRequests.map((request) =>
                          _buildRequestCard(request, themeService, context)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(UnexecutedRequestsController controller, 
      ThemeService themeService, BuildContext context) {
    return Container(
      padding: ResponsiveUtils.responsiveHorizontalPadding(
          context, mobile: 16, tablet: 20, desktop: 24).add(
          ResponsiveUtils.responsiveVerticalPadding(
              context, mobile: 16, tablet: 18, desktop: 20)
      ),
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: ResponsiveUtils.responsiveHorizontalPadding(
                context, mobile: 12, tablet: 14, desktop: 16),
            decoration: BoxDecoration(
              color: themeService.getWarningColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.pending_actions_outlined,
              color: themeService.getWarningColor(),
              size: ResponsiveUtils.responsiveIconSize(
                  context, mobile: 24, tablet: 26, desktop: 28),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 12, tablet: 14, desktop: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('un_executed'),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context, mobile: 18, tablet: 20, desktop: 22),
                    fontWeight: FontWeight.w600,
                    color: themeService.getTextPrimaryColor(),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                  '${controller.unexecutedRequestsTotal.value} ${tr('pending')}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context, mobile: 14, tablet: 15, desktop: 16),
                    color: themeService.getTextSecondaryColor(),
                  ),
                )),
              ],
            ),
          ),
          Obx(() => Container(
            padding: ResponsiveUtils.responsiveHorizontalPadding(
                context, mobile: 12, tablet: 14, desktop: 16).add(
                ResponsiveUtils.responsiveVerticalPadding(
                    context, mobile: 6, tablet: 7, desktop: 8)
            ),
            decoration: BoxDecoration(
              color: themeService.getWarningColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              controller.unexecutedRequestsTotal.value.toString(),
              style: TextStyle(
                fontSize: ResponsiveUtils.responsiveFontSize(
                    context, mobile: 16, tablet: 17, desktop: 18),
                fontWeight: FontWeight.bold,
                color: themeService.getWarningColor(),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRequestCard(UnexecutedRequest request, 
      ThemeService themeService, BuildContext context) {
    final requestTypeColor = _getRequestTypeColor(request.requestType, themeService);
    
    return Container(
      margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 12, tablet: 14, desktop: 16)),
      padding: ResponsiveUtils.responsiveHorizontalPadding(
          context, mobile: 16, tablet: 18, desktop: 20).add(
          ResponsiveUtils.responsiveVerticalPadding(
              context, mobile: 16, tablet: 18, desktop: 20)
      ),
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: requestTypeColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: ResponsiveUtils.responsiveHorizontalPadding(
                    context, mobile: 8, tablet: 10, desktop: 12),
                decoration: BoxDecoration(
                  color: requestTypeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getRequestTypeIcon(request.requestType),
                  color: requestTypeColor,
                  size: ResponsiveUtils.responsiveIconSize(
                      context, mobile: 20, tablet: 22, desktop: 24),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 12, tablet: 14, desktop: 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.employeeName,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                            context, mobile: 16, tablet: 17, desktop: 18),
                        fontWeight: FontWeight.w600,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.departmentName,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveFontSize(
                            context, mobile: 13, tablet: 14, desktop: 15),
                        color: themeService.getTextSecondaryColor(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: ResponsiveUtils.responsiveHorizontalPadding(
                    context, mobile: 8, tablet: 10, desktop: 12).add(
                    ResponsiveUtils.responsiveVerticalPadding(
                        context, mobile: 4, tablet: 5, desktop: 6)
                ),
                decoration: BoxDecoration(
                  color: themeService.getWarningColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tr('pending'),
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context, mobile: 11, tablet: 12, desktop: 13),
                    fontWeight: FontWeight.w600,
                    color: themeService.getWarningColor(),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 12, tablet: 14, desktop: 16)),

          // Request Number
          Row(
            children: [
              Text(
                '${tr('req#')}: ',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                      context, mobile: 13, tablet: 14, desktop: 15),
                  color: themeService.getTextSecondaryColor(),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: requestTypeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${request.requestNumber}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context, mobile: 13, tablet: 14, desktop: 15),
                    fontWeight: FontWeight.w600,
                    color: requestTypeColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 8, tablet: 9, desktop: 10)),

          // Request Type
          Row(
            children: [
              Icon(
                Icons.work_outline,
                size: ResponsiveUtils.responsiveIconSize(
                    context, mobile: 16, tablet: 17, desktop: 18),
                color: themeService.getTextSecondaryColor(),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 6, tablet: 7, desktop: 8)),
              Text(
                '${request.requestType}${request.leaveType.isNotEmpty ? ' - ${request.leaveType}' : ''}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                      context, mobile: 13, tablet: 14, desktop: 15),
                  color: themeService.getTextSecondaryColor(),
                ),
              ),
            ],
          ),

          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 8, tablet: 9, desktop: 10)),

          // Request Date
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: ResponsiveUtils.responsiveIconSize(
                    context, mobile: 16, tablet: 17, desktop: 18),
                color: themeService.getTextSecondaryColor(),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 6, tablet: 7, desktop: 8)),
              Text(
                '${tr('request_date')}: ${_formatDate(request.requestDateG)}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                      context, mobile: 13, tablet: 14, desktop: 15),
                  color: themeService.getTextSecondaryColor(),
                ),
              ),
            ],
          ),

          // URL-based attachments from API
          if (request.attachments.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
                context, mobile: 8, tablet: 10, desktop: 12)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: request.attachments.map((url) {
                final isImage = url.toLowerCase().contains('.jpg') ||
                    url.toLowerCase().contains('.jpeg') ||
                    url.toLowerCase().contains('.png');
                return GestureDetector(
                  onTap: () => _openAttachment(url, context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: themeService.getActionColor('requests').withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: themeService.getActionColor('requests').withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isImage ? Icons.image_outlined : Icons.attach_file,
                          size: 14,
                          color: themeService.getActionColor('requests'),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          url.split('/').last.length > 20
                              ? '${url.split('/').last.substring(0, 20)}...'
                              : url.split('/').last,
                          style: TextStyle(
                            fontSize: 11,
                            color: themeService.getActionColor('requests'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // File attachments section
          _buildFileAttachments(request.id.toString(), themeService, context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeService themeService, BuildContext context, 
      UnexecutedRequestsController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: ResponsiveUtils.responsiveHorizontalPadding(
                context, mobile: 24, tablet: 28, desktop: 32),
            decoration: BoxDecoration(
              color: themeService.getSuccessColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: ResponsiveUtils.responsiveIconSize(
                  context, mobile: 64, tablet: 72, desktop: 80),
              color: themeService.getSuccessColor(),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 24, tablet: 28, desktop: 32)),
          Text(
            tr('no_unexecuted_requests'),
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                  context, mobile: 20, tablet: 22, desktop: 24),
              fontWeight: FontWeight.w600,
              color: themeService.getTextPrimaryColor(),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 8, tablet: 10, desktop: 12)),
          Text(
            'All requests have been processed',
            style: TextStyle(
              fontSize: ResponsiveUtils.responsiveFontSize(
                  context, mobile: 14, tablet: 15, desktop: 16),
              color: themeService.getTextSecondaryColor(),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 24, tablet: 28, desktop: 32)),
          ElevatedButton.icon(
            onPressed: () => controller.loadUnexecutedRequests(),
            icon: const Icon(Icons.refresh),
            label: Text(tr('refresh')),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeService.getActionColor('requests'),
              foregroundColor: Colors.white,
              padding: ResponsiveUtils.responsiveHorizontalPadding(
                  context, mobile: 24, tablet: 28, desktop: 32).add(
                  ResponsiveUtils.responsiveVerticalPadding(
                      context, mobile: 12, tablet: 14, desktop: 16)
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRequestTypeColor(String? requestType, ThemeService themeService) {
    if (requestType == null) return themeService.getActionColor('requests');
    
    switch (requestType.toLowerCase()) {
      case 'leave':
        return themeService.getActionColor('schedule');
      case 'permission':
      case 'permit':
        return themeService.getActionColor('profile');
      case 'loan':
        return themeService.getSuccessColor();
      case 'letter':
        return themeService.getActionColor('documents');
      default:
        return themeService.getActionColor('requests');
    }
  }

  IconData _getRequestTypeIcon(String? requestType) {
    if (requestType == null) return Icons.assignment_outlined;
    
    switch (requestType.toLowerCase()) {
      case 'leave':
        return Icons.calendar_today;
      case 'permission':
      case 'permit':
        return Icons.badge_outlined;
      case 'loan':
        return Icons.account_balance_wallet;
      case 'letter':
        return Icons.description;
      default:
        return Icons.assignment_outlined;
    }
  }

  String _formatDate(String? dateTimeString) {
    if (dateTimeString == null) return '';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return dateTimeString;
    }
  }

  void _openAttachment(String url, BuildContext context) {
    final lower = url.toLowerCase();
    final isImage = lower.contains('.jpg') || lower.contains('.jpeg') || lower.contains('.png');
    final isPdf = lower.contains('.pdf');

    if (isPdf) {
      _downloadAndOpenPdf(url, context);
      return;
    }

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
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white, size: 64),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.insert_drive_file, color: Colors.white, size: 64),
                    ),
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

  Future<void> _downloadAndOpenPdf(String url, BuildContext context) async {
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

  Widget _buildFileAttachments(String requestId,
      ThemeService themeService, BuildContext context) {
    final controller = Get.find<UnexecutedRequestsController>();
    
    return Obx(() {
      final files = controller.getFilesForRequest(requestId);
      
      if (files.isEmpty) return const SizedBox.shrink();
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 12, tablet: 14, desktop: 16)),
          
          // File attachments header
          Row(
            children: [
              Icon(
                Icons.attach_file,
                size: ResponsiveUtils.responsiveIconSize(
                    context, mobile: 16, tablet: 17, desktop: 18),
                color: themeService.getTextSecondaryColor(),
              ),
              SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(
                  context, mobile: 6, tablet: 7, desktop: 8)),
              Text(
                'Attachments (${files.length})',
                style: TextStyle(
                  fontSize: ResponsiveUtils.responsiveFontSize(
                      context, mobile: 13, tablet: 14, desktop: 15),
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextSecondaryColor(),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 8, tablet: 9, desktop: 10)),
          
          // File list
          ...files.map((file) => _buildFileItem(file, themeService, context, controller)),
        ],
      );
    });
  }

  Widget _buildFileItem(Map<String, dynamic> file, ThemeService themeService, 
      BuildContext context, UnexecutedRequestsController controller) {
    final fileName = file['name'] ?? file['file_name'] ?? 'Unknown file';
    final fileSize = file['size'] ?? file['file_size'];
    final fileType = file['type'] ?? file['mime_type'] ?? _getFileTypeFromName(fileName);
    
    return Container(
      margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 8, tablet: 9, desktop: 10)),
      padding: ResponsiveUtils.responsiveHorizontalPadding(
          context, mobile: 12, tablet: 14, desktop: 16).add(
          ResponsiveUtils.responsiveVerticalPadding(
              context, mobile: 8, tablet: 9, desktop: 10)
      ),
      decoration: BoxDecoration(
        color: themeService.getActionColor('documents').withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: themeService.getActionColor('documents').withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // File icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeService.getActionColor('documents').withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getFileIcon(fileType),
              size: ResponsiveUtils.responsiveIconSize(
                  context, mobile: 16, tablet: 18, desktop: 20),
              color: themeService.getActionColor('documents'),
            ),
          ),
          
          SizedBox(width: ResponsiveUtils.getResponsiveValue<double>(
              context, mobile: 12, tablet: 14, desktop: 16)),
          
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.responsiveFontSize(
                        context, mobile: 13, tablet: 14, desktop: 15),
                    fontWeight: FontWeight.w500,
                    color: themeService.getTextPrimaryColor(),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSize != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatFileSize(fileSize),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveFontSize(
                          context, mobile: 11, tablet: 12, desktop: 13),
                      color: themeService.getTextSecondaryColor(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Download/View button
          IconButton(
            onPressed: () => controller.handleFileAction(file),
            icon: Icon(
              Icons.download,
              size: ResponsiveUtils.responsiveIconSize(
                  context, mobile: 18, tablet: 20, desktop: 22),
              color: themeService.getActionColor('documents'),
            ),
            tooltip: 'Download file',
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;
    
    final type = fileType.toLowerCase();
    if (type.contains('pdf')) return Icons.picture_as_pdf;
    if (type.contains('image') || type.contains('jpg') || type.contains('png')) return Icons.image;
    if (type.contains('video')) return Icons.video_file;
    if (type.contains('audio')) return Icons.audio_file;
    if (type.contains('word') || type.contains('doc')) return Icons.description;
    if (type.contains('excel') || type.contains('sheet')) return Icons.table_chart;
    if (type.contains('zip') || type.contains('rar')) return Icons.folder_zip;
    
    return Icons.insert_drive_file;
  }

  String _getFileTypeFromName(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf': return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'doc':
      case 'docx': return 'application/msword';
      case 'xls':
      case 'xlsx': return 'application/excel';
      default: return 'application/octet-stream';
    }
  }

  String _formatFileSize(dynamic size) {
    if (size == null) return '';
    
    double bytes;
    if (size is String) {
      bytes = double.tryParse(size) ?? 0;
    } else {
      bytes = size.toDouble();
    }
    
    if (bytes < 1024) return '${bytes.toInt()} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}