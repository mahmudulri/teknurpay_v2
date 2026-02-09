import 'dart:io';

import 'package:teknurpay/widgets/custom_text.dart';
import 'package:teknurpay/widgets/button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/add_hawala_controller.dart';
import '../controllers/branch_controller.dart';
import '../controllers/conversation_controller.dart';
import '../controllers/currency_controller.dart';
import '../controllers/hawala_currency_controller.dart';
import '../controllers/sign_in_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';
import '../utils/colors.dart';
import '../widgets/authtextfield.dart';
import '../widgets/bottomsheet.dart';
import '../widgets/button_one.dart';
import 'hawala_list_screen.dart';

class HawalaScreen extends StatefulWidget {
  HawalaScreen({super.key});

  @override
  State<HawalaScreen> createState() => _HawalaScreenState();
}

class _HawalaScreenState extends State<HawalaScreen> {
  final Mypagecontroller mypagecontroller = Get.find();
  final AddHawalaController addHawalaController = Get.put(
    AddHawalaController(),
  );
  SignInController signInController = Get.put(SignInController());

  final CurrencyController currencyController = Get.put(CurrencyController());
  final BranchController branchController = Get.put(BranchController());

  HawalaCurrencyController hawalaCurrencyController = Get.put(
    HawalaCurrencyController(),
  );

  final box = GetStorage();

  List commissionpaidby = [];

  RxString person = "".obs;
  final pageController = Get.find<Mypagecontroller>();
  LanguagesController languagesController = Get.put(LanguagesController());

  ConversationController conversationController = Get.put(
    ConversationController(),
  );

  @override
  void initState() {
    super.initState();
    hawalaCurrencyController.fetchcurrency();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );

    addHawalaController.amountController.clear();
    addHawalaController.currency.value = '';
    addHawalaController.finalAmount.value = '';
    conversationController.selectedCurrency.value = "";
    addHawalaController.senderNameController.clear();
    addHawalaController.receiverNameController.clear();
    addHawalaController.fatherNameController.clear();
    addHawalaController.idcardController.clear();
    addHawalaController.currencyID.value == "";
    addHawalaController.paidbyreceiver.value = "";
    addHawalaController.paidbysender.value = "";
    addHawalaController.branchId.value = "";
    addHawalaController.currency.value = "";
    addHawalaController.currency2.value = "";
    addHawalaController.branch.value = "";

