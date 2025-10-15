import 'package:get/get.dart';
import 'package:com.injazatsoftware.injazathr/repository/benefit_deduction_repository.dart';
import 'package:com.injazatsoftware.injazathr/data/remote/response/benefits_response.dart';

class BenefitDetailController extends GetxController {
  final BenefitDeductionRepository _repository = BenefitDeductionRepository();

  // Observable variables
  final isLoading = false.obs;
  final benefitsResponse = Rx<BenefitsResponse?>(null);

  // Computed values
  List<Earning> get earnings =>
      benefitsResponse.value?.data?.earnings ?? [];

  String get totalEarning =>
      benefitsResponse.value?.data?.totals.totalEarning.toString() ?? '0.00';

  // Total salary is same as total earning in the API response
  String get totalSalary =>
      benefitsResponse.value?.data?.totals.totalEarning.toString() ?? '0.00';

  @override
  void onInit() {
    super.onInit();
    fetchBenefits();
  }

  Future<void> fetchBenefits() async {
    try {
      isLoading.value = true;

      final response = await _repository.getBenefits();

      if (!response.error) {
        benefitsResponse.value = response;
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

  Future<void> refreshBenefits() async {
    await fetchBenefits();
  }
}