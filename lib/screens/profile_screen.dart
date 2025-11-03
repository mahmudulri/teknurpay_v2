import 'dart:io';

import 'package:teknurpay/widgets/custom_text.dart';
import 'package:teknurpay/widgets/button.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teknurpay/controllers/dashboard_controller.dart';
import 'package:teknurpay/controllers/drawer_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/pages/homepages.dart';
import 'package:teknurpay/screens/change_pin.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:teknurpay/widgets/button_one.dart';
import 'package:teknurpay/widgets/drawer.dart';

import '../global_controller/page_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final dashboardController = Get.find<DashboardController>();

  LanguagesController languagesController = Get.put(LanguagesController());

  final Mypagecontroller mypagecontroller = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MyDrawerController drawerController = Get.put(MyDrawerController());
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

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 40),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          mypagecontroller.goBack();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            "assets/icons/backicon.png",
                            height: 40,
                          ),
                        ),
                      ),
                      Spacer(),
                      Obx(
                        () => KText(
                          text: languagesController.tr("PROFILE"),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                          color: Colors.black,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          CustomFullScreenSheet.show(context);
                        },
                        child: Image.asset(
                          "assets/icons/drawericon.png",
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child:
                  dashboardController
                          .alldashboardData
                          .value
                          .data!
                          .userInfo!
                          .profileImageUrl !=
                      null
                  ? Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            dashboardController
                                .alldashboardData
                                .value
                                .data!
                                .userInfo!
                                .profileImageUrl
                                .toString(),
                          ),
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    )
                  : Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 10),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 100),
            //   child: GestureDetector(
            //     onTap: () {
            //       mypagecontroller.changePage(
            //         ChangePinScreen(),
            //         isMainPage: false,
            //       );
            //     },
            //     child: DefaultButton1(
            //       width: double.maxFinite,
            //       height: 45,
            //       buttonName: languagesController.tr("CHANGE_PIN"),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  child: ListView(
                    padding: EdgeInsets.all(0),
                    children: [
                      SizedBox(height: 15),
                      Obx(
                        () => Profilebox(
                          boxname: languagesController.tr("FULL_NAME"),
                          data: dashboardController
                              .alldashboardData
                              .value
                              .data!
                              .userInfo!
                              .resellerName
                              .toString(),
                        ),
                      ),

                      Obx(
                        () => Profilebox(
                          boxname: languagesController.tr("EMAIL"),
                          data: dashboardController
                              .alldashboardData
                              .value
                              .data!
                              .userInfo!
                              .email
                              .toString(),
                        ),
                      ),

                      Obx(
                        () => Profilebox(
                          boxname: languagesController.tr("PHONENUMBER"),
                          data: dashboardController
                              .alldashboardData
                              .value
                              .data!
                              .userInfo!
                              .phone
                              .toString(),
                        ),
                      ),

                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Profilebox(
                      //   boxname: "Location",
                      //   data: "IRAN, RAZAVIKHHORASAN, MASHHAD",
                      // ),
                      Obx(
                        () => Profilebox(
                          boxname: languagesController.tr("BALANCE"),
                          data:
                              dashboardController
                                  .alldashboardData
                                  .value
                                  .data!
                                  .userInfo!
                                  .balance
                                  .toString() +
                              " " +
                              box.read("currency_code"),
                        ),
                      ),

                      Obx(
                        () => Profilebox(
                          boxname: languagesController.tr("LOAN_BALANCE"),
                          data:
                              dashboardController
                                  .alldashboardData
                                  .value
                                  .data!
                                  .userInfo!
                                  .loanBalance
                                  .toString() +
                              " " +
                              box.read("currency_code"),
                        ),
                      ),

                      Obx(
                        () => Profilebox(
                          boxname: languagesController.tr("TOTAL_SOLD_AMOUNT"),
                          data:
                              dashboardController
                                  .alldashboardData
                                  .value
                                  .data!
                                  .totalSoldAmount
                                  .toString() +
                              " " +
                              box.read("currency_code"),
                        ),
                      ),

                      Obx(
                        () => Profilebox(
                          boxname: languagesController.tr("TOTAL_REVENUE"),
                          data:
                              dashboardController
                                  .alldashboardData
                                  .value
                                  .data!
                                  .totalRevenue
                                  .toString() +
                              " " +
                              box.read("currency_code"),
                        ),
                      ),
                    ],
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

class Profilebox extends StatelessWidget {
  Profilebox({super.key, this.boxname, this.data});

  String? boxname;
  String? data;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      height: screenHeight * 0.065,
      width: screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // subtle shadow
            spreadRadius: 1, // how much the shadow spreads
            blurRadius: 6, // softness of the shadow
            offset: Offset(0, 0), // no offset, shadow on all sides
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            KText(text: boxname.toString()),
            Text(
              data.toString(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
