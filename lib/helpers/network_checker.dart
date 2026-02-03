import 'package:get/get.dart';
import 'package:teknurpay/global_controller/check_internet_controller.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
