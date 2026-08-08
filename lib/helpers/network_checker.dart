import 'package:get/get.dart';
import 'package:teknurpay/global_controller/check_internet_controller.dart';
import 'package:teknurpay/global_controller/fcm_device_token_controller.dart';

class DependencyInjection {
  static void init() {
    Get.put<FcmDeviceTokenController>(
      FcmDeviceTokenController(),
      permanent: true,
    );

    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
