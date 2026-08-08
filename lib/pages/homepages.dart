import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:teknurpay/accounting/accounting_base.dart';
import 'package:teknurpay/controllers/notifications_controller.dart';
import 'package:teknurpay/pages/notification_details_page.dart';
import 'package:teknurpay/screens/all_notifications_page.dart';
import 'package:teknurpay/screens/financial_screen.dart';
import 'package:teknurpay/widgets/custom_text.dart';
import 'package:teknurpay/widgets/button.dart';
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
import '../controllers/categories_controller.dart';
import '../controllers/company_controller.dart';
import '../controllers/conversation_controller.dart';
import '../controllers/custom_recharge_controller.dart';
import '../global_controller/balance_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/page_controller.dart';
import '../models/country_list_model.dart';
import '../screens/country_selection.dart';
import '../screens/service_screen.dart';
import '../utils/colors.dart';
import '../widgets/bottomsheet.dart';
import 'package:intl/intl.dart';

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

  // final dashboardController = Get.find<DashboardController>();

  DashboardController dashboardController = Get.put(DashboardController());
  final bundleController = Get.find<BundleController>();

  final box = GetStorage();

  final confirmPinController = Get.find<ConfirmPinController>();

  final NumberFormat _formatter = NumberFormat('#,##0');

  LanguagesController languagesController = Get.put(LanguagesController());
  MyDrawerController drawerController = Get.put(MyDrawerController());
  NotificationController notificationController = Get.put(
    NotificationController(),
  );

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

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkforUpdate();
    notificationController.fetchData();

    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      var sliderItems =
          dashboardController
              .alldashboardData
              .value
              .data
              ?.advertisementSliders ??
          [];

      if (sliderItems.isEmpty) return;

      if (currentIndex.value < sliderItems.length - 1) {
        currentIndex.value++;
      } else {
        currentIndex.value = 0;
      }

      _pageController.animateToPage(
        currentIndex.value,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });

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
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    String formattedDate = DateFormat("dd MMM yyyy").format(DateTime.now());

    return Obx(() {
      if (dashboardController.isLoading.value) {
        return Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.grey)),
        );
      } else if (dashboardController.deactiveStatus.value
              .trim()
              .toLowerCase() ==
          "deactivated") {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  dashboardController.deactiveStatus.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
                  dashboardController.deactivateMessage.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 70),
                  child: GestureDetector(
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
                      height: 45,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/icons/whatsapp.png",
                            height: 30,
                            color: Colors.white,
                          ),
                          SizedBox(width: 20),
                          KText(
                            text: languagesController.tr("CONTACTUS"),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
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
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),
                      child: Text(
                        languagesController.tr("LOGOUT"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    dashboardController.fetchDashboardData();
                  },
                  child: Icon(Icons.refresh, size: 35),
                ),
              ],
            ),
          ),
        );
      } else {
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
                            Obx(() {
                              final unreadCount =
                                  notificationController.unreadlength.value;

                              return GestureDetector(
                                onTap: () {
                                  showNotificationPopup(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.black,
                                        size: 29,
                                      ),

                                      if (unreadCount > 0)
                                        Positioned(
                                          right: -7,
                                          top: -7,
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 19,
                                              minHeight: 19,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              unreadCount > 99
                                                  ? '99+'
                                                  : unreadCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => AccountingBaseScreen());
                              },

                              child: Icon(
                                Icons.account_balance,
                                color: AppColors.primaryColor,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                CustomFullScreenSheet.show(context);
                                // print(box.read("userToken"));
                              },
                              child: Image.asset(
                                "assets/icons/drawericon.png",
                                height: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    height: 140,
                    width: screenWidth,
                    child: Obx(() {
                      var sliderItems =
                          dashboardController
                              .alldashboardData
                              .value
                              .data!
                              .advertisementSliders ??
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

                          // reset timer
                          _timer?.cancel();
                          _timer = Timer.periodic(Duration(seconds: 3), (
                            Timer timer,
                          ) {
                            var sliderItems =
                                dashboardController
                                    .alldashboardData
                                    .value
                                    .data
                                    ?.advertisementSliders ??
                                [];

                            if (sliderItems.isEmpty) return;

                            if (currentIndex.value < sliderItems.length - 1) {
                              currentIndex.value++;
                            } else {
                              currentIndex.value = 0;
                            }

                            _pageController.animateToPage(
                              currentIndex.value,
                              duration: Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          });
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
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                            ),
                          );
                        },
                      );
                    }),
                  ),

                  // Dot indicator below the container
                  SizedBox(height: 8),
                  Obx(() {
                    var sliderItems =
                        dashboardController
                            .alldashboardData
                            .value
                            .data!
                            .advertisementSliders ??
                        [];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(sliderItems.length, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 3),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                            text: languagesController.tr(
                                              "BALANCE",
                                            ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Obx(
                                            () =>
                                                dashboardController
                                                        .isLoading
                                                        .value ==
                                                    false
                                                ? Text(
                                                    NumberFormat.currency(
                                                      locale: 'en_US',
                                                      symbol: '',
                                                      decimalDigits: 2,
                                                    ).format(
                                                      double.parse(
                                                        dashboardController
                                                            .userBalanceController
                                                            .balance
                                                            .toString(),
                                                      ),
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                : SizedBox(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: DefaultButton1(
                      height: 50,
                      buttonName: languagesController.tr(
                        "AFGHANISTAN_RECHARGE",
                      ),
                      onpressed: () {
                        Country? afghanistan;

                        if (countryListController.finalCountryList.isNotEmpty) {
                          try {
                            afghanistan = countryListController.finalCountryList
                                .firstWhere(
                                  (country) =>
                                      country.countryName
                                          ?.trim()
                                          .toLowerCase() ==
                                      "afghanistan",
                                );
                          } catch (e) {
                            afghanistan = null;
                          }

                          if (afghanistan != null) {
                            print(
                              "The ID for Afghanistan is: ${afghanistan.id}",
                            );

                            box.write("country_id", afghanistan.id);

                            box.write(
                              "countryName",
                              afghanistan.countryName ?? "Afghanistan",
                            );

                            box.write(
                              "maxlength",
                              afghanistan.phoneNumberLength ?? "10",
                            );

                            box.write(
                              "enable_operator_lookup",
                              afghanistan.enableOperatorLookup,
                            );

                            box.write("validity_type", "");
                            box.write("company_id", "");
                            box.write("search_tag", "");
                          } else {
                            print("Afghanistan not found in the country list.");
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
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
                                          final icon =
                                              icons[index % icons.length];
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Text(
                                                    data.categoryName
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize:
                                                          screenHeight * 0.015,
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
    });
  }

  void showNotificationPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return Dialog(
          alignment: Alignment.topRight,
          insetPadding: const EdgeInsets.only(
            top: 70,
            right: 15,
            left: 25,
            bottom: 30,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(maxHeight: 480),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Obx(() {
              final isLoading = notificationController.isLoading.value;

              final notifications =
                  notificationController
                      .allnotificationlist
                      .value
                      .data
                      ?.notifications ??
                  [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 12, 12),
                    child: Row(
                      children: [
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.primaryColor,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            languagesController.tr("NOTIFICATIONS"),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

                  if (isLoading)
                    const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (notifications.isEmpty)
                    SizedBox(
                      height: 250,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 55,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            languagesController.tr("NO_NOTIFICATIONS"),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,

                        // Popup-এ শুধু latest 10 notifications দেখাবে
                        itemCount: notifications.length > 10
                            ? 10
                            : notifications.length,

                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 1,
                            thickness: 1,
                            indent: 70,
                            color: Colors.grey.shade200,
                          );
                        },

                        itemBuilder: (context, index) {
                          final notification = notifications[index];

                          return InkWell(
                            onTap: () async {
                              Get.back();

                              await Get.to(
                                () => NotificationDetailsPage(
                                  notification: notification,
                                ),
                              );

                              await notificationController.fetchData();
                            },
                            child: Container(
                              color: notification.isRead == false
                                  ? AppColors.primaryColor.withOpacity(0.05)
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 13,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        height: 43,
                                        width: 43,
                                        decoration: BoxDecoration(
                                          color: notification.isRead == false
                                              ? AppColors.primaryColor
                                                    .withOpacity(0.13)
                                              : Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.notifications_rounded,
                                          size: 21,
                                          color: notification.isRead == false
                                              ? AppColors.primaryColor
                                              : Colors.grey,
                                        ),
                                      ),

                                      if (notification.isRead == false)
                                        Positioned(
                                          right: 1,
                                          top: 1,
                                          child: Container(
                                            height: 9,
                                            width: 9,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title ?? "",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                                notification.isRead == false
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          notification.message ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.4,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          notification.createdAt == null
                                              ? ""
                                              : DateFormat(
                                                  "dd MMM yyyy, hh:mm a",
                                                ).format(
                                                  notification.createdAt!
                                                      .toLocal(),
                                                ),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();

                          await Get.to(() => const AllNotificationsPage());

                          await notificationController.fetchData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          languagesController.tr("VIEW_ALL"),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
