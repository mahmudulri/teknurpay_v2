import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:teknurpay/utils/api_endpoints.dart';

import '../global_controller/fcm_device_token_controller.dart';
import '../routes/routes.dart';
import 'dashboard_controller.dart';

final dashboardController = Get.find<DashboardController>();

class SignInController extends GetxController {
  final box = GetStorage();

  final FcmDeviceTokenController fcmDeviceTokenController =
      Get.find<FcmDeviceTokenController>();

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool loginsuccess = false.obs;

  Future<void> signIn() async {
    if (isLoading.value) {
      return;
    }

    try {
      isLoading.value = true;
      loginsuccess.value = false;

      final String username = usernameController.text.trim();
      final String password = passwordController.text;

      if (username.isEmpty || password.isEmpty) {
        Get.snackbar(
          "Login Failed",
          "Please enter username and password.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final url = Uri.parse(
        ApiEndPoints.baseUrl + ApiEndPoints.otherendpoints.loginIink,
      );

      debugPrint("API URL: $url");

      final Map<String, dynamic> body = {
        'username': username,
        'password': password,
      };

      debugPrint("Request Body: $body");

      final http.Response response = await http
          .post(url, body: jsonEncode(body), headers: headers)
          .timeout(const Duration(seconds: 30));

      dynamic decodedResponse;

      try {
        decodedResponse = jsonDecode(response.body);
      } catch (_) {
        decodedResponse = null;
      }

      if (decodedResponse is! Map<String, dynamic>) {
        Get.snackbar(
          "Error",
          "Invalid server response.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Map<String, dynamic> results = decodedResponse;

      debugPrint("Response Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode < 200 || response.statusCode >= 300) {
        _showError(results);
        return;
      }

      if (results["success"] != true) {
        _showError(results);
        return;
      }

      final dynamic rawData = results["data"];

      if (rawData is! Map) {
        Get.snackbar(
          "Login Failed",
          "Login data was not found.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);

      final String apiToken = data["api_token"]?.toString() ?? "";

      if (apiToken.isEmpty) {
        Get.snackbar(
          "Login Failed",
          "API token was not found.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Map<String, dynamic> userInfo = _toStringDynamicMap(
        data["user_info"],
      );

      final Map<String, dynamic> currency = _toStringDynamicMap(
        userInfo["currency"],
      );

      final Map<String, dynamic> reseller = _toStringDynamicMap(
        userInfo["reseller"],
      );

      /*
       * Login data save
       */
      await box.write("userToken", apiToken);

      await box.write("currency_code", currency["code"]?.toString() ?? "");

      await box.write("currency_symbol", currency["symbol"]?.toString() ?? "");

      await box.write("currencyName", currency["name"]?.toString() ?? "");

      await box.write("countryID", reseller["country_id"]);

      await box.write(
        "currencypreferenceID",
        userInfo["currency_preference_id"],
      );

      await box.write("resellerrate", currency["exchange_rate_per_usd"]);

      /*
       * ------------------------------------------------------------
       * FCM DEVICE TOKEN REGISTER
       * ------------------------------------------------------------
       *
       * userToken save হওয়ার পরে current FCM token server-এ পাঠানো হবে।
       *
       * FCM token register fail হলেও login বন্ধ হবে না।
       */
      try {
        final bool fcmTokenSaved = await fcmDeviceTokenController
            .sendCurrentTokenToServer();

        debugPrint("FCM device token saved: $fcmTokenSaved");
      } catch (error, stackTrace) {
        debugPrint("Unable to register FCM token: $error");

        debugPrintStack(stackTrace: stackTrace);
      }

      /*
       * Login completed successfully
       */
      loginsuccess.value = true;

      Fluttertoast.showToast(
        msg: results["message"]?.toString() ?? "Login successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      /*
       * Dashboard data load
       */
      dashboardController.fetchDashboardData();

      /*
       * Go to base screen
       */
      Get.offAllNamed(basescreen);
    } on http.ClientException catch (error) {
      debugPrint("Login network error: $error");

      Get.snackbar(
        "Network Error",
        "Unable to connect to the server.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } on FormatException catch (error) {
      debugPrint("Login response format error: $error");

      Get.snackbar(
        "Error",
        "Invalid server response.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (error, stackTrace) {
      debugPrint("Error during sign in: $error");

      debugPrintStack(stackTrace: stackTrace);

      Get.snackbar(
        "Login Failed",
        "Please check your internet connection and try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _toStringDynamicMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  void _showError(Map<String, dynamic> results) {
    String errorMessage = "Login failed";

    final dynamic errors = results["errors"];

    if (errors is String && errors.trim().isNotEmpty) {
      errorMessage = errors;
    } else if (errors is Map && errors.isNotEmpty) {
      final dynamic firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        errorMessage = firstError.first.toString();
      } else if (firstError != null) {
        errorMessage = firstError.toString();
      }
    } else if (results["message"] != null) {
      errorMessage = results["message"].toString();
    }

    Get.snackbar(
      results["message"]?.toString() ?? "Error",
      errorMessage,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();

    super.onClose();
  }
}
