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
import '../controllers/add_payment_controller.dart';
import '../controllers/branch_controller.dart';
import '../controllers/conversation_controller.dart';
import '../controllers/currency_controller.dart';
import '../controllers/payment_method_controller.dart';
import '../controllers/payment_type_controller.dart';
import '../controllers/sign_in_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';
import '../utils/colors.dart';
import '../widgets/authtextfield.dart';
import '../widgets/bottomsheet.dart';
import '../widgets/button_one.dart';
import 'hawala_list_screen.dart';
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
    currencyController.fetchCurrency();
    paymentTypeController.fetchtypes();
    selectedcurrency.value = box.read("currency_code");
    addPaymentController.currencyID.value = box.read("countryID");
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
                                    height: 450,
                                    width: screenWidth,
                                    color: Colors.white,
                                    child: Obx(
                                      () =>
                                          paymentMethodController
                                                  .isLoading
                                                  .value ==
                                              false
                                          ? ListView.builder(
                                              itemCount: paymentMethodController
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
                                                    addPaymentController
                                                        .payment_method_id
                                                        .value = data.id
                                                        .toString();
                                                    selectedMethod.value = data
                                                        .methodName
                                                        .toString();

                                                    Navigator.pop(context);
                                                  },
                                                  child: PaymentMethodBox(
                                                    methodName: data.methodName,
                                                    bankName: data.bankName,
                                                    holderName:
                                                        data.accountHolderName,
                                                    cardNumber: data.cardNumber,
                                                    accountNumber:
                                                        data.accountNumber,
                                                    sebaNumber:
                                                        data.shebaNumber,
                                                    details:
                                                        data.accountDetails,
                                                    imagelink:
                                                        data.accountImage,
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
                                    text: selectedMethod.toString(),
                                    fontSize: screenHeight * 0.020,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: AppColors.primaryColor
                                    .withOpacity(0.7),
                                radius: 15,
                                child: Icon(
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
                                child: Icon(
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

class PaymentMethodBox extends StatelessWidget {
  String? methodName;
  String? bankName;
  String? holderName;
  String? cardNumber;
  String? accountNumber;
  String? sebaNumber;
  String? details;
  String? imagelink;

  PaymentMethodBox({
    super.key,
    this.methodName,
    this.bankName,
    this.holderName,
    this.cardNumber,
    this.accountNumber,
    this.sebaNumber,
    this.details,
    this.imagelink,
  });

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Visibility(
      visible: cardNumber != null,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        height: 350,
        width: screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff1e3c72), Color(0xff2a5298), Color(0xff4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Method Name
                    Row(
                      children: [
                        Icon(Icons.payment, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            methodName.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (imagelink != null &&
                            imagelink.toString().isNotEmpty) ...[
                          SizedBox(width: 5),
                          Container(
                            width: 50,
                            height: 40,

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.network(
                              imagelink.toString(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.broken_image,
                                  size: 30,
                                  color: Colors.grey[400],
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xff4A90E2),
                                            ),
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Card Number
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Obx(
                                  () => Text(
                                    languagesController.tr("CARD_NUMBER") +
                                        ": ",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    cardNumber.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: cardNumber.toString()),
                              );
                              Get.snackbar(
                                'Copied',
                                'Card number copied',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.white,
                                colorText: Color(0xff4A90E2),
                                duration: Duration(seconds: 2),
                                margin: EdgeInsets.all(16),
                              );
                            },
                            icon: Icon(
                              Icons.copy,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Account Number
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Obx(
                                  () => Text(
                                    languagesController.tr("ACCOUNT_NUMBER") +
                                        ": ",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    accountNumber.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: accountNumber.toString()),
                              );
                              Get.snackbar(
                                'Copied',
                                'Account number copied',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.white,
                                colorText: Color(0xff4A90E2),
                                duration: Duration(seconds: 2),
                                margin: EdgeInsets.all(16),
                              );
                            },
                            icon: Icon(
                              Icons.copy,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Holder Name & Bank Name in Row
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Obx(
                                () => Text(
                                  languagesController.tr("HOLDER_NAME") + ": ",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  holderName.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Bank Name
                    Row(
                      children: [
                        Obx(
                          () => Text(
                            languagesController.tr("BANK_NAME") + ": ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            bankName.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // SEBA Number
                    Visibility(
                      visible: sebaNumber != null,
                      child: Row(
                        children: [
                          Obx(
                            () => Text(
                              languagesController.tr("SEBA_NUMBER") + ": ",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              sebaNumber.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Details & Image in Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => Text(
                                  languagesController.tr("DETAILS") + ": ",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                details.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
    );
  }
}
