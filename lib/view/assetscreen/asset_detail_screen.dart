import 'package:co.injazathr.injazathr/data/remote/response/asset_response.dart';
import 'package:co.injazathr.injazathr/repository/assetrepository.dart';
import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetDetailScreen extends StatefulWidget {
  final int assignmentId;
  const AssetDetailScreen({super.key, required this.assignmentId});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final _repository = AssetRepository();
  AssetAssignmentItem? _item;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final response = await _repository.getMyAssetDetail(widget.assignmentId);
      if (response.error || response.data == null) {
        setState(() => _error = response.message);
      } else {
        setState(() => _item = response.data);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getSurfaceColor(),
        elevation: 0,
        title: Text(
          tr('asset_detail'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: themeService.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(themeService),
    );
  }

  Widget _buildError() {
    final themeService = ThemeService.instance;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: themeService.getTextSecondaryColor()),
          const SizedBox(height: 12),
          Text(_error ?? tr('error_occurred'),
              style: TextStyle(color: themeService.getTextSecondaryColor())),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadDetail, child: Text(tr('retry'))),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeService themeService) {
    final item = _item!;
    final asset = item.asset;
    final statusColor = _statusColor(item.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(_statusIcon(item.status), color: statusColor, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset?.name ?? tr('unknown_asset'),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    Text(
                      asset?.assetCode ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: themeService.getTextSecondaryColor(),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status.capitalizeFirst ?? item.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Assignment info
          _sectionCard(
            themeService,
            title: tr('assignment_info'),
            icon: Icons.assignment_outlined,
            children: [
              _infoRow(themeService, tr('assigned_date'), item.assignedDate ?? '-'),
              _infoRow(themeService, tr('expected_return'), item.expectedReturnDate ?? '-'),
              if (item.returnDate != null)
                _infoRow(themeService, tr('return_date'), item.returnDate!),
              _infoRow(themeService, tr('condition_at_assign'), item.conditionAtAssign ?? '-'),
              if (item.conditionAtReturn != null)
                _infoRow(themeService, tr('condition_at_return'), item.conditionAtReturn!),
              if (item.assignedBy != null)
                _infoRow(themeService, tr('assigned_by'), item.assignedBy!),
              if (item.notes != null && item.notes!.isNotEmpty)
                _infoRow(themeService, tr('notes'), item.notes!),
            ],
          ),

          if (asset != null) ...[
            const SizedBox(height: 12),

            // Asset info
            _sectionCard(
              themeService,
              title: tr('asset_info'),
              icon: Icons.inventory_2_outlined,
              children: [
                if (asset.brand != null)
                  _infoRow(themeService, tr('brand'), asset.brand!),
                if (asset.model != null)
                  _infoRow(themeService, tr('model'), asset.model!),
                if (asset.serialNumber != null)
                  _infoRow(themeService, tr('serial_number'), asset.serialNumber!),
                if (asset.condition != null)
                  _infoRow(themeService, tr('condition'), asset.condition!),
                if (asset.vendorName != null)
                  _infoRow(themeService, tr('vendor'), asset.vendorName!),
                if (asset.purchaseDate != null)
                  _infoRow(themeService, tr('purchase_date'), asset.purchaseDate!),
                if (asset.warrantyStart != null)
                  _infoRow(themeService, tr('warranty_start'), asset.warrantyStart!),
                if (asset.warrantyEnd != null)
                  _infoRow(themeService, tr('warranty_end'), asset.warrantyEnd!),
                if (asset.category != null)
                  _infoRow(themeService, tr('category'), asset.category!.name ?? '-'),
                if (asset.branch != null)
                  _infoRow(themeService, tr('branch'), asset.branch!.name ?? '-'),
                if (asset.department != null)
                  _infoRow(themeService, tr('department'), asset.department!.name ?? '-'),
              ],
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionCard(
    ThemeService themeService, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(12),
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
              Icon(icon, size: 18, color: themeService.getTextSecondaryColor()),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(ThemeService themeService, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: themeService.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
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
}
