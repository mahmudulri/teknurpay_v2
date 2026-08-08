import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:teknurpay/widgets/custom_text.dart';

import '../controllers/withdrawlist_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';
import 'create_withdraw_screen.dart';

class WithdrawScreen extends StatefulWidget {
  WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  LanguagesController languagesController = Get.put(LanguagesController());
  final box = GetStorage();

  // final withdrawlistController = Get.find<WithdrawlistController>();

  final WithdrawlistController withdrawlistController = Get.put(
    WithdrawlistController(),
  );

  final Mypagecontroller mypagecontroller = Get.find();

  @override
  void initState() {
    super.initState();
    withdrawlistController.fetchlist();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15, top: 0),
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
                            text: languagesController.tr("WITHDRAW"),
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 50,
                  width: screenWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      mypagecontroller.changePage(
                        CreateWithdrawScreen(),
                        isMainPage: false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Color(0xFF2575FC).withOpacity(0.4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_card, size: 22),
                        SizedBox(width: 8),
                        Text(
                          languagesController.tr("NEW_WITHDRAW_REQUEST"),

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (withdrawlistController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      ),
                    );
                  }

                  if (withdrawlistController
                              .allwithdrawlist
                              .value
                              .data
                              ?.withdrawRequests ==
                          null ||
                      withdrawlistController
                          .allwithdrawlist
                          .value
                          .data!
                          .withdrawRequests!
                          .isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 80,
                            color: Colors.white60,
                          ),
                          SizedBox(height: 16),
                          Text(
                            languagesController.tr("NO_DATA_FOUND"),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily:
                                  box.read("language").toString() == "Fa"
                                  ? Get.find<FontController>().currentFont
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: BouncingScrollPhysics(),

                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: withdrawlistController
                        .allwithdrawlist
                        .value!
                        .data!
                        .withdrawRequests!
                        .length,
                    itemBuilder: (context, index) {
                      final request = withdrawlistController
                          .allwithdrawlist
                          .value!
                          .data!
                          .withdrawRequests![index];

                      return _buildWithdrawCard(
                        request,
                        screenHeight,
                        screenWidth,
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawCard(
    dynamic request,
    double screenHeight,
    double screenWidth,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Amount Section
          Container(
            padding: EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountDetail(
                      languagesController.tr("AMOUNT"),
                      request.amount ?? '0',
                      Colors.blue.shade700,
                    ),
                    _buildAmountDetail(
                      languagesController.tr("COMMISSION"),
                      request.commissionAmount ?? '0',
                      Colors.orange.shade700,
                    ),
                  ],
                ),

                SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        languagesController.tr("NET_AMOUNT"),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade900,
                          fontFamily: box.read("language").toString() == "Fa"
                              ? Get.find<FontController>().currentFont
                              : null,
                        ),
                      ),
                      Text(
                        '${request.netAmount ?? '0'}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                          fontFamily: box.read("language").toString() == "Fa"
                              ? Get.find<FontController>().currentFont
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                // Status Text
                Text(
                  '${languagesController.tr("STATUS")}: ${request.status?.toUpperCase() ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(request.status),
                    fontFamily: box.read("language").toString() == "Fa"
                        ? Get.find<FontController>().currentFont
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // Bank Details Section
          if (request.bankDetails != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 6),
                      Text(
                        languagesController.tr("BANK_DETAILS"),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                          fontFamily: box.read("language").toString() == "Fa"
                              ? Get.find<FontController>().currentFont
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  _buildBankDetailRow(
                    languagesController.tr("BANK_NAME"),
                    request.bankDetails!.bankName ?? 'N/A',
                  ),
                  _buildBankDetailRow(
                    languagesController.tr("ACCOUNT_HOLDER"),
                    request.bankDetails!.accountHolderName ?? 'N/A',
                  ),
                  _buildBankDetailRow(
                    languagesController.tr("ACCOUNT_NUMBER"),
                    request.bankDetails!.accountNumber ?? 'N/A',
                  ),
                  if (request.bankDetails!.iban != null &&
                      request.bankDetails!.iban!.isNotEmpty)
                    _buildBankDetailRow(
                      languagesController.tr("IBAN"),
                      request.bankDetails!.iban!,
                    ),
                  SizedBox(height: 8),
                  // Date Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateInfo(
                        Icons.calendar_today,
                        languagesController.tr("CREATED"),
                        request.createdAt != null
                            ? DateFormat(
                                'dd MMM yyyy',
                              ).format(request.createdAt!)
                            : 'N/A',
                      ),
                      _buildDateInfo(
                        Icons.update,
                        languagesController.tr("UPDATED"),
                        request.updatedAt != null
                            ? DateFormat(
                                'dd MMM yyyy',
                              ).format(request.updatedAt!)
                            : 'N/A',
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAmountDetail(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontFamily: box.read("language").toString() == "Fa"
                ? Get.find<FontController>().currentFont
                : null,
          ),
        ),
        SizedBox(height: 2),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: box.read("language").toString() == "Fa"
                ? Get.find<FontController>().currentFont
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontFamily: box.read("language").toString() == "Fa"
                  ? Get.find<FontController>().currentFont
                  : null,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontFamily: box.read("language").toString() == "Fa"
                    ? Get.find<FontController>().currentFont
                    : null,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(IconData icon, String label, String date) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade600),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                fontFamily: box.read("language").toString() == "Fa"
                    ? Get.find<FontController>().currentFont
                    : null,
              ),
            ),
            Text(
              date,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontFamily: box.read("language").toString() == "Fa"
                    ? Get.find<FontController>().currentFont
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
