// File: lib/view/document/document_widgets.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/remote/response/document_response.dart';
import '../../services/theme_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/translation_helper.dart';
import 'document_controller.dart';
import 'document_upload_screen.dart';

class DocumentStatusChip extends StatelessWidget {
  final String status;

  const DocumentStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = themeService.getStatusBackgroundColor('active');
        textColor = themeService.getStatusColor('active');
        text = tr('active');
        icon = Icons.check_circle_outline;
        break;
      case 'expired':
        backgroundColor = themeService.getStatusBackgroundColor('expired');
        textColor = themeService.getStatusColor('expired');
        text = tr('expired');
        icon = Icons.access_time;
        break;
      case 'pending':
        backgroundColor = themeService.getStatusBackgroundColor('pending');
        textColor = themeService.getStatusColor('pending');
        text = tr('pending');
        icon = Icons.schedule;
        break;
      case 'rejected':
        backgroundColor = themeService.getStatusBackgroundColor('rejected');
        textColor = themeService.getStatusColor('rejected');
        text = tr('rejected');
        icon = Icons.cancel_outlined;
        break;
      default:
        backgroundColor = themeService.getStatusBackgroundColor('draft');
        textColor = themeService.getStatusColor('draft');
        text = status.capitalize ?? 'Unknown';
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final DocumentResponseData document;

  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.viewDocumentDetails(document),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
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
                    _buildDocumentIcon(document.fileType ?? ''),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeService.instance.getTextPrimaryColor(),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            document.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: ThemeService.instance.getTextSecondaryColor(),
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    DocumentStatusChip(status: document.status),
                  ],
                ),

                const SizedBox(height: 16),

                // Document Details Row - Fixed overflow
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDetailChip(
                        document.category.capitalize ?? '',
                        controller.getCategoryColor(document.category),
                        Icons.folder_outlined,
                      ),
                      const SizedBox(width: 8),
                      _buildDetailChip(
                        document.fileType?.toUpperCase() ?? '',
                        ThemeService.instance.getDocumentColor(2),
                        Icons.insert_drive_file,
                      ),
                      if (document.docNo != null && document.docNo!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _buildDetailChip(
                          document.docNo!,
                          ThemeService.instance.getDocumentColor(8),
                          Icons.numbers,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom Row
                Row(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 16,
                      color: ThemeService.instance.getTextSecondaryColor(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${tr('uploaded')} ${document.uploadedDate}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeService.instance.getTextSecondaryColor(),
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),

                  ],
                ),

                // Expiry Warning
                if (_isExpiringSoon(document))
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.getStatusBackgroundColor('pending'),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ThemeService.instance.getStatusColor('pending'),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          size: 16,
                          color: ThemeService.instance.getStatusColor('pending'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Expires on ${document.expiryDate}',
                            style: TextStyle(
                              fontSize: 12,
                              color: ThemeService.instance.getStatusColor('pending'),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isExpiringSoon(DocumentResponseData document) {
    if (document.expiryDate == null || document.expiryDate!.isEmpty) return false;

    try {
      final expiry = DateTime.parse(document.expiryDate!);
      final now = DateTime.now();
      final difference = expiry.difference(now).inDays;
      return difference <= 30 && difference > 0; // Expires within 30 days
    } catch (e) {
      return false;
    }
  }

  Widget _buildDocumentIcon(String fileType) {
    IconData icon;
    Color color;

    switch (fileType.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = ThemeService.instance.getDocumentColor(0);
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        icon = Icons.image;
        color = ThemeService.instance.getDocumentColor(7);
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = ThemeService.instance.getDocumentColor(1);
        break;
      default:
        icon = Icons.insert_drive_file;
        color = ThemeService.instance.getTextSecondaryColor();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildDetailChip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentGridCard extends StatelessWidget {
  final DocumentResponseData document;

  const DocumentGridCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentController>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.viewDocumentDetails(document),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status and Icon Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDocumentIcon(document.fileType ?? ''),
                  DocumentStatusChip(status: document.status),
                ],
              ),

              const SizedBox(height: 12),

              // Document Name
              Text(
                document.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.getTextPrimaryColor(),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // File Details
              Row(
                children: [
                  Expanded(
                    child: Text(
                      document.fileType?.toUpperCase() ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        color: ThemeService.instance.getTextSecondaryColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 12),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentIcon(String fileType) {
    IconData icon;
    Color color;

    switch (fileType.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = ThemeService.instance.getDocumentColor(0);
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        icon = Icons.image;
        color = ThemeService.instance.getDocumentColor(7);
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = ThemeService.instance.getDocumentColor(1);
        break;
      default:
        icon = Icons.insert_drive_file;
        color = ThemeService.instance.getTextSecondaryColor();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class DocumentSummaryCard extends StatelessWidget {
  final DocumentSummaryResponseData summary;

  const DocumentSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeService.instance.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeService.instance.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : AppTheme.getActionColor('payroll').withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('document_overview'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.getTextPrimaryColor(),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeService.instance.getTextPrimaryColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${summary.totalDocuments} ${tr('docs')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeService.instance.getTextPrimaryColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  tr('active'),
                  '${summary.activeDocuments}',
                  Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 16),

              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  tr('expired')
                  ,
                  '${summary.expiredDocuments}',
                  Icons.access_time,
                ),
              ),
            ],
          ),


        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: ThemeService.instance.getTextPrimaryColor(), size: 24),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            color: ThemeService.instance.getTextPrimaryColor(),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: ThemeService.instance.getTextPrimaryColor().withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class DocumentCategoryTabs extends StatelessWidget {
  const DocumentCategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentController>();

    return SizedBox(
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('categories'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeService.instance.getTextPrimaryColor(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.isCategoriesLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: ThemeService.instance.getPrimaryColor(),
                    strokeWidth: 2,
                  ),
                );
              }
              
              if (controller.availableCategories.isEmpty) {
                return Center(
                  child: Text(
                    tr('no_categories_available'),
                    style: TextStyle(
                      color: ThemeService.instance.getTextSecondaryColor(),
                      fontSize: 14,
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.availableCategories.length,
                itemBuilder: (context, index) {
                  final categoryData = controller.availableCategories[index];
                  final categoryName = categoryData.documentName.toLowerCase();
                  final color = controller.getCategoryColor(categoryName);
                  final count = categoryData.totalCount;

                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.filterByCategoryId(categoryData.id),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(categoryName),
                                color: color,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Text(
                                  categoryData.documentName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return Icons.person;
      case 'work':
        return Icons.work;
      case 'legal':
        return Icons.gavel;
      case 'financial':
        return Icons.account_balance;
      case 'medical':
        return Icons.medical_services;
      case 'other':
        return Icons.folder;
      default:
        return Icons.folder;
    }
  }
}

class EmptyDocumentState extends StatelessWidget {
  final String message;

  const EmptyDocumentState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentController>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: ThemeService.instance.getTextSecondaryColor(),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: ThemeService.instance.getTextSecondaryColor(),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: controller.uploadNewDocument,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Upload Document'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeService.instance.getPrimaryColor(),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentSearchBar extends StatelessWidget {
  const DocumentSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeService.instance.getCardColor(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        decoration: InputDecoration(
          hintText: tr('search_documents'),
          prefixIcon: Icon(Icons.search, color: ThemeService.instance.getPrimaryColor()),
          suffixIcon: Obx(() => controller.isGridView.value
              ? IconButton(
            icon: Icon(Icons.view_list, color: ThemeService.instance.getPrimaryColor()),
            onPressed: controller.toggleViewMode,
          )
              : IconButton(
            icon: Icon(Icons.grid_view, color: ThemeService.instance.getPrimaryColor()),
            onPressed: controller.toggleViewMode,
          ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: TextStyle(
            color: ThemeService.instance.getTextSecondaryColor(),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class DocumentDetailBottomSheet extends StatelessWidget {
  final DocumentResponseData document;

  const DocumentDetailBottomSheet({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentController>();

    return Container(
      height: Get.height * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeService.instance.getSurfaceColor(),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: ThemeService.instance.getDividerColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              _buildDocumentIcon(document.fileType ?? ''),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ThemeService.instance.getTextPrimaryColor(),
                      ),
                    ),
                    Text(
                      document.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeService.instance.getTextSecondaryColor(),
                      ),
                    ),
                  ],
                ),
              ),
              DocumentStatusChip(status: document.status),
            ],
          ),

          const SizedBox(height: 30),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document Info Cards
                  _buildDocumentInfoCards(document),

                  const SizedBox(height: 30),

                  // Details Section
                  _buildDocumentDetails(document),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Action Buttons
          const SizedBox(height: 20),
          _buildDocumentActionButtons(context, document, controller),
        ],
      ),
    );
  }

  Widget _buildDocumentIcon(String fileType) {
    IconData icon;
    Color color;

    switch (fileType.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = ThemeService.instance.getDocumentColor(0);
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        icon = Icons.image;
        color = ThemeService.instance.getDocumentColor(7);
        break;
      case 'doc':
      case 'docx':
        icon = Icons.description;
        color = ThemeService.instance.getDocumentColor(1);
        break;
      default:
        icon = Icons.insert_drive_file;
        color = ThemeService.instance.getTextSecondaryColor();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  Widget _buildDocumentInfoCards(DocumentResponseData document) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                tr('file_type'),
                document.fileType?.toUpperCase() ?? '',
                Icons.insert_drive_file,
                ThemeService.instance.getDocumentColor(0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                tr('category'),
                document.category.capitalize ?? '',
                Icons.folder,
                ThemeService.instance.getDocumentColor(8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                '${tr('uploaded')}',
                document.uploadedDate,
                Icons.cloud_upload,
                ThemeService.instance.getDocumentColor(7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ThemeService.instance.getTextPrimaryColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentDetails(DocumentResponseData document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('document_details'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ThemeService.instance.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(height: 16),
        if (document.docNo != null && document.docNo!.isNotEmpty)
          _buildDetailRow(tr('doc_number'), document.docNo!),
        if (document.expiryDate != null && document.expiryDate!.isNotEmpty)
          _buildDetailRow(tr('expiry_date'), document.expiryDate!),
        if (document.placeIssued != null && document.placeIssued!.isNotEmpty)
          _buildDetailRow(tr('place_issued'), document.placeIssued!),
        if (document.country != null && document.country!.isNotEmpty)
          _buildDetailRow(tr('country'), document.country!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: ThemeService.instance.getTextSecondaryColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeService.instance.getTextPrimaryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentActionButtons(BuildContext context, DocumentResponseData document, DocumentController controller) {
    final ts = ThemeService.instance;

    // Look up renewable flag from already-loaded categories
    // (the document list endpoint doesn't return it, but /filter/categories does)
    final isRenewable = controller.availableCategories
        .firstWhereOrNull(
          (c) => c.documentName.toLowerCase() == document.category.toLowerCase(),
        )
        ?.renewable ?? false;

    return Column(
      children: [
        // Renew button — only shown when document type is renewable
        if (isRenewable) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await Get.to(
                  () => DocumentUploadScreen(renewDocument: document),
                );
                if (result == true) await controller.refreshDocuments();
              },
              icon: const Icon(Icons.autorenew, color: Colors.white),
              label: Text(
                tr('renew_document'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Download + Share
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.downloadDocument(document);
                },
                icon: const Icon(Icons.download, color: Colors.white),
                label: Text(
                  tr('download'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ts.getPrimaryColor(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.shareDocument(document);
                },
                icon: Icon(Icons.share, color: ts.getPrimaryColor()),
                label: Text(
                  tr('share'),
                  style: TextStyle(color: ts.getPrimaryColor(), fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ts.getPrimaryColor()),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}