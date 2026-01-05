import 'package:teknurpay/controllers/currency_controller.dart';
import 'package:teknurpay/widgets/custom_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/drawer_controller.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:teknurpay/widgets/drawer.dart';
import 'package:lottie/lottie.dart';
import 'package:teknurpay/controllers/country_list_controller.dart';
import 'package:teknurpay/controllers/custom_history_controller.dart';
import 'package:teknurpay/controllers/custom_recharge_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/global_controller/page_controller.dart';
import 'package:teknurpay/pages/homepages.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/button_one.dart';

import '../controllers/company_controller.dart';
import '../controllers/conversation_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/service_controller.dart';
import '../global_controller/font_controller.dart';
import '../widgets/button.dart';

class CreditTransfer extends StatefulWidget {
  CreditTransfer({super.key});

  @override
  State<CreditTransfer> createState() => _CreditTransferState();
}

class _CreditTransferState extends State<CreditTransfer> {
  final customhistoryController = Get.find<CustomHistoryController>();

  final countryListController = Get.find<CountryListController>();
  LanguagesController languagesController = Get.put(LanguagesController());
  CurrencyController currencyController = Get.put(CurrencyController());
  CustomRechargeController customRechargeController = Get.put(
    CustomRechargeController(),
  );
  final box = GetStorage();
  int selectedIndex = 0;

  final FocusNode _focusNode = FocusNode();

  RxList<bool> expandedIndices = <bool>[].obs;

  final ScrollController scrollController = ScrollController();

  final dashboardController = Get.find<DashboardController>();
  final companyController = Get.find<CompanyController>();

  ConversationController conversationController = Get.put(
    ConversationController(),
  );

