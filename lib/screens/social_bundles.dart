import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/drawer_controller.dart';
import 'package:teknurpay/pages/homepages.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:teknurpay/widgets/drawer.dart';
import 'package:lottie/lottie.dart';
import 'package:teknurpay/controllers/bundle_controller.dart';
import 'package:teknurpay/controllers/confirm_pin_controller.dart';
import 'package:teknurpay/controllers/country_list_controller.dart';
import 'package:teknurpay/controllers/service_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/global_controller/page_controller.dart';
import 'package:teknurpay/helpers/price.dart';
import 'package:teknurpay/utils/colors.dart';

import '../global_controller/font_controller.dart';
import '../widgets/custom_text.dart';
import 'country_selection.dart';

class SocialBundles extends StatefulWidget {
  SocialBundles({super.key});

  @override
  State<SocialBundles> createState() => _SocialBundlesState();
}

class _SocialBundlesState extends State<SocialBundles> {
  final serviceController = Get.find<ServiceController>();

  final bundleController = Get.find<BundleController>();
  LanguagesController languagesController = Get.put(LanguagesController());

  // final confirmPinController = Get.find<ConfirmPinController>();

  final ScrollController scrollController = ScrollController();

  String search = "";
  String inputNumber = "";

  int selectedIndex = -1;
  int duration_selectedIndex = -1;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );

    bundleController.finalList.clear();
    bundleController.initialpage = 1;
    scrollController.addListener(refresh);
    // Use addPostFrameCallback to ensure this runs after the initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      serviceController.fetchservices();
      bundleController.fetchallbundles();
    });
  }

  Future<void> refresh() async {
    final int totalPages =
        bundleController.allbundleslist.value.payload?.pagination!.totalPages ??
        0;
    final int currentPage = bundleController.initialpage;

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
      bundleController.initialpage++;

      // Prevent fetching if the next page exceeds total pages
      if (bundleController.initialpage <= totalPages) {
        print("Load More...................");
        bundleController.fetchallbundles();
      } else {
        bundleController.initialpage =
            totalPages; // Reset to the last valid page
        print("Already on the last page");
      }
    }
  }

  List countryCode = ["+93", "+880", "+91"];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MyDrawerController drawerController = Get.put(MyDrawerController());

  @override
  Widget build(BuildContext context) {
    final Mypagecontroller mypagecontroller = Get.find();
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
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
                            // mypagecontroller.goBack();
                            bundleController.initialpage = 1;
                            bundleController.finalList.clear();
                            bundleController.fetchallbundles();
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
                            text:
                                "${languagesController.tr("COMMUNICATION_PACKAGES")}",
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

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Container(
                    width: screenWidth,

                    child: Padding(
                      padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Obx(
                              () =>
                                  bundleController.isLoading.value == false &&
                                      bundleController.finalList.isNotEmpty
                                  ? RefreshIndicator(
                                      onRefresh: refresh,
                                      child: ListView.separated(
                                        separatorBuilder: (context, index) {
                                          return SizedBox(height: 2);
                                        },
                                        padding: EdgeInsets.all(0),
                                        shrinkWrap: false,
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        controller: scrollController,
                                        itemCount:
                                            bundleController.finalList.length,
                                        itemBuilder: (context, index) {
                                          final data =
                                              bundleController.finalList[index];
                                          return GestureDetector(
                                            onTap: () {
                                              box.write(
                                                "bundleID",
                                                data.id.toString(),
                                              );
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            17,
                                                          ),
                                                    ),
                                                    content: SocialdialogBox(
                                                      companyname: data
                                                          .service!
                                                          .company!
                                                          .companyName
                                                          .toString(),
                                                      title: data.bundleTitle,
                                                      validity:
                                                          data.validityType,
                                                      buyingprice:
                                                          data.buyingPrice,
                                                      sellingprice:
                                                          data.sellingPrice,
                                                      imagelink: data
                                                          .service!
                                                          .company!
                                                          .companyLogo
                                                          .toString(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 3,
                                              ),
                                              child: Container(
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 0),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 5,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        data
                                                            .service!
                                                            .company!
                                                            .companyLogo
                                                            .toString(),
                                                        height: 60,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 3,
                                                            ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  data.bundleTitle
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                KText(
                                                                  text: data
                                                                      .service!
                                                                      .company!
                                                                      .companyName
                                                                      .toString(),
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 15,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Obx(
                                                                  () => KText(
                                                                    text: languagesController
                                                                        .tr(
                                                                          "SALE",
                                                                        ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  " : ",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                                PriceTextView(
                                                                  price: data
                                                                      .sellingPrice
                                                                      .toString(),
                                                                  textStyle: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Text(
                                                                  " ${box.read("currency_code")}",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Obx(
                                                                () => KText(
                                                                  text: languagesController
                                                                      .tr(
                                                                        "BUY",
                                                                      ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              Text(
                                                                " : ",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              PriceTextView(
                                                                price: data
                                                                    .buyingPrice
                                                                    .toString(),
                                                                textStyle: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Text(
                                                                " ${box.read("currency_code")}",
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : bundleController.finalList.isEmpty
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.grey,
                                      ),
                                    )
                                  : RefreshIndicator(
                                      onRefresh: refresh,
                                      child: ListView.separated(
                                        separatorBuilder: (context, index) {
                                          return SizedBox(height: 2);
                                        },
                                        padding: EdgeInsets.all(0),
                                        shrinkWrap: false,
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        controller: scrollController,
                                        itemCount:
                                            bundleController.finalList.length,
                                        itemBuilder: (context, index) {
                                          final data =
                                              bundleController.finalList[index];
                                          return GestureDetector(
                                            onTap: () {
                                              box.write(
                                                "bundleID",
                                                data.id.toString(),
                                              );
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.all(0),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            17,
                                                          ),
                                                    ),
                                                    content: SocialdialogBox(
                                                      companyname: data
                                                          .service!
                                                          .company!
                                                          .companyName
                                                          .toString(),
                                                      title: data.bundleTitle,
                                                      validity:
                                                          data.validityType,
                                                      buyingprice:
                                                          data.buyingPrice,
                                                      sellingprice:
                                                          data.sellingPrice,
                                                      imagelink: data
                                                          .service!
                                                          .company!
                                                          .companyLogo
                                                          .toString(),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 3,
                                              ),
                                              child: Container(
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 2,
                                                      offset: Offset(0, 0),
                                                    ),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 5,
                                                      ),
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        data
                                                            .service!
                                                            .company!
                                                            .companyLogo
                                                            .toString(),
                                                        height: 60,
                                                      ),
                                                      SizedBox(width: 5),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 3,
                                                            ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                KText(
                                                                  text: data
                                                                      .bundleTitle
                                                                      .toString(),
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 15,
                                                                ),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                KText(
                                                                  text: data
                                                                      .service!
                                                                      .company!
                                                                      .companyName
                                                                      .toString(),
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 15,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Obx(
                                                                  () => KText(
                                                                    text: languagesController
                                                                        .tr(
                                                                          "SALE",
                                                                        ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  " : ",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                                PriceTextView(
                                                                  price: data
                                                                      .sellingPrice
                                                                      .toString(),
                                                                  textStyle: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 3,
                                                                ),
                                                                Text(
                                                                  " ${box.read("currency_code")}",
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    color: Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Obx(
                                                                () => KText(
                                                                  text: languagesController
                                                                      .tr(
                                                                        "BUY",
                                                                      ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              Text(
                                                                " : ",
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                              PriceTextView(
                                                                price: data
                                                                    .buyingPrice
                                                                    .toString(),
                                                                textStyle: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              Text(
                                                                " ${box.read("currency_code")}",
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            ),
                          ),
                          Obx(
                            () => bundleController.isLoading.value == true
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ],
                                  )
                                : SizedBox(),
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
      ),
    );
  }
}

class SocialdialogBox extends StatefulWidget {
  SocialdialogBox({
    super.key,
    this.title,
    this.validity,
    this.buyingprice,
    this.sellingprice,
    this.imagelink,
    this.companyname,
  });

  String? companyname;
  String? title;
  String? validity;
  String? buyingprice;
  String? sellingprice;
  String? imagelink;

  @override
  State<SocialdialogBox> createState() => _SocialdialogBoxState();
}

class _SocialdialogBoxState extends State<SocialdialogBox> {
  String selectedCode = "+93";

  final countrylistController = Get.find<CountryListController>();

  final confirmPinController = Get.find<ConfirmPinController>();

  final box = GetStorage();

  final FocusNode _focusNode = FocusNode();

  LanguagesController languagesController = Get.put(LanguagesController());

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 360,
      width: screenWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 45, vertical: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: Colors.grey.shade300),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    children: [
                      KText(
                        text: widget.companyname.toString(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 15),
                      Image.network(widget.imagelink.toString(), height: 70),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          KText(
                            text: languagesController.tr("BUNDLE_TITLE"),
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          // Text(
                          //   widget.validity.toString(),
                          //   style: TextStyle(
                          //     color: Color(0xff1890FF),
                          //     fontSize: 14,
                          //   ),
                          // ),
                          Text(
                            widget.title.toString(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          KText(
                            text: languagesController.tr("BUY"),
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          Spacer(),
                          Text(
                            widget.buyingprice.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(width: 5),
                          KText(
                            text: box.read("currency_code"),
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          KText(
                            text: languagesController.tr("SALE"),
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          Spacer(),
                          Text(
                            widget.sellingprice.toString(),
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          SizedBox(width: 5),
                          Text(
                            box.read("currency_code"),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
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
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              contentPadding: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                              content: Container(
                                height: 200,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 55,
                                        width: screenWidth,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          child: Row(
                                            children: [
                                              // Phone Number Input Field
                                              Expanded(
                                                child: TextField(
                                                  controller:
                                                      confirmPinController
                                                          .numberController,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText:
                                                        languagesController.tr(
                                                          "PHONENUMBER",
                                                        ),
                                                    hintStyle: TextStyle(
                                                      color:
                                                          Colors.grey.shade400,
                                                      fontSize: 15,
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
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 30),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        child: Container(
                                          height: 50,
                                          width: screenWidth,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (confirmPinController
                                                        .numberController
                                                        .text
                                                        .isNotEmpty) {
                                                      Navigator.pop(context);
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    17,
                                                                  ),
                                                            ),
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            content: StatefulBuilder(
                                                              builder: (context, setState) {
                                                                return Container(
                                                                  height: 320,
                                                                  width:
                                                                      screenWidth,
                                                                  decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          17,
                                                                        ),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  child: Obx(
                                                                    () =>
                                                                        confirmPinController.isLoading.value ==
                                                                                false &&
                                                                            confirmPinController.loadsuccess.value ==
                                                                                false
                                                                        ? Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            children: [
                                                                              SizedBox(
                                                                                height: 100,
                                                                                child: Lottie.asset(
                                                                                  'assets/loties/pin.json',
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                height: 45,
                                                                                child: Obx(
                                                                                  () => Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        confirmPinController.isLoading.value ==
                                                                                                    false &&
                                                                                                confirmPinController.loadsuccess.value ==
                                                                                                    false
                                                                                            ? languagesController.tr(
                                                                                                "CONFIRM_YOUR_PIN",
                                                                                              )
                                                                                            : languagesController.tr(
                                                                                                "PLEASE_WAIT",
                                                                                              ),
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.w600,
                                                                                          fontSize: 15,
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: 7,
                                                                                      ),
                                                                                      confirmPinController.isLoading.value ==
                                                                                                  true &&
                                                                                              confirmPinController.loadsuccess.value ==
                                                                                                  true
                                                                                          ? Center(
                                                                                              child: CircularProgressIndicator(
                                                                                                color: Colors.black,
                                                                                              ),
                                                                                            )
                                                                                          : SizedBox(),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              // OTPInput(),
                                                                              Container(
                                                                                height: 40,
                                                                                width: 100,
                                                                                // color: Colors.red,
                                                                                child: TextField(
                                                                                  focusNode: _focusNode,
                                                                                  style: TextStyle(
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                  controller: confirmPinController.pinController,
                                                                                  maxLength: 4,
                                                                                  textAlign: TextAlign.center,
                                                                                  keyboardType: TextInputType.phone,
                                                                                  decoration: InputDecoration(
                                                                                    counterText: '',
                                                                                    focusedBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: Colors.grey,
                                                                                        width: 2.0,
                                                                                      ),
                                                                                    ),
                                                                                    enabledBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: Colors.grey,
                                                                                        width: 2.0,
                                                                                      ),
                                                                                    ),
                                                                                    errorBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: Colors.grey,
                                                                                        width: 2.0,
                                                                                      ),
                                                                                    ),
                                                                                    focusedErrorBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(
                                                                                        color: Colors.grey,
                                                                                        width: 2.0,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                              SizedBox(
                                                                                height: 30,
                                                                              ),

                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  GestureDetector(
                                                                                    onTap: () {
                                                                                      Navigator.pop(
                                                                                        context,
                                                                                      );
                                                                                      confirmPinController.pinController.clear();
                                                                                    },
                                                                                    child: Container(
                                                                                      height: 50,
                                                                                      width: 120,
                                                                                      decoration: BoxDecoration(
                                                                                        border: Border.all(
                                                                                          width: 1,
                                                                                          color: Colors.grey,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(
                                                                                          5,
                                                                                        ),
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: Text(
                                                                                          languagesController.tr(
                                                                                            "CANCEL",
                                                                                          ),
                                                                                          style: TextStyle(
                                                                                            color: Colors.black,
                                                                                            fontWeight: FontWeight.w500,
                                                                                            fontSize: 15,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 10,
                                                                                  ),
                                                                                  GestureDetector(
                                                                                    onTap: () async {
                                                                                      if (!confirmPinController.isLoading.value) {
                                                                                        if (confirmPinController.pinController.text.isEmpty ||
                                                                                            confirmPinController.pinController.text.length !=
                                                                                                4) {
                                                                                          Fluttertoast.showToast(
                                                                                            msg: languagesController.tr(
                                                                                              "ENTER_YOUR_PIN",
                                                                                            ),
                                                                                            toastLength: Toast.LENGTH_SHORT,
                                                                                            gravity: ToastGravity.BOTTOM,
                                                                                            timeInSecForIosWeb: 1,
                                                                                            backgroundColor: Colors.black,
                                                                                            textColor: Colors.white,
                                                                                            fontSize: 16.0,
                                                                                          );
                                                                                        } else {
                                                                                          await confirmPinController.verify(
                                                                                            context,
                                                                                          );
                                                                                          if (confirmPinController.loadsuccess.value ==
                                                                                              true) {
                                                                                            print(
                                                                                              "recharge Done...........",
                                                                                            );
                                                                                          }
                                                                                        }
                                                                                      }
                                                                                    },
                                                                                    child: Container(
                                                                                      width: 120,
                                                                                      height: 50,
                                                                                      decoration: BoxDecoration(
                                                                                        color: Color(
                                                                                          0xff04B75D,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(
                                                                                          10,
                                                                                        ),
                                                                                      ),
                                                                                      child: Stack(
                                                                                        children: [
                                                                                          Positioned.fill(
                                                                                            child: Container(
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(
                                                                                                  10,
                                                                                                ),
                                                                                                gradient: LinearGradient(
                                                                                                  begin: Alignment.topCenter,
                                                                                                  end: Alignment.bottomCenter,
                                                                                                  colors: [
                                                                                                    Colors.white.withOpacity(
                                                                                                      0.3,
                                                                                                    ),
                                                                                                    Colors.transparent,
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                              child: Center(
                                                                                                child: KText(
                                                                                                  text: languagesController.tr(
                                                                                                    "VERIFY",
                                                                                                  ),
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
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : Center(
                                                                            child: Container(
                                                                              height: 250,
                                                                              width: 250,
                                                                              child: Lottie.asset(
                                                                                'assets/loties/recharge.json',
                                                                              ),
                                                                            ),
                                                                          ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      Fluttertoast.showToast(
                                                        msg: languagesController
                                                            .tr(
                                                              "ENTER_PHONE_NUMBER",
                                                            ),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.black,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0,
                                                      );
                                                    }
                                                  },
                                                  child: Container(
                                                    width: double.maxFinite,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff04B75D),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Positioned.fill(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    10,
                                                                  ),
                                                              gradient: LinearGradient(
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomCenter,
                                                                colors: [
                                                                  Colors.white
                                                                      .withOpacity(
                                                                        0.3,
                                                                      ),
                                                                  Colors
                                                                      .transparent,
                                                                ],
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: KText(
                                                                text: languagesController.tr(
                                                                  "CONFIRMATION",
                                                                ),
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        languagesController.tr(
                                                          "CANCEL",
                                                        ),
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xff04B75D),
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
                                    colors: [
                                      Colors.white.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: KText(
                                    text: languagesController.tr(
                                      "CONFIRMATION",
                                    ),
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
                            languagesController.tr("CANCEL"),
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
