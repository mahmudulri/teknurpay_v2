import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/update_selling_price_controller.dart';
import 'package:teknurpay/widgets/authtextfield.dart';
import '../controllers/categories_controller.dart';
import '../controllers/delete_selling_price_controller.dart';
import '../controllers/only_service_controller.dart';
import '../controllers/selling_price_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';
import '../models/service_category_model.dart';
import '../pages/homepages.dart';
import '../utils/colors.dart';
import '../widgets/bottomsheet.dart';
import '../widgets/button.dart';
import 'create_selling_price_screen.dart';

class SellingPriceScreen extends StatefulWidget {
  SellingPriceScreen({super.key});

  @override
  State<SellingPriceScreen> createState() => _SellingPriceScreenState();
}

class _SellingPriceScreenState extends State<SellingPriceScreen> {
  LanguagesController languagesController = Get.put(LanguagesController());

  final SellingPriceController sellingPriceController = Get.put(
    SellingPriceController(),
  );

  UpdateSellingPriceController updateSellingPriceController = Get.put(
    UpdateSellingPriceController(),
  );

  final box = GetStorage();

  final Mypagecontroller mypagecontroller = Get.find();

  List commissiontype = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    commissiontype = [
      {"name": languagesController.tr("PERCENTAGE"), "value": "percentage"},
      {"name": languagesController.tr("FIXED"), "value": "fixed"},
    ];
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );
    categorisListController.fetchcategories();
    sellingPriceController.fetchpriceData();
    serviceController.fetchservices();
  }

  final categorisListController = Get.find<CategorisListController>();

  final OnlyServiceController serviceController = Get.put(
    OnlyServiceController(),
  );
  @override
  Widget build(BuildContext context) {
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
                        () => Text(
                          languagesController.tr("SELLING_PRICE"),
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
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 50,
                width: screenWidth,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: languagesController.tr("SEARCH"),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: screenHeight * 0.020,
                                fontFamily:
                                    box.read("language").toString() == "Fa"
                                    ? Get.find<FontController>().currentFont
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: DefaultButton1(
                        buttonName: languagesController.tr("CREATE_NEW"),
                        height: 50,
                        width: double.maxFinite,
                        onpressed: () {
                          mypagecontroller.changePage(
                            CreateSellingPriceScreen(),
                            isMainPage: false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Obx(
                  () =>
                      sellingPriceController.isLoading.value == false &&
                          serviceController.isLoading.value == false
                      ? ListView.builder(
                          padding: EdgeInsets.all(0),
                          physics: BouncingScrollPhysics(),
                          itemCount: sellingPriceController
                              .allpricelist
                              .value
                              .data!
                              .pricings!
                              .length,
                          itemBuilder: (context, index) {
                            final data = sellingPriceController
                                .allpricelist
                                .value
                                .data!
                                .pricings![index];
                            return Container(
                              height: 100,
                              width: screenWidth,
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            serviceController
                                                .allservices
                                                .value
                                                .data!
                                                .services
                                                .firstWhere(
                                                  (srvs) =>
                                                      srvs.id.toString() ==
                                                      data.serviceId.toString(),
                                                )
                                                .company!
                                                .companyLogo
                                                .toString(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                serviceController
                                                    .allservices
                                                    .value
                                                    .data!
                                                    .services
                                                    .firstWhere(
                                                      (srvs) =>
                                                          srvs.id.toString() ==
                                                          data.serviceId
                                                              .toString(),
                                                    )
                                                    .company!
                                                    .companyName
                                                    .toString(),
                                              ),
                                              Text(
                                                categorisListController
                                                    .allcategorieslist
                                                    .value
                                                    .data!
                                                    .servicecategories!
                                                    .firstWhere(
                                                      (cat) =>
                                                          cat.id.toString() ==
                                                          data
                                                              .service!
                                                              .serviceCategoryId
                                                              .toString(),
                                                      orElse: () =>
                                                          Servicecategory(
                                                            categoryName:
                                                                'null',
                                                          ),
                                                    )
                                                    .categoryName
                                                    .toString(),
                                                style: TextStyle(
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
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                languagesController.tr(
                                                  "COMMISSION_TYPE",
                                                ),
                                              ),
                                              Text(
                                                data.commissionType
                                                            .toString() ==
                                                        "percentage"
                                                    ? languagesController.tr(
                                                        "PERCENTAGE",
                                                      )
                                                    : languagesController.tr(
                                                        "FIXED",
                                                      ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                languagesController.tr(
                                                  "AMOUNT",
                                                ),
                                                style: TextStyle(
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
                                              Text(
                                                data.amount.toString(),
                                                style: TextStyle(),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            print(
                                              data.commissionType.toString(),
                                            );
                                            updateSellingPriceController
                                                .amountController
                                                .text = data.amount
                                                .toString();
                                            // updateSellingPriceController
                                            //         .commissiontype.value =
                                            //     data.commissionType.toString();
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  contentPadding:
                                                      EdgeInsets.all(0.0),
                                                  content: Container(
                                                    height: 500,
                                                    width: screenWidth,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffEEF4FF),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          spreadRadius: 2,
                                                          blurRadius: 2,
                                                          offset: Offset(0, 0),
                                                        ),
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 10,
                                                          ),
                                                      child: ListView(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  print(
                                                                    updateSellingPriceController
                                                                        .commissiontype
                                                                        .toString(),
                                                                  );
                                                                },
                                                                child: Text(
                                                                  languagesController
                                                                      .tr(
                                                                        "AMOUNT",
                                                                      ),
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade600,
                                                                    fontSize:
                                                                        18,
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
                                                            ],
                                                          ),
                                                          SizedBox(height: 5),
                                                          Authtextfield(
                                                            hinttext:
                                                                languagesController.tr(
                                                                  "ENTER_AMOUNT",
                                                                ),
                                                            controller:
                                                                updateSellingPriceController
                                                                    .amountController,
                                                          ),
                                                          SizedBox(height: 5),
                                                          GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (context) {
                                                                  return AlertDialog(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    content: Container(
                                                                      height:
                                                                          150,
                                                                      width:
                                                                          screenWidth,
                                                                      color: Colors
                                                                          .white,
                                                                      child: ListView.builder(
                                                                        itemCount:
                                                                            commissiontype.length,
                                                                        itemBuilder:
                                                                            (
                                                                              context,
                                                                              index,
                                                                            ) {
                                                                              return GestureDetector(
                                                                                onTap: () {
                                                                                  updateSellingPriceController.commitype.value = commissiontype[index]["name"];
                                                                                  updateSellingPriceController.commissiontype.value = commissiontype[index]["value"];
                                                                                  Navigator.pop(
                                                                                    context,
                                                                                  );
                                                                                },
                                                                                child: Container(
                                                                                  margin: EdgeInsets.only(
                                                                                    bottom: 8,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(
                                                                                      width: 1,
                                                                                      color: Colors.grey,
                                                                                    ),
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      8,
                                                                                    ),
                                                                                  ),
                                                                                  height: 50,
                                                                                  child: Padding(
                                                                                    padding: EdgeInsets.all(
                                                                                      10.0,
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Text(
                                                                                        commissiontype[index]["name"],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            child: Container(
                                                              height: 50,
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Obx(
                                                                      () => Text(
                                                                        updateSellingPriceController
                                                                            .commitype
                                                                            .value
                                                                            .toString(),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Icon(
                                                                    FontAwesomeIcons
                                                                        .chevronDown,
                                                                    size:
                                                                        screenHeight *
                                                                        0.018,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 12),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                languagesController
                                                                    .tr(
                                                                      "SERVICE",
                                                                    ),
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                  fontSize:
                                                                      screenHeight *
                                                                      0.020,
                                                                  fontFamily:
                                                                      box.read("language").toString() ==
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
                                                            children: [
                                                              Container(
                                                                height: 120,
                                                                width: 140,
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        12,
                                                                      ),
                                                                ),
                                                                child: Center(
                                                                  child: Obx(
                                                                    () =>
                                                                        updateSellingPriceController.catName.value !=
                                                                            ''
                                                                        ? Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Image.network(
                                                                                updateSellingPriceController.logolink.toString(),
                                                                                height: 50,
                                                                              ),
                                                                              Text(
                                                                                updateSellingPriceController.serviceName.toString(),
                                                                              ),
                                                                              Text(
                                                                                updateSellingPriceController.catName.toString(),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : SizedBox(
                                                                            child: Text(
                                                                              "",
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 20,
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (context) {
                                                                      return Dialog(
                                                                        insetPadding:
                                                                            EdgeInsets.zero,
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                        child:
                                                                            UpdateServiceBox(),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                                child: CircleAvatar(
                                                                  radius: 22,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .white,
                                                                  child: Center(
                                                                    child: Icon(
                                                                      FontAwesomeIcons
                                                                          .chevronDown,
                                                                      size: 14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 30),
                                                          Obx(
                                                            () => DefaultButton1(
                                                              height: 50,
                                                              width:
                                                                  screenWidth,
                                                              buttonName:
                                                                  updateSellingPriceController
                                                                          .isLoading
                                                                          .value ==
                                                                      false
                                                                  ? languagesController.tr(
                                                                      "UPDATE_NOW",
                                                                    )
                                                                  : languagesController.tr(
                                                                      "PLEASE_WAIT",
                                                                    ),
                                                              onpressed: () {
                                                                if (updateSellingPriceController
                                                                        .amountController
                                                                        .text
                                                                        .isNotEmpty &&
                                                                    updateSellingPriceController
                                                                            .commissiontype
                                                                            .value !=
                                                                        "" &&
                                                                    updateSellingPriceController
                                                                        .serviceidcontroller
                                                                        .text
                                                                        .isNotEmpty) {
                                                                  updateSellingPriceController
                                                                      .updatenow(
                                                                        data.id
                                                                            .toString(),
                                                                      );
                                                                } else {
                                                                  Fluttertoast.showToast(
                                                                    msg: languagesController.tr(
                                                                      "FILL_DATA_CORRECTLY",
                                                                    ),
                                                                    toastLength:
                                                                        Toast
                                                                            .LENGTH_SHORT,
                                                                    gravity:
                                                                        ToastGravity
                                                                            .CENTER,
                                                                    timeInSecForIosWeb:
                                                                        1,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        16.0,
                                                                  );
                                                                }
                                                              },
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
                                          child: Icon(Icons.edit),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  content: DeleteDialog(
                                                    priceID: data.id.toString(),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class DeleteDialog extends StatelessWidget {
  DeleteDialog({super.key, this.priceID});

  String? priceID;

  final DeleteSellingPriceController controller = Get.put(
    DeleteSellingPriceController(),
  );

  LanguagesController languagesController = Get.put(LanguagesController());

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 200,
      width: screenWidth,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            languagesController.tr("DO_YOU_WANT_TO_DELETE"),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 25),
          Container(
            height: 50,
            width: screenWidth,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.deleteprice(priceID.toString());
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 45,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Obx(
                        () => Text(
                          controller.isLoading.value == false
                              ? languagesController.tr("YES")
                              : languagesController.tr("PLEASE_WAIT"),
                          style: TextStyle(
                            color: Color(0xffFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 45,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        languagesController.tr("NO"),
                        style: TextStyle(
                          color: Color(0xffFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateServiceBox extends StatelessWidget {
  UpdateServiceBox({super.key});

  final OnlyServiceController serviceController = Get.put(
    OnlyServiceController(),
  );

  final categorisListController = Get.find<CategorisListController>();
  UpdateSellingPriceController updateSellingPriceController = Get.put(
    UpdateSellingPriceController(),
  );
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Container(
        height: 500,
        width: screenWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(
            () => serviceController.isLoading.value == false
                ? GridView.builder(
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: serviceController
                        .allservices
                        .value
                        .data!
                        .services
                        .length,
                    itemBuilder: (context, index) {
                      final data = serviceController
                          .allservices
                          .value
                          .data!
                          .services[index];
                      return Padding(
                        padding: EdgeInsets.all(3.0),
                        child: GestureDetector(
                          onTap: () {
                            updateSellingPriceController
                                .serviceidcontroller
                                .text = data.id
                                .toString();

                            updateSellingPriceController.catName.value =
                                categorisListController
                                    .allcategorieslist
                                    .value
                                    .data!
                                    .servicecategories!
                                    .firstWhere(
                                      (cat) =>
                                          cat.id.toString() ==
                                          data.serviceCategoryId.toString(),
                                      orElse: () =>
                                          Servicecategory(categoryName: ''),
                                    )
                                    .categoryName
                                    .toString();

                            updateSellingPriceController.logolink.value = data
                                .company!
                                .companyLogo
                                .toString();

                            updateSellingPriceController.serviceName.value =
                                data.company!.companyName.toString();

                            Navigator.pop(context);
                          },
                          child: Container(
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
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          data.company!.companyLogo.toString(),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Column(
                                    children: [
                                      Text(
                                        textAlign: TextAlign.center,
                                        data.company!.companyName.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily:
                                              box.read("language").toString() ==
                                                  "Fa"
                                              ? Get.find<FontController>()
                                                    .currentFont
                                              : null,
                                        ),
                                      ),
                                      // Text(data.serviceCategoryId.toString()),
                                      Text(
                                        categorisListController
                                            .allcategorieslist
                                            .value
                                            .data!
                                            .servicecategories!
                                            .firstWhere(
                                              (cat) =>
                                                  cat.id.toString() ==
                                                  data.serviceCategoryId
                                                      .toString(),
                                              orElse: () => Servicecategory(
                                                categoryName: '',
                                              ),
                                            )
                                            .categoryName
                                            .toString(),
                                        style: TextStyle(
                                          fontFamily:
                                              box.read("language").toString() ==
                                                  "Fa"
                                              ? Get.find<FontController>()
                                                    .currentFont
                                              : null,
                                        ),
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
                  )
                : Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
