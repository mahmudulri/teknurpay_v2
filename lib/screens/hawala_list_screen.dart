import 'package:teknurpay/controllers/branch_controller.dart';
import 'package:teknurpay/widgets/custom_text.dart';
import 'package:teknurpay/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/hawala_cancel_controller.dart';
import '../controllers/hawala_list_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';
import '../helpers/capture_image_helper.dart';
import '../helpers/share_image_helper.dart';
import '../pages/homepages.dart';
import '../pages/transaction_type.dart';
import '../utils/colors.dart';
import '../widgets/bottomsheet.dart';
import 'create_hawala_screen.dart';

class HawalaListScreen extends StatefulWidget {
  HawalaListScreen({super.key});

  @override
  State<HawalaListScreen> createState() => _HawalaListScreenState();
}

class _HawalaListScreenState extends State<HawalaListScreen> {
  final box = GetStorage();

  final hawalalistController = Get.find<HawalaListController>();

  final Mypagecontroller mypagecontroller = Get.find();

  LanguagesController languagesController = Get.put(LanguagesController());

  BranchController branchController = Get.put(BranchController());

  final ScrollController scrollController = ScrollController();

  Future<void> refresh() async {
    final int totalPages =
        hawalalistController.allhawalalist.value.data!.pagination!.totalPages ??
        0;
    final int currentPage = hawalalistController.initialpage;

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
      hawalalistController.initialpage++;

      // Prevent fetching if the next page exceeds total pages
      if (hawalalistController.initialpage <= totalPages) {
        print("Load More...................");
        hawalalistController.fetchhawala();
      } else {
        hawalalistController.initialpage =
            totalPages; // Reset to the last valid page
        print("Already on the last page");
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );
    hawalalistController.finalList.clear();
    hawalalistController.initialpage = 1;

    hawalalistController.fetchhawala();
    branchController.fetchallbranch();
    scrollController.addListener(refresh);
  }

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
                        () => KText(
                          text: languagesController.tr("HAWALA_ORDER_LIST"),
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
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 50,
                width: screenWidth,
                child: Row(
                  children: [
                    // Expanded(
                    //   flex: 5,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       border: Border.all(
                    //         width: 1,
                    //         color: Colors.grey.shade400,
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     child: Padding(
                    //       padding: const EdgeInsets.symmetric(horizontal: 10),
                    //       child: TextField(
                    //         decoration: InputDecoration(
                    //           border: InputBorder.none,
                    //           hintText: languagesController.tr("SEARCH"),
                    //           hintStyle: TextStyle(
                    //             color: Colors.grey,
                    //             fontSize: screenHeight * 0.020,
                    //             fontFamily:
                    //                 Get.find<FontController>().currentFont,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: GestureDetector(
                        onTap: () {
                          mypagecontroller.changePage(
                            HawalaScreen(),
                            isMainPage: false,
                          );
                        },
                        child: DefaultButton1(
                          width: double.maxFinite,
                          height: 50,
                          buttonName: languagesController.tr("NEW_ORDER"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Obx(
                () => hawalalistController.isLoading.value == false
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: RefreshIndicator(
                          onRefresh: refresh,
                          child: ListView.separated(
                            padding: EdgeInsets.all(0),
                            physics: AlwaysScrollableScrollPhysics(),
                            controller: scrollController,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 5);
                            },
                            itemCount: hawalalistController.finalList.length,
                            itemBuilder: (context, index) {
                              final data =
                                  hawalalistController.finalList[index];
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            17,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.all(0),
                                        content: HawalaDetailsDialog(
                                          id: data.id.toString(),
                                          hawalaNumber: data.hawalaNumber,
                                          status: data.status,
                                          branchID: data.hawalaBranchId,
                                          senderName: data.senderName,
                                          receiverName: data.receiverName,
                                          fatherName: data.receiverFatherName,
                                          idcardnumber:
                                              data.receiverIdCardNumber,
                                          amount: data.hawalaAmount,
                                          hawalacurrencyRate:
                                              data.hawalaAmountCurrencyRate,
                                          hawalacurrencyCode:
                                              data.hawalaAmountCurrencyCode,
                                          resellercurrencyCode:
                                              data.resellerPreferedCurrencyCode,
                                          resellCurrencyRate:
                                              data.resellerPreferedCurrencyRate,
                                          paidbysender: data
                                              .commissionPaidBySender
                                              .toString(),
                                          paidbyreceiver: data
                                              .commissionPaidByReceiver
                                              .toString(),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  width: screenWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      width: 1,
                                      color: data.status.toString() == "pending"
                                          ? Color(0xffFFC107)
                                          : data.status.toString() ==
                                                "confirmed"
                                          ? Colors.green
                                          : Color(0xffFF4842),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color:
                                              data.status.toString() ==
                                                  "pending"
                                              ? Color(0xffFFC107)
                                              : data.status.toString() ==
                                                    "confirmed"
                                              ? Colors.green
                                              : Color(0xffFF4842),
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            topLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 5,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              data.hawalaCustomNumber == null
                                                  ? Text(
                                                      languagesController.tr(
                                                            "HAWALA_NUMBER",
                                                          ) +
                                                          " - " +
                                                          data.hawalaNumber
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )
                                                  : Text(
                                                      languagesController.tr(
                                                            "HAWALA_NUMBER",
                                                          ) +
                                                          " - " +
                                                          data.hawalaCustomNumber
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                              Text(
                                                data.status.toString(),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
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
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  languagesController.tr(
                                                    "SENDER_NAME",
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.w400,
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
                                                Text(
                                                  data.senderName.toString(),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
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
                                              ],
                                            ),
                                            SizedBox(height: 3),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  languagesController.tr(
                                                    "RECEIVER_NAME",
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.w400,
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
                                                Text(
                                                  data.receiverName.toString(),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
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
                                              ],
                                            ),
                                            SizedBox(height: 3),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  languagesController.tr(
                                                    "HAWALA_AMOUNT",
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.w400,
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
                                                Text(
                                                  data.hawalaAmount.toString(),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 3),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  languagesController.tr(
                                                    "PAYABLE_AMOUNT",
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.w400,
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
                                                Text(
                                                  data.hawalaAmountCurrencyRate
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
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
                              );
                            },
                          ),
                        ),
                      )
                    : Center(child: CircularProgressIndicator()),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class HawalaDetailsDialog extends StatelessWidget {
  HawalaDetailsDialog({
    super.key,
    this.id,
    this.hawalaNumber,
    this.hawalaCustomNumber,
    this.status,
    this.branchID,
    this.senderName,
    this.receiverName,
    this.fatherName,
    this.idcardnumber,
    this.amount,
    this.hawalacurrencyRate,
    this.hawalacurrencyCode,
    this.resellercurrencyCode,
    this.resellCurrencyRate,
    this.paidbysender,
    this.paidbyreceiver,
  });
  String? id;
  String? hawalaNumber;
  String? hawalaCustomNumber;
  String? status;
  String? branchID;
  String? senderName;
  String? receiverName;
  String? fatherName;
  String? idcardnumber;
  String? amount;
  String? hawalacurrencyRate;
  String? hawalacurrencyCode;
  String? resellercurrencyCode;
  String? resellCurrencyRate;
  String? paidbysender;
  String? paidbyreceiver;

  LanguagesController languagesController = Get.put(LanguagesController());

  final box = GetStorage();
  BranchController branchController = Get.put(BranchController());

  CancelHawalaController cancelHawalaController = Get.put(
    CancelHawalaController(),
  );

  RxBool isopen = true.obs;

  final GlobalKey catpureKey = GlobalKey();
  final GlobalKey _shareKey = GlobalKey();

  Color _getStatusColor() {
    switch (status.toString()) {
      case "pending":
        return Color(0xffFFC107);
      case "confirmed":
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  String _getStatusIcon() {
    switch (status.toString()) {
      case "pending":
        return "assets/icons/pending.png";
      case "confirmed":
        return "assets/icons/successful.png";
      default:
        return "assets/icons/rejected.png";
    }
  }

  String _getStatusText() {
    switch (status.toString()) {
      case "pending":
        return languagesController.tr("PENDING");
      case "confirmed":
        return languagesController.tr("CONFIRMED");
      default:
        return languagesController.tr("REJECTED");
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    bool isFarsi = box.read("language").toString() == "Fa";
    String? fontFamily = isFarsi
        ? Get.find<FontController>().currentFont
        : null;

    return Container(
      height: 570,
      width: screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Main Receipt Card
            RepaintBoundary(
              key: catpureKey,
              child: RepaintBoundary(
                key: _shareKey,
                child: Container(
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(width: 2, color: _getStatusColor()),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor().withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Logo
                        Image.asset("assets/icons/logo.png", height: 50),
                        SizedBox(height: 8),

                        // Status Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                _getStatusIcon(),
                                height: 20,
                                width: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                _getStatusText(),
                                style: TextStyle(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 10),

                        // Hawala Number
                        _buildInfoRow(
                          label: languagesController.tr("HAWALA_NUMBER"),
                          value: hawalaCustomNumber ?? hawalaNumber.toString(),
                          fontFamily: fontFamily,
                          isHighlight: true,
                        ),

                        Divider(height: 10, color: Colors.grey.shade300),

                        // Amount
                        _buildInfoRow(
                          label: languagesController.tr("HAWALA_AMOUNT"),
                          value: amount.toString(),
                          fontFamily: fontFamily,
                          valueStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),

                        // Sender
                        _buildInfoRow(
                          label: languagesController.tr("SENDER_NAME"),
                          value: senderName.toString(),
                          fontFamily: fontFamily,
                        ),

                        // Receiver
                        _buildInfoRow(
                          label: languagesController.tr("RECEIVER_NAME"),
                          value: receiverName.toString(),
                          fontFamily: fontFamily,
                        ),

                        SizedBox(height: 10),

                        // Branch Information Card
                        Container(
                          width: screenWidth,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryColor.withOpacity(0.08),
                                AppColors.primaryColor.withOpacity(0.12),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Branch Name
                                _buildInfoRow(
                                  label: languagesController.tr("BRANCH"),
                                  value: branchController
                                      .allbranch
                                      .value
                                      .data!
                                      .hawalabranches!
                                      .firstWhere(
                                        (item) =>
                                            item.id.toString() ==
                                            branchID.toString(),
                                      )
                                      .name
                                      .toString(),
                                  fontFamily: fontFamily,
                                  compact: true,
                                ),

                                SizedBox(height: 5),

                                // Address
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        languagesController.tr("ADDRESS"),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                          fontFamily: fontFamily,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        branchController
                                            .allbranch
                                            .value
                                            .data!
                                            .hawalabranches!
                                            .firstWhere(
                                              (item) =>
                                                  item.id.toString() ==
                                                  branchID.toString(),
                                            )
                                            .address
                                            .toString(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 5),

                                // Phone Number
                                _buildInfoRow(
                                  label: languagesController.tr("PHONE_NUMBER"),
                                  value: branchController
                                      .allbranch
                                      .value
                                      .data!
                                      .hawalabranches!
                                      .firstWhere(
                                        (item) =>
                                            item.id.toString() ==
                                            branchID.toString(),
                                      )
                                      .phoneNumber
                                      .toString(),
                                  fontFamily: fontFamily,
                                  compact: true,
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

            SizedBox(height: 8),

            // Action Buttons Row
            Container(
              height: 45,
              width: screenWidth,
              child: Row(
                children: [
                  Expanded(
                    child: _buildOutlinedButton(
                      onTap: () async {
                        capturePng(catpureKey);
                      },
                      label: languagesController.tr("SAVE_TO_GALLERY"),
                      fontFamily: fontFamily,

                      icon: Icons.download_rounded,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildFilledButton(
                      onTap: () async {
                        captureImageFromWidgetAsFile(_shareKey);
                      },
                      label: languagesController.tr("SHARE"),
                      fontFamily: fontFamily,
                      icon: Icons.share_rounded,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 5),

            // Cancel Order Button with Animation
            Obx(
              () => AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: isopen.value
                    ? Visibility(
                        visible: status.toString() == "pending",
                        child: GestureDetector(
                          onTap: () {
                            isopen.value = false;
                          },
                          child: Container(
                            key: ValueKey('cancel'),
                            height: 45,
                            width: screenWidth,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                languagesController.tr("CANCEL_ORDER"),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        key: ValueKey('confirm'),
                        height: 45,
                        width: screenWidth,
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  isopen.value = true;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade600,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      languagesController.tr("NO"),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        fontFamily: fontFamily,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  cancelHawalaController.cancelnow(id);
                                  print(id.toString());
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      languagesController.tr("YES"),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        fontFamily: fontFamily,
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
            ),

            SizedBox(height: 5),

            // Close Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 45,
                width: screenWidth,
                decoration: BoxDecoration(
                  border: Border.all(width: 1.5, color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Center(
                  child: Text(
                    languagesController.tr("CLOSE"),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontFamily: fontFamily,
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

  Widget _buildInfoRow({
    required String label,
    required String value,
    String? fontFamily,
    bool isHighlight = false,
    bool compact = false,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 13 : 14,
            color: Colors.grey.shade700,
            fontFamily: fontFamily,
          ),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style:
                valueStyle ??
                TextStyle(
                  fontSize: compact ? 13 : 14,
                  fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
                  color: isHighlight ? AppColors.primaryColor : Colors.black87,
                  fontFamily: fontFamily,
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedButton({
    required VoidCallback onTap,
    required String label,
    String? fontFamily,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.primaryColor),
                SizedBox(width: 6),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilledButton({
    required VoidCallback onTap,
    required String label,
    String? fontFamily,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
