import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:intl/intl.dart';

import '../global_controller/time_zone_controller.dart';
import '../helpers/capture_image_helper.dart';

import '../helpers/localtime_helper.dart';
import '../helpers/share_image_helper.dart';

class OrderDetailsScreen extends StatefulWidget {
  OrderDetailsScreen({
    super.key,
    this.createDate,
    this.status,
    this.rejectReason,
    this.companyName,
    this.bundleTitle,
    this.rechargebleAccount,
    this.validityType,
    this.sellingPrice,
    this.buyingPrice,
    this.orderID,
    this.resellerName,
    this.resellerPhone,
    this.companyLogo,
    this.amount,
  });
  String? createDate;
  String? status;
  String? rejectReason;
  String? companyName;
  String? bundleTitle;
  String? rechargebleAccount;
  String? validityType;
  String? sellingPrice;
  String? buyingPrice;
  String? orderID;
  String? resellerName;
  String? resellerPhone;
  String? companyLogo;
  String? amount;
  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final TimeZoneController timeZoneController = Get.put(TimeZoneController());

  LanguagesController languagesController = Get.put(LanguagesController());

  final box = GetStorage();
  bool showprice = false;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[700],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF2C2C2C), // dark gray
              Color.fromARGB(255, 83, 82, 82), // lighter gray
            ],
          ),
        ),
        height: screenHeight,
        width: screenWidth,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RepaintBoundary(
                  key: catpureKey,
                  child: RepaintBoundary(
                    key: shareKey,
                    child: Container(
                      height: 450,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffE8F4FF),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(height: 8),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30,
                                      ),
                                      child: Container(
                                        height: 70,
                                        width: double.maxFinite,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                print(widget.status.toString());
                                              },
                                              child: Image.asset(
                                                "assets/icons/logo.png",
                                                height: 60,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        KText(
                                          text: widget.status.toString() == "0"
                                              ? languagesController.tr(
                                                  "PENDING",
                                                )
                                              : widget.status.toString() == "1"
                                              ? languagesController.tr(
                                                  "CONFIRMED",
                                                )
                                              : languagesController.tr(
                                                  "REJECTED",
                                                ),
                                          fontWeight: FontWeight.w600,
                                          color: widget.status.toString() == "0"
                                              ? Colors.black
                                              : widget.status.toString() == "1"
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 16,
                                        ),
                                        SizedBox(width: 20),
                                        Image.asset(
                                          widget.status.toString() == "0"
                                              ? "assets/icons/info-circle.png"
                                              : widget.status.toString() == "1"
                                              ? "assets/icons/confirmed.png"
                                              : "assets/icons/close-circle.png",
                                          height: 28,
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible: widget.status.toString() == "2",
                                      child: KText(
                                        text: widget.rejectReason.toString(),
                                        color: Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 40,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: NetworkImage(
                                                  widget.companyLogo.toString(),
                                                ),
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            widget.bundleTitle.toString(),
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xff212B36),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Spacer(),
                                          KText(
                                            text:
                                                widget.validityType
                                                        .toString() ==
                                                    "yearly"
                                                ? languagesController.tr(
                                                    "YEARLY",
                                                  )
                                                : widget.validityType
                                                          .toString() ==
                                                      "unlimited"
                                                ? languagesController.tr(
                                                    "UNLIMITED",
                                                  )
                                                : widget.validityType
                                                          .toString() ==
                                                      "monthly"
                                                ? languagesController.tr(
                                                    "MONTHLY",
                                                  )
                                                : widget.validityType
                                                          .toString() ==
                                                      "weekly"
                                                ? languagesController.tr(
                                                    "WEEKLY",
                                                  )
                                                : widget.validityType
                                                          .toString() ==
                                                      "daily"
                                                ? languagesController.tr(
                                                    "DAILY",
                                                  )
                                                : widget.validityType
                                                          .toString() ==
                                                      "hourly"
                                                ? languagesController.tr(
                                                    "HOURLY",
                                                  )
                                                : widget.validityType
                                                          .toString() ==
                                                      "nightly"
                                                ? languagesController.tr(
                                                    "NIGHTLY",
                                                  )
                                                : "",
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Color(0xff3E4094),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          KText(
                                            text: languagesController.tr(
                                              "ORDER_ID",
                                            ),
                                            fontSize: 14,
                                            color: Color(0xff637381),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          Text(
                                            "WT#- " + widget.orderID.toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xff212B36),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          KText(
                                            text: languagesController.tr(
                                              "DATE",
                                            ),
                                            fontSize: 14,
                                            color: Color(0xff637381),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          SizedBox(width: 5),
                                          convertToDate(
                                            widget.createDate.toString(),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          KText(
                                            text: languagesController.tr(
                                              "TIME",
                                            ),
                                            fontSize: 14,
                                            color: Color(0xff637381),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          SizedBox(width: 5),
                                          convertToLocalTime(
                                            widget.createDate.toString(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffE8F4FF),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          KText(
                                            text: languagesController.tr(
                                              "PHONE_NUMBER",
                                            ),
                                            fontSize: 14,
                                            color: Color(0xff637381),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              widget.rechargebleAccount
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xff212B36),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          KText(
                                            text: languagesController.tr(
                                              "SENDER",
                                            ),
                                            fontSize: 14,
                                            color: Color(0xff637381),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          SizedBox(width: 10),
                                          Flexible(
                                            child: KText(
                                              text: widget.resellerName
                                                  .toString(),
                                              fontSize: 14,
                                              color: Color(0xff212B36),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Visibility(
                                        visible: showprice,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            KText(
                                              text: languagesController.tr(
                                                "PRICE",
                                              ),
                                              fontSize: 14,
                                              color: Color(0xff637381),
                                              fontWeight: FontWeight.w400,
                                            ),
                                            Row(
                                              children: [
                                                KText(
                                                  text: box.read(
                                                    "currency_code",
                                                  ),
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  NumberFormat.currency(
                                                    locale: 'en_US',
                                                    symbol: '',
                                                    decimalDigits: 2,
                                                  ).format(
                                                    double.parse(
                                                      widget.sellingPrice
                                                          .toString(),
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                    color: Color(0xff212B36),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
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
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(20),
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showprice = !showprice;
                            });
                          },
                          child: Icon(
                            showprice
                                ? Icons.visibility
                                : Icons.visibility_off_outlined,
                            size: 35,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          height: 50,
                          width: double.maxFinite,
                          // color: Colors.red,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () async {
                                    capturePng();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Color(0xff2196F3),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: KText(
                                        text: languagesController.tr(
                                          "SAVE_TO_GALLERY",
                                        ),
                                        fontSize: 12,
                                        color: Color(0xff2196F3),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () async {
                                    captureImageFromWidgetAsFile(shareKey);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xff2196F3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: KText(
                                        text: languagesController.tr("SHARE"),
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: KText(
                                text: languagesController.tr("CLOSE"),
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }
}