  Future<void> refresh() async {
    final int totalPages =
        customhistoryController
            .allorderlist
            .value
            .payload
            ?.pagination!
            .totalPages ??
        0;
    final int currentPage = customhistoryController.initialpage;

    // Prevent loading more pages if we've reached the last page
    if (currentPage >= totalPages) {
      print(
        "End..........................................End.....................",
      );
      return;
    }

    // Check if the scroll position is at the bottom
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      customhistoryController.initialpage++;

      // Prevent fetching if the next page exceeds total pages
      if (customhistoryController.initialpage <= totalPages) {
        print("Load More...................");
        customhistoryController.fetchHistory();
      } else {
        customhistoryController.initialpage =
            totalPages; // Reset to the last valid page
        print("Already on the last page");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    currencyController.fetchCurrency();
    customRechargeController.numberController.clear();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );

    customRechargeController.numberController.addListener(() {
      final text = customRechargeController.numberController.text;
      companyController.matchCompanyByPhoneNumber(text);
    });

    customhistoryController.finalList.clear();
    customhistoryController.initialpage = 1;
    customhistoryController.fetchHistory();
    scrollController.addListener(refresh);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MyDrawerController drawerController = Get.put(MyDrawerController());

  @override
  Widget build(BuildContext context) {
    final Mypagecontroller mypagecontroller = Get.find();
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: Container(
          height: screenHeight,
          width: screenWidth,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15, top: 10),
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
                          () => GestureDetector(
                            onTap: () {
                              print(
                                customRechargeController.pinController.text
                                    .toString(),
                              );
                            },
                            child: Text(
                              languagesController.tr("CREDIT_TRANSFER"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.045,
                                color: Colors.black,
                              ),
                            ),
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
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Container(
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
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    countryListController.flagimageurl
                                        .toString(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: TextField(
                                      maxLength: 10,
                                      keyboardType: TextInputType.phone,
                                      controller: customRechargeController
                                          .numberController,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        border: InputBorder.none,
                                        hintText: languagesController.tr(
                                          "PHONENUMBER",
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Obx(() {
                                final company =
                                    companyController.matchedCompany.value;
                                return Container(
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: company == null
                                        ? Colors.transparent
                                        : null,
                                    image: company != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              company.companyLogo ?? '',
                                            ),
                                            fit: BoxFit.contain,
                                          )
                                        : null,
                                  ),
                                  child: company == null
                                      ? Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                );
                              }),
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   height: 8,
                        // ),
                        // Row(
                        //   children: [
                        //     Text(
                        //       "${languagesController.tr("TRANSFER_TOTAL_BALANCE")} (194/700/255 )",
                        //       style: TextStyle(
                        //         color: AppColors.primarycolor2,
                        //         fontWeight: FontWeight.w500,
                        //         fontSize: screenHeight * 0.017,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: 8),
                        Container(
                          height: 50,
                          width: screenWidth,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    onChanged: (value) {
                                      conversationController.inputAmount.value =
                                          double.tryParse(value) ?? 0.0;
                                    },
                                    controller: customRechargeController
                                        .amountController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: languagesController.tr(
                                        "AMOUNT",
                                      ),
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                                KText(
                                  text: "AFN",
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          height: 50,
                          child: Obx(() {
                            final convertedList = conversationController
                                .getConvertedValues();

                            if (convertedList.isEmpty) {
                              return Center(child: Text(""));
                            }

                            final item =
                                convertedList.first; // only show the first item

                            return Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("${item['symbol']} (${item['name']}):"),
                                  Text(item['value'].toStringAsFixed(2)),
                                ],
                              ),
                            );
                          }),
                        ),

                        DefaultButton1(
                          height: 50,
                          width: screenWidth,
                          buttonName: languagesController.tr(
                            "SEND_TO_DESTINATION",
                          ),
                          onpressed: () {
                            if (customRechargeController
                                    .numberController
                                    .text
                                    .isEmpty ||
                                customRechargeController
                                    .amountController
                                    .text
                                    .isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Enter required data",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            } else {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    content: Container(
                                      height: 320,
                                      width: screenWidth,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(17),
                                        color: Colors.white,
                                      ),
                                      child: Obx(() {
                                        final state = customRechargeController
                                            .rechargeState
                                            .value;

                                        /// ================= LOADING =================
                                        if (state == RechargeState.loading) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Lottie.asset(
                                                'assets/loties/recharge.json',
                                                height: 200,
                                              ),
                                              const SizedBox(height: 15),
                                              Text(
                                                languagesController.tr(
                                                  "PLEASE_WAIT",
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        /// ================= SUCCESS =================
                                        if (state == RechargeState.success) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Lottie.asset(
                                                'assets/loties/loadsuccess.json',
                                                height: 200,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                languagesController.tr(
                                                  "RECHARGE_SUCCESSFULL",
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              ElevatedButton(
                                                onPressed: () {
                                                  customRechargeController
                                                      .resetState();
                                                  Navigator.pop(
                                                    context,
                                                  ); // close pin dialog
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                                child: Text(
                                                  languagesController.tr(
                                                    "CLOSE",
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        /// ================= ERROR =================
                                        if (state == RechargeState.error) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/icons/rejected.png',
                                                height: 180,
                                              ),
                                              const SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                child: Text(
                                                  customRechargeController
                                                      .errorMessage
                                                      .value,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              ElevatedButton(
                                                onPressed: () {
                                                  customRechargeController
                                                      .resetState();
                                                },
                                                child: Text(
                                                  languagesController.tr(
                                                    "TRY_AGAIN",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }

                                        /// ================= IDLE (PIN INPUT) =================
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 20),
                                            Lottie.asset(
                                              'assets/loties/pin.json',
                                              height: 100,
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              languagesController.tr(
                                                "CONFIRM_YOUR_PIN",
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            SizedBox(
                                              width: 100,
                                              child: TextField(
                                                controller:
                                                    customRechargeController
                                                        .pinController,
                                                maxLength: 4,
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: const InputDecoration(
                                                  counterText: '',
                                                  focusedBorder:
                                                      UnderlineInputBorder(),
                                                  enabledBorder:
                                                      UnderlineInputBorder(),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                /// CANCEL
                                                GestureDetector(
                                                  onTap: () {
                                                    customRechargeController
                                                        .pinController
                                                        .clear();
                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        languagesController.tr(
                                                          "CANCEL",
                                                        ),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),

                                                /// VERIFY
                                                GestureDetector(
                                                  onTap: () {
                                                    if (customRechargeController
                                                            .pinController
                                                            .text
                                                            .length !=
                                                        4) {
                                                      Fluttertoast.showToast(
                                                        msg: languagesController
                                                            .tr(
                                                              "ENTER_YOUR_PIN",
                                                            ),
                                                      );
                                                      return;
                                                    }
                                                    customRechargeController
                                                        .placeOrder();
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        languagesController.tr(
                                                          "VERIFY",
                                                        ),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Obx(() {
                        // Ensure expandedIndices matches the length of finalList
                        if (expandedIndices.length !=
                            customhistoryController.finalList.length) {
                          expandedIndices.assignAll(
                            List.generate(
                              customhistoryController.finalList.length,
                              (index) => false,
                            ),
                          );
                        }

                        return customhistoryController.isLoading.value ==
                                    false &&
                                customhistoryController.finalList.isNotEmpty
                            ? RefreshIndicator(
                                onRefresh: refresh,
                                child: ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount:
                                      customhistoryController.finalList.length,
                                  itemBuilder: (context, index) {
                                    final data = customhistoryController
                                        .finalList[index];

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 5),
                                      width: screenWidth,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        children: [
                                          ExpansionTile(
                                            key: Key(
                                              index.toString(),
                                            ), // Ensure state retention
                                            initiallyExpanded:
                                                expandedIndices[index],
                                            onExpansionChanged: (isExpanded) {
                                              expandedIndices[index] =
                                                  isExpanded;
                                            },
                                            tilePadding: EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            title: Row(
                                              children: [
                                                Container(
                                                  height: 45,
                                                  width: 45,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                        data
                                                            .bundle!
                                                            .service!
                                                            .company!
                                                            .companyLogo
                                                            .toString(),
                                                      ),
                                                      fit: BoxFit.fill,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      data.bundle!.bundleTitle
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      data.rechargebleAccount
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            trailing: expandedIndices[index]
                                                ? null
                                                : GestureDetector(
                                                    onTap: () {
                                                      expandedIndices[index] =
                                                          true;
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SizedBox(width: 5),
                                                        Icon(
                                                          FontAwesomeIcons
                                                              .chevronDown,
                                                          size:
                                                              screenHeight *
                                                              0.022,
                                                          color: Color(
                                                            0xff1890FF,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          languagesController.tr(
                                                            "TRANSFER_STATUS",
                                                          ),
                                                        ),
                                                        Text(
                                                          data.status
                                                                      .toString() ==
                                                                  "0"
                                                              ? languagesController
                                                                    .tr(
                                                                      "PENDING",
                                                                    )
                                                              : data.status
                                                                        .toString() ==
                                                                    "1"
                                                              ? languagesController
                                                                    .tr(
                                                                      "SUCCESS",
                                                                    )
                                                              : languagesController
                                                                    .tr(
                                                                      "REJECTED",
                                                                    ),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                box
                                                                        .read(
                                                                          "language",
                                                                        )
                                                                        .toString() ==
                                                                    "Fa"
                                                                ? Get.find<
                                                                        FontController
                                                                      >()
                                                                      .currentFont
                                                                : null,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          languagesController
                                                              .tr("AMOUNT"),
                                                        ),
                                                        Text(
                                                          "${data.bundle.amount} ${box.read("currency_code")}",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          languagesController
                                                              .tr("DATE"),
                                                          style: TextStyle(
                                                            fontFamily:
                                                                box
                                                                        .read(
                                                                          "language",
                                                                        )
                                                                        .toString() ==
                                                                    "Fa"
                                                                ? Get.find<
                                                                        FontController
                                                                      >()
                                                                      .currentFont
                                                                : null,
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                            'yyyy-MM-dd',
                                                          ).format(
                                                            DateTime.parse(
                                                              data.createdAt
                                                                  .toString(),
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 5),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          languagesController
                                                              .tr("TIME"),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontFamily:
                                                                box
                                                                        .read(
                                                                          "language",
                                                                        )
                                                                        .toString() ==
                                                                    "Fa"
                                                                ? Get.find<
                                                                        FontController
                                                                      >()
                                                                      .currentFont
                                                                : null,
                                                          ),
                                                        ),
                                                        Text(
                                                          DateFormat(
                                                            'hh:mm a',
                                                          ).format(
                                                            DateTime.parse(
                                                              data.createdAt
                                                                  .toString(),
                                                            ),
                                                          ),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : customhistoryController.finalList.isEmpty
                            ? SizedBox()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemCount:
                                    customhistoryController.finalList.length,
                                itemBuilder: (context, index) {
                                  final data =
                                      customhistoryController.finalList[index];

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    width: screenWidth,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                      children: [
                                        ExpansionTile(
                                          key: Key(
                                            index.toString(),
                                          ), // Ensure state retention
                                          initiallyExpanded:
                                              expandedIndices[index],
                                          onExpansionChanged: (isExpanded) {
                                            expandedIndices[index] = isExpanded;
                                          },
                                          tilePadding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          title: Row(
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                      data
                                                          .bundle!
                                                          .service!
                                                          .company!
                                                          .companyLogo
                                                          .toString(),
                                                    ),
                                                    fit: BoxFit.fill,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.bundle!.bundleTitle
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  Text(
                                                    data.rechargebleAccount
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: expandedIndices[index]
                                              ? null
                                              : GestureDetector(
                                                  onTap: () {
                                                    expandedIndices[index] =
                                                        true;
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SizedBox(width: 5),
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .chevronDown,
                                                        size:
                                                            screenHeight *
                                                            0.022,
                                                        color: Color(
                                                          0xff1890FF,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        languagesController.tr(
                                                          "TRANSFER_STATUS",
                                                        ),
                                                      ),
                                                      Text(
                                                        data.status
                                                                    .toString() ==
                                                                "0"
                                                            ? languagesController
                                                                  .tr("PENDING")
                                                            : data.status
                                                                      .toString() ==
                                                                  "1"
                                                            ? languagesController
                                                                  .tr("SUCCESS")
                                                            : languagesController
                                                                  .tr(
                                                                    "REJECTED",
                                                                  ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        languagesController.tr(
                                                          "AMOUNT",
                                                        ),
                                                      ),
                                                      Text(
                                                        "${data.bundle.amount} ${box.read("currency_code")}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        languagesController.tr(
                                                          "DATE",
                                                        ),
                                                      ),
                                                      Text(
                                                        DateFormat(
                                                          'yyyy-MM-dd',
                                                        ).format(
                                                          DateTime.parse(
                                                            data.createdAt
                                                                .toString(),
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        languagesController.tr(
                                                          "TIME",
                                                        ),
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        DateFormat(
                                                          'hh:mm a',
                                                        ).format(
                                                          DateTime.parse(
                                                            data.createdAt
                                                                .toString(),
                                                          ),
                                                        ),
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
