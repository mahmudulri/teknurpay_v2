import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../global_controller/languages_controller.dart';
import '../utils/api_endpoints.dart';
import 'office_transactions_controller.dart';

class CreateTransactionController extends GetxController {
  TextEditingController accountidController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController typeController = TextEditingController();

  OfficeTransactionsListController transactionsListController = Get.put(
    OfficeTransactionsListController(),
  );

  final languagesController = Get.find<LanguagesController>();

  RxBool isLoading = false.obs;
  final box = GetStorage();

  Future<void> createnow() async {
    // Validation

    double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Fluttertoast.showToast(
        msg: languagesController.tr("SELECT_AMOUNT"),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${box.read("userToken")}',
      };
      var url = Uri.parse("${ApiEndPoints.baseUrl}accounting-transactions");

      Map<String, dynamic> body = {
        'counterparty_account_id': accountidController.text,
        'type': typeController.text,
        'amount': amount,
        'description': descriptionController.text,
      };

      http.Response response = await http.post(
        url,
        body: jsonEncode(body),
        headers: headers,
      );

      final results = jsonDecode(response.body);
      print(results.toString());

      if (response.statusCode == 201 && results["success"] == true) {
        // refresh transactions list
        transactionsListController.finalList.clear();
        transactionsListController.initialpage = 1;
        transactionsListController.fetchtransactions(
          int.parse(box.read("officeID")),
        );
        accountidController.clear();
        amountController.clear();
        descriptionController.clear();
        typeController.clear();

        Fluttertoast.showToast(
          msg: results["message"],
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Clear inputs
      } else {
        Fluttertoast.showToast(
          msg: results["message"] ?? "Something went wrong",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
