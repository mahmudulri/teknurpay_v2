import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/global_controller/page_controller.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:teknurpay/widgets/button_one.dart';
import 'package:teknurpay/widgets/custom_text.dart';

import '../controllers/create_withdraw_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/languages_controller.dart';
import '../widgets/authtextfield.dart';

class CreateWithdrawScreen extends StatelessWidget {
  CreateWithdrawScreen({super.key});

  LanguagesController languagesController = Get.put(LanguagesController());
  CreateWithdrawController createWithdrawController = Get.put(
    CreateWithdrawController(),
  );
  final Mypagecontroller mypagecontroller = Get.find();
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // gradient: LinearGradient(
          //   colors: [Color(0xFFE0BCF3), Color(0xFF7EE7EE)],
          //   begin: Alignment.centerLeft,
          //   end: Alignment.centerRight,
          // ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 0, right: 0, top: 0),
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
                            text: languagesController.tr("CREATE_NEW_WITHDRAW"),
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

              /// ================= ACCOUNT NAME
              Text(
                languagesController.tr("AMOUNT"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.amountController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),
              Text(
                languagesController.tr("ACCOUNT_NAME"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.accountNameController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= ACCOUNT NUMBER
              Text(
                languagesController.tr("ACCOUNT_NUMBER"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.accountNumberController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= BANK NAME
              Text(
                languagesController.tr("BANK_NAME"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.bankNameController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= NOTES
              Text(
                languagesController.tr("NOTES"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.notesController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= BANK DETAILS TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    languagesController.tr("BANK_DETAILS"),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenHeight * 0.022,
                      fontFamily: box.read("language").toString() == "Fa"
                          ? Get.find<FontController>().currentFont
                          : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              /// ================= BANK DETAIL NAME
              Text(
                languagesController.tr("BANK_NAME"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.bankDetailNameController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= ACCOUNT HOLDER NAME
              Text(
                languagesController.tr("ACCOUNT_HOLDER_NAME"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.bankHolderNameController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= BANK ACCOUNT NUMBER
              Text(
                languagesController.tr("ACCOUNT_NUMBER"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller:
                    createWithdrawController.bankAccountNumberController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= IBAN
              Text(
                languagesController.tr("IBAN"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.ibanController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= BRANCH
              Text(
                languagesController.tr("BRANCH"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.branchController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= SWIFT CODE
              Text(
                languagesController.tr("SWIFT_CODE"),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: screenHeight * 0.020,
                  fontFamily: box.read("language").toString() == "Fa"
                      ? Get.find<FontController>().currentFont
                      : null,
                ),
              ),
              SizedBox(height: 5),
              Authtextfield(
                controller: createWithdrawController.swiftCodeController,
                hinttext: languagesController.tr(""),
              ),

              SizedBox(height: 10),

              /// ================= SUBMIT BUTTON (UNCHANGED STYLE)
              Obx(
                () => DefaultButton(
                  buttonName: createWithdrawController.isLoading.value == false
                      ? languagesController.tr("CREATE_NOW")
                      : languagesController.tr("PLEASE_WAIT"),
                  mycolor: Colors.green,
                  onpressed: createWithdrawController.isLoading.value
                      ? null
                      : () {
                          createWithdrawController.createBankWithdraw();
                        },
                ),
              ),

              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
