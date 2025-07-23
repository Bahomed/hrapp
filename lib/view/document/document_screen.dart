// File: lib/view/document/document_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import 'package:injazat_hr_app/utils/theme_widgets.dart';
import '../../services/theme_service.dart';
import 'document_controller.dart';
import 'document_widgets.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DocumentController());

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('documents')),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: controller.uploadNewDocument,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: ThemeService.instance.getSurfaceColor(),
            child: Column(
              children: [
                // Filter Buttons
                _buildFilterButtons(controller),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ThemeWidgets.buildLoadingWidget(message: tr('loading'));
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDocuments,
          color: ThemeService.instance.getPrimaryColor(),
          child: CustomScrollView(
            slivers: [
<<<<<<< HEAD
=======
              // Search Bar
              const SliverToBoxAdapter(
                child: DocumentSearchBar(),
              ),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604

              // Summary Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (controller.documentSummary.value != null)
                        DocumentSummaryCard(summary: controller.documentSummary.value!),
                      const SizedBox(height: 20),
                      const DocumentCategoryTabs(),
                      const SizedBox(height: 20),
<<<<<<< HEAD
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${tr('document_list')} (${controller.documents.length} files)',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeService.instance.getTextPrimaryColor(),
                                  ),
                                ),
                                // Add more widgets here if needed
                              ],
                            ),
                          ),

                        ],
                      ),

=======
                      ThemeWidgets.buildSectionHeader(
                        title: tr('document_list'),
                        subtitle: '${controller.documents.length} files',
                      ),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Documents List/Grid
              if (controller.documents.isEmpty)
                SliverFillRemaining(
                  child: ThemeWidgets.buildEmptyState(
                    message: tr('no_documents_found'),
                    icon: Icons.folder_open,
                  ),
                )
              else
                controller.isGridView.value
                    ? _buildDocumentGrid(controller)
                    : _buildDocumentList(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterButtons(DocumentController controller) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => Row(
        children: controller.filters.map((filter) {
          final filterName = filter['name'] as String;
          final filterColor = filter['color'] as Color;
          final isSelected = controller.selectedFilter.value == filterName;

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeFilter(filterName),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? filterColor : ThemeService.instance.getCardColor(),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? filterColor : ThemeService.instance.getDividerColor(),
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: filterColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        controller.getFilterIcon(filterName),
                        color: ThemeService.instance.getContrastTextColor(filterColor),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        filterName,
                        style: TextStyle(
                          color: isSelected ? ThemeService.instance.getContrastTextColor(filterColor) : filterColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildDocumentList(DocumentController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final document = controller.documents[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              index == controller.documents.length - 1 ? 100 : 0,
            ),
            child: DocumentCard(document: document),
          );
        },
        childCount: controller.documents.length,
      ),
    );
  }

  Widget _buildDocumentGrid(DocumentController controller) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final document = controller.documents[index];
            return DocumentGridCard(document: document);
          },
          childCount: controller.documents.length,
        ),
      ),
    );
  }
}