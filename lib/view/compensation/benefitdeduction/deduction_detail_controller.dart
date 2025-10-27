import 'package:get/get.dart';
import 'package:co.injazathr.injazathr/repository/benefit_deduction_repository.dart';
import 'package:co.injazathr.injazathr/data/remote/response/deductions_response.dart';

class DeductionDetailController extends GetxController {
  final BenefitDeductionRepository _repository = BenefitDeductionRepository();

  // Observable variables
  final isLoading = false.obs;
  final deductionsResponse = Rx<DeductionsResponse?>(null);

  // Computed values
  List<UserDeduction> get userDeductions =>
      deductionsResponse.value?.data?.userDeduction ?? [];

  String get totalDeductionAmount =>
      deductionsResponse.value?.data?.totalDeductionAmount.toString() ?? '0.00';

  String get totalDeductionAmountTobePaid =>
      deductionsResponse.value?.data?.totalDeductionAmountTobePaid.toString() ?? '0.00';

  String get totalDeductionAmountPaid =>
      deductionsResponse.value?.data?.totalDeductionAmountPaid.toString() ?? '0.00';

  @override
  void onInit() {
    super.onInit();
    fetchDeductions();
  }

  Future<void> fetchDeductions() async {
    try {
      isLoading.value = true;

      final response = await _repository.getDeductions();

      if (!response.error) {
        deductionsResponse.value = response;
      } else {
        Get.snackbar(
          'Error',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDeductions() async {
    await fetchDeductions();
  }
}