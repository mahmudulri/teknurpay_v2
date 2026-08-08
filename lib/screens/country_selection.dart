import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/bundle_controller.dart';
import 'package:teknurpay/controllers/country_list_controller.dart';
import 'package:teknurpay/controllers/dashboard_controller.dart';
import 'package:teknurpay/controllers/drawer_controller.dart';
import 'package:teknurpay/controllers/service_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/models/country_list_model.dart';
import 'package:teknurpay/pages/homepages.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:teknurpay/widgets/drawer.dart';

import '../global_controller/page_controller.dart';
import '../utils/colors.dart';
import 'recharge_screen.dart';

class InternetPack extends StatefulWidget {
  InternetPack({super.key});

  @override
  State<InternetPack> createState() => _InternetPackState();
}

class _InternetPackState extends State<InternetPack> {
  LanguagesController languagesController = Get.put(LanguagesController());

  CountryListController countrylistController = Get.put(
    CountryListController(),
  );

  BundleController bundleController = Get.put(BundleController());

  ServiceController serviceController = Get.put(ServiceController());

  MyDrawerController drawerController = Get.put(MyDrawerController());

  // final countrylistController = Get.find<CountryListController>();
  final box = GetStorage();

  // final serviceController = Get.find<ServiceController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final Mypagecontroller mypagecontroller = Get.find();

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
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
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
                        () => Text(
                          languagesController.tr("COUNTRY_SELECTION"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                            color: Colors.black,
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
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 6,
                      blurRadius: 6,
                      offset: Offset(0, 0),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Obx(
                    () => countrylistController.isLoading.value == false
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Obx(
                                    () => Text(
                                      languagesController.tr("BOOKING_FOR"),
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.040,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontFamily:
                                            languagesController.selectedlan ==
                                                "Fa"
                                            ? "Iranfont"
                                            : "Roboto",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                      childAspectRatio: 1.5,
                                    ),
                                itemCount: countrylistController
                                    .finalCountryList
                                    .length,
                                itemBuilder: (context, index) {
                                  final Country data = countrylistController
                                      .finalCountryList[index];

                                  return GestureDetector(
                                    onTap: () {
                                      final Country selectedCountry =
                                          countrylistController
                                              .finalCountryList[index];

                                      final bool enableOperatorLookup =
                                          selectedCountry.enableOperatorLookup;

                                      box.write(
                                        "country_id",
                                        selectedCountry.id,
                                      );

                                      box.write(
                                        "countryName",
                                        selectedCountry.countryName ?? "",
                                      );

                                      box.write(
                                        "maxlength",
                                        selectedCountry.phoneNumberLength ?? "",
                                      );

                                      // গুরুত্বপূর্ণ: lookup value storage-এও save করছি
                                      box.write(
                                        "enable_operator_lookup",
                                        enableOperatorLookup,
                                      );

                                      box.write("validity_type", "");
                                      box.write("company_id", "");
                                      box.write("search_tag", "");

                                      serviceController.reserveDigit.clear();
                                      bundleController.resetBundles();

                                      print(
                                        "Selected country: ${selectedCountry.countryName}",
                                      );
                                      print(
                                        "Selected lookup value: $enableOperatorLookup",
                                      );
                                      print(
                                        "Stored lookup value: ${box.read("enable_operator_lookup")}",
                                      );

                                      mypagecontroller.changePage(
                                        RechargeScreen(
                                          enableOperatorLookup:
                                              enableOperatorLookup,
                                        ),
                                        isMainPage: false,
                                      );
                                    },
                                    child: InnerShadow(
                                      shadows: [
                                        Shadow(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 5,
                                          offset: const Offset(3, 0),
                                        ),
                                        Shadow(
                                          color: AppColors.primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 5,
                                          offset: const Offset(0, -3),
                                        ),
                                      ],
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor: Colors.grey,
                                                backgroundImage: NetworkImage(
                                                  data.countryFlagImageUrl ??
                                                      "",
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                data.countryName ?? "",
                                                style: TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize:
                                                      screenHeight * 0.020,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        : const Center(child: CircularProgressIndicator()),
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
