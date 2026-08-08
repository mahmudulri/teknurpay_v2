import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:teknurpay/utils/api_endpoints.dart';

import 'withdrawlist_controller.dart';

final withdrawlistController = Get.find<WithdrawlistController>();

class CreateWithdrawController extends GetxController {
  final box = GetStorage();

  // =======================
  // Text Controllers
  // =======================
  TextEditingController amountController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  // Bank details
  TextEditingController bankDetailNameController = TextEditingController();
  TextEditingController bankHolderNameController = TextEditingController();
  TextEditingController bankAccountNumberController = TextEditingController();
  TextEditingController ibanController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController swiftCodeController = TextEditingController();

  // =======================
  // Reactive Variables
  // =======================
  RxBool isLoading = false.obs;

  // =======================
  // API Call
  // =======================
  Future<bool> createBankWithdraw() async {
    try {
      isLoading.value = true;

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${box.read("userToken")}',
      };

      final url = Uri.parse(
        ApiEndPoints.baseUrl + ApiEndPoints.otherendpoints.withdrawrequests,
      );

      final Map<String, dynamic> body = {
        "amount": double.tryParse(amountController.text) ?? 0,
        "account_name": accountNameController.text,
        "account_number": accountNumberController.text,
        "bank_name": bankNameController.text,
        "notes": notesController.text,
        "bank_details": {
          "bank_name": bankDetailNameController.text,
          "account_holder_name": bankHolderNameController.text,
          "account_number": bankAccountNumberController.text,
          "iban": ibanController.text,
          "branch": branchController.text,
          "swift_code": swiftCodeController.text,
        },
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      print(url);
      print(response.body.toString());

      final result = jsonDecode(response.body);
      print(response.statusCode.toString());

      if (response.statusCode == 201 && result["success"] == true) {
        _clearFields();

        Fluttertoast.showToast(
          msg: result["message"] ?? "Withdrawal created successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        return true;
      } else {
        Get.snackbar(
          "Error",
          result["message"] ?? "Something went wrong",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint("CreateBankWithdraw Error: $e");
      Get.snackbar(
        "Error",
        "Unexpected error occurred",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // =======================
  // Clear Form
  // =======================
  void _clearFields() {
    amountController.clear();
    accountNameController.clear();
    accountNumberController.clear();
    bankNameController.clear();
    notesController.clear();

    bankDetailNameController.clear();
    bankHolderNameController.clear();
    bankAccountNumberController.clear();
    ibanController.clear();
    branchController.clear();
    swiftCodeController.clear();
  }

  @override
  void onClose() {
    amountController.dispose();
    accountNameController.dispose();
    accountNumberController.dispose();
    bankNameController.dispose();
    notesController.dispose();
    bankDetailNameController.dispose();
    bankHolderNameController.dispose();
    bankAccountNumberController.dispose();
    ibanController.dispose();
    branchController.dispose();
    swiftCodeController.dispose();
    super.onClose();
  }
}
