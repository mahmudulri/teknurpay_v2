import 'package:get/get.dart';

import '../models/payment_method_model.dart';
import '../services/payment_method_service.dart';

class PaymentMethodController extends GetxController {
  var isLoading = false.obs;

  var allmethods = PaymentMethodModel().obs;

  Future<void> fetchmethods() async {
    try {
      isLoading.value = true;

      final value = await PaymentMethodSApi().fetchmethod();

      allmethods.value = value;
    } catch (e) {
      print("Payment method fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
