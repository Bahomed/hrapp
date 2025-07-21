
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saudi_riyal_symbol/saudi_riyal_symbol.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../repository/payroll_repository.dart';
import '../../data/remote/response/payroll_records_response.dart';
import '../../data/remote/response/payroll_summary_response.dart';
import '../../data/remote/response/payslip_download_response.dart';
import '../../utils/app_theme.dart';

class PayrollController extends GetxController {
  final PayrollRepository _payrollRepository = PayrollRepository();

  // Reactive variables
  final RxString selectedFilter = 'All'.obs;
  final RxString selectedYear = '2024'.obs;
  final RxBool isLoading = false.obs;
  final RxList<PayrollRecordResponseData> payrollRecords = <PayrollRecordResponseData>[].obs;
  final Rx<PayrollSummaryResponseData?> payrollSummary = Rx<PayrollSummaryResponseData?>(null);

  // Filter configuration
  List<Map<String, dynamic>> get filters => [
    {'name': 'All', 'key': 'all', 'color': getFilterColor('all')},
    {'name': 'Processed', 'key': 'processed', 'color': getFilterColor('processed')},
    {'name': 'Pending', 'key': 'pending', 'color': getFilterColor('pending')},
    {'name': 'Failed', 'key': 'failed', 'color': getFilterColor('failed')},
  ];

  @override
  void onInit() {
    super.onInit();
    loadPayrollData();
    loadPayrollSummary();
  }

