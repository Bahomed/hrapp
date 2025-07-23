// File: lib/view/request_leave/create_request/edit_loan_request_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injazat_hr_app/data/remote/response/base_response.dart';
import 'package:injazat_hr_app/data/remote/response/loan_request_response.dart';
import 'package:injazat_hr_app/utils/translation_helper.dart';
import '../../../services/theme_service.dart';

import '../request_controller.dart';

class EditLoanRequestScreen extends StatelessWidget {
  final LoanRequest request;

  const EditLoanRequestScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RequestController>();
    final themeService = ThemeService.instance;
    final formKey = GlobalKey<FormState>();

    final purposeController = TextEditingController(text: request.purpose);
    final amountController = TextEditingController(text: request.amount.toString());
    final repaymentMonthsController = TextEditingController(text: request.repaymentMonths.toString());
    final selectedLoanType = Rx<RequestTypeOption?>(null);

    // Find and set the current loan type from the dropdown options
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentType = controller.loanTypes.cast<RequestTypeOption?>().firstWhere(
            (type) => type?.name == request.loanType,
        orElse: () => null,
      );
      selectedLoanType.value = currentType;
    });

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getCardColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeService.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
        title: Text(
          tr('edit_loan_request'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: themeService.getSuccessColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: themeService.getSuccessColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.edit_document, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr('edit_loan_request'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: themeService.getSuccessColor(),
                            ),
                          ),
                          Text(
                            tr('edit_loan_request_description'),
                            style: TextStyle(
                              fontSize: 14,
                              color: themeService.getTextSecondaryColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Request ID Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeService.getCardColor(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: themeService.getTextSecondaryColor(), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${tr('request_id')}: ${request.id}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: themeService.getTextPrimaryColor(),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status, themeService),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Loan Type Dropdown with API data
              _buildApiDropdownField(
                label: tr('loan_type'),
                selectedValue: selectedLoanType,
                options: controller.loanTypes,
                isLoading: controller.isLoadingTypes,
                validator: (value) {
                  if (value == null) {
                    return tr('please_select_loan_type');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Amount Field
              _buildTextField(
                label: tr('amount_dollars'),
                controller: amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('please_enter_loan_amount');
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return tr('please_enter_valid_amount');
                  }
                  if (amount > 100000) {
                    return tr('amount_cannot_exceed_limit');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Repayment Months Number Input
              _buildTextField(
                label: tr('repayment_period_months'),
                controller: repaymentMonthsController,
                keyboardType: TextInputType.number,
                hintText: tr('enter_repayment_months_hint'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('please_enter_repayment_period');
                  }
                  final months = int.tryParse(value);
                  if (months == null) {
                    return tr('please_enter_valid_number');
                  }
                  if (months < 1) {
                    return tr('repayment_period_minimum');
                  }
<<<<<<< HEAD
                  if (months > 24) {
=======
                  if (months > 120) {
>>>>>>> 9b93ad055ddc8208dd97b5fb9b2690abb6194604
                    return tr('repayment_period_maximum');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Purpose Field
              _buildTextAreaField(
                label: tr('purpose'),
                controller: purposeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('please_provide_purpose');
                  }
                  if (value.length < 10) {
                    return tr('purpose_minimum_characters');
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Update Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                    if (formKey.currentState!.validate() && selectedLoanType.value != null) {
                      final success = await controller.updateLoanRequestWithData(
                        id: request.id,
                        loanTypeId: selectedLoanType.value!.id,
                        purpose: purposeController.text,
                        amount: double.parse(amountController.text),
                        repaymentMonths: int.parse(repaymentMonthsController.text),
                      );

                      // Only navigate if request was successful
                      if (success) {
                        // Small delay to show success message then navigate back
                        await Future.delayed(const Duration(milliseconds: 1500));

                        // Try multiple navigation methods
                        if (context.mounted) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            // Fallback: Use Get navigation
                            Get.back();
                          }
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeService.getSuccessColor(),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: controller.isLoading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    tr('update_loan_request'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeService themeService) {
    switch (status.toLowerCase()) {
      case 'approved':
        return themeService.getSuccessColor();
      case 'rejected':
        return themeService.getErrorColor();
      case 'for-approval':
      case 'pending':
        return themeService.getWarningColor();
      default:
        return themeService.getTextSecondaryColor();
    }
  }
}

// Helper widget for API-driven dropdowns
Widget _buildApiDropdownField({
  required String label,
  required Rx<RequestTypeOption?> selectedValue,
  required RxList<RequestTypeOption> options,
  required RxBool isLoading,
  String? Function(RequestTypeOption?)? validator,
}) {
  final themeService = ThemeService.instance;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      const SizedBox(height: 8),
      Obx(() => DropdownButtonFormField<RequestTypeOption>(
        value: selectedValue.value,
        validator: validator,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        dropdownColor: themeService.getCardColor(),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getSuccessColor()),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getErrorColor()),
          ),
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: isLoading.value
              ? SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(themeService.getSuccessColor()),
              ),
            ),
          )
              : null,
        ),
        hint: Text(
          trParams('select_field', {'field': label}),
          style: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
        items: options.map((RequestTypeOption option) {
          return DropdownMenuItem<RequestTypeOption>(
            value: option,
            child: Text(
              option.name,
              style: TextStyle(color: themeService.getTextPrimaryColor()),
            ),
          );
        }).toList(),
        onChanged: isLoading.value
            ? null
            : (RequestTypeOption? value) {
          selectedValue.value = value;
        },
      )),
    ],
  );
}

Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
  String? hintText,
}) {
  final themeService = ThemeService.instance;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          hintText: hintText,
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getSuccessColor()),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getErrorColor()),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    ],
  );
}

Widget _buildTextAreaField({
  required String label,
  required TextEditingController controller,
  String? Function(String?)? validator,
}) {
  final themeService = ThemeService.instance;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        validator: validator,
        maxLines: 4,
        style: TextStyle(color: themeService.getTextPrimaryColor()),
        decoration: InputDecoration(
          filled: true,
          fillColor: themeService.getCardColor(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getTextSecondaryColor().withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getSuccessColor()),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeService.getErrorColor()),
          ),
          contentPadding: const EdgeInsets.all(16),
          hintStyle: TextStyle(color: themeService.getTextSecondaryColor()),
        ),
      ),
    ],
  );
}