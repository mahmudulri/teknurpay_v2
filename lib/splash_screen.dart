import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:teknurpay/controllers/dashboard_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';

import 'routes/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  final GetStorage box = GetStorage();

  final LanguagesController languagesController =
      Get.isRegistered<LanguagesController>()
      ? Get.find<LanguagesController>()
      : Get.put(LanguagesController());

  Future<void> checkData() async {
    try {
      // Restore previously selected language.
      final savedLanguage = await languagesController.restoreSavedLanguage();

      final String languageShortName = savedLanguage["name"] ?? "En";

      final String isoCode = savedLanguage["isoCode"] ?? "en";

      final String region = savedLanguage["region"] ?? "US";

      final String direction = savedLanguage["direction"] ?? "ltr";

      debugPrint("🌐 Restored Language: $languageShortName");

      debugPrint("🌐 Locale: $isoCode-$region");

      debugPrint("🌐 Direction: $direction");

      if (!mounted) return;

      // Synchronize EasyLocalization.
      final Locale locale = Locale(isoCode, region);

      await context.setLocale(locale);

      if (!mounted) return;

      // Check authentication.
      final userToken = box.read("userToken");

      if (userToken == null || userToken.toString().trim().isEmpty) {
        Get.offAllNamed(welcomescreen);
      } else {
        dashboardController.fetchDashboardData();

        Get.offAllNamed(basescreen);
      }
    } catch (e) {
      debugPrint("❌ Splash Screen Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      await checkData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset("assets/icons/logo.png", height: 130)),
    );
  }
}
