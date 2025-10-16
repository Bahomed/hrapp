import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.injazatsoftware.injazathr/utils/translation_helper.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/response/deduction_history_response.dart';
import 'package:com.injazatsoftware.injazathr/widgets/saudi_riyal_display.dart';
import 'package:com.injazatsoftware.injazathr/repository/benefit_deduction_repository.dart';
import '../../services/theme_service.dart';

void showDeductionHistoryDialog(int deductionId, String deductionName) {
  Get.bottomSheet(
    DeductionHistoryBottomSheet(
      deductionId: deductionId,
      deductionName: deductionName,
    ),
    isScrollControlled: true,
  );
}

class DeductionHistoryBottomSheet extends StatefulWidget {
  final int deductionId;
  final String deductionName;

  const DeductionHistoryBottomSheet({
    super.key,
    required this.deductionId,
    required this.deductionName,
  });

  @override
  State<DeductionHistoryBottomSheet> createState() => _DeductionHistoryBottomSheetState();
}

class _DeductionHistoryBottomSheetState extends State<DeductionHistoryBottomSheet> {
  final BenefitDeductionRepository _repository = BenefitDeductionRepository();
  final themeService = ThemeService.instance;

  bool isLoading = true;
  List<DeductionHistoryItem> historyItems = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await _repository.getDeductionHistory(widget.deductionId);

      setState(() {
        historyItems = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      height: Get.height * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeService.getSurfaceColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                color: themeService.getDividerColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('deduction_history', fallback: 'Deduction History'),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.deductionName,
                      style: TextStyle(
                        fontSize: 16,
                        color: themeService.getTextSecondaryColor(),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: themeService.getPrimaryColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 14,
                      color: themeService.getPrimaryColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${historyItems.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: themeService.getPrimaryColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Content
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: themeService.getPrimaryColor(),
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: themeService.getErrorColor(),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              style: TextStyle(
                                color: themeService.getTextSecondaryColor(),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadHistory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeService.getPrimaryColor(),
                              ),
                              child: Text(tr('retry')),
                            ),
                          ],
                        ),
                      )
                    : historyItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 64,
                                  color: themeService.getTextSecondaryColor(),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  tr('no_history_found', fallback: 'No history found'),
                                  style: TextStyle(
                                    color: themeService.getTextSecondaryColor(),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: _buildHistoryTable(context, isTablet),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTable(BuildContext context, bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = isTablet ? 12.0 : (screenWidth < 400 ? 9.0 : 10.0);
    final headerFontSize = isTablet ? 13.0 : (screenWidth < 400 ? 10.0 : 11.0);

    return Container(
      decoration: BoxDecoration(
        color: themeService.getCardColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeService.getTextSecondaryColor().withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _buildTableHeader(context, headerFontSize),
          ...historyItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildTableRow(context, index + 1, item, fontSize);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: themeService.getPrimaryColor().withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: themeService.getPrimaryColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              tr('date', fallback: 'Date'),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: themeService.getPrimaryColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: SaudiRiyalDisplay(
              customText: tr('loan_amount', fallback: 'Loan'),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: themeService.getPrimaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SaudiRiyalDisplay(
              customText: tr('deduction_amount', fallback: 'Deduction'),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: themeService.getPrimaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              tr('status', fallback: 'Status'),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: themeService.getPrimaryColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: SaudiRiyalDisplay(
              customText: tr('balance', fallback: 'Balance'),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: themeService.getPrimaryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, int index, DeductionHistoryItem item, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeService.getTextSecondaryColor().withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              index.toString(),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.settleDate,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: themeService.getTextPrimaryColor(),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: SaudiRiyalDisplay(
              amount: double.tryParse(item.loanAmount) ?? 0.0,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SaudiRiyalDisplay(
              amount: double.tryParse(item.amountPaid) ?? 0.0,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                color: themeService.getSuccessColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  fontSize: fontSize - 1,
                  fontWeight: FontWeight.w600,
                  color: themeService.getSuccessColor(),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SaudiRiyalDisplay(
              amount: item.amountToBePaid,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
