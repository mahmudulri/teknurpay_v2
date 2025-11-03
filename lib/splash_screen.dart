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
  final dashboardController = Get.find<DashboardController>();
  final box = GetStorage();
  LanguagesController languagesController = Get.put(LanguagesController());

  checkData() async {
    // Default language is now English
    String languageShortName = box.read("language") ?? "En";

    // Find selected language details from the list
    final matchedLang = languagesController.alllanguagedata.firstWhere(
      (lang) => lang["name"] == languageShortName,
      orElse: () => {"isoCode": "en", "direction": "ltr"},
    );

    final isoCode = matchedLang["isoCode"] ?? "en";
    final direction = matchedLang["direction"] ?? "ltr";

    box.write("language", languageShortName);
    box.write("direction", direction);

    languagesController.changeLanguage(languageShortName);

    Locale locale;
    switch (isoCode) {
      case "fa":
        locale = Locale("fa", "IR");
        break;
      case "en":
        locale = Locale("en", "US");
        break;
      case "ar":
        locale = Locale("ar", "AE");
        break;
      case "ps":
        locale = Locale("ps", "AF");
        break;
      case "tr":
        locale = Locale("tr", "TR");
        break;
      case "bn":
        locale = Locale("bn", "BD");
        break;
      default:
        locale = Locale("en", "US");
    }

    setState(() {
      EasyLocalization.of(context)!.setLocale(locale);
    });

    // If no token, go to onboarding
    if (box.read('userToken') == null) {
      Get.toNamed(welcomescreen);
    } else {
      // Fetch initial data
      dashboardController.fetchDashboardData();
      Get.toNamed(basescreen);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () => checkData());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset("assets/icons/logo.png", height: 130)),
    );
  }
}
