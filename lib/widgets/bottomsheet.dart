// file: widgets/custom_full_screen_sheet.dart

import 'dart:io';

import 'package:teknurpay/widgets/custom_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/drawer_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/global_controller/page_controller.dart';
import 'package:teknurpay/screens/helpscreen.dart';
import 'package:teknurpay/screens/termscondition.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../accounting/accounting_base.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/sign_in_controller.dart';
import '../pages/homepages.dart';
import '../screens/change_password_screen.dart';
import '../screens/change_pin.dart';
import '../screens/commission_group_screen.dart';
import '../screens/hawala_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/selling_price_screen.dart';
import '../screens/sign_in_screen.dart';
import 'drawer.dart';

class CustomFullScreenSheet extends StatefulWidget {
  CustomFullScreenSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomFullScreenSheet(),
    );
  }

  @override
  State<CustomFullScreenSheet> createState() => _CustomFullScreenSheetState();
}

class _CustomFullScreenSheetState extends State<CustomFullScreenSheet> {
  final dashboardController = Get.find<DashboardController>();
  LanguagesController languagesController = Get.put(LanguagesController());

  final box = GetStorage();
  final Mypagecontroller mypagecontroller = Get.find();
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: MediaQuery.of(context).size.height - 120, // 100px gap from top
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
      child: Obx(
        () => dashboardController.deactiveStatus.value == "Deactivated"
            ? Center(
                child: Text(
                  textAlign: TextAlign.center,
                  dashboardController.deactivateMessage.value.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              )
            : Column(
                children: [
                  SizedBox(height: 5),
                  Container(
                    height: 5,
                    width: 130,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                            contentPadding: EdgeInsets.all(0),
                            content: ContactDialogBox(),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 80,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Color(0xffE8FCF1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/icons/drawerwhatsapp.png",
                            height: 35,
                          ),
                          SizedBox(height: 5),
                          KText(
                            text: languagesController.tr("CONTACTUS"),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 100,
                    width: screenWidth,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(Duration(milliseconds: 100), () {
                                mypagecontroller.changePage(
                                  Helpscreen(),
                                  isMainPage: false,
                                );
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffFFF4EF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/drawerguide.png",
                                    height: 35,
                                  ),
                                  SizedBox(height: 5),
                                  KText(
                                    text: languagesController.tr("GUIDE"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff8E5B42),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      languagesController.tr("CHANGE_LANGUAGE"),
                                    ),
                                    content: Container(
                                      height: 350,
                                      width: screenWidth,
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

                                              final matched =
                                                  languagesController
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

                                              // Store selected language & direction
                                              languagesController
                                                  .changeLanguage(languageName);
                                              box.write(
                                                "language",
                                                languageName,
                                              );
                                              box.write(
                                                "direction",
                                                languageDirection,
                                              );

                                              // Set locale based on ISO
                                              Locale locale;
                                              switch (languageISO) {
                                                case "fa":
                                                  locale = Locale("fa", "IR");
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
                                                case "en":
                                                default:
                                                  locale = Locale("en", "US");
                                              }

                                              // Set app locale
                                              setState(() {
                                                EasyLocalization.of(
                                                  context,
                                                )!.setLocale(locale);
                                              });

                                              // Pop dialog
                                              Navigator.pop(context);

                                              print(
                                                "🌐 Language changed to $languageName ($languageISO), Direction: $languageDirection",
                                              );
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              height: 45,
                                              width: screenWidth,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey.shade300,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Center(
                                                      child: KText(
                                                        text: languagesController
                                                            .alllanguagedata[index]["fullname"]
                                                            .toString(),
                                                      ),
                                                    ),
                                                  ],
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
                              decoration: BoxDecoration(
                                color: Color(0xff6F76FF).withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/drawerlanguage.png",
                                    height: 35,
                                  ),
                                  SizedBox(height: 5),
                                  KText(
                                    textAlign: TextAlign.center,
                                    text: languagesController.tr("LANGUAGES"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xffA37700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(Duration(milliseconds: 100), () {
                                mypagecontroller.changePage(
                                  ProfileScreen(),
                                  isMainPage: false,
                                );
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffE8FCF1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/drawerprofile.png",
                                    height: 35,
                                  ),
                                  SizedBox(height: 5),
                                  KText(
                                    text: languagesController.tr("PROFILE"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff067D3D),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 80,
                    width: screenWidth,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(Duration(milliseconds: 100), () {
                                mypagecontroller.changePage(
                                  ChangePinScreen(),
                                  isMainPage: false,
                                );
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff1abc9c).withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/key.png",
                                    height: 35,
                                    color: Color(0xff6F76FF),
                                  ),
                                  SizedBox(height: 5),
                                  KText(
                                    text: languagesController.tr("CHANGE_PIN"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff6F76FF),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(Duration(milliseconds: 100), () {
                                mypagecontroller.changePage(
                                  ChangePasswordScreen(),
                                  isMainPage: false,
                                );
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff8e44ad).withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/padlock.png",
                                    color: Color(0xff8e44ad),
                                    height: 35,
                                  ),
                                  SizedBox(height: 5),
                                  KText(
                                    text: languagesController.tr(
                                      "CHANGE_PASSWORD",
                                    ),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff8e44ad),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  // GestureDetector(
                  //   onTap: () {
                  //     Get.to(() => AccountingBaseScreen());
                  //   },
                  //   child: Container(
                  //     height: 80,
                  //     width: screenWidth,
                  //     decoration: BoxDecoration(
                  //       color: Color(0xff2c3e50).withOpacity(0.30),
                  //       borderRadius: BorderRadius.circular(6),
                  //       border: Border.all(
                  //         width: 1,
                  //         color: Colors.grey.shade200,
                  //       ),
                  //     ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Image.asset("assets/icons/logout.png", height: 35),
                  //         SizedBox(width: 10),
                  //         KText(
                  //           text: languagesController.tr("ACCOUNTING"),
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.w700,
                  //           color: Color(0xffFFFFFF),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 10),
                  Container(
                    height: 90,
                    width: screenWidth,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(Duration(milliseconds: 100), () {
                                mypagecontroller.changePage(
                                  SellingPriceScreen(),
                                  isMainPage: false,
                                );
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffc0392b).withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/faq.png",
                                    height: 35,
                                    color: Color(0xffc0392b),
                                  ),
                                  SizedBox(height: 5),
                                  KText(
                                    text: languagesController.tr(
                                      "SET_SALE_PRICE",
                                    ),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xffc0392b),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(Duration(milliseconds: 100), () {
                                mypagecontroller.changePage(
                                  CommissionGroupScreen(),
                                  isMainPage: false,
                                );
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/discount.png",
                                    color: AppColors.primaryColor,
                                    height: 35,
                                  ),
                                  SizedBox(height: 5),
                                  KText(
                                    text: languagesController.tr(
                                      "COMMISSION_GROUP",
                                    ),
                                    textAlign: TextAlign.center,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            contentPadding: EdgeInsets.all(0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            content: LogoutDialogBox(),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 80,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Color(0xff8E5B42).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 1,
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/icons/logout.png", height: 35),
                          SizedBox(height: 5),
                          KText(
                            text: languagesController.tr("LOGOUT"),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff8E5B42),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

whatsapp() async {
  var contact = "+93708488200";
  var androidUrl = "whatsapp://send?phone=$contact&text=Hi, I need some help";
  var iosUrl = "https://wa.me/$contact?text=${Uri.parse('')}";

  try {
    if (Platform.isIOS) {
      await launchUrl(Uri.parse(iosUrl));
    } else {
      await launchUrl(Uri.parse(androidUrl));
    }
  } on Exception {
    print("not found");
  }
}

class ContactDialogBox extends StatelessWidget {
  const ContactDialogBox({super.key});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 300,
      width: screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset("assets/icons/whatsapp2.png", height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "You will be redirected to the WhatsApp page to contact us. Continue?",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              width: screenWidth,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () {
                        whatsapp();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Yes",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutDialogBox extends StatelessWidget {
  LogoutDialogBox({super.key});

  final signInController = Get.find<SignInController>();
  final Mypagecontroller mypagecontroller = Get.find();

  final box = GetStorage();

  LanguagesController languagesController = Get.put(LanguagesController());

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 200,
      width: screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/rejected.png", height: 40),
              SizedBox(width: 15),
              KText(
                text: languagesController.tr("DO_YOU_WANT_TO_LOG_OUT"),
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          // SizedBox(
          //   height: 20,
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 45,
              width: screenWidth,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () {
                        signInController.usernameController.clear();
                        signInController.passwordController.clear();

                        box.remove("userToken");
                        mypagecontroller.changePage(
                          Homepages(),
                          isMainPage: false,
                        );

                        Get.to(() => SignInScreen());
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: KText(
                            text: languagesController.tr("YES_IAMGOING_OUT"),
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: KText(
                            text: languagesController.tr("CANCEL"),
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
