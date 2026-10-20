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
import '../controllers/add_payment_controller.dart';
import '../controllers/currency_controller.dart';
import '../controllers/payment_method_controller.dart';
import '../controllers/payment_type_controller.dart';
import '../controllers/sign_in_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';
import '../models/payment_method_model.dart';
import '../utils/colors.dart';
import '../widgets/authtextfield.dart';
import '../widgets/bottomsheet.dart';
import 'receipts_screen.dart';

class CreatePaymentsScreen extends StatefulWidget {
  CreatePaymentsScreen({super.key});

  @override
  State<CreatePaymentsScreen> createState() => _CreatePaymentsScreenState();
}

class _CreatePaymentsScreenState extends State<CreatePaymentsScreen> {
  final Mypagecontroller mypagecontroller = Get.find();

  SignInController signInController = Get.put(SignInController());

  CurrencyController currencyController = Get.put(CurrencyController());
  PaymentMethodController paymentMethodController = Get.put(
    PaymentMethodController(),
  );
  PaymentTypeController paymentTypeController = Get.put(
    PaymentTypeController(),
  );

  late Rx<DateTime?> mydate;
  Future<void> pickStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: mydate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      mydate.value = picked;

      addPaymentController.selectedDate.value = DateFormat(
        'yyyy-MM-dd',
      ).format(picked);
      print(addPaymentController.selectedDate.value.toString());
    }
  }

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
    final now = DateTime.now();
    mydate = Rx<DateTime?>(now);

    addPaymentController.selectedDate.value = DateFormat(
      'yyyy-MM-dd',
    ).format(now);
    paymentMethodController.fetchmethods();
    currencyController.fetchCurrencyList();
    paymentTypeController.fetchtypes();
    selectedcurrency.value = (box.read("currency_code") ?? "").toString();
    addPaymentController.currencyID.value = (box.read("countryID") ?? "")
        .toString();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );

    commissionpaidby = [
      languagesController.tr("SENDER"),
      languagesController.tr("RECEIVER"),
    ];
  }

  var selectedMethod = "".obs;
  var selectedType = "".obs;
  var selectedcurrency = "".obs;

  void showPaymentMethodBottomSheet() {
    final RxString selectedFilter = "All".obs;

    final RxString temporarySelectedId =
        addPaymentController.payment_method_id.value.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext sheetContext) {
        final screenHeight = MediaQuery.of(sheetContext).size.height;
        final screenWidth = MediaQuery.of(sheetContext).size.width;

        return SafeArea(
          child: Container(
            height: screenHeight * 0.78,
            width: screenWidth,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Drag indicator
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),

                const SizedBox(height: 18),

                // Sheet title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 38),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Select Payment Method",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff102A43),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Choose where you sent the payment",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                        },
                        child: const SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            Icons.close,
                            color: Colors.black87,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: Obx(() {
                    if (paymentMethodController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final List<PaymentMethod> allMethods =
                        paymentMethodController
                            .allmethods
                            .value
                            .data
                            ?.paymentMethods ??
                        <PaymentMethod>[];

                    if (allMethods.isEmpty) {
                      return Center(
                        child: Text(
                          "No payment methods found",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      );
                    }

                    // Build unique method-name filters from the API.
                    final List<String> methodNames = [];

                    for (final method in allMethods) {
                      final name = method.methodName?.trim() ?? "";

                      if (name.isNotEmpty && !methodNames.contains(name)) {
                        methodNames.add(name);
                      }
                    }

                    final List<String> filters = ["All", ...methodNames];

                    // "All" is selected by default.
                    final List<PaymentMethod> filteredMethods =
                        selectedFilter.value == "All"
                        ? allMethods
                        : allMethods.where((element) {
                            return element.methodName?.trim() ==
                                selectedFilter.value;
                          }).toList();

                    return Column(
                      children: [
                        // Payment-method name filters
                        SizedBox(
                          height: 46,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: filters.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 10);
                            },
                            itemBuilder: (context, index) {
                              final filter = filters[index];
                              final bool isSelected =
                                  selectedFilter.value == filter;

                              return GestureDetector(
                                onTap: () {
                                  selectedFilter.value = filter;
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryColor
                                          : Colors.grey.shade400,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      filter,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Filtered payment-method list
                        Expanded(
                          child: filteredMethods.isEmpty
                              ? Center(
                                  child: Text(
                                    "No payment method found",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  itemCount: filteredMethods.length,
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 10);
                                  },
                                  itemBuilder: (context, index) {
                                    final PaymentMethod data =
                                        filteredMethods[index];

                                    return Obx(() {
                                      final bool isSelected =
                                          temporarySelectedId.value ==
                                          data.id?.toString();

                                      return PaymentMethodSelectionCard(
                                        paymentMethod: data,
                                        isSelected: isSelected,
                                        onTap: () {
                                          temporarySelectedId.value =
                                              data.id?.toString() ?? "";
                                        },
                                      );
                                    });
                                  },
                                ),
                        ),

                        // Continue button
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                          child: Obx(() {
                            final bool canContinue =
                                temporarySelectedId.value.isNotEmpty;

                            return GestureDetector(
                              onTap: !canContinue
                                  ? null
                                  : () {
                                      PaymentMethod? selectedPaymentMethod;

                                      for (final method in allMethods) {
                                        if (method.id?.toString() ==
                                            temporarySelectedId.value) {
                                          selectedPaymentMethod = method;
                                          break;
                                        }
                                      }

                                      if (selectedPaymentMethod == null) {
                                        return;
                                      }

                                      addPaymentController
                                              .payment_method_id
                                              .value =
                                          selectedPaymentMethod.id
                                              ?.toString() ??
                                          "";

                                      selectedMethod.value =
                                          selectedPaymentMethod.methodName ??
                                          "";

                                      Navigator.pop(sheetContext);
                                    },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: canContinue
                                      ? AppColors.primaryColor
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(
                                      color: canContinue
                                          ? Colors.white
                                          : Colors.grey.shade500,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                        () => GestureDetector(
                          onTap: () {
                            print(
                              addPaymentController.currencyID.value.toString(),
                            );
                          },
                          child: KText(
                            text: languagesController.tr("ADD_NEW_RECEIPT"),
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
                height: 600,
                width: screenWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  children: [
                    KText(
                      text: languagesController.tr("PAYMENT_METHOD"),
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.020,
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            showPaymentMethodBottomSheet();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Obx(
                                    () => KText(
                                      text: selectedMethod.value.isEmpty
                                          ? languagesController.tr(
                                              "PAYMENT_METHOD",
                                            )
                                          : selectedMethod.value,
                                      fontSize: screenHeight * 0.020,
                                      color: selectedMethod.value.isEmpty
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Obx(
                                  () => Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.10,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      selectedMethod.value.isEmpty
                                          ? Icons.keyboard_arrow_down_rounded
                                          : Icons.edit_outlined,
                                      color: AppColors.primaryColor,
                                      size: 20,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        KText(
                          text: languagesController.tr("AMOUNT"),
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.020,
                        ),
                        KText(
                          text: languagesController.tr("CURRENCY"),
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.020,
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 50,
                      width: screenWidth,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
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
                                  controller:
                                      addPaymentController.amountController,
                                  style: TextStyle(),
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
                            flex: 2,
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
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(
                                        () => KText(
                                          text: selectedcurrency.toString(),
                                          color: Colors.grey.shade600,
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
                                                                    .allcurrencylist
                                                                    .value
                                                                    .data!
                                                                    .currencies!
                                                                    .length,
                                                            itemBuilder: (context, index) {
                                                              final data =
                                                                  currencyController
                                                                      .allcurrencylist
                                                                      .value
                                                                      .data!
                                                                      .currencies![index];
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  addPaymentController
                                                                      .currencyID
                                                                      .value = data
                                                                      .id
                                                                      .toString();
                                                                  selectedcurrency
                                                                      .value = data
                                                                      .code
                                                                      .toString();
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
                                                                          KText(
                                                                            text:
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
                                        child: CircleAvatar(
                                          backgroundColor: AppColors
                                              .primaryColor
                                              .withOpacity(0.7),
                                          radius: 15,
                                          child: FaIcon(
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    KText(
                      text: languagesController.tr("PAYMENT_DATE"),
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.020,
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
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => Text(
                                  addPaymentController.selectedDate.value,
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.020,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                pickStartDate(context);
                              },
                              child: Icon(
                                Icons.calendar_month,
                                size: 22,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    KText(
                      text: languagesController.tr("TRACKING_CODE"),
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.020,
                    ),
                    SizedBox(height: 5),
                    Authtextfield(
                      hinttext: "",
                      controller: addPaymentController.trackingCodeController,
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        KText(
                          text: languagesController.tr("NOTES"),
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.020,
                        ),
                        SizedBox(width: 10),
                        KText(
                          text: "(${languagesController.tr("OPTIONAL")})",
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.018,
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Authtextfield(
                      hinttext: "",
                      controller: addPaymentController.noteController,
                    ),
                    SizedBox(height: 10),
                    KText(
                      text: languagesController.tr("PAYMENT_TYPE"),
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.020,
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
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  content: Container(
                                    height: 170,
                                    width: screenWidth,
                                    color: Colors.white,
                                    child: Obx(
                                      () =>
                                          paymentTypeController
                                                  .isLoading
                                                  .value ==
                                              false
                                          ? ListView.builder(
                                              itemCount: paymentTypeController
                                                  .alltypes
                                                  .value
                                                  .data!
                                                  .paymentTypes!
                                                  .length,
                                              itemBuilder: (context, index) {
                                                final data =
                                                    paymentTypeController
                                                        .alltypes
                                                        .value
                                                        .data!
                                                        .paymentTypes![index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    addPaymentController
                                                        .payment_type_id
                                                        .value = data.id
                                                        .toString();
                                                    selectedType.value = data
                                                        .name
                                                        .toString();

                                                    Navigator.pop(context);
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                      bottom: 8,
                                                    ),
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Flexible(
                                                            child: KText(
                                                              text: data.name
                                                                  .toString(),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => KText(
                                    text: selectedType.toString(),
                                    fontSize: screenHeight * 0.020,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor
                                    .withOpacity(0.7),
                                radius: 15,
                                child: FaIcon(
                                  FontAwesomeIcons.chevronDown,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    KText(
                      text: languagesController.tr("UPLOAD_IMAGES"),
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.020,
                    ),
                    SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          buildImageUploaderBox(
                            context,
                            languagesController.tr("IMAGE_ONE"),
                            addPaymentController.paymentImagePath,
                            () => addPaymentController.pickImage("payment"),
                          ),
                          SizedBox(width: 10),
                          buildImageUploaderBox(
                            context,
                            languagesController.tr("IMAGE_TOW"),
                            addPaymentController.extraImage1Path,
                            () => addPaymentController.pickImage("extra1"),
                          ),
                          SizedBox(width: 10),
                          buildImageUploaderBox(
                            context,
                            languagesController.tr("IMAGE_THREE"),
                            addPaymentController.extraImage2Path,
                            () => addPaymentController.pickImage("extra2"),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Obx(
                      () => DefaultButton1(
                        height: 50,
                        width: screenWidth,
                        buttonName:
                            addPaymentController.isLoading.value == false
                            ? languagesController.tr("ADD_NOW")
                            : languagesController.tr("PLEASE_WAIT"),
                        onpressed: () {
                          if (addPaymentController.payment_method_id.value ==
                                  '' ||
                              addPaymentController
                                  .amountController
                                  .text
                                  .isEmpty ||
                              addPaymentController.currencyID.value == '' ||
                              addPaymentController.selectedDate.value ==
                                  '' || // <-- FIXED
                              addPaymentController
                                  .trackingCodeController
                                  .text
                                  .isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Please fill all required fields correctly",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          } else {
                            addPaymentController.addNow();
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildImageUploaderBox(
  BuildContext context,
  String label,
  RxString imagePath,
  VoidCallback onPick,
) {
  return Obx(
    () => Stack(
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: 160,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: imagePath.value.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(imagePath.value),
                      width: 160,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: KText(
                        text: label,
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ),
        ),
        if (imagePath.value.isNotEmpty)
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                imagePath.value = '';
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
      ],
    ),
  );
}

class PaymentMethodSelectionCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodSelectionCard({
    super.key,
    required this.paymentMethod,
    required this.isSelected,
    required this.onTap,
  });

  bool _hasValue(String? value) {
    if (value == null) {
      return false;
    }

    final text = value.trim();

    return text.isNotEmpty && text.toLowerCase() != "null" && text != ".";
  }

  String _getPrimaryNumber() {
    if (_hasValue(paymentMethod.accountNumber)) {
      return paymentMethod.accountNumber!.trim();
    }

    if (_hasValue(paymentMethod.cardNumber)) {
      return paymentMethod.cardNumber!.trim();
    }

    if (_hasValue(paymentMethod.accountHolderName)) {
      return paymentMethod.accountHolderName!.trim();
    }

    return "";
  }

  bool _shouldShowShebaWarning() {
    if (!_hasValue(paymentMethod.shebaNumber)) {
      return false;
    }

    final sheba = paymentMethod.shebaNumber!.trim();

    if (sheba == paymentMethod.accountNumber?.trim()) {
      return false;
    }

    if (sheba == paymentMethod.cardNumber?.trim()) {
      return false;
    }

    return true;
  }

  bool _hasUsableImage() {
    final image = paymentMethod.accountImage?.trim() ?? "";

    if (image.isEmpty || !image.startsWith("http")) {
      return false;
    }

    final uri = Uri.tryParse(image);

    if (uri == null || uri.pathSegments.isEmpty) {
      return false;
    }

    final lastSegment = uri.pathSegments.last.trim();

    return lastSegment.contains(".");
  }

  Future<void> _copyValue(String value) async {
    await Clipboard.setData(ClipboardData(text: value));

    Fluttertoast.showToast(
      msg: "Copied",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String primaryNumber = _getPrimaryNumber();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment image / fallback icon
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: _hasUsableImage()
                  ? Image.network(
                      paymentMethod.accountImage!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primaryColor,
                          size: 30,
                        );
                      },
                    )
                  : Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.primaryColor,
                      size: 30,
                    ),
            ),

            const SizedBox(width: 12),

            // Payment-method details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          paymentMethod.methodName ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xff102A43),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (_hasValue(paymentMethod.bankName))
                        Container(
                          constraints: const BoxConstraints(maxWidth: 115),
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            paymentMethod.bankName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (_hasValue(paymentMethod.accountHolderName)) ...[
                    const SizedBox(height: 5),
                    Text(
                      paymentMethod.accountHolderName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  if (primaryNumber.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            primaryNumber,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _copyValue(primaryNumber);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.copy_rounded,
                              color: AppColors.primaryColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (_shouldShowShebaWarning()) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xfffff5df),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xffE5A11B),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              paymentMethod.shebaNumber!,
                              style: const TextStyle(
                                color: Color(0xff8A6817),
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (_hasValue(paymentMethod.accountDetails)) ...[
                    const SizedBox(height: 7),
                    Text(
                      paymentMethod.accountDetails!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : Colors.grey.shade400,
                  width: 1.4,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 22,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
