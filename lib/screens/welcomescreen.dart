import 'dart:ffi';
import 'dart:io';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:teknurpay/widgets/button_one.dart';
import 'package:teknurpay/widgets/custom_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/dashboard_controller.dart';
import 'package:teknurpay/controllers/sign_in_controller.dart';
import 'package:teknurpay/global_controller/page_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/routes/routes.dart';

import 'package:teknurpay/screens/sign_up_screen.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/authtextfield.dart';
import 'package:teknurpay/widgets/social_button.dart';

import '../widgets/button.dart';

class Welcomescreen extends StatefulWidget {
  Welcomescreen({super.key});

  @override
  State<Welcomescreen> createState() => _WelcomescreenState();
}

class _WelcomescreenState extends State<Welcomescreen> {
  LanguagesController languagesController = Get.put(LanguagesController());

  // final signInController = Get.find<SignInController>();

  // final dashboardController = Get.find<DashboardController>();

  final box = GetStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );
  }

  final Mypagecontroller mypagecontroller = Get.put(Mypagecontroller());
  Future<bool> showExitPopup() async {
    final shouldExit = mypagecontroller.goBack();
    if (shouldExit) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(languagesController.tr("EXIT_APP")),
              content: Text(languagesController.tr("DO_YOU_WANT_TO_EXIT_APP")),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(languagesController.tr("NO")),
                ),
                ElevatedButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text(languagesController.tr("YES")),
                ),
              ],
            ),
          ) ??
          false;
    }
    setState(() {}); // Rebuild screen after popping
    return false;
  }

  String longtext =
      "Send money, buy mobile credit and internet packages, pay bills, and manage all your transactions — all in one place.  Fast, secure, and always at your fingertips!";

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            height: screenHeight,
            width: screenWidth,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/signback.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  Image.asset("assets/icons/logo.png", height: 100),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      // color: Colors.blue,
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: -130, // overlap depth
                              child: Container(
                                width: screenWidth - 40,
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Color(0xffD3EAFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "All Your Financial Services in One App",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        longtext,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 80,
                              child: Image.asset(
                                "assets/images/signinitem1.png",
                                height: 300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 150),
                  Container(
                    height: 50,
                    width: screenWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: DefaultButton1(
                            buttonName: "Register",
                            height: 50,
                            onpressed: () {
                              whatsapp();
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: BlankButton(
                            buttonName: "Log in",
                            height: 50,
                            onpressed: () {
                              Get.toNamed(signinscreen);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class languageBox extends StatelessWidget {
  const languageBox({super.key, this.lanName, this.onpressed});
  final String? lanName;
  final VoidCallback? onpressed;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: GestureDetector(
        onTap: onpressed,
        child: Container(
          margin: EdgeInsets.only(bottom: 6),
          height: 40,
          width: screenWidth,
          decoration: BoxDecoration(
            color: Colors.lightBlue,
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              lanName.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SinInbutton extends StatelessWidget {
  final double width;
  final double height;
  final String? buttonName;
  final VoidCallback? onpressed;

  SinInbutton({
    required this.width,
    required this.height,
    this.buttonName,
    this.onpressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Color(0xffFF6A60),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                  ),
                ),
                child: Center(
                  child: KText(
                    text: buttonName.toString(),
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
