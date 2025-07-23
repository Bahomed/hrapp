<<<<<<< HEAD
import 'dart:convert';
import 'dart:io';
=======

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
<<<<<<< HEAD
import '../../repository/payroll_repository.dart';
import '../../data/remote/response/payroll_records_response.dart';
import '../../data/remote/response/payroll_summary_response.dart';
import '../../services/theme_service.dart';
import '../../widgets/saudi_riyal_display.dart';

class PayrollController extends GetxController {
  final PayrollRepository _payrollRepository = PayrollRepository();
  final ThemeService _themeService = ThemeService.instance;

  // Reactive variables
  final RxString selectedYear = ''.obs; // Initialize as empty
  final RxBool isLoading = false.obs;
  final RxList<PayrollRecordResponseData> payrollRecords = <
      PayrollRecordResponseData>[].obs;
  final RxList<PayrollSummaryItem> payrollSummary = <PayrollSummaryItem>[].obs;
=======
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
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604

  @override
  void onInit() {
    super.onInit();
<<<<<<< HEAD
    initializePayrollData();
  }

  // Initialize payroll data with the highest available year
  Future<void> initializePayrollData() async {
    isLoading.value = true;
    try {
      // Get available years and select the highest one
      final years = await getAvailableYears();
      if (years.isNotEmpty) {
        selectedYear.value =
            years.reduce((a, b) => int.parse(a) > int.parse(b) ? a : b);
      } else {
        selectedYear.value = DateTime
            .now()
            .year
            .toString(); // Fallback to current year
      }

      // Load payroll data and summary for the selected year
      await Future.wait([
        loadPayrollData(),
        loadPayrollSummary(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize payroll data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _themeService.getErrorColor(),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load payroll data
  Future<void> loadPayrollData() async {
    if (selectedYear.value.isEmpty) return; // Guard clause

    isLoading.value = true;
    try {
      final response = await _payrollRepository.getPayrollRecordsByYear(
          selectedYear.value);
=======
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
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
      if (response.success) {
        payrollRecords.value = response.data;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
<<<<<<< HEAD
          backgroundColor: _themeService.getErrorColor(),
=======
          backgroundColor: Colors.red,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payroll records: $e',
        snackPosition: SnackPosition.BOTTOM,
<<<<<<< HEAD
        backgroundColor: _themeService.getErrorColor(),
=======
        backgroundColor: AppTheme.errorColor,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

<<<<<<< HEAD
  // Load payroll summary
=======
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
          backgroundColor: _themeService.getErrorColor(),
=======
          backgroundColor: Colors.red,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payroll summary: $e',
        snackPosition: SnackPosition.BOTTOM,
<<<<<<< HEAD
        backgroundColor: _themeService.getErrorColor(),
=======
        backgroundColor: AppTheme.errorColor,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        colorText: Colors.white,
      );
    }
  }

<<<<<<< HEAD
  // Change year
=======
  // Filter methods
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    loadPayrollData();
  }

>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
  void changeYear(String year) {
    selectedYear.value = year;
    loadPayrollRecordsByYear(year);
    loadPayrollSummary(year);
  }

<<<<<<< HEAD
  // Load payroll records by year
=======
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
          backgroundColor: _themeService.getErrorColor(),
=======
          backgroundColor: Colors.red,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payroll records for year $year: $e',
        snackPosition: SnackPosition.BOTTOM,
<<<<<<< HEAD
        backgroundColor: _themeService.getErrorColor(),
=======
        backgroundColor: AppTheme.errorColor,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

<<<<<<< HEAD
=======
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

>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
        decoration: BoxDecoration(
          color: _themeService.getSurfaceColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
=======
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
                  color: _themeService.getDividerColor(),
=======
                  color: Colors.grey[300],
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
                    Text(
=======
                    const Text(
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
                      'Payslip Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
<<<<<<< HEAD
                        color: _themeService.getTextPrimaryColor(),
                      ),
                    ),
                    Text(
                      record.period,
                      style: TextStyle(
                        fontSize: 16,
                        color: _themeService.getTextSecondaryColor(),
=======
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      record.period, // Using period as formattedPeriod
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
                   _buildSummaryCards(record),
=======
                    _buildSummaryCards(record),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604

                    const SizedBox(height: 30),

                    // Benefits Section
                    _buildBenefitsSection(record),

                    const SizedBox(height: 30),

                    // Deductions Section
                    _buildDeductionsSection(record),

                    const SizedBox(height: 30),

                    // Net Pay Section
<<<<<<< HEAD
                    _buildNetPaySection('Net Pay',record.netSalary,_themeService.getSecondaryColor()),
=======
                    _buildNetPaySection(record),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
        backgroundColor = _themeService.getStatusBackgroundColor('processed');
        textColor = _themeService.getStatusColor('processed');
=======
        backgroundColor = AppTheme.getStatusBackgroundColor('processed');
        textColor = AppTheme.getStatusColor('processed');
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        text = 'Processed';
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
<<<<<<< HEAD
        backgroundColor = _themeService.getStatusBackgroundColor('pending');
        textColor = _themeService.getStatusColor('pending');
=======
        backgroundColor = AppTheme.getStatusBackgroundColor('pending');
        textColor = AppTheme.getStatusColor('pending');
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case 'failed':
<<<<<<< HEAD
        backgroundColor = _themeService.getStatusBackgroundColor('failed');
        textColor = _themeService.getStatusColor('failed');
=======
        backgroundColor = AppTheme.getStatusBackgroundColor('failed');
        textColor = AppTheme.getStatusColor('failed');
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        text = 'Failed';
        icon = Icons.error_outline;
        break;
      default:
<<<<<<< HEAD
        backgroundColor = _themeService.getStatusBackgroundColor('draft');
        textColor = _themeService.getStatusColor('draft');
=======
        backgroundColor = AppTheme.getStatusBackgroundColor('draft');
        textColor = AppTheme.getStatusColor('draft');
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNetPaySection(
          'Gross Pay',
          record.totalBenefits,
          _themeService.getSecondaryColor(),
        ),
        const SizedBox(height: 16),
        _buildNetPaySection(
          'Deductions',
          record.totalDeductions,
          _themeService.getErrorColor(),
        ),
        const SizedBox(height: 16),
        _buildNetPaySection(
          'Net Pay',
          record.netSalary,
          _themeService.getSecondaryColor(),
=======
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
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        ),
      ],
    );
  }

<<<<<<< HEAD
=======
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
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604

  Widget _buildBenefitsSection(PayrollRecordResponseData record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
<<<<<<< HEAD
        Text(
=======
        const Text(
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          'Benefits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
<<<<<<< HEAD
            color: _themeService.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(height: 16),
        ...record.benefits.map((item) =>
            _buildPayrollItem(
              item.description,
              SaudiRiyalDisplay(
                amount: item.amount,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
              _themeService.getSuccessColor(),
            )),
=======
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
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
      ],
    );
  }

  Widget _buildDeductionsSection(PayrollRecordResponseData record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
<<<<<<< HEAD
        Text(
=======
        const Text(
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          'Deductions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
<<<<<<< HEAD
            color: _themeService.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(height: 16),
        ...record.deductions.map((item) =>
            _buildPayrollItem(
              item.description,
              SaudiRiyalDisplay(
                amount: item.amount,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
              _themeService.getErrorColor(),
            )),
=======
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
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
      ],
    );
  }

<<<<<<< HEAD
  Widget _buildNetPaySection(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
=======
  Widget _buildNetPaySection(PayrollRecordResponseData record) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryColor.withOpacity(0.3),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
<<<<<<< HEAD
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SaudiRiyalDisplay(
            amount: amount,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
=======
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
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildPayrollItem(String description, Widget amount,
      Color amountColor) {
=======
  Widget _buildPayrollItem(String description, Widget amount, Color amountColor) {
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
<<<<<<< HEAD
              color: _themeService.getTextSecondaryColor(),
=======
              color: Colors.grey[700],
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
          backgroundColor: _themeService.getSecondaryColor(),
=======
          backgroundColor: AppTheme.secondaryColor,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
      backgroundColor: _themeService.getSecondaryColor(),
=======
      backgroundColor: AppTheme.secondaryColor,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );

    isLoading.value = true;

    try {
      final response = await _payrollRepository.downloadPayslip(payrollId);
<<<<<<< HEAD

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

=======
      
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
        
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        if (result.type == ResultType.done) {
          Get.snackbar(
            'Success',
            'Payslip opened: ${response.data.filename}',
            snackPosition: SnackPosition.BOTTOM,
<<<<<<< HEAD
            backgroundColor: _themeService.getSuccessColor(),
=======
            backgroundColor: AppTheme.successColor,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Info',
<<<<<<< HEAD
            'PDF saved but could not open automatically: ${response.data
                .filename}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _themeService.getWarningColor(),
=======
            'PDF saved but could not open automatically: ${response.data.filename}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.warningColor,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
<<<<<<< HEAD
          backgroundColor: _themeService.getErrorColor(),
=======
          backgroundColor: Colors.red,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download payslip: $e',
        snackPosition: SnackPosition.BOTTOM,
<<<<<<< HEAD
        backgroundColor: _themeService.getErrorColor(),
=======
        backgroundColor: AppTheme.errorColor,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

<<<<<<< HEAD
=======

>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
  // Show year picker
  void showYearPicker() async {
    final years = await getAvailableYears();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
<<<<<<< HEAD
        decoration: BoxDecoration(
          color: _themeService.getSurfaceColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
=======
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
<<<<<<< HEAD
                color: _themeService.getDividerColor(),
=======
                color: Colors.grey[300],
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.4, // Limit height to 40% of screen
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
                    return ListTile(
                      title: Text(year),
                      trailing: selectedYear.value == year
                          ? Icon(
                          Icons.check, color: _themeService.getPrimaryColor())
                          : null,
                      onTap: () {
                        changeYear(year);
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ),
=======
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
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
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
<<<<<<< HEAD
          backgroundColor: _themeService.getErrorColor(),
=======
          backgroundColor: Colors.red,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data: $e',
        snackPosition: SnackPosition.BOTTOM,
<<<<<<< HEAD
        backgroundColor: _themeService.getErrorColor(),
=======
        backgroundColor: AppTheme.errorColor,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Format currency
  Widget formatCurrency(double amount) {
<<<<<<< HEAD
    return SaudiRiyalDisplay(
      amount: amount,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
=======
    return SaudiCurrencySymbol(
      price: amount,
      priceStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      symbolFontSize: 16,
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
    );
  }

  // Get status color
  Color getStatusColor(String status) {
<<<<<<< HEAD
    return _themeService.getStatusColor(status);
  }

}
=======
    return AppTheme.getStatusColor(status);
  }

  // Get filter color
  Color getFilterColor(String filter) {
    return AppTheme.getFilterColor(filter);
  }
}
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
