import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/authtextfield.dart';
import 'package:teknurpay/widgets/custom_text.dart';
import 'package:teknurpay/widgets/social_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/sign_in_controller.dart';
import '../global_controller/languages_controller.dart';
import '../routes/routes.dart';
import '../widgets/bottomsheet.dart';
import '../widgets/button.dart';
import '../widgets/socialbuttonbox.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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

  final box = GetStorage();
  LanguagesController languagesController = Get.put(LanguagesController());

  final signInController = Get.find<SignInController>();
  final dashboardController = Get.find<DashboardController>();

  final String phoneNumber = "+93708488200";

  // Future<bool> showExitPopup() async {
  //   return await showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(languagesController.tr("EXIT_APP")),
  //       content: Text(languagesController.tr("DO_YOU_WANT_TO_EXIT_APP")),
  //       actions: [
  //         ElevatedButton(
  //           onPressed: () => Navigator.of(context).pop(false),
  //           child: Text(languagesController.tr("NO")),
  //         ),
  //         ElevatedButton(
  //           onPressed: () => exit(0),
  //           child: Text(languagesController.tr("YES")),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<bool> showExitPopup() async {
    // Just minimize the app
    if (Platform.isAndroid) {
      // This will move the app to background
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return false; // prevent default back behavior
    }
    return true; // for iOS, let default behavior happen
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: showExitPopup,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Container(
            height: screenHeight,
            width: screenWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: ListView(
                children: [
                  SizedBox(height: 40),
                  Image.asset("assets/icons/logo.png", height: 80),
                  SizedBox(height: 30),
                  Container(
                    height: 50,
                    width: screenWidth,
                    // color: Colors.green,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KText(
                              text: languagesController.tr("LOGIN"),
                              fontWeight: FontWeight.bold,
                            ),
                            KText(
                              text: languagesController.tr(
                                "PLEASE_ENTER_YOUR_INFORMATION",
                              ),
                              color: AppColors.fontColor,
                            ),
                          ],
                        ),

                        // Container(
                        //   width: 80,
                        //   height: 50,
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(10),
                        //     border: Border.all(
                        //       width: 1,
                        //       color: AppColors.fontColor,
                        //     ),
                        //   ),
                        //   child: ClipRRect(
                        //     borderRadius: BorderRadius.circular(10),
                        //     child: Stack(
                        //       children: [
                        //         // Inner shadow layer
                        //         Positioned.fill(
                        //           child: Container(
                        //             decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(10),
                        //               boxShadow: [
                        //                 BoxShadow(
                        //                   // color: Colors.green.withOpacity(0.6),
                        //                   color: AppColors.primaryColor
                        //                       .withOpacity(0.1),
                        //                   blurRadius: 8,
                        //                   offset: Offset(2, 2),
                        //                   spreadRadius: 1,
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //         // Button content
                        //         Center(
                        //           child: Text(
                        //             "Button",
                        //             style: TextStyle(color: Colors.black),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // )
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    languagesController.tr("LANGUAGES"),
                                  ),
                                  content: SizedBox(
                                    height: 350,
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: languagesController
                                          .alllanguagedata
                                          .length,
                                      itemBuilder: (context, index) {
                                        final data = languagesController
                                            .alllanguagedata[index];

                                        return GestureDetector(
                                          onTap: () {
                                            final languageName = data["name"]
                                                .toString();

                                            final matched = languagesController
                                                .alllanguagedata
                                                .firstWhere(
                                                  (lang) =>
                                                      lang["name"] ==
                                                      languageName,
                                                  orElse: () => {
                                                    "isoCode": "en",
                                                    "direction": "ltr",
                                                  },
                                                );

                                            final languageISO =
                                                matched["isoCode"]!;
                                            final languageDirection =
                                                matched["direction"]!;

                                            // Save & apply
                                            languagesController.changeLanguage(
                                              languageName,
                                            );
                                            box.write("language", languageName);
                                            box.write(
                                              "direction",
                                              languageDirection,
                                            );

                                            // Map iso → Locale
                                            Locale locale;
                                            switch (languageISO) {
                                              case "fa":
                                                locale = const Locale(
                                                  "fa",
                                                  "IR",
                                                );
                                                break;
                                              case "ar":
                                                locale = const Locale(
                                                  "ar",
                                                  "AE",
                                                );
                                                break;
                                              case "ps":
                                                locale = const Locale(
                                                  "ps",
                                                  "AF",
                                                );
                                                break;
                                              case "tr":
                                                locale = const Locale(
                                                  "tr",
                                                  "TR",
                                                );
                                                break;
                                              case "bn":
                                                locale = const Locale(
                                                  "bn",
                                                  "BD",
                                                );
                                                break;
                                              case "en":
                                              default:
                                                locale = const Locale(
                                                  "en",
                                                  "US",
                                                );
                                            }

                                            setState(() {
                                              EasyLocalization.of(
                                                context,
                                              )!.setLocale(locale);
                                            });

                                            Navigator.pop(context);
                                            debugPrint(
                                              "🌐 Language: $languageName ($languageISO), dir: $languageDirection",
                                            );
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 5,
                                            ),
                                            height: 45,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.grey.shade300,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data["fullname"].toString(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 45,
                            width: 80,
                            child: InnerShadow(
                              shadows: [
                                Shadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.4,
                                  ), // your green shadow
                                  blurRadius: 4,
                                  offset: Offset
                                      .zero, // ✅ no offset, shadow appears on all sides
                                ),
                              ],
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Obx(
                                      () => KText(
                                        text: languagesController
                                            .selectedlan
                                            .value,
                                        color: Color(0xff233F78),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Icon(
                                      Icons.language,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Authtextfield(
                    hinttext: languagesController.tr("USERNAME"),
                    controller: signInController.usernameController,
                  ),
                  SizedBox(height: 10),
                  Authtextfield(
                    hinttext: languagesController.tr("PASSWORD"),
                    controller: signInController.passwordController,
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      KText(
                        text: languagesController.tr("FORGOT_YOUR_PASSWORD"),
                        color: AppColors.fontColor,
                        fontSize: 14,
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          whatsapp();
                        },
                        child: KText(
                          text: languagesController.tr("PASSWORD_RECOVERY"),
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Obx(
                    () => DefaultButton1(
                      buttonName: signInController.isLoading.value == false
                          ? languagesController.tr("LOGIN")
                          : languagesController.tr("PLEASE_WAIT"),
                      height: 50,
                      onpressed: () async {
                        if (signInController.usernameController.text.isEmpty ||
                            signInController.passwordController.text.isEmpty) {
                          Get.snackbar("Oops!", "Fill the text fields");
                        } else {
                          print("Attempting login...");
                          await signInController.signIn();

                          if (signInController.loginsuccess.value == false) {
                            dashboardController.fetchDashboardData();

                            Get.toNamed(basescreen);
                          } else {
                            print("Navigation conditions not met.");
                          }
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 80),
                  Container(
                    height: 60,
                    width: screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            whatsapp();
                          },
                          child: Icon(FontAwesomeIcons.whatsapp, size: 40),
                        ),
                        SizedBox(width: 50),
                        GestureDetector(
                          onTap: () {
                            showSocialPopup(context);
                          },
                          child: Image.asset(
                            "assets/icons/social-media.png",
                            height: 40,
                          ),
                        ),
                        SizedBox(width: 50),
                        GestureDetector(
                          onTap: () {
                            _makePhoneCall(phoneNumber);
                          },
                          child: Icon(FontAwesomeIcons.phone, size: 28),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("--"),
                      KText(
                        text: languagesController.tr("FIND_US_ON"),
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      Text("--"),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _makePhoneCall(String number) async {
  final Uri url = Uri(scheme: 'tel', path: number);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
