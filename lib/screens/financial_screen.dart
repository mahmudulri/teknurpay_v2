import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:teknurpay/utils/colors.dart';

import '../controllers/dashboard_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';
import '../pages/homepages.dart';
import '../widgets/bottomsheet.dart';
import '../widgets/custom_text.dart';

class FinancialScreen extends StatelessWidget {
  FinancialScreen({super.key});

  LanguagesController languagesController = Get.put(LanguagesController());

  final Mypagecontroller mypagecontroller = Get.find();

  final box = GetStorage();

  final dashboardController = Get.find<DashboardController>();
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat("dd MMM yyyy").format(DateTime.now());
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
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
                          text: languagesController.tr("FINANCIAL_REPORT"),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
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
                height: 120,
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
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languagesController.tr("DATE"),
                                  style: TextStyle(
                                    color: AppColors.fontColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              KText(
                                text: languagesController.tr("CURRENCY"),
                                color: AppColors.fontColor,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 4,
                                  ),
                                  child: KText(
                                    text: box.read("currency_code"),
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
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
            ),
            SizedBox(height: 10),
            BalanceBox(
              imagelink: "assets/icons/wallet.png",
              boxname: languagesController.tr("BALANCE"),
              balance: dashboardController.userBalanceController.balance
                  .toString(),
            ),
            SizedBox(height: 8),
            BalanceBox(
              imagelink: "assets/icons/sales.png",
              boxname: languagesController.tr("SALE"),
              balance: dashboardController
                  .alldashboardData
                  .value
                  .data!
                  .totalSoldAmount
                  .toString(),
            ),
            SizedBox(height: 8),
            BalanceBox(
              imagelink: "assets/icons/debit.png",
              boxname: languagesController.tr("DEBIT"),
              balance: dashboardController
                  .alldashboardData
                  .value
                  .data!
                  .totalSoldAmount
                  .toString(),
            ),
            SizedBox(height: 8),
            BalanceBox(
              imagelink: "assets/icons/profit.png",
              boxname: languagesController.tr("PROFIT"),
              balance: dashboardController
                  .alldashboardData
                  .value
                  .data!
                  .totalRevenue
                  .toString(),
            ),
            SizedBox(height: 8),
            BalanceBox(
              imagelink: "assets/icons/loan.png",
              boxname: languagesController.tr("LOAN_BALANCE"),
              balance: dashboardController
                  .alldashboardData
                  .value
                  .data!
                  .loanBalance
                  .toString(),
            ),
            SizedBox(height: 8),
            BalanceBox(
              imagelink: "assets/icons/comission.png",
              boxname: languagesController.tr("COMISSION"),
              balance: dashboardController
                  .alldashboardData
                  .value
                  .data!
                  .userInfo!
                  .totalearning
                  .toString(),
            ),
          ],
        ),
      ),
    );
  }
}

class BalanceBox extends StatelessWidget {
  BalanceBox({super.key, this.imagelink, this.boxname, this.balance});

  String? imagelink;
  String? boxname;
  String? balance;

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: 60,
        width: double.maxFinite,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.50),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Image.asset(
                    imagelink.toString(),
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 6),
              KText(
                text: boxname.toString(),
                color: AppColors.fontColor,
                fontSize: 16,
              ),
              Spacer(),
              Text(
                balance.toString(),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              SizedBox(width: 6),
              KText(
                text: box.read("currency_code"),
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
