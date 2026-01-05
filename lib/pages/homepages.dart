import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:teknurpay/screens/financial_screen.dart';
import 'package:teknurpay/widgets/custom_text.dart';
import 'package:teknurpay/widgets/button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/bundle_controller.dart';
import 'package:teknurpay/controllers/confirm_pin_controller.dart';
import 'package:teknurpay/controllers/country_list_controller.dart';
import 'package:teknurpay/controllers/dashboard_controller.dart';
import 'package:teknurpay/controllers/drawer_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/screens/credit_transfer.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/categories_controller.dart';
import '../controllers/company_controller.dart';
import '../controllers/conversation_controller.dart';
import '../controllers/custom_recharge_controller.dart';
import '../controllers/history_controller.dart';
import '../controllers/slider_controller.dart';
import '../global_controller/balance_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/page_controller.dart';
import '../screens/country_selection.dart';
import '../screens/order_details_screen.dart';
import '../screens/service_screen.dart';
import '../screens/social_bundles.dart';
import '../utils/colors.dart';

class Homepages extends StatefulWidget {
  Homepages({super.key});

  @override
  State<Homepages> createState() => _HomepagesState();
}

class _HomepagesState extends State<Homepages> {
  List mycolor = [
    Color(0xffF4EBFC),
    Color(0xff7D9AFF).withOpacity(0.14),
    Color(0xffE9F2ED),
    Color(0xffFBF5F1),
    Color(0xffEAFBFB),
    Color(0xffF7FBEF),
  ];

  final List<String> icons = [
    "assets/icons/sim.png",
    "assets/icons/social-bundles.png",
    "assets/icons/dataplan.png",
    "assets/icons/credit-transfer.png",
    "assets/icons/callsmsplan.png",
  ];

  final dashboardController = Get.find<DashboardController>();
  final bundleController = Get.find<BundleController>();

  final box = GetStorage();

  final sliderController = Get.find<SliderController>();

  final confirmPinController = Get.find<ConfirmPinController>();

  LanguagesController languagesController = Get.put(LanguagesController());
  MyDrawerController drawerController = Get.put(MyDrawerController());

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CountryListController countrylistController = Get.put(
    CountryListController(),
  );

  final categorisListController = Get.find<CategorisListController>();

  final countryListController = Get.find<CountryListController>();

  UserBalanceController userBalanceController = Get.put(
    UserBalanceController(),
  );

