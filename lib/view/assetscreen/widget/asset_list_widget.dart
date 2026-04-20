import 'package:co.injazathr.injazathr/data/remote/response/asset_response.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/responsive_utils.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/assetscreen/assetscreen_controller.dart';
import 'package:co.injazathr.injazathr/view/assetscreen/asset_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetListWidget extends StatelessWidget {
  const AssetListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AssetScreenController());
    final themeService = ThemeService.instance;

    return Column(
      children: [
        _buildSummaryCards(context, controller, themeService),
        _buildFilterSection(context, controller, themeService),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.assetList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.assetList.isEmpty) {
              return _buildEmptyState(context, controller, themeService);
            }
            return _buildList(context, controller, themeService);
          }),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    AssetScreenController controller,
    ThemeService themeService,
  ) {
    return Obx(() {
      final s = controller.summary.value;
      if (s == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: themeService.getSurfaceColor(),
        child: Row(
          children: [
            _summaryChip(tr('assigned'), s.assigned, const Color(0xFF4CAF50), themeService),
            const SizedBox(width: 8),
            _summaryChip(tr('overdue'), s.overdue, const Color(0xFFFF6B6B), themeService),
            const SizedBox(width: 8),
            _summaryChip(tr('returned'), s.returned, const Color(0xFF26D0CE), themeService),
            const SizedBox(width: 8),
            _summaryChip(tr('total'), s.total, const Color(0xFF9F7AEA), themeService),
          ],
        ),
      );
    });
  }

  Widget _summaryChip(String label, int count, Color color, ThemeService themeService) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: themeService.getTextSecondaryColor(),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    AssetScreenController controller,
    ThemeService themeService,
  ) {
    return Container(
      padding: ResponsiveUtils.responsiveHorizontalPadding(
              context, mobile: 16, tablet: 20, desktop: 24)
          .add(const EdgeInsets.symmetric(vertical: 10)),
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: [
                _filterChip(
                  controller,
                  themeService,
                  'assigned',
                  tr('assigned'),
                  Icons.inventory_2_outlined,
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  controller,
                  themeService,
                  'overdue',
                  tr('overdue'),
                  Icons.warning_amber_outlined,
                  const Color(0xFFFF6B6B),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  controller,
                  themeService,
                  'returned',
                  tr('returned'),
                  Icons.assignment_return_outlined,
                  const Color(0xFF26D0CE),
                ),
                const SizedBox(width: 8),
                _filterChip(
                  controller,
                  themeService,
                  'all',
                  tr('all'),
                  Icons.list_alt_outlined,
                  const Color(0xFF9F7AEA),
                ),
              ],
            )),
      ),
    );
  }

  Widget _filterChip(
    AssetScreenController controller,
    ThemeService themeService,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Obx(() {
      final selected = controller.selectedFilter.value == value;
      return FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? color : themeService.getTextSecondaryColor()),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => controller.filterByStatus(value),
        backgroundColor: themeService.getSurfaceColor(),
        selectedColor: color.withValues(alpha: 0.15),
        checkmarkColor: color,
        labelStyle: TextStyle(
          fontSize: 12,
          color: selected ? color : themeService.getTextSecondaryColor(),
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? color : themeService.getTextSecondaryColor().withValues(alpha: 0.3),
        ),
      );
    });
  }

  Widget _buildList(
    BuildContext context,
    AssetScreenController controller,
    ThemeService themeService,
  ) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: Obx(() {
        final items = controller.assetList;
        return ListView.builder(
          controller: controller.scrollController,
          padding: ResponsiveUtils.responsiveHorizontalPadding(
                  context, mobile: 16, tablet: 20, desktop: 24)
              .add(const EdgeInsets.symmetric(vertical: 12)),
          itemCount: items.length + (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _buildAssetCard(items[index], themeService);
          },
        );
      }),
    );
  }

  Widget _buildAssetCard(AssetAssignmentItem item, ThemeService themeService) {
    final statusColor = _statusColor(item.status);
    final asset = item.asset;

    return GestureDetector(
      onTap: () => Get.to(() => AssetDetailScreen(assignmentId: item.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeService.getCardColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _statusIcon(item.status),
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset?.name ?? tr('unknown_asset'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: themeService.getTextPrimaryColor(),
                        ),
                      ),
                      if (asset?.assetCode != null)
                        Text(
                          asset!.assetCode!,
                          style: TextStyle(
                            fontSize: 12,
                            color: themeService.getTextSecondaryColor(),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(item.status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                if (asset?.category != null)
                  _infoChip(
                    Icons.category_outlined,
                    asset!.category!.name ?? '',
                    themeService,
                  ),
                const SizedBox(width: 8),
                if (asset?.brand != null)
                  _infoChip(Icons.business_outlined, asset!.brand!, themeService),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 13, color: themeService.getTextSecondaryColor()),
                const SizedBox(width: 4),
                Text(
                  '${tr('assigned')}: ${item.assignedDate ?? '-'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeService.getTextSecondaryColor(),
                  ),
                ),
                if (item.expectedReturnDate != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.event_outlined,
                      size: 13, color: themeService.getTextSecondaryColor()),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${tr('expected_return')}: ${item.expectedReturnDate}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeService.getTextSecondaryColor(),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, ThemeService themeService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: themeService.getTextSecondaryColor().withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: themeService.getTextSecondaryColor()),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: themeService.getTextSecondaryColor()),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AssetScreenController controller,
    ThemeService themeService,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: themeService.getTextSecondaryColor().withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            tr('no_assets_found'),
            style: TextStyle(
              fontSize: 16,
              color: themeService.getTextSecondaryColor(),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return const Color(0xFF4CAF50);
      case 'overdue':
        return const Color(0xFFFF6B6B);
      case 'returned':
        return const Color(0xFF26D0CE);
      default:
        return const Color(0xFF9F7AEA);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Icons.inventory_2_outlined;
      case 'overdue':
        return Icons.warning_amber_outlined;
      case 'returned':
        return Icons.assignment_return_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return tr('assigned');
      case 'overdue':
        return tr('overdue');
      case 'returned':
        return tr('returned');
      default:
        return status;
    }
  }
}
