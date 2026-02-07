import 'package:get/get.dart';
import 'package:teknurpay/services/dashboard_service.dart';

import '../global_controller/balance_controller.dart';
import '../models/dashboard_data_model.dart';

class DashboardController extends GetxController {
  @override
  void onInit() {
    fetchDashboardData();
    super.onInit();
  }

  var isLoading = false.obs;
  final deactiveStatus = ''.obs;
  final deactivateMessage = ''.obs;

  var alldashboardData = DashboardDataModel().obs;

  UserBalanceController userBalanceController = Get.put(
    UserBalanceController(),
  );
  void setDeactivated(String status, String message) {
    deactiveStatus.value = status;
    deactivateMessage.value = message;
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      await DashboardApi().fetchDashboard().then((value) {
        alldashboardData.value = value;
        userBalanceController.balance.value = alldashboardData
            .value
            .data!
            .balance
            .toString();
      });
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
