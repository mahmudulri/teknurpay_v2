import 'dart:io';

import 'package:teknurpay/widgets/button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/add_hawala_controller.dart';
import '../controllers/add_payment_controller.dart';
import '../controllers/branch_controller.dart';
import '../controllers/conversation_controller.dart';
import '../controllers/currency_controller.dart';
import '../controllers/payment_method_controller.dart';
import '../controllers/sign_in_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';
import '../utils/colors.dart';
import '../widgets/authtextfield.dart';
import '../widgets/bottomsheet.dart';
import '../widgets/button_one.dart';
import 'hawala_list_screen.dart';

class Draft extends StatefulWidget {
  Draft({super.key});

  @override
  State<Draft> createState() => _DraftState();
}

class _DraftState extends State<Draft> {
  final Mypagecontroller mypagecontroller = Get.find();
  final AddHawalaController addHawalaController = Get.put(
    AddHawalaController(),
  );
  SignInController signInController = Get.put(SignInController());

  final CurrencyController currencyController = Get.put(CurrencyController());
  PaymentMethodController paymentMethodController = Get.put(
    PaymentMethodController(),
  );

  final box = GetStorage();

  List commissionpaidby = [];

  RxString person = "".obs;
  final pageController = Get.find<Mypagecontroller>();
  LanguagesController languagesController = Get.put(LanguagesController());

  AddPaymentController addPaymentController = Get.put(AddPaymentController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    paymentMethodController.fetchmethods();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Color(0xff011A52), // Status bar background color
        statusBarIconBrightness: Brightness.light, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );

