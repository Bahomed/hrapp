import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
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

  @override
  void onInit() {
    super.onInit();
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
      if (response.success) {
        payrollRecords.value = response.data;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _themeService.getErrorColor(),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payroll records: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _themeService.getErrorColor(),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load payroll summary
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
          backgroundColor: _themeService.getErrorColor(),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payroll summary: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _themeService.getErrorColor(),
        colorText: Colors.white,
      );
    }
  }

  // Change year
  void changeYear(String year) {
    selectedYear.value = year;
    loadPayrollRecordsByYear(year);
    loadPayrollSummary(year);
  }

  // Load payroll records by year
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
          backgroundColor: _themeService.getErrorColor(),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load payroll records for year $year: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _themeService.getErrorColor(),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
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
        decoration: BoxDecoration(
          color: _themeService.getSurfaceColor(),
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
                  color: _themeService.getDividerColor(),
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
                    Text(
                      'Payslip Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _themeService.getTextPrimaryColor(),
                      ),
                    ),
                    Text(
                      record.period,
                      style: TextStyle(
                        fontSize: 16,
                        color: _themeService.getTextSecondaryColor(),
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
                    _buildNetPaySection('Net Pay',record.netSalary,_themeService.getSecondaryColor()),
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
        backgroundColor = _themeService.getStatusBackgroundColor('processed');
        textColor = _themeService.getStatusColor('processed');
        text = 'Processed';
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
        backgroundColor = _themeService.getStatusBackgroundColor('pending');
        textColor = _themeService.getStatusColor('pending');
        text = 'Pending';
        icon = Icons.schedule;
        break;
      case 'failed':
        backgroundColor = _themeService.getStatusBackgroundColor('failed');
        textColor = _themeService.getStatusColor('failed');
        text = 'Failed';
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = _themeService.getStatusBackgroundColor('draft');
        textColor = _themeService.getStatusColor('draft');
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
        ),
      ],
    );
  }


  Widget _buildBenefitsSection(PayrollRecordResponseData record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _buildDeductionsSection(PayrollRecordResponseData record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deductions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
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
      ],
    );
  }

  Widget _buildNetPaySection(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollItem(String description, Widget amount,
      Color amountColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: _themeService.getTextSecondaryColor(),
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
          backgroundColor: _themeService.getSecondaryColor(),
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
      backgroundColor: _themeService.getSecondaryColor(),
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
            backgroundColor: _themeService.getSuccessColor(),
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Info',
            'PDF saved but could not open automatically: ${response.data
                .filename}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: _themeService.getWarningColor(),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _themeService.getErrorColor(),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download payslip: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _themeService.getErrorColor(),
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
        decoration: BoxDecoration(
          color: _themeService.getSurfaceColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: _themeService.getDividerColor(),
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
          backgroundColor: _themeService.getErrorColor(),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _themeService.getErrorColor(),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Format currency
  Widget formatCurrency(double amount) {
    return SaudiRiyalDisplay(
      amount: amount,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );
  }

  // Get status color
  Color getStatusColor(String status) {
    return _themeService.getStatusColor(status);
  }

}