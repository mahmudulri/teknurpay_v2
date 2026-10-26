import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../global_controller/page_controller.dart';
import '../utils/api_endpoints.dart';
import 'payments_controller.dart';

class AddPaymentController extends GetxController {
  var photoLink = ''.obs;
  RxString selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;
  var payment_method_id = ''.obs;
  var payment_type_id = ''.obs; // ✅ Optional
  var currencyID = ''.obs;
  var paymentDate = ''.obs;

  TextEditingController amountController = TextEditingController();
  TextEditingController trackingCodeController = TextEditingController();
  TextEditingController noteController = TextEditingController();

  final box = GetStorage();

  var paymentImagePath = ''.obs;
  var extraImage1Path = ''.obs;
  var extraImage2Path = ''.obs;

  File? paymentImageFile;
  File? extraImage1File;
  File? extraImage2File;

  RxBool isLoading = false.obs;

  Future<void> pickImage(String type) async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImageFile != null) {
      final file = File(pickedImageFile.path);
      if (type == 'payment') {
        paymentImagePath.value = pickedImageFile.path;
        paymentImageFile = file;
      } else if (type == 'extra1') {
        extraImage1Path.value = pickedImageFile.path;
        extraImage1File = file;
      } else if (type == 'extra2') {
        extraImage2Path.value = pickedImageFile.path;
        extraImage2File = file;
      }
    } else {
      print("No image selected for $type");
    }
  }

  Future<void> addNow() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      paymentDate.value = selectedDate.value;

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${box.read("userToken")}',
      };

      Map<String, String> body = {
        'payment_method_id': payment_method_id.value,
        'amount': amountController.text,
        'currency_id': currencyID.value,
        'payment_date': toEnglishDigits(paymentDate.value),
        'tracking_code': trackingCodeController.text,
        'notes': noteController.text,
      };

      // Optional payment type
      if (payment_type_id.value.isNotEmpty) {
        body['payment_type_id'] = payment_type_id.value;
      }

      var url = Uri.parse("${ApiEndPoints.baseUrl}reseller-payments");

      var request = http.MultipartRequest('POST', url);

      request.headers.addAll(headers);
      request.fields.addAll(body);

      // Payment Image
      if (paymentImagePath.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'payment_image',
            paymentImagePath.value,
            filename: "payment_image.jpg",
          ),
        );
      }

      // Extra Image 1
      if (extraImage1Path.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'extra_image_1',
            extraImage1Path.value,
            filename: "extra_image_1.jpg",
          ),
        );
      }

      // Extra Image 2
      if (extraImage2Path.value.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'extra_image_2',
            extraImage2Path.value,
            filename: "extra_image_2.jpg",
          ),
        );
      }

      var responseStream = await request.send();

      var responseBody = await http.Response.fromStream(responseStream);

      print("Status: ${responseStream.statusCode}");
      print("Response: ${responseBody.body}");

      if (responseStream.statusCode == 201) {
        // Clear text fields
        amountController.clear();
        trackingCodeController.clear();
        noteController.clear();

        // Clear selected values
        currencyID.value = '';
        payment_method_id.value = '';
        payment_type_id.value = '';

        // Clear images
        paymentImagePath.value = '';
        extraImage1Path.value = '';
        extraImage2Path.value = '';

        paymentImageFile = null;
        extraImage1File = null;
        extraImage2File = null;

        // Show success message
        Fluttertoast.showToast(
          msg: "Successfully Created",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Refresh payments list before navigating back
        final paymentsController = Get.find<PaymentsController>();
        paymentsController.fetchpayments();

        // Navigate back using existing page controller
        final mypagecontroller = Get.find<Mypagecontroller>();
        mypagecontroller.goBack();
      } else {
        Get.snackbar(
          "Wrong",
          "Something error",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Exception: ${e.toString()}");

      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

String toEnglishDigits(String input) {
  const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  for (int i = 0; i < 10; i++) {
    input = input.replaceAll(persianDigits[i], englishDigits[i]);
  }
  return input;
}
