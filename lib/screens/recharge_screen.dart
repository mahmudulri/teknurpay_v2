import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/drawer_controller.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:lottie/lottie.dart';
import 'package:teknurpay/controllers/bundle_controller.dart';
import 'package:teknurpay/controllers/confirm_pin_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/helpers/price.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:teknurpay/widgets/number_textfield.dart';
import '../controllers/service_controller.dart';
import '../global_controller/page_controller.dart';
import '../widgets/custom_text.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key, required this.enableOperatorLookup});

  final bool enableOperatorLookup;

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final LanguagesController languagesController = Get.put(
    LanguagesController(),
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GetStorage box = GetStorage();

  final ScrollController scrollController = ScrollController();

  final ConfirmPinController confirmPinController =
      Get.find<ConfirmPinController>();

  final ServiceController serviceController = Get.find<ServiceController>();

  final BundleController bundleController = Get.find<BundleController>();

  final MyDrawerController drawerController = Get.put(MyDrawerController());

  int selectedIndex = -1;
  int duration_selectedIndex = 0;

  List<Map<String, String>> duration = [];

  String search = "";
  String inputNumber = "";
  bool isOperatorLookupConfirmed = false;

  Timer? _lookupDebounce;

  String? originalCompanyId;
  String? detectedCompanyId;

  bool get isOperatorLookupEnabled {
    final dynamic storedValue = box.read("enable_operator_lookup");

    if (storedValue is bool) {
      return storedValue;
    }

    if (storedValue is int) {
      return storedValue == 1;
    }

    final String normalizedValue =
        storedValue?.toString().trim().toLowerCase() ?? "";

    if (normalizedValue == "true" ||
        normalizedValue == "1" ||
        normalizedValue == "yes") {
      return true;
    }

    if (normalizedValue == "false" ||
        normalizedValue == "0" ||
        normalizedValue == "no") {
      return false;
    }

    return widget.enableOperatorLookup;
  }

  void initializeDuration() {
    duration = [
      {"Name": languagesController.tr("All"), "Value": ""},
      {"Name": languagesController.tr("UNLIMITED"), "Value": "unlimited"},
      {"Name": languagesController.tr("MONTHLY"), "Value": "monthly"},
      {"Name": languagesController.tr("WEEKLY"), "Value": "weekly"},
      {"Name": languagesController.tr("DAILY"), "Value": "daily"},
      {"Name": languagesController.tr("HOURLY"), "Value": "hourly"},
      {"Name": languagesController.tr("NIGHTLY"), "Value": "nightly"},
    ];
  }

  int get _maximumPhoneLength {
    final dynamic storedLength = box.read("maxlength");

    return int.tryParse(storedLength?.toString() ?? "") ?? 0;
  }

  Future<void> refresh() async {
    if (bundleController.isLoading.value ||
        bundleController.isLookupLoading.value) {
      return;
    }

    if (!scrollController.hasClients) {
      return;
    }

    final bool reachedBottom =
        scrollController.position.pixels >=
        scrollController.position.maxScrollExtent;

    if (!reachedBottom) return;

    if (isOperatorLookupEnabled) {
      return;
    }

    final int totalPages =
        bundleController.allbundleslist.value.payload?.pagination.totalPages ??
        0;

    if (bundleController.initialpage >= totalPages) {
      return;
    }

    bundleController.initialpage++;

    await bundleController.fetchallbundles();
  }

  void _onTextChanged() {
    if (!mounted) return;

    final String number = confirmPinController.numberController.text.trim();

    final int requiredLength = _maximumPhoneLength;

    final services =
        serviceController.allserviceslist.value.data?.services ?? [];

    String? matchedOriginalCompanyId;

    // Prefix অনুযায়ী original operator detect
    for (final service in services) {
      final companyCodes = service.company?.companycodes ?? [];

      for (final code in companyCodes) {
        final String reservedDigit =
            code.reservedDigit?.toString().trim() ?? "";

        if (reservedDigit.isEmpty) {
          continue;
        }

        final String normalizedNumber = number.startsWith("0")
            ? number.substring(1)
            : number;

        final String normalizedReservedDigit = reservedDigit.startsWith("0")
            ? reservedDigit.substring(1)
            : reservedDigit;

        final bool prefixMatched =
            number.startsWith(reservedDigit) ||
            normalizedNumber.startsWith(normalizedReservedDigit);

        if (prefixMatched) {
          matchedOriginalCompanyId = service.companyId?.toString();

          break;
        }
      }

      if (matchedOriginalCompanyId != null) {
        break;
      }
    }

    _lookupDebounce?.cancel();

    setState(() {
      inputNumber = number;
      originalCompanyId = matchedOriginalCompanyId;

      // নতুন number typing শুরু হলে পুরোনো lookup result reset
      detectedCompanyId = null;
      isOperatorLookupConfirmed = false;
    });

    print("Original company id: $originalCompanyId");

    if (!isOperatorLookupEnabled) {
      _handleNormalNumber(number);
      return;
    }

    // Number empty
    if (number.isEmpty) {
      setState(() {
        originalCompanyId = null;
        detectedCompanyId = null;
        isOperatorLookupConfirmed = false;
        selectedIndex = -1;
      });

      bundleController.initialpage = 1;
      bundleController.finalList.clear();

      bundleController.fetchallbundles();
      return;
    }

    /*
   * Full number না হওয়া পর্যন্ত lookup API call হবে না।
   * শুধু prefix অনুযায়ী original operator দেখা যাবে।
   */
    if (requiredLength <= 0 || number.length != requiredLength) {
      print(
        "Waiting for full number: "
        "${number.length}/$requiredLength",
      );

      return;
    }

    // Full number হলে lookup API call
    _lookupDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;

      final String requestedNumber = confirmPinController.numberController.text
          .trim();

      if (requestedNumber.length != requiredLength) {
        return;
      }

      bundleController.initialpage = 1;
      bundleController.finalList.clear();

      try {
        await bundleController.fetchlookupbundles(requestedNumber);

        if (!mounted) return;

        final String latestNumber = confirmPinController.numberController.text
            .trim();

        // API response আসার আগে number change হলে ignore
        if (latestNumber != requestedNumber) {
          return;
        }

        String? lookupCompanyId;

        if (bundleController.finalList.isNotEmpty) {
          final firstBundle = bundleController.finalList.first;

          lookupCompanyId = firstBundle.service?.company?.id?.toString();
        }

        setState(() {
          detectedCompanyId = lookupCompanyId;

          // API response শেষ হওয়ার পরেই confirmed হবে
          isOperatorLookupConfirmed = lookupCompanyId != null;
        });

        final bool isPorted =
            isOperatorLookupConfirmed &&
            originalCompanyId != null &&
            detectedCompanyId != null &&
            originalCompanyId != detectedCompanyId;

        print("Full number lookup completed");

        print(
          "Original company id: "
          "$originalCompanyId",
        );

        print(
          "Detected company id: "
          "$detectedCompanyId",
        );

        print("Is ported number: $isPorted");
      } catch (e) {
        if (!mounted) return;

        setState(() {
          detectedCompanyId = null;
          isOperatorLookupConfirmed = false;
        });

        print("Operator lookup failed: $e");
      }
    });
  }

  void _handleNormalNumber(String number) {
    _lookupDebounce?.cancel();

    if (number.isEmpty) {
      box.write("company_id", "");

      selectedIndex = -1;

      bundleController.initialpage = 1;
      bundleController.finalList.clear();

      bundleController.fetchallbundles();

      return;
    }

    if (number.length != 3 && number.length != 4) {
      return;
    }

    final services =
        serviceController.allserviceslist.value.data?.services ?? [];

    bool matchFound = false;

    for (final service in services) {
      final companyCodes = service.company?.companycodes ?? [];

      for (final code in companyCodes) {
        final String reservedDigit = code.reservedDigit?.toString() ?? "";

        print(
          "Checking reservedDigit: "
          "$reservedDigit",
        );

        if (reservedDigit == number) {
          box.write("company_id", service.companyId);

          bundleController.initialpage = 1;
          bundleController.finalList.clear();

          bundleController.fetchallbundles();

          print(
            "Matched company_id: "
            "${service.companyId} "
            "with input: $number",
          );

          matchFound = true;
          break;
        }
      }

      if (matchFound) {
        break;
      }
    }

    if (!matchFound) {
      print(
        "No company matched for input: "
        "$number",
      );
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    initializeDuration();

    bundleController.resetBundles();

    confirmPinController.pinController.clear();
    confirmPinController.numberController.clear();

    box.write("company_id", "");

    serviceController.fetchservices();

    bundleController.fetchallbundles();

    confirmPinController.numberController.addListener(_onTextChanged);

    scrollController.addListener(refresh);
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();

    confirmPinController.numberController.removeListener(_onTextChanged);

    scrollController.removeListener(refresh);
    scrollController.dispose();

    super.dispose();
  }

  // তোমার existing build() method এখানে থাকবে।

  @override
  Widget build(BuildContext context) {
    print(box.read("enable_operator_lookup"));
    print(widget.enableOperatorLookup);
    final Mypagecontroller mypagecontroller = Get.find();
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          mypagecontroller.goBack();
                          confirmPinController.numberController.clear();
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
                              " ${box.read("countryName")} ${languagesController.tr("INTERNET_PACKAGE")}",
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.040,
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Obx(
                        () => CustomTextField(
                          confirmPinController:
                              confirmPinController.numberController,
                          languageData: languagesController.tr(
                            "ENTER_PHONE_NUMBER",
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 62,
                        color: Colors.transparent,
                        width: screenWidth,
                        child: Obx(() {
                          // Check if the allserviceslist is not null and contains data
                          final services =
                              serviceController
                                  .allserviceslist
                                  .value
                                  .data
                                  ?.services ??
                              [];

                          final bool isFullNumber =
                              _maximumPhoneLength > 0 &&
                              inputNumber.length == _maximumPhoneLength;

                          final filteredServices = inputNumber.isEmpty
                              ? services
                              : isOperatorLookupEnabled
                              ? services.where((service) {
                                  final String currentCompanyId =
                                      service.companyId?.toString() ?? "";

                                  final bool isOriginal =
                                      originalCompanyId != null &&
                                      currentCompanyId == originalCompanyId;

                                  final bool isDetected =
                                      isFullNumber &&
                                      isOperatorLookupConfirmed &&
                                      detectedCompanyId != null &&
                                      currentCompanyId == detectedCompanyId;

                                  return isOriginal || isDetected;
                                }).toList()
                              : services.where((service) {
                                  return service.company?.companycodes?.any((
                                        code,
                                      ) {
                                        final String reservedDigit =
                                            code.reservedDigit?.toString() ??
                                            "";

                                        return reservedDigit.isNotEmpty &&
                                            inputNumber.startsWith(
                                              reservedDigit,
                                            );
                                      }) ??
                                      false;
                                }).toList();

                          return serviceController.isLoading.value == false
                              ? Center(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    separatorBuilder: (context, index) {
                                      return SizedBox(width: 5);
                                    },
                                    scrollDirection: Axis.horizontal,
                                    itemCount: filteredServices.length,
                                    itemBuilder: (context, index) {
                                      final data = filteredServices[index];

                                      final String currentCompanyId =
                                          data.companyId?.toString() ?? "";

                                      final bool isDetectedOperator =
                                          isOperatorLookupEnabled &&
                                          isOperatorLookupConfirmed &&
                                          inputNumber.length ==
                                              _maximumPhoneLength &&
                                          detectedCompanyId != null &&
                                          currentCompanyId == detectedCompanyId;
                                      final bool isPorted =
                                          isOperatorLookupConfirmed &&
                                          inputNumber.length ==
                                              _maximumPhoneLength &&
                                          originalCompanyId != null &&
                                          detectedCompanyId != null &&
                                          originalCompanyId !=
                                              detectedCompanyId;

                                      final bool showPortedBadge =
                                          isDetectedOperator && isPorted;
                                      final bool isSelected =
                                          isOperatorLookupEnabled &&
                                              isOperatorLookupConfirmed &&
                                              inputNumber.length ==
                                                  _maximumPhoneLength
                                          ? isDetectedOperator
                                          : selectedIndex == index;

                                      return GestureDetector(
                                        onTap: () async {
                                          final bool isFullNumber =
                                              _maximumPhoneLength > 0 &&
                                              inputNumber.length ==
                                                  _maximumPhoneLength;

                                          final bool
                                          shouldLockOperatorSelection =
                                              isOperatorLookupEnabled &&
                                              isFullNumber &&
                                              isOperatorLookupConfirmed;

                                          if (shouldLockOperatorSelection) {
                                            return;
                                          }

                                          setState(() {
                                            bundleController.initialpage = 1;
                                            bundleController.finalList.clear();

                                            selectedIndex = index;

                                            box.write(
                                              "company_id",
                                              data.companyId,
                                            );
                                          });

                                          await bundleController
                                              .fetchallbundles();
                                        },
                                        child: SizedBox(
                                          width: showPortedBadge ? 67 : 52,
                                          height: 62,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                left: 1,
                                                bottom: 1,
                                                child: Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? const Color(
                                                            0xffFFFFFF,
                                                          )
                                                        : Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: showPortedBadge
                                                          ? Colors.orange
                                                          : Colors.transparent,
                                                      width: showPortedBadge
                                                          ? 1.5
                                                          : 0,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    5,
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        data
                                                            .company
                                                            ?.companyLogo ??
                                                        "",
                                                    fit: BoxFit.contain,
                                                    placeholder: (_, __) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 1,
                                                            ),
                                                      );
                                                    },
                                                    errorWidget: (_, __, ___) {
                                                      return const Icon(
                                                        Icons.error_outline,
                                                        size: 20,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),

                                              if (showPortedBadge)
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                0.12,
                                                              ),
                                                          blurRadius: 3,
                                                          offset: const Offset(
                                                            0,
                                                            1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Text(
                                                      "PORTED",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 7,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                    strokeWidth: 1.0,
                                  ),
                                );
                        }),
                      ),

                      SizedBox(height: 15),
                      SizedBox(
                        height: 35,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: duration.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  duration_selectedIndex = index;
                                });

                                box.write(
                                  "validity_type",
                                  duration[index]["Value"],
                                );

                                bundleController.initialpage = 1;
                                bundleController.finalList.clear();

                                if (isOperatorLookupEnabled) {
                                  final String phoneNumber =
                                      confirmPinController.numberController.text
                                          .trim();

                                  final int requiredLength =
                                      _maximumPhoneLength;

                                  if (phoneNumber.length == requiredLength) {
                                    await bundleController.fetchlookupbundles(
                                      phoneNumber,
                                    );
                                  } else {
                                    print(
                                      "Complete phone number required before filtering lookup bundles.",
                                    );
                                  }
                                } else {
                                  await bundleController.fetchallbundles();
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: duration_selectedIndex == index
                                        ? Color(0xff57C3E7).withOpacity(0.4)
                                        : Color(0xff57C3E7).withOpacity(0.4),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: duration_selectedIndex == index
                                      ? Color(0xff57C3E7)
                                      : Colors.white.withOpacity(0.30),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 0,
                                    ),
                                    child: KText(
                                      text: languagesController.tr(
                                        duration[index]["Name"]!,
                                      ),
                                      fontSize: screenWidth * 0.030,
                                      color: duration_selectedIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    // color: AppColors.secondaryColor,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(0.2),
                    //     spreadRadius: 2,
                    //     blurRadius: 2,
                    //     offset: Offset(0, 0),
                    //   ),
                    // ],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Obx(
                      () =>
                          bundleController.isLoading.value == false &&
                              bundleController.finalList.isNotEmpty
                          ? RefreshIndicator(
                              onRefresh: refresh,
                              child: ListView.builder(
                                padding: EdgeInsets.all(0),
                                physics: AlwaysScrollableScrollPhysics(),
                                controller: scrollController,
                                itemCount: bundleController.finalList.length,
                                itemBuilder: (context, index) {
                                  final data =
                                      bundleController.finalList[index];
                                  return GestureDetector(
                                    onTap: () {
                                      if (confirmPinController
                                          .numberController
                                          .text
                                          .isEmpty) {
                                        Fluttertoast.showToast(
                                          msg: languagesController.tr(
                                            "ENTER_PHONE_NUMBER",
                                          ),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      } else {
                                        if (box.read("permission") == "no" ||
                                            confirmPinController
                                                    .numberController
                                                    .text
                                                    .length
                                                    .toString() !=
                                                box
                                                    .read("maxlength")
                                                    .toString()) {
                                          Fluttertoast.showToast(
                                            msg: languagesController.tr(
                                              "ENTER_CORRECT_NUMBER",
                                            ),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          // Stop further execution if permission is "no"
                                        } else {
                                          box.write(
                                            "bundleID",
                                            data.id.toString(),
                                          );

                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(28),
                                                ),
                                                contentPadding: EdgeInsets.zero,
                                                backgroundColor:
                                                    Colors.transparent,
                                                content: StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              28,
                                                            ),
                                                        gradient:
                                                            LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Colors.white,
                                                                Colors
                                                                    .grey
                                                                    .shade50,
                                                              ],
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                            blurRadius: 30,
                                                            offset: Offset(
                                                              0,
                                                              15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      height: 480,
                                                      width: screenWidth,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              28,
                                                            ),
                                                        child: Obx(
                                                          () =>
                                                              confirmPinController
                                                                      .isLoading
                                                                      .value ==
                                                                  false
                                                              ? ListView(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        24,
                                                                      ),
                                                                  children: [
                                                                    // Header Section with Company Logo & Info
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            20,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                          colors: [
                                                                            AppColors.primaryColor.withOpacity(
                                                                              0.1,
                                                                            ),
                                                                            AppColors.primaryColor.withOpacity(
                                                                              0.05,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              20,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: AppColors.primaryColor.withOpacity(
                                                                            0.2,
                                                                          ),
                                                                          width:
                                                                              1.5,
                                                                        ),
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          // Company Logo
                                                                          Container(
                                                                            height:
                                                                                50,
                                                                            width:
                                                                                50,
                                                                            padding: EdgeInsets.all(
                                                                              8,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              shape: BoxShape.circle,
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors.black.withOpacity(
                                                                                    0.1,
                                                                                  ),
                                                                                  blurRadius: 10,
                                                                                  offset: Offset(
                                                                                    0,
                                                                                    4,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child: ClipOval(
                                                                              child: CachedNetworkImage(
                                                                                imageUrl: data.service!.company!.companyLogo.toString(),
                                                                                fit: BoxFit.cover,
                                                                                errorWidget:
                                                                                    (
                                                                                      context,
                                                                                      url,
                                                                                      error,
                                                                                    ) => Icon(
                                                                                      Icons.business,
                                                                                      color: Colors.grey.shade400,
                                                                                      size: 30,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                16,
                                                                          ),

                                                                          // Company Details
                                                                          Expanded(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                // Bundle Title
                                                                                Text(
                                                                                  data.bundleTitle.toString(),
                                                                                  style: TextStyle(
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Colors.grey.shade800,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 8,
                                                                                ),

                                                                                // Validity Badge
                                                                                Container(
                                                                                  padding: EdgeInsets.symmetric(
                                                                                    horizontal: 12,
                                                                                    vertical: 4,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color:
                                                                                        Color(
                                                                                          0xff826AF9,
                                                                                        ).withOpacity(
                                                                                          0.15,
                                                                                        ),
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      8,
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    data.validityType.toString() ==
                                                                                            "unlimited"
                                                                                        ? languagesController.tr(
                                                                                            "UNLIMITED",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "monthly"
                                                                                        ? languagesController.tr(
                                                                                            "MONTHLY",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "weekly"
                                                                                        ? languagesController.tr(
                                                                                            "WEEKLY",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "daily"
                                                                                        ? languagesController.tr(
                                                                                            "DAILY",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "hourly"
                                                                                        ? languagesController.tr(
                                                                                            "HOURLY",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "nightly"
                                                                                        ? languagesController.tr(
                                                                                            "NIGHTLY",
                                                                                          )
                                                                                        : "",
                                                                                    style: TextStyle(
                                                                                      color: Color(
                                                                                        0xff826AF9,
                                                                                      ),
                                                                                      fontSize: 11,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    SizedBox(
                                                                      height: 8,
                                                                    ),

                                                                    // Pricing Section
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            18,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              16,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          width:
                                                                              1.5,
                                                                        ),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.black.withOpacity(
                                                                              0.04,
                                                                            ),
                                                                            blurRadius:
                                                                                10,
                                                                            offset: Offset(
                                                                              0,
                                                                              4,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: Column(
                                                                        children: [
                                                                          // Buy Price
                                                                          Row(
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.all(
                                                                                  8,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color: AppColors.primaryColor.withOpacity(
                                                                                    0.1,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10,
                                                                                  ),
                                                                                ),
                                                                                child: Icon(
                                                                                  Icons.shopping_bag_outlined,
                                                                                  color: AppColors.primaryColor,
                                                                                  size: 18,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 12,
                                                                              ),
                                                                              Text(
                                                                                languagesController.tr(
                                                                                  "BUY",
                                                                                ),
                                                                                style: TextStyle(
                                                                                  color: Colors.grey.shade600,
                                                                                  fontSize: 13,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                              Spacer(),
                                                                              PriceTextView(
                                                                                price: data.buyingPrice.toString(),
                                                                                textStyle: TextStyle(
                                                                                  color: Colors.black87,
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 4,
                                                                              ),
                                                                              Text(
                                                                                box.read(
                                                                                  "currency_code",
                                                                                ),
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Colors.grey.shade600,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),

                                                                          Padding(
                                                                            padding: EdgeInsets.symmetric(
                                                                              vertical: 12,
                                                                            ),
                                                                            child: Divider(
                                                                              height: 1,
                                                                              thickness: 1.5,
                                                                              color: Colors.grey.shade200,
                                                                            ),
                                                                          ),

                                                                          // Sell Price
                                                                          Row(
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.all(
                                                                                  8,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.green.shade50,
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10,
                                                                                  ),
                                                                                ),
                                                                                child: Icon(
                                                                                  Icons.sell_outlined,
                                                                                  color: Colors.green.shade600,
                                                                                  size: 18,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 12,
                                                                              ),
                                                                              Text(
                                                                                languagesController.tr(
                                                                                  "SELL",
                                                                                ),
                                                                                style: TextStyle(
                                                                                  color: Colors.grey.shade600,
                                                                                  fontSize: 13,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                              Spacer(),
                                                                              PriceTextView(
                                                                                price: data.sellingPrice.toString(),
                                                                                textStyle: TextStyle(
                                                                                  color: Colors.green.shade600,
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 4,
                                                                              ),
                                                                              Text(
                                                                                box.read(
                                                                                  "currency_code",
                                                                                ),
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Colors.grey.shade600,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),

                                                                    // Container(
                                                                    //   padding:
                                                                    //       EdgeInsets.all(
                                                                    //         16,
                                                                    //       ),
                                                                    //   decoration: BoxDecoration(
                                                                    //     color: Colors
                                                                    //         .blue
                                                                    //         .shade50,
                                                                    //     borderRadius: BorderRadius.circular(
                                                                    //       14,
                                                                    //     ),
                                                                    //     border: Border.all(
                                                                    //       color:
                                                                    //           Colors.blue.shade100,
                                                                    //       width:
                                                                    //           1,
                                                                    //     ),
                                                                    //   ),
                                                                    //   child: Row(
                                                                    //     crossAxisAlignment:
                                                                    //         CrossAxisAlignment.start,
                                                                    //     children: [
                                                                    //       Icon(
                                                                    //         Icons.info_outline_rounded,
                                                                    //         color: Colors.blue.shade600,
                                                                    //         size: 20,
                                                                    //       ),
                                                                    //       SizedBox(
                                                                    //         width: 10,
                                                                    //       ),
                                                                    //       Expanded(
                                                                    //         child: Text(
                                                                    //           "If there is any explanation about the package, it will be included in this section...",
                                                                    //           style: TextStyle(
                                                                    //             color: Colors.grey.shade700,
                                                                    //             fontSize: 12,
                                                                    //             height: 1.4,
                                                                    //           ),
                                                                    //         ),
                                                                    //       ),
                                                                    //     ],
                                                                    //   ),
                                                                    // ),

                                                                    // SizedBox(
                                                                    //   height:
                                                                    //       16,
                                                                    // ),

                                                                    // Phone Number Display
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade50,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          width:
                                                                              1,
                                                                        ),
                                                                      ),
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            languagesController.tr(
                                                                              "PHONENUMBER",
                                                                            ),
                                                                            style: TextStyle(
                                                                              color: Colors.grey.shade600,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            confirmPinController.numberController.text.toString(),
                                                                            style: TextStyle(
                                                                              color: Colors.grey.shade800,
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),

                                                                    // PIN Input
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child: Container(
                                                                        height:
                                                                            60,
                                                                        width:
                                                                            140,
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          border: Border.all(
                                                                            width:
                                                                                2,
                                                                            color:
                                                                                Colors.grey.shade300,
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(
                                                                            16,
                                                                          ),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(
                                                                                0.05,
                                                                              ),
                                                                              blurRadius: 10,
                                                                              offset: Offset(
                                                                                0,
                                                                                4,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.lock_outline_rounded,
                                                                              color: AppColors.primaryColor,
                                                                              size: 18,
                                                                            ),
                                                                            SizedBox(
                                                                              height: 4,
                                                                            ),
                                                                            TextField(
                                                                              maxLength: 4,
                                                                              controller: confirmPinController.pinController,
                                                                              keyboardType: TextInputType.phone,
                                                                              textAlign: TextAlign.center,
                                                                              obscureText: true,
                                                                              decoration: InputDecoration(
                                                                                counterText: '',
                                                                                hintText: languagesController.tr(
                                                                                  "PIN",
                                                                                ),
                                                                                hintStyle: TextStyle(
                                                                                  color: Colors.grey.shade400,
                                                                                  fontSize: 13,
                                                                                ),
                                                                                border: InputBorder.none,
                                                                                isDense: true,
                                                                                contentPadding: EdgeInsets.zero,
                                                                              ),
                                                                              style: TextStyle(
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),

                                                                    // Action Buttons
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              3,
                                                                          child: GestureDetector(
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
                                                                                  await confirmPinController.placeOrder(
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
                                                                              height: 52,
                                                                              decoration: BoxDecoration(
                                                                                gradient: LinearGradient(
                                                                                  colors: [
                                                                                    Colors.green.shade400,
                                                                                    Colors.green.shade600,
                                                                                  ],
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(
                                                                                  16,
                                                                                ),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.green.withOpacity(
                                                                                      0.3,
                                                                                    ),
                                                                                    blurRadius: 12,
                                                                                    offset: Offset(
                                                                                      0,
                                                                                      6,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.check_circle_rounded,
                                                                                    color: Colors.white,
                                                                                    size: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 8,
                                                                                  ),
                                                                                  Text(
                                                                                    languagesController.tr(
                                                                                      "CONFIRMATION",
                                                                                    ),
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              12,
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child: GestureDetector(
                                                                            onTap: () {
                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                            },
                                                                            child: Container(
                                                                              height: 52,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.circular(
                                                                                  16,
                                                                                ),
                                                                                border: Border.all(
                                                                                  width: 2,
                                                                                  color: Colors.grey.shade300,
                                                                                ),
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.close_rounded,
                                                                                    color: Colors.grey.shade700,
                                                                                    size: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 6,
                                                                                  ),
                                                                                  Text(
                                                                                    languagesController.tr(
                                                                                      "CANCEL",
                                                                                    ),
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey.shade700,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
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
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 3,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              spreadRadius: 2,
                                              blurRadius: 2,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image:
                                                        CachedNetworkImageProvider(
                                                          data
                                                              .service!
                                                              .company!
                                                              .companyLogo
                                                              .toString(),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),

                                              // Left Column - Bundle Title and Buying Price
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      data.bundleTitle
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Obx(
                                                          () => KText(
                                                            text:
                                                                languagesController
                                                                    .tr("BUY"),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 13,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        Text(
                                                          " : ",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        PriceTextView(
                                                          price: data
                                                              .buyingPrice
                                                              .toString(),
                                                          textStyle: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          " ${box.read("currency_code")}",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Right Column - Validity Type and Selling Price
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  // Validity Type
                                                  Obx(
                                                    () => KText(
                                                      text:
                                                          data.validityType
                                                                  .toString() ==
                                                              "unlimited"
                                                          ? languagesController
                                                                .tr("UNLIMITED")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "monthly"
                                                          ? languagesController
                                                                .tr("MONTHLY")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "weekly"
                                                          ? languagesController
                                                                .tr("WEEKLY")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "daily"
                                                          ? languagesController
                                                                .tr("DAILY")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "hourly"
                                                          ? languagesController
                                                                .tr("HOURLY")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "nightly"
                                                          ? languagesController
                                                                .tr("NIGHTLY")
                                                          : "",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),

                                                  // Selling Price
                                                  Row(
                                                    children: [
                                                      Obx(
                                                        () => KText(
                                                          text:
                                                              languagesController
                                                                  .tr("SALE"),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      Text(
                                                        " : ",
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      PriceTextView(
                                                        price: data.sellingPrice
                                                            .toString(),
                                                        textStyle: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        " ${box.read("currency_code")}",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.green,
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
                          ? Center(child: CircularProgressIndicator())
                          : RefreshIndicator(
                              onRefresh: refresh,
                              child: ListView.builder(
                                padding: EdgeInsets.all(0),
                                physics: AlwaysScrollableScrollPhysics(),
                                controller: scrollController,
                                itemCount: bundleController.finalList.length,
                                itemBuilder: (context, index) {
                                  final data =
                                      bundleController.finalList[index];
                                  return GestureDetector(
                                    onTap: () {
                                      if (confirmPinController
                                          .numberController
                                          .text
                                          .isEmpty) {
                                        Fluttertoast.showToast(
                                          msg: languagesController.tr(
                                            "ENTER_PHONE_NUMBER",
                                          ),
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      } else {
                                        if (box.read("permission") == "no" ||
                                            confirmPinController
                                                    .numberController
                                                    .text
                                                    .length
                                                    .toString() !=
                                                box
                                                    .read("maxlength")
                                                    .toString()) {
                                          Fluttertoast.showToast(
                                            msg: languagesController.tr(
                                              "ENTER_CORRECT_NUMBER",
                                            ),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                          // Stop further execution if permission is "no"
                                        } else {
                                          box.write(
                                            "bundleID",
                                            data.id.toString(),
                                          );

                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(28),
                                                ),
                                                contentPadding: EdgeInsets.zero,
                                                backgroundColor:
                                                    Colors.transparent,
                                                content: StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              28,
                                                            ),
                                                        gradient:
                                                            LinearGradient(
                                                              begin: Alignment
                                                                  .topCenter,
                                                              end: Alignment
                                                                  .bottomCenter,
                                                              colors: [
                                                                Colors.white,
                                                                Colors
                                                                    .grey
                                                                    .shade50,
                                                              ],
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.2,
                                                                ),
                                                            blurRadius: 30,
                                                            offset: Offset(
                                                              0,
                                                              15,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      height: 480,
                                                      width: screenWidth,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              28,
                                                            ),
                                                        child: Obx(
                                                          () =>
                                                              confirmPinController
                                                                      .isLoading
                                                                      .value ==
                                                                  false
                                                              ? ListView(
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        24,
                                                                      ),
                                                                  children: [
                                                                    // Header Section with Company Logo & Info
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            20,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        gradient: LinearGradient(
                                                                          colors: [
                                                                            AppColors.primaryColor.withOpacity(
                                                                              0.1,
                                                                            ),
                                                                            AppColors.primaryColor.withOpacity(
                                                                              0.05,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              20,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: AppColors.primaryColor.withOpacity(
                                                                            0.2,
                                                                          ),
                                                                          width:
                                                                              1.5,
                                                                        ),
                                                                      ),
                                                                      child: Row(
                                                                        children: [
                                                                          // Company Logo
                                                                          Container(
                                                                            height:
                                                                                50,
                                                                            width:
                                                                                50,
                                                                            padding: EdgeInsets.all(
                                                                              8,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              shape: BoxShape.circle,
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors.black.withOpacity(
                                                                                    0.1,
                                                                                  ),
                                                                                  blurRadius: 10,
                                                                                  offset: Offset(
                                                                                    0,
                                                                                    4,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            child: ClipOval(
                                                                              child: CachedNetworkImage(
                                                                                imageUrl: data.service!.company!.companyLogo.toString(),
                                                                                fit: BoxFit.cover,
                                                                                errorWidget:
                                                                                    (
                                                                                      context,
                                                                                      url,
                                                                                      error,
                                                                                    ) => Icon(
                                                                                      Icons.business,
                                                                                      color: Colors.grey.shade400,
                                                                                      size: 30,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                16,
                                                                          ),

                                                                          // Company Details
                                                                          Expanded(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                // Bundle Title
                                                                                Text(
                                                                                  data.bundleTitle.toString(),
                                                                                  style: TextStyle(
                                                                                    fontSize: 13,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Colors.grey.shade800,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 8,
                                                                                ),

                                                                                // Validity Badge
                                                                                Container(
                                                                                  padding: EdgeInsets.symmetric(
                                                                                    horizontal: 12,
                                                                                    vertical: 4,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color:
                                                                                        Color(
                                                                                          0xff826AF9,
                                                                                        ).withOpacity(
                                                                                          0.15,
                                                                                        ),
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      8,
                                                                                    ),
                                                                                  ),
                                                                                  child: Text(
                                                                                    data.validityType.toString() ==
                                                                                            "unlimited"
                                                                                        ? languagesController.tr(
                                                                                            "UNLIMITED",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "monthly"
                                                                                        ? languagesController.tr(
                                                                                            "MONTHLY",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "weekly"
                                                                                        ? languagesController.tr(
                                                                                            "WEEKLY",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "daily"
                                                                                        ? languagesController.tr(
                                                                                            "DAILY",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "hourly"
                                                                                        ? languagesController.tr(
                                                                                            "HOURLY",
                                                                                          )
                                                                                        : data.validityType.toString() ==
                                                                                              "nightly"
                                                                                        ? languagesController.tr(
                                                                                            "NIGHTLY",
                                                                                          )
                                                                                        : "",
                                                                                    style: TextStyle(
                                                                                      color: Color(
                                                                                        0xff826AF9,
                                                                                      ),
                                                                                      fontSize: 11,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    SizedBox(
                                                                      height: 8,
                                                                    ),

                                                                    // Pricing Section
                                                                    Container(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                            18,
                                                                          ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              16,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          width:
                                                                              1.5,
                                                                        ),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.black.withOpacity(
                                                                              0.04,
                                                                            ),
                                                                            blurRadius:
                                                                                10,
                                                                            offset: Offset(
                                                                              0,
                                                                              4,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: Column(
                                                                        children: [
                                                                          // Buy Price
                                                                          Row(
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.all(
                                                                                  8,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color: AppColors.primaryColor.withOpacity(
                                                                                    0.1,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10,
                                                                                  ),
                                                                                ),
                                                                                child: Icon(
                                                                                  Icons.shopping_bag_outlined,
                                                                                  color: AppColors.primaryColor,
                                                                                  size: 18,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 12,
                                                                              ),
                                                                              Text(
                                                                                languagesController.tr(
                                                                                  "BUY",
                                                                                ),
                                                                                style: TextStyle(
                                                                                  color: Colors.grey.shade600,
                                                                                  fontSize: 13,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                              Spacer(),
                                                                              PriceTextView(
                                                                                price: data.buyingPrice.toString(),
                                                                                textStyle: TextStyle(
                                                                                  color: Colors.black87,
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 4,
                                                                              ),
                                                                              Text(
                                                                                box.read(
                                                                                  "currency_code",
                                                                                ),
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Colors.grey.shade600,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),

                                                                          Padding(
                                                                            padding: EdgeInsets.symmetric(
                                                                              vertical: 12,
                                                                            ),
                                                                            child: Divider(
                                                                              height: 1,
                                                                              thickness: 1.5,
                                                                              color: Colors.grey.shade200,
                                                                            ),
                                                                          ),

                                                                          // Sell Price
                                                                          Row(
                                                                            children: [
                                                                              Container(
                                                                                padding: EdgeInsets.all(
                                                                                  8,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.green.shade50,
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    10,
                                                                                  ),
                                                                                ),
                                                                                child: Icon(
                                                                                  Icons.sell_outlined,
                                                                                  color: Colors.green.shade600,
                                                                                  size: 18,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 12,
                                                                              ),
                                                                              Text(
                                                                                languagesController.tr(
                                                                                  "SELL",
                                                                                ),
                                                                                style: TextStyle(
                                                                                  color: Colors.grey.shade600,
                                                                                  fontSize: 13,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                              Spacer(),
                                                                              PriceTextView(
                                                                                price: data.sellingPrice.toString(),
                                                                                textStyle: TextStyle(
                                                                                  color: Colors.green.shade600,
                                                                                  fontSize: 15,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 4,
                                                                              ),
                                                                              Text(
                                                                                box.read(
                                                                                  "currency_code",
                                                                                ),
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Colors.grey.shade600,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),

                                                                    // Container(
                                                                    //   padding:
                                                                    //       EdgeInsets.all(
                                                                    //         16,
                                                                    //       ),
                                                                    //   decoration: BoxDecoration(
                                                                    //     color: Colors
                                                                    //         .blue
                                                                    //         .shade50,
                                                                    //     borderRadius: BorderRadius.circular(
                                                                    //       14,
                                                                    //     ),
                                                                    //     border: Border.all(
                                                                    //       color:
                                                                    //           Colors.blue.shade100,
                                                                    //       width:
                                                                    //           1,
                                                                    //     ),
                                                                    //   ),
                                                                    //   child: Row(
                                                                    //     crossAxisAlignment:
                                                                    //         CrossAxisAlignment.start,
                                                                    //     children: [
                                                                    //       Icon(
                                                                    //         Icons.info_outline_rounded,
                                                                    //         color: Colors.blue.shade600,
                                                                    //         size: 20,
                                                                    //       ),
                                                                    //       SizedBox(
                                                                    //         width: 10,
                                                                    //       ),
                                                                    //       Expanded(
                                                                    //         child: Text(
                                                                    //           "If there is any explanation about the package, it will be included in this section...",
                                                                    //           style: TextStyle(
                                                                    //             color: Colors.grey.shade700,
                                                                    //             fontSize: 12,
                                                                    //             height: 1.4,
                                                                    //           ),
                                                                    //         ),
                                                                    //       ),
                                                                    //     ],
                                                                    //   ),
                                                                    // ),

                                                                    // SizedBox(
                                                                    //   height:
                                                                    //       16,
                                                                    // ),

                                                                    // Phone Number Display
                                                                    Container(
                                                                      padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            16,
                                                                        vertical:
                                                                            12,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .shade50,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              12,
                                                                            ),
                                                                        border: Border.all(
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          width:
                                                                              1,
                                                                        ),
                                                                      ),
                                                                      child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            languagesController.tr(
                                                                              "PHONENUMBER",
                                                                            ),
                                                                            style: TextStyle(
                                                                              color: Colors.grey.shade600,
                                                                              fontSize: 13,
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            confirmPinController.numberController.text.toString(),
                                                                            style: TextStyle(
                                                                              color: Colors.grey.shade800,
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),

                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),

                                                                    // PIN Input
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child: Container(
                                                                        height:
                                                                            60,
                                                                        width:
                                                                            140,
                                                                        decoration: BoxDecoration(
                                                                          color:
                                                                              Colors.white,
                                                                          border: Border.all(
                                                                            width:
                                                                                2,
                                                                            color:
                                                                                Colors.grey.shade300,
                                                                          ),
                                                                          borderRadius: BorderRadius.circular(
                                                                            16,
                                                                          ),
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(
                                                                                0.05,
                                                                              ),
                                                                              blurRadius: 10,
                                                                              offset: Offset(
                                                                                0,
                                                                                4,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.lock_outline_rounded,
                                                                              color: AppColors.primaryColor,
                                                                              size: 18,
                                                                            ),
                                                                            SizedBox(
                                                                              height: 4,
                                                                            ),
                                                                            TextField(
                                                                              maxLength: 4,
                                                                              controller: confirmPinController.pinController,
                                                                              keyboardType: TextInputType.phone,
                                                                              textAlign: TextAlign.center,
                                                                              obscureText: true,
                                                                              decoration: InputDecoration(
                                                                                counterText: '',
                                                                                hintText: languagesController.tr(
                                                                                  "PIN",
                                                                                ),
                                                                                hintStyle: TextStyle(
                                                                                  color: Colors.grey.shade400,
                                                                                  fontSize: 13,
                                                                                ),
                                                                                border: InputBorder.none,
                                                                                isDense: true,
                                                                                contentPadding: EdgeInsets.zero,
                                                                              ),
                                                                              style: TextStyle(
                                                                                fontSize: 18,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),

                                                                    // Action Buttons
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              3,
                                                                          child: GestureDetector(
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
                                                                                  await confirmPinController.placeOrder(
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
                                                                              height: 52,
                                                                              decoration: BoxDecoration(
                                                                                gradient: LinearGradient(
                                                                                  colors: [
                                                                                    Colors.green.shade400,
                                                                                    Colors.green.shade600,
                                                                                  ],
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(
                                                                                  16,
                                                                                ),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.green.withOpacity(
                                                                                      0.3,
                                                                                    ),
                                                                                    blurRadius: 12,
                                                                                    offset: Offset(
                                                                                      0,
                                                                                      6,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.check_circle_rounded,
                                                                                    color: Colors.white,
                                                                                    size: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 8,
                                                                                  ),
                                                                                  Text(
                                                                                    languagesController.tr(
                                                                                      "CONFIRMATION",
                                                                                    ),
                                                                                    style: TextStyle(
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              12,
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child: GestureDetector(
                                                                            onTap: () {
                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                            },
                                                                            child: Container(
                                                                              height: 52,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.circular(
                                                                                  16,
                                                                                ),
                                                                                border: Border.all(
                                                                                  width: 2,
                                                                                  color: Colors.grey.shade300,
                                                                                ),
                                                                              ),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Icon(
                                                                                    Icons.close_rounded,
                                                                                    color: Colors.grey.shade700,
                                                                                    size: 20,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: 6,
                                                                                  ),
                                                                                  Text(
                                                                                    languagesController.tr(
                                                                                      "CANCEL",
                                                                                    ),
                                                                                    style: TextStyle(
                                                                                      color: Colors.grey.shade700,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: 15,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
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
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 3,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              spreadRadius: 2,
                                              blurRadius: 2,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image:
                                                        CachedNetworkImageProvider(
                                                          data
                                                              .service!
                                                              .company!
                                                              .companyLogo
                                                              .toString(),
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),

                                              // Left Column - Bundle Title and Buying Price
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      data.bundleTitle
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Obx(
                                                          () => KText(
                                                            text:
                                                                languagesController
                                                                    .tr("BUY"),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 13,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        Text(
                                                          " : ",
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                        PriceTextView(
                                                          price: data
                                                              .buyingPrice
                                                              .toString(),
                                                          textStyle: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          " ${box.read("currency_code")}",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Right Column - Validity Type and Selling Price
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  // Validity Type
                                                  Obx(
                                                    () => KText(
                                                      text:
                                                          data.validityType
                                                                  .toString() ==
                                                              "unlimited"
                                                          ? languagesController
                                                                .tr("UNLIMITED")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "monthly"
                                                          ? languagesController
                                                                .tr("MONTHLY")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "weekly"
                                                          ? languagesController
                                                                .tr("WEEKLY")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "daily"
                                                          ? languagesController
                                                                .tr("DAILY")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "hourly"
                                                          ? languagesController
                                                                .tr("HOURLY")
                                                          : data.validityType
                                                                    .toString() ==
                                                                "nightly"
                                                          ? languagesController
                                                                .tr("NIGHTLY")
                                                          : "",
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),

                                                  // Selling Price
                                                  Row(
                                                    children: [
                                                      Obx(
                                                        () => KText(
                                                          text:
                                                              languagesController
                                                                  .tr("SALE"),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 12,
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      Text(
                                                        " : ",
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                        ),
                                                      ),
                                                      PriceTextView(
                                                        price: data.sellingPrice
                                                            .toString(),
                                                        textStyle: TextStyle(
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        " ${box.read("currency_code")}",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.green,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
