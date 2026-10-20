import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/utils/api_endpoints.dart';

class ConfirmPinController extends GetxController {
  TextEditingController numberController = TextEditingController();
  TextEditingController pinController = TextEditingController();

  LanguagesController languagesController = Get.put(LanguagesController());

  final box = GetStorage();

  RxBool isLoading = false.obs;
  RxBool loadsuccess = false.obs;

  // IMO account type: ID / NUMBER / empty
  RxString rechargebleAccountType = ''.obs;

  Future<void> placeOrder(BuildContext context) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      loadsuccess.value = false;

      final url = Uri.parse("${ApiEndPoints.baseUrl}place_order");

      final String selectedAccountType = rechargebleAccountType.value;

      // Build request body
      Map<String, dynamic> body = {
        'bundle_id': box.read("bundleID"),
        'rechargeble_account': numberController.text.trim(),
        'pin': pinController.text,

        // Only include account type when ID or NUMBER is selected
        if (selectedAccountType == 'ID' || selectedAccountType == 'NUMBER')
          'rechargeble_account_type': selectedAccountType,
      };

      final http.Response response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${box.read("userToken")}',
        },
      );

      debugPrint("Place Order URL: $url");
      debugPrint("Place Order Status: ${response.statusCode}");

      final orderResults = jsonDecode(response.body);

      if (response.statusCode == 201 && orderResults["success"] == true) {
        // Recharge successful
        loadsuccess.value = true;

        pinController.clear();
        numberController.clear();

        box.remove("bundleID");

        // Reset account type after successful recharge
        rechargebleAccountType.value = '';

        isLoading.value = false;

        if (context.mounted) {
          showSuccessDialog(context);
        }
      } else {
        // Recharge failed
        loadsuccess.value = false;

        pinController.clear();

        isLoading.value = false;

        // Keep selected account type for retry
        if (context.mounted) {
          showErrorDialog(
            context,
            orderResults["message"]?.toString() ?? "Something went wrong",
          );
        }
      }
    } catch (e) {
      loadsuccess.value = false;

      pinController.clear();

      isLoading.value = false;

      if (context.mounted) {
        showErrorDialog(context, e.toString());
      }
    }
  }

  void showSuccessDialog(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    pinController.clear();
    numberController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: 350,
            width: screenWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(languagesController.tr("SUCCESS")),
                SizedBox(height: 15),
                Text(
                  languagesController.tr("RECHARGE_SUCCESSFULL"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    languagesController.tr("CLOSE"),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    var screenWidth = MediaQuery.of(context).size.width;

    pinController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: 350,
            width: screenWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Failed"),
                SizedBox(height: 15),
                Text(
                  "Recharge Failed!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
