import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/utils/api_endpoints.dart';

import 'custom_history_controller.dart';

enum RechargeState { idle, loading, success, error }

final customhistoryController = Get.find<CustomHistoryController>();

class CustomRechargeController extends GetxController {
  /// TEXT CONTROLLERS
  final TextEditingController numberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  /// CONTROLLERS & STORAGE
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );
  final GetStorage box = GetStorage();

  /// STATE
  final Rx<RechargeState> rechargeState = RechargeState.idle.obs;
  final RxString errorMessage = ''.obs;

  /// ================= PLACE ORDER =================
  Future<void> placeOrder() async {
    if (rechargeState.value == RechargeState.loading) return;

    rechargeState.value = RechargeState.loading;
    errorMessage.value = '';

    try {
      final Uri url = Uri.parse("${ApiEndPoints.baseUrl}custom-recharge");

      final body = {
        'rechargeble_account': numberController.text.trim(),
        'amount': amountController.text.trim(),
        'pin': pinController.text.trim(),
      };

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${box.read("userToken")}',
        },
      );

      final result = jsonDecode(response.body);

      if (response.statusCode == 201 && result["success"] == true) {
        rechargeState.value = RechargeState.success;
        customhistoryController.finalList.clear();
        customhistoryController.initialpage = 1;
        customhistoryController.fetchHistory();
        clearAll();
        box.remove("bundleID");
      } else {
        errorMessage.value = result["message"] ?? "Something went wrong";
        rechargeState.value = RechargeState.error;
        pinController.clear();
      }
    } catch (e) {
      errorMessage.value = "Network error, please try again";
      rechargeState.value = RechargeState.error;
      pinController.clear();
    }
  }

  /// ================= HELPERS =================
  void resetState() {
    rechargeState.value = RechargeState.idle;
    errorMessage.value = '';
  }

  void clearAll() {
    pinController.clear();
    numberController.clear();
    amountController.clear();
  }

  @override
  void onClose() {
    numberController.dispose();
    amountController.dispose();
    pinController.dispose();
    super.onClose();
  }
}