  // Load methods
  Future<void> loadPayrollData() async {
    isLoading.value = true;
    try {
      PayrollRecordsResponse response;
      if (selectedFilter.value == 'All') {
        response = await _payrollRepository.getPayrollRecords();
      } else {
        response = await _payrollRepository.getPayrollRecordsByStatus(selectedFilter.value.toLowerCase());
      }
      if (response.success) {
        payrollRecords.value = response.data;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payroll records: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPayrollSummary([String? year]) async {
    try {
      final yearToUse = year ?? selectedYear.value;
      final response = await _payrollRepository.getPayrollSummary(yearToUse);
      if (response.success) {
        payrollSummary.value = response.data;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payroll summary: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    }
  }

  // Filter methods
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    loadPayrollData();
  }

  void changeYear(String year) {
    selectedYear.value = year;
    loadPayrollRecordsByYear(year);
    loadPayrollSummary(year);
  }

  Future<void> loadPayrollRecordsByYear(String year) async {
    isLoading.value = true;
    try {
      final response = await _payrollRepository.getPayrollRecordsByYear(year);
      if (response.success) {
        payrollRecords.value = response.data;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payroll records for year $year: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  IconData getFilterIcon(String filterName) {
    switch (filterName) {
      case 'All':
        return Icons.list;
      case 'Processed':
        return Icons.check_circle;
      case 'Pending':
        return Icons.schedule;
      case 'Failed':
        return Icons.error;
      default:
        return Icons.circle;
    }
  }

  // Get available years
  Future<List<String>> getAvailableYears() async {
    try {
      final response = await _payrollRepository.getAvailableYears();
      if (response.success) {
        return response.data;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // View payroll details
  void viewPayrollDetails(PayrollRecordResponseData record) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payslip Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      record.period, // Using period as formattedPeriod
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                _buildPayrollStatusChip(record.status),
              ],
            ),

            const SizedBox(height: 30),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(record),

                    const SizedBox(height: 30),

                    // Benefits Section
                    _buildBenefitsSection(record),

                    const SizedBox(height: 30),

                    // Deductions Section
                    _buildDeductionsSection(record),

                    const SizedBox(height: 30),

                    // Net Pay Section
                    _buildNetPaySection(record),
                  ],
                ),
              ),
            ),

            // Action Buttons
            const SizedBox(height: 20),
            _buildActionButtons(record),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPayrollStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'processed':
        backgroundColor = AppTheme.getStatusBackgroundColor('processed');
        textColor = AppTheme.getStatusColor('processed');
        text = 'Processed';
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
        backgroundColor = AppTheme.getStatusBackgroundColor('pending');
        textColor = AppTheme.getStatusColor('pending');
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case 'failed':
        backgroundColor = AppTheme.getStatusBackgroundColor('failed');
        textColor = AppTheme.getStatusColor('failed');
        text = 'Failed';
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = AppTheme.getStatusBackgroundColor('draft');
        textColor = AppTheme.getStatusColor('draft');
        text = 'Unknown';
        icon = Icons.circle;
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

  Widget _buildSummaryCards(PayrollRecordResponseData record) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Gross Pay',
            SaudiCurrencySymbol(
              price: record.totalBenefits,
              priceStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.successColor),
              symbolFontSize: 18,
              symbolFontColor: AppTheme.successColor,
            ),
            AppTheme.successColor,
            AppTheme.getStatusBackgroundColor('processed'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Deductions',
            SaudiCurrencySymbol(
              price: record.totalDeductions,
              priceStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.errorColor),
              symbolFontSize: 18,
              symbolFontColor: AppTheme.errorColor,
            ),
            AppTheme.errorColor,
            AppTheme.getStatusBackgroundColor('failed'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Net Pay',
            SaudiCurrencySymbol(
              price: record.netSalary,
              priceStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.secondaryColor),
              symbolFontSize: 18,
              symbolFontColor: AppTheme.secondaryColor,
            ),
            AppTheme.secondaryColor,
            AppTheme.getStatusBackgroundColor('all'),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, Widget amount, Color textColor, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          amount,
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(PayrollRecordResponseData record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Benefits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...record.benefits.map((item) => _buildPayrollItem(
          item.description,
          SaudiCurrencySymbol(
            price: item.amount,
            priceStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.successColor),
            symbolFontSize: 14,
            symbolFontColor: AppTheme.successColor,
          ),
          AppTheme.successColor,
        )),
      ],
    );
  }

  Widget _buildDeductionsSection(PayrollRecordResponseData record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deductions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        ...record.deductions.map((item) => _buildPayrollItem(
          item.description,
          SaudiCurrencySymbol(
            price: item.amount,
            priceStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.errorColor),
            symbolFontSize: 14,
            symbolFontColor: AppTheme.errorColor,
          ),
          AppTheme.errorColor,
        )),
      ],
    );
  }

  Widget _buildNetPaySection(PayrollRecordResponseData record) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Net Pay',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondaryColor,
            ),
          ),
          SaudiCurrencySymbol(
            price: record.netSalary,
            priceStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.secondaryColor),
            symbolFontSize: 24,
            symbolFontColor: AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollItem(String description, Widget amount, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          amount,
        ],
      ),
    );
  }

  Widget _buildActionButtons(PayrollRecordResponseData record) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => downloadPayslip(record.id),
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text(
          'Download',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // Download payslip
  Future<void> downloadPayslip(String payrollId) async {
    Get.back(); // Close bottom sheet

    Get.snackbar(
      'Downloading',
      'Downloading payslip...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.secondaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );

    isLoading.value = true;

    try {
      final response = await _payrollRepository.downloadPayslip(payrollId);
      
      if (response.success) {
        // Decode Base64 to bytes
        final bytes = base64Decode(response.data.pdfBase64);
        
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/${response.data.filename}';
        
        // Save PDF file
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        
        // Open the PDF file using open_file package
        final result = await OpenFile.open(filePath);
        
        if (result.type == ResultType.done) {
          Get.snackbar(
            'Success',
            'Payslip opened: ${response.data.filename}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.successColor,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Info',
            'PDF saved but could not open automatically: ${response.data.filename}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.warningColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download payslip: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


  // Show year picker
  void showYearPicker() async {
    final years = await getAvailableYears();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Year',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ...years.map((year) => ListTile(
              title: Text(year),
              trailing: selectedYear.value == year
                  ? Icon(Icons.check, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                changeYear(year);
                Get.back();
              },
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Refresh method
  Future<void> refreshPayrollData() async {
    isLoading.value = true;

    try {
      final response = await _payrollRepository.refreshPayrollData();
      if (response.success) {
        payrollRecords.value = response.data;
        await loadPayrollSummary(selectedYear.value);
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Format currency
  Widget formatCurrency(double amount) {
    return SaudiCurrencySymbol(
      price: amount,
      priceStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      symbolFontSize: 16,
    );
  }

  // Get status color
  Color getStatusColor(String status) {
    return AppTheme.getStatusColor(status);
  }

  // Get filter color
  Color getFilterColor(String filter) {
    return AppTheme.getFilterColor(filter);
  }
}
