import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../global_controller/languages_controller.dart';
import '../utils/api_endpoints.dart';
import 'counter_party_controller.dart';

class CreateCounterPartyController extends GetxController {
  final box = GetStorage();

  final languageController = Get.find<LanguagesController>();

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController currencyController = TextEditingController();
  TextEditingController balanceController = TextEditingController();

  RxBool createDefaultAccount = true.obs;

  RxString selectedType = "supplier".obs;
  RxString selectedAccountType = "saving".obs;

  CounterPartyController counterPartyListController = Get.put(
    CounterPartyController(),
  );

  // String? currencyFullName(List<Datum> allCurrencies) {
  //   final c = allCurrencies.firstWhereOrNull(
  //     (e) => e.code == selectedCurrency.value,
  //   );
  //   return c != null ? "${c.name} (${c.code})" : null;
  // }

  Map<String, dynamic> getCounterPartyData() {
    return {
      "name": nameController.text,
      "type": selectedType.value.toLowerCase(),
      "phone": phoneController.text,
      "email": emailController.text,
      "default_currency_code": currencyController.text,
      "create_default_account": createDefaultAccount.value,
      "currency_code": currencyController.text,
      "account_type": selectedAccountType.value,
      "opening_balance": balanceController.text.isEmpty
          ? 0
          : int.tryParse(balanceController.text) ?? 0,
    };
  }

  RxBool isLoading = false.obs;

  Future<void> createNow() async {
    try {
      isLoading.value = true;

      var url = Uri.parse(ApiEndPoints.baseUrl + "counterparties");

      Map<String, dynamic> body = getCounterPartyData();
      print("Request Body: $body");
      print("API URL: $url");

      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${box.read("userToken")}",
        },
      );

      print("Response: ${response.body}");

      final result = jsonDecode(response.body);

      if (response.statusCode == 201) {
        counterPartyListController.initialpage = 1;
        counterPartyListController.finalList.clear();
        counterPartyListController.fetchtransactions();

        nameController.clear();
        phoneController.clear();
        emailController.clear();
        balanceController.clear();
        currencyController.clear();
        selectedType.value = "supplier";
        selectedAccountType.value = "saving";
        createDefaultAccount.value = true;

        Fluttertoast.showToast(
          msg: result["message"] ?? "Created Successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          result["message"] ?? "Something went wrong",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error Creating CounterParty: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