    currencyController.fetchCurrencyList();
    branchController.fetchallbranch();
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
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
                          text: languagesController.tr("CREATE_HAWALA"),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 600,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      Text(
                        languagesController.tr("SENDER_NAME"),
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
                        controller: addHawalaController.senderNameController,
                      ),
                      SizedBox(height: 5),
                      Text(
                        languagesController.tr("RECEIVER_NAME"),
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
                        controller: addHawalaController.receiverNameController,
                      ),
                      // SizedBox(height: 10),
                      // Row(
                      //   children: [
                      //     Text(
                      //       languagesController.tr("RECEIVER_FATHERS_NAME"),
                      //       style: TextStyle(
                      //         color: Colors.grey.shade600,
                      //         fontSize: screenHeight * 0.020,
                      //         fontFamily:
                      //             box.read("language").toString() == "Fa"
                      //             ? Get.find<FontController>().currentFont
                      //             : null,
                      //       ),
                      //     ),
                      //     SizedBox(width: 8),
                      //     Text(
                      //       "(${languagesController.tr("OPTIONAL")})",
                      //       style: TextStyle(
                      //         color: Colors.grey.shade600,
                      //         fontSize: screenHeight * 0.018,
                      //         fontFamily:
                      //             box.read("language").toString() == "Fa"
                      //             ? Get.find<FontController>().currentFont
                      //             : null,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: 5),
                      // Authtextfield(
                      //   hinttext: "",
                      //   controller: addHawalaController.fatherNameController,
                      // ),
                      // SizedBox(height: 5),
                      // Row(
                      //   children: [
                      //     Text(
                      //       languagesController.tr("RECEIVER_ID_CARD_NUMBER"),
                      //       style: TextStyle(
                      //         color: Colors.grey.shade600,
                      //         fontSize: screenHeight * 0.020,
                      //         fontFamily:
                      //             box.read("language").toString() == "Fa"
                      //             ? Get.find<FontController>().currentFont
                      //             : null,
                      //       ),
                      //     ),
                      //     SizedBox(width: 8),
                      //     Text(
                      //       "(${languagesController.tr("OPTIONAL")})",
                      //       style: TextStyle(
                      //         color: Colors.grey.shade600,
                      //         fontSize: screenHeight * 0.018,
                      //         fontFamily:
                      //             box.read("language").toString() == "Fa"
                      //             ? Get.find<FontController>().currentFont
                      //             : null,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: 5),
                      // Authtextfield(
                      //   hinttext: "",
                      //   controller: addHawalaController.idcardController,
                      // ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              hawalaCurrencyController.fetchcurrency();
                            },
                            child: Text(
                              languagesController.tr("HAWALA_AMOUNT"),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: screenHeight * 0.020,
                                fontFamily:
                                    box.read("language").toString() == "Fa"
                                    ? Get.find<FontController>().currentFont
                                    : null,
                              ),
                            ),
                          ),
                          Text(
                            languagesController.tr("CURRENCY"),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: screenHeight * 0.020,
                              fontFamily:
                                  box.read("language").toString() == "Fa"
                                  ? Get.find<FontController>().currentFont
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
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
                                    controller:
                                        addHawalaController.amountController,
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
                                    onChanged: (value) {
                                      final selected = addHawalaController
                                          .selectedRate
                                          .value;

                                      // যদি কোন currency সিলেক্ট না করা হয় (selected null হয়) তাহলে হিসাব না করো
                                      if (selected == null ||
                                          addHawalaController
                                              .currency
                                              .value
                                              .isEmpty) {
                                        addHawalaController.finalAmount.value =
                                            "0.00";
                                        return;
                                      }

                                      double input =
                                          double.tryParse(
                                            addHawalaController
                                                .amountController
                                                .text
                                                .trim(),
                                          ) ??
                                          0;
                                      double dAmount =
                                          double.tryParse(
                                            selected.amount?.toString() ?? "0",
                                          ) ??
                                          0;
                                      double sRate =
                                          double.tryParse(
                                            selected.sellRate?.toString() ??
                                                "0",
                                          ) ??
                                          0;

                                      double result = 0;
                                      if (dAmount > 0 && sRate > 0) {
                                        result = (input / dAmount) * sRate;
                                      }

                                      addHawalaController.finalAmount.value =
                                          result.toStringAsFixed(2);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),

                            Expanded(
                              flex: 1,
                              child: Obx(() {
                                // rates আনছি (dynamic list)
                                final List<dynamic> rates =
                                    (hawalaCurrencyController
                                            .hawalafilteredcurrency
                                            .value
                                            .data
                                            ?.rates
                                        as List?) ??
                                    <dynamic>[];

                                // helper: নিরাপদে double parse
                                double _toDouble(dynamic v) {
                                  if (v == null) return 0;
                                  return double.tryParse(v.toString()) ?? 0;
                                }

                                final bool langIsFa =
                                    box.read("language").toString() == "Fa";

                                // 1) ডুপ্লিকেট toCurrency.id বাদ দিয়ে প্রথম occurrence রাখি
                                final Map<String, dynamic> uniqueByToId = {};
                                for (final r in rates) {
                                  final String toId =
                                      ((r?.toCurrency?.id) ?? '').toString();
                                  if (toId.isEmpty) continue;
                                  // আগে রাখা না থাকলে রাখি (প্রথমটাই থাকবে)
                                  uniqueByToId.putIfAbsent(toId, () => r);
                                }

                                // 2) Dropdown items তৈরি
                                final dropdownItems = uniqueByToId.entries
                                    .map<DropdownMenuItem<String>>((e) {
                                      final symbol =
                                          ((e.value?.toCurrency?.symbol) ?? '')
                                              .toString();
                                      return DropdownMenuItem<String>(
                                        value: e.key, // toCurrency.id
                                        child: Text(symbol),
                                      );
                                    })
                                    .toList();

                                // 3) বর্তমান value dropdown-এ আছে কিনা
                                final currentValue =
                                    addHawalaController.currencyID.value;
                                final bool valueExists =
                                    currentValue.isNotEmpty &&
                                    uniqueByToId.containsKey(currentValue);

                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey.shade300,
                                    ),
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    alignment: !langIsFa
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,

                                    // dropdown-এ না থাকলে null
                                    value: valueExists ? currentValue : null,

                                    items: dropdownItems,

                                    onChanged: (value) {
                                      if (value == null) return;

                                      // 4) নির্বাচিত rate (ডুপ্লিকেট ফ্রি map থেকে)
                                      final selectedRate = uniqueByToId[value];

                                      // 5) controller আপডেট
                                      addHawalaController.currencyID.value =
                                          value;
                                      addHawalaController.currency.value =
                                          ((selectedRate?.toCurrency?.symbol) ??
                                                  '')
                                              .toString();
                                      addHawalaController.selectedRate.value =
                                          selectedRate;

                                      // 6) হিসাব
                                      final input = _toDouble(
                                        addHawalaController
                                            .amountController
                                            .text
                                            .trim(),
                                      );
                                      final dAmount = _toDouble(
                                        selectedRate?.amount,
                                      );
                                      final sRate = _toDouble(
                                        selectedRate?.sellRate,
                                      );

                                      double result = 0;
                                      if (dAmount > 0 && sRate > 0) {
                                        result = (input / dAmount) * sRate;
                                      }
                                      addHawalaController.finalAmount.value =
                                          result.toStringAsFixed(2);
                                    },

                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    icon: Icon(
                                      FontAwesomeIcons.chevronDown,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    hint: Text(
                                      addHawalaController.currency.value.isEmpty
                                          ? ''
                                          : addHawalaController.currency.value,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      // Text(
                      //   languagesController.tr("COMMISSION_PAID_BY"),
                      //   style: TextStyle(
                      //     color: Colors.grey.shade600,
                      //     fontSize: screenHeight * 0.020,
                      //     fontFamily: box.read("language").toString() == "Fa"
                      //         ? Get.find<FontController>().currentFont
                      //         : null,
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      // Container(
                      //   height: 50,
                      //   width: screenWidth,
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(10),
                      //     border: Border.all(
                      //       width: 1,
                      //       color: Colors.grey.shade300,
                      //     ),
                      //   ),
                      //   child: Padding(
                      //     padding: EdgeInsets.only(left: 8, right: 8),
                      //     child: Row(
                      //       children: [
                      //         Expanded(
                      //           child: Obx(
                      //             () => Text(
                      //               person.value.toString(),
                      //               style: TextStyle(
                      //                 fontSize: screenHeight * 0.020,
                      //                 color: Colors.grey.shade600,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //         GestureDetector(
                      //           onTap: () {
                      //             showDialog(
                      //               context: context,
                      //               builder: (context) {
                      //                 return AlertDialog(
                      //                   backgroundColor: Colors.white,
                      //                   content: Container(
                      //                     height: 150,
                      //                     width: screenWidth,
                      //                     color: Colors.white,
                      //                     child: ListView.builder(
                      //                       itemCount: commissionpaidby.length,
                      //                       itemBuilder: (context, index) {
                      //                         return GestureDetector(
                      //                           onTap: () {
                      //                             person.value =
                      //                                 commissionpaidby[index];
                      //                             if (commissionpaidby[index] ==
                      //                                 "sender") {
                      //                               addHawalaController
                      //                                       .paidbysender
                      //                                       .value =
                      //                                   "1";
                      //                               addHawalaController
                      //                                       .paidbyreceiver
                      //                                       .value =
                      //                                   "0";
                      //                             } else {
                      //                               addHawalaController
                      //                                       .paidbysender
                      //                                       .value =
                      //                                   "0";
                      //                               addHawalaController
                      //                                       .paidbyreceiver
                      //                                       .value =
                      //                                   "1";
                      //                             }
                      //                             Navigator.pop(context);
                      //                           },
                      //                           child: Container(
                      //                             margin: EdgeInsets.only(
                      //                               bottom: 8,
                      //                             ),

                      //                             height: 40,
                      //                             padding: EdgeInsets.symmetric(
                      //                               horizontal: 10,
                      //                             ),
                      //                             alignment:
                      //                                 Alignment.centerLeft,
                      //                             decoration: BoxDecoration(
                      //                               border: Border.all(
                      //                                 width: 1,
                      //                                 color: Colors.grey,
                      //                               ),
                      //                               borderRadius:
                      //                                   BorderRadius.circular(
                      //                                     8,
                      //                                   ),
                      //                             ),
                      //                             child: Padding(
                      //                               padding:
                      //                                   EdgeInsets.symmetric(
                      //                                     horizontal: 5,
                      //                                     vertical: 8,
                      //                                   ),
                      //                               child: Text(
                      //                                 commissionpaidby[index],
                      //                                 style: TextStyle(
                      //                                   fontSize: 16,
                      //                                 ),
                      //                               ),
                      //                             ),
                      //                           ),
                      //                         );
                      //                       },
                      //                     ),
                      //                   ),
                      //                 );
                      //               },
                      //             );
                      //           },
                      //           child: CircleAvatar(
                      //             backgroundColor: AppColors.primaryColor
                      //                 .withOpacity(0.7),
                      //             radius: 15,
                      //             child: Icon(
                      //               FontAwesomeIcons.chevronDown,
                      //               color: Colors.white,
                      //               size: 17,
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      Container(
                        height: 50,
                        width: screenWidth,
                        decoration: BoxDecoration(
                          color: Color(0xff352B73),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                () => Text(
                                  addHawalaController.finalAmount.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    // fontFamily:
                                    //     box.read("language").toString() == "Fa"
                                    //         ? Get.find<FontController>()
                                    //             .currentFont
                                    //         : null,
                                  ),
                                ),
                              ),
                              Text(
                                box.read("currency_code"),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                      box.read("language").toString() == "Fa"
                                      ? Get.find<FontController>().currentFont
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        languagesController.tr(
                          "FINAL_AMOUNT_DEDUCTED_FROM_YOUR_BALANCE",
                        ),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: screenHeight * 0.015,
                          fontFamily: box.read("language").toString() == "Fa"
                              ? Get.find<FontController>().currentFont
                              : null,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        languagesController.tr("BRANCH"),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.020,
                          fontFamily: box.read("language").toString() == "Fa"
                              ? Get.find<FontController>().currentFont
                              : null,
                        ),
                      ),
                      SizedBox(height: 10),
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
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => Text(
                                    addHawalaController.branch.toString(),
                                    style: TextStyle(
                                      fontSize: screenHeight * 0.020,
                                      color: Colors.grey.shade600,
                                      fontFamily:
                                          box.read("language").toString() ==
                                              "Fa"
                                          ? Get.find<FontController>()
                                                .currentFont
                                          : null,
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
                                        backgroundColor: Colors.white,
                                        content: Container(
                                          height: 150,
                                          width: screenWidth,
                                          color: Colors.white,
                                          child: Obx(
                                            () =>
                                                branchController
                                                        .isLoading
                                                        .value ==
                                                    false
                                                ? ListView.builder(
                                                    itemCount: branchController
                                                        .allbranch
                                                        .value
                                                        .data!
                                                        .hawalabranches!
                                                        .length,
                                                    itemBuilder: (context, index) {
                                                      final data = branchController
                                                          .allbranch
                                                          .value
                                                          .data!
                                                          .hawalabranches![index];
                                                      return GestureDetector(
                                                        onTap: () {
                                                          addHawalaController
                                                              .branch
                                                              .value = data.name
                                                              .toString();
                                                          addHawalaController
                                                              .branchId
                                                              .value = data.id
                                                              .toString();

                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                bottom: 8,
                                                              ),

                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              width: 1,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.symmetric(
                                                                  horizontal: 5,
                                                                  vertical: 8,
                                                                ),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    data.name
                                                                        .toString(),
                                                                    maxLines: 2,
                                                                    softWrap:
                                                                        true,
                                                                  ),
                                                                ),
                                                              ],
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
                                child: CircleAvatar(
                                  backgroundColor: AppColors.primaryColor
                                      .withOpacity(0.7),
                                  radius: 15,
                                  child: Icon(
                                    FontAwesomeIcons.chevronDown,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