    commissionpaidby = [
      languagesController.tr("SENDER"),
      languagesController.tr("RECEIVER"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pageController = Get.find<Mypagecontroller>();
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/homeback.webp'),
            fit: BoxFit.fill,
          ),
        ),
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
                          mypagecontroller.changePage(
                            HawalaListScreen(),
                            isMainPage: false,
                          );
                        },
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(FontAwesomeIcons.chevronLeft),
                          ),
                        ),
                      ),
                      Spacer(),
                      Obx(
                        () => Text(
                          languagesController.tr("ADD_NEW_RECEIPT"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          CustomFullScreenSheet.show(context);
                        },
                        child: Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.menu, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 600,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Color(0xffEEF4FF),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(0, 0),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ListView(
                    children: [
                      Container(
                        height: 50,
                        width: screenWidth,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: screenHeight * 0.065,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  color: Color(0xffF9FAFB),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: TextField(
                                    style: TextStyle(height: 1.1),
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}'),
                                      ),
                                    ],
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: screenHeight * 0.018,
                                        fontFamily:
                                            box.read("language").toString() ==
                                                "Fa"
                                            ? Get.find<FontController>()
                                                  .currentFont
                                            : null,
                                      ),
                                    ),
                                    onChanged: (value) {},
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Obx(
                                        () => Text(
                                          addHawalaController.currency.value
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontFamily:
                                                box
                                                        .read("language")
                                                        .toString() ==
                                                    "Fa"
                                                ? Get.find<FontController>()
                                                      .currentFont
                                                : null,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // currencyController.fetchCurrency();
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                content: Container(
                                                  height: 250,
                                                  width: double.maxFinite,
                                                  child: Obx(
                                                    () =>
                                                        currencyController
                                                                .isLoading
                                                                .value ==
                                                            false
                                                        ? ListView.separated(
                                                            separatorBuilder:
                                                                (
                                                                  context,
                                                                  index,
                                                                ) {
                                                                  return SizedBox(
                                                                    height: 5,
                                                                  );
                                                                },
                                                            itemCount:
                                                                currencyController
                                                                    .allcurrency
                                                                    .value
                                                                    .data!
                                                                    .currencies!
                                                                    .length,
                                                            itemBuilder: (context, index) {
                                                              final data =
                                                                  currencyController
                                                                      .allcurrency
                                                                      .value
                                                                      .data!
                                                                      .currencies![index];
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                },
                                                                child: Container(
                                                                  height: 40,
                                                                  width: double
                                                                      .maxFinite,
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade300,
                                                                    ),
                                                                  ),
                                                                  child: Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                          5.0,
                                                                        ),
                                                                    child: Center(
                                                                      child: Row(
                                                                        children: [
                                                                          Text(
                                                                            data.symbol.toString(),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Icon(
                                          FontAwesomeIcons.chevronDown,
                                          color: Colors.grey.shade600,
                                          size: screenHeight * 0.020,
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
                      SizedBox(height: 10),
                      Text(
                        languagesController.tr("TRACKING_CODE"),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.020,
                          fontFamily: box.read("language").toString() == "Fa"
                              ? Get.find<FontController>().currentFont
                              : null,
                        ),
                      ),
                      SizedBox(height: 5),
                      Authtextfield(
                        hinttext: "",
                        controller: addHawalaController.idcardController,
                      ),
                      SizedBox(height: 10),
                      Text(
                        languagesController.tr("PAYMENT_TYPE"),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.020,
                          fontFamily: box.read("language").toString() == "Fa"
                              ? Get.find<FontController>().currentFont
                              : null,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        height: 50,
                        width: screenWidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => Text(
                                    addHawalaController.branch.toString(),
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.020,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Container(
                                          height: 150,
                                          width: screenWidth,
                                          color: Colors.white,
                                          child: Obx(
                                            () =>
                                                paymentMethodController
                                                        .isLoading
                                                        .value ==
                                                    false
                                                ? ListView.builder(
                                                    itemCount:
                                                        paymentMethodController
                                                            .allmethods
                                                            .value
                                                            .data!
                                                            .paymentMethods!
                                                            .length,
                                                    itemBuilder: (context, index) {
                                                      final data =
                                                          paymentMethodController
                                                              .allmethods
                                                              .value
                                                              .data!
                                                              .paymentMethods![index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          // addHawalaController
                                                          //         .branch
                                                          //         .value =
                                                          //     data.methodName
                                                          //         .toString();
                                                          // addHawalaController
                                                          //         .branchId
                                                          //         .value =
                                                          //     data.id
                                                          //         .toString();

                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                bottom: 8,
                                                              ),
                                                          height: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                                border: Border.all(
                                                                  width: 1,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                data.methodName
                                                                    .toString(),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Icon(
                                  FontAwesomeIcons.chevronDown,
                                  size: screenHeight * 0.018,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        languagesController.tr("NOTES"),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.020,
                          fontFamily: box.read("language").toString() == "Fa"
                              ? Get.find<FontController>().currentFont
                              : null,
                        ),
                      ),
                      SizedBox(height: 5),
                      Authtextfield(
                        hinttext: "",
                        controller: addHawalaController.idcardController,
                      ),
                      SizedBox(height: 10),
                      Obx(
                        () => DefaultButton1(
                          buttonName:
                              addHawalaController.isLoading.value == false
                              ? languagesController.tr("CONFIRM_AND_SUBMIT")
                              : languagesController.tr("PLEASE_WAIT"),
                          height: 50,
                          width: double.maxFinite,
                          onpressed: () async {
                            if (addHawalaController
                                    .senderNameController
                                    .text
                                    .isNotEmpty &&
                                addHawalaController
                                    .receiverNameController
                                    .text
                                    .isNotEmpty &&
                                addHawalaController
                                    .amountController
                                    .text
                                    .isNotEmpty &&
                                addHawalaController
                                    .fatherNameController
                                    .text
                                    .isNotEmpty &&
                                addHawalaController
                                    .idcardController
                                    .text
                                    .isNotEmpty &&
                                addHawalaController.currencyID.value != "" &&
                                addHawalaController.paidbyreceiver.value !=
                                    "" &&
                                addHawalaController.branchId.value != "") {
                              print("All is ok............");

                              bool success = await addHawalaController
                                  .createhawala();
                              if (success) {
                                Get.find<Mypagecontroller>().goBack();
                              }
                            } else {
                              Fluttertoast.showToast(
                                msg: "Enter All data",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 80),
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