  // var items = <Map<String, String>>[].obs;
  List<Map<String, String>> get items {
    return [
      {
        'name': languagesController.tr("BALANCE"),
        'icon': 'assets/icons/balance2.png',
      },
      {
        'name': languagesController.tr("DEBIT"),
        'icon': 'assets/icons/debit.png',
      },
      {
        'name': languagesController.tr("PROFIT"),
        'icon': 'assets/icons/profit2.png',
      },
      {
        'name': languagesController.tr("SALE"),
        'icon': 'assets/icons/profit2.png',
      },
      {
        'name': languagesController.tr("COMISSION"),
        'icon': 'assets/icons/profit2.png',
      },
    ];
  }

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkforUpdate();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );
    companyController.fetchCompany();

    countrylistController.fetchCountryData();
    dashboardController.fetchDashboardData();
    categorisListController.fetchcategories();
  }

  Future<void> _checkforUpdate() async {
    print("checking");
    await InAppUpdate.checkForUpdate()
        .then((info) {
          setState(() {
            if (info.updateAvailability == UpdateAvailability.updateAvailable) {
              print("update available");
              _update();
            }
          });
        })
        .catchError((error) {
          print(error.toString());
        });
  }

  void _update() async {
    print("Updating");
    await InAppUpdate.startFlexibleUpdate();
    InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((error) {
      print(error.toString());
    });
  }

  final companyController = Get.find<CompanyController>();
  ConversationController conversationController = Get.put(
    ConversationController(),
  );
  CustomRechargeController customRechargeController = Get.put(
    CustomRechargeController(),
  );

  final PageController _pageController = PageController();
  final Mypagecontroller mypagecontroller = Get.find();
  var currentIndex = 0.obs;

  @override
  Widget build(BuildContext context) {
    conversationController.resetConversion();
    customRechargeController.amountController.clear();
    confirmPinController.numberController.clear();

    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    String formattedDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    return SafeArea(
      child: Scaffold(
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
                        Obx(() {
                          final profileImageUrl = dashboardController
                              .alldashboardData
                              .value
                              .data
                              ?.userInfo
                              ?.profileImageUrl;

                          if (dashboardController.isLoading.value ||
                              profileImageUrl == null ||
                              profileImageUrl.isEmpty) {
                            return Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 30,
                              ),
                            );
                          }

                          return Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(profileImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }),
                        SizedBox(width: 10),
                        Obx(
                          () => dashboardController.isLoading.value == false
                              ? Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        KText(
                                          text: dashboardController
                                              .alldashboardData
                                              .value
                                              .data!
                                              .userInfo!
                                              .resellerName
                                              .toString(),
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),

                                        // only for reseller...................
                                        Visibility(
                                          visible:
                                              dashboardController
                                                      .alldashboardData
                                                      .value
                                                      .data
                                                      ?.resellerGroup !=
                                                  null &&
                                              dashboardController
                                                      .alldashboardData
                                                      .value
                                                      .data!
                                                      .resellerGroup !=
                                                  "null",
                                          child: Text(
                                            dashboardController
                                                    .alldashboardData
                                                    .value
                                                    .data
                                                    ?.resellerGroup ??
                                                '',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : SizedBox(),
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
              GestureDetector(
                onTap: () {
                  companyController.fetchCompany();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  height: 140,
                  width: screenWidth,
                  child: Obx(() {
                    var sliderItems =
                        sliderController
                            .allsliderlist
                            .value
                            .data
                            ?.advertisements ??
                        [];

                    if (sliderItems.isEmpty) {
                      return Container(
                        alignment: Alignment.center,
                        child: const Text(""),
                      );
                    }

                    return PageView.builder(
                      controller: _pageController,
                      itemCount: sliderItems.length,
                      onPageChanged: (index) {
                        currentIndex.value = index;
                      },
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            sliderItems[index].adSliderImageUrl ?? "",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),

              // Dot indicator below the container
              const SizedBox(height: 8),
              Obx(() {
                var sliderItems =
                    sliderController.allsliderlist.value.data?.advertisements ??
                    [];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(sliderItems.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: currentIndex.value == index ? 10 : 7,
                      height: currentIndex.value == index ? 10 : 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex.value == index
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    );
                  }),
                );
              }),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: () {
                    mypagecontroller.changePage(
                      FinancialScreen(),
                      isMainPage: false,
                    );
                  },
                  child: Container(
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              KText(
                                text: languagesController.tr(
                                  "FINANCIAL_REPORT",
                                ),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              KText(
                                text: languagesController.tr("SEE_ALL"),
                                color: AppColors.primarycolor2,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          Container(
                            width: screenWidth,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryColor
                                          .withOpacity(0.50),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(7.0),
                                      child: Image.asset(
                                        "assets/icons/wallet.png",
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      KText(
                                        text: languagesController.tr("BALANCE"),
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: AppColors.fontColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        dashboardController
                                            .userBalanceController
                                            .balance
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      KText(
                                        text: box.read("currency_code"),
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ],
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
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: DefaultButton1(
                  height: 50,
                  buttonName: languagesController.tr("CREDIT_TRANSFER"),
                  onpressed: () {
                    if (countryListController.finalCountryList.isNotEmpty) {
                      // Find the country where the name is "Afghanistan"
                      var afghanistan = countryListController.finalCountryList
                          .firstWhere(
                            (country) =>
                                country['country_name'] == "Afghanistan",
                            orElse: () => null, // Return null if not found
                          );

                      if (afghanistan != null) {
                        print(
                          "The ID for Afghanistan is: ${afghanistan['id']}",
                        );
                        box.write("country_id", "${afghanistan['id']}");
                        box.write("maxlength", "10");
                      } else {
                        print("Afghanistan not found in the list");
                      }
                    } else {
                      print("Country list is empty.");
                    }

                    mypagecontroller.changePage(
                      CreditTransfer(),
                      isMainPage: false,
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: screenWidth,
                  child: Obx(
                    () => categorisListController.isLoading.value == false
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    physics: BouncingScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              3, // Number of columns in the grid
                                          crossAxisSpacing:
                                              7.0, // Spacing between columns
                                          mainAxisSpacing:
                                              7.0, // Spacing between rows
                                          childAspectRatio: 1.0,
                                        ),
                                    itemCount: categorisListController
                                        .allcategorieslist
                                        .value
                                        .data!
                                        .servicecategories!
                                        .length,
                                    itemBuilder: (context, index) {
                                      final data = categorisListController
                                          .allcategorieslist
                                          .value
                                          .data!
                                          .servicecategories![index];
                                      final color =
                                          mycolor[index % mycolor.length];
                                      final icon = icons[index % icons.length];
                                      return GestureDetector(
                                        onTap: () {
                                          box.write(
                                            "service_category_id",
                                            categorisListController
                                                .allcategorieslist
                                                .value
                                                .data!
                                                .servicecategories![index]
                                                .id,
                                          );

                                          if (data.type.toString() ==
                                              "nonsocial") {
                                            mypagecontroller.changePage(
                                              InternetPack(),
                                              isMainPage: false,
                                            );
                                          } else {
                                            box.write("validity_type", "");

                                            box.write("search_tag", "");
                                            box.write(
                                              "service_category_id",
                                              categorisListController
                                                  .allcategorieslist
                                                  .value
                                                  .data!
                                                  .servicecategories![index]
                                                  .id,
                                            );

                                            box.write("country_id", "");
                                            box.write("company_id", "");

                                            // mypagecontroller.changePage(
                                            //   SocialBundles(),
                                            //   isMainPage: false,
                                            // );

                                            mypagecontroller.changePage(
                                              ServiceScreen(),
                                              isMainPage: false,
                                            );
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                data.categoryName.toString(),
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize:
                                                      screenHeight * 0.015,
                                                  fontFamily:
                                                      box
                                                              .read("language")
                                                              .toString() ==
                                                          "Fa"
                                                      ? Get.find<
                                                              FontController
                                                            >()
                                                            .currentFont
                                                      : null,
                                                ),
                                              ),
                                              data.categoryImageUrl
                                                          .toString() ==
                                                      "null"
                                                  ? Image.asset(
                                                      icon,
                                                      height: 50,
                                                    )
                                                  : Image.network(
                                                      data.categoryImageUrl
                                                          .toString(),
                                                      height: 50,
                                                    ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Center(child: CircularProgressIndicator()),
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
