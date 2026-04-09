import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/remote/response/loan_request_response.dart';
import '../../repository/requestrepository.dart';
import '../../services/theme_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/translation_helper.dart';
import '../../widgets/saudi_riyal_display.dart';

class LoanDetailsScreen extends StatefulWidget {
  final LoanRequest request;

  const LoanDetailsScreen({super.key, required this.request});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  final RequestRepository _repository = RequestRepository();
  List<LoanSettlement>? _settlements;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLoanDetails();
  }

  Future<void> _loadLoanDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final settlementId = widget.request.executedDeductionId ?? widget.request.id;
      final response = await _repository.getLoanSettlements(settlementId);

      if (response.success) {
        setState(() {
          _settlements = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.instance.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: ThemeService.instance.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeService.instance.getTextPrimaryColor()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          tr('loan_details'),
          style: TextStyle(
            color: ThemeService.instance.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: ThemeService.instance.getActionColor('requests'),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: ThemeService.instance.getErrorColor(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: ThemeService.instance.getTextSecondaryColor(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLoanDetails,
                        child: Text(tr('retry')),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildLoanDetailsCard(),
                  ),
                ),
    );
  }

  Widget _buildLoanDetailsCard() {
    final loan = widget.request;

    return Container(
      decoration: BoxDecoration(
        color: ThemeService.instance.getCardColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeService.instance.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : ThemeService.instance.getActionColor('requests').withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loan Info Section
          _buildLoanInfo(loan),

          // Settlements Table
          if (_settlements != null && _settlements!.isNotEmpty)
            _buildSettlementsTable(),
        ],
      ),
    );
  }

  Widget _buildLoanInfo(LoanRequest loan) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(tr('request_number'), Text(
            '#${loan.requestNumber}',
            style: TextStyle(
              color: ThemeService.instance.getTextPrimaryColor(),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          )),
          const SizedBox(height: 12),
          _buildInfoRow(tr('amount'), SaudiRiyalDisplay(
            customText: '${double.tryParse(loan.amount) ?? 0.0}',
            style: TextStyle(
              color: ThemeService.instance.getSuccessColor(),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          )),
          const SizedBox(height: 12),

          _buildInfoRow(tr('instalment'), Text(
            '${loan.repaymentMonths} ${tr('months')}',
            style: TextStyle(
              color: ThemeService.instance.getWarningColor(),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          )),

          if (loan.startDate != null && loan.startDate!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(tr('repayment_start_date'), Text(
              _formatDate(loan.startDate!),
              style: TextStyle(
                color: ThemeService.instance.getActionColor('requests'),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            )),
          ],

          // Executed details if available
          if (loan.executedAmount != null || loan.executedInstallments != null) ...[
            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: ThemeService.instance.getTextSecondaryColor().withOpacity(0.1),
            ),
            const SizedBox(height: 16),

            if (loan.executedAmount != null) ...[
              _buildInfoRow(tr('executed_amount'), SaudiRiyalDisplay(
                customText: '${double.tryParse(loan.executedAmount!) ?? 0.0}',
                style: TextStyle(
                  color: ThemeService.instance.getActionColor('profile'),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              )),
              const SizedBox(height: 12),
            ],

            if (loan.executedInstallments != null) ...[
              _buildInfoRow(tr('executed_installments'), Text(
                '${loan.executedInstallments} ${tr('months')}',
                style: TextStyle(
                  color: ThemeService.instance.getActionColor('profile'),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              )),
              const SizedBox(height: 12),
            ],

            if (loan.executedDeductionStartDate != null && loan.executedDeductionStartDate!.isNotEmpty) ...[
              _buildInfoRow(tr('deduction_start_date'), Text(
                _formatDate(loan.executedDeductionStartDate!),
                style: TextStyle(
                  color: const Color(0xFF6366F1),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              )),
              const SizedBox(height: 12),
            ],
          ],

          const SizedBox(height: 4),
          Divider(
            height: 1,
            color: ThemeService.instance.getTextSecondaryColor().withOpacity(0.1),
          ),
          const SizedBox(height: 16),

          // Timeline
          _buildTimelineItem(
            tr('submitted'),
            _formatDate(loan.submittedDate),
            ThemeService.instance.getTextSecondaryColor(),
          ),
          if (loan.approvedDate != null)
            _buildTimelineItem(
              tr('approved'),
              _formatDate(loan.approvedDate!),
              ThemeService.instance.getSuccessColor(),
            ),
          if (loan.executedDate != null)
            _buildTimelineItem(
              tr('executed'),
              _formatDate(loan.executedDate!),
              ThemeService.instance.getActionColor('profile'),
            ),
        ],
      ),
    );
  }

  Widget _buildSettlementsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Settlements Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            tr('settlements'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ThemeService.instance.getTextPrimaryColor(),
            ),
          ),
        ),

        // Table
        Column(
          children: [
            _buildTableHeader(),
            ..._settlements!.map((settlement) => _buildTableRow(settlement)),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              tr('date'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ThemeService.instance.getTextSecondaryColor(),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                tr('status'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.getTextSecondaryColor(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                tr('loan_amount'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.getTextSecondaryColor(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                tr('amount_paid'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.getTextSecondaryColor(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                tr('balance'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.getTextSecondaryColor(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(LoanSettlement settlement) {
    final index = _settlements!.indexOf(settlement);
    double runningBalance = 0.0;

    // Calculate running balance
    for (int i = 0; i <= index; i++) {
      if (i == 0) {
        runningBalance = double.tryParse(_settlements![i].loanAmount) ?? 0.0;
      }
      final amountPaid = double.tryParse(_settlements![i].amountPaid) ?? 0.0;
      runningBalance = runningBalance - amountPaid;
    }

    final isLastRow = index == _settlements!.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLastRow
              ? BorderSide.none
              : BorderSide(
                  color: ThemeService.instance.getTextSecondaryColor().withOpacity(0.1),
                  width: 1,
                ),
        ),
      ),
      child: Row(
        children: [
          // Date Column
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(settlement.settleDate),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ThemeService.instance.getTextPrimaryColor(),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Status Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeService.instance.getActionColor('profile').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  settlement.status,
                  style: TextStyle(
                    color: ThemeService.instance.getActionColor('profile'),
                    fontWeight: FontWeight.w600,
                    fontSize: 8,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),

          // Loan Amount Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                settlement.loanAmount,
                style: TextStyle(
                  color: ThemeService.instance.getSuccessColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          // Amount Paid Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                settlement.amountPaid,
                style: TextStyle(
                  color: ThemeService.instance.getWarningColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          // Balance Column
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                runningBalance.toStringAsFixed(2),
                style: TextStyle(
                  color: runningBalance > 0
                      ? ThemeService.instance.getErrorColor()
                      : ThemeService.instance.getSuccessColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: ThemeService.instance.getTextSecondaryColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
        value,
      ],
    );
  }

  Widget _buildTimelineItem(String label, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ThemeService.instance.getTextPrimaryColor(),
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
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
}
