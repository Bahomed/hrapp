import 'package:get/get.dart';
import '../../../repository/employees_repository.dart';

class EmployeeDetailController extends GetxController {
  final EmployeesRepository _repository = EmployeesRepository();

  final isLoadingBalance = false.obs;
  final vacationBalance = 0.0.obs;
  final phPdEnabled = false.obs;
  final phBalance = 0.0.obs;
  final pdBalance = 0.0.obs;
  final balanceError = ''.obs;
  final balanceLoaded = false.obs;

  Future<void> loadLeaveBalance(int empId) async {
    isLoadingBalance.value = true;
    balanceError.value = '';
    try {
      final response = await _repository.getLeaveBalance(empId);
      vacationBalance.value = response.vacationBalance;
      phPdEnabled.value = response.phPdEnabled;
      phBalance.value = response.phBalance;
      pdBalance.value = response.pdBalance;
      balanceLoaded.value = true;
    } catch (e) {
      balanceError.value = e.toString();
    } finally {
      isLoadingBalance.value = false;
    }
  }
}
