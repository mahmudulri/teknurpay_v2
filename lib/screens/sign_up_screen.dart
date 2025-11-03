import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';

import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/authtextfield.dart';
import 'package:teknurpay/widgets/social_button.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  LanguagesController languagesController = Get.put(LanguagesController());

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Image.asset(
                            "assets/images/sign_in_back.png",
                            width: 220,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 10,
                    child: Container(
                      height: 40,
                      width: 60, // Adjusted width to fit the dropdown text
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: DropdownButtonHideUnderline(
                        child: Obx(
                          () => DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            value: languagesController.selectedlan.value,
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 24,
                            ),
                            selectedItemBuilder: (BuildContext context) {
                              return languagesController.alllanguagedata
                                  .map<Widget>(
                                    (data) => Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        data["name"].toString(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList();
                            },
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                languagesController.changeLanguage(newValue);
                              }
                            },
                            items: languagesController.alllanguagedata
                                .map<DropdownMenuItem<String>>((data) {
                                  return DropdownMenuItem<String>(
                                    value: data["name"]
                                        .toString(), // Ensure exact match
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        data["name"].toString(),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                languagesController.tr("REGISTER"),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenHeight * 0.025,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                languagesController.tr("ENTER_YOUR_LOGIN_INFO"),
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: screenHeight * 0.020,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Authtextfield(
                            hinttext: languagesController.tr("USERNAME"),
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: screenHeight * 0.070,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                width: 1,
                                color: AppColors.primaryColor.withOpacity(0.20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Image.asset(
                                          "assets/icons/afghanistan.png",
                                          height: 35,
                                        ),
                                        Text(
                                          "+93",
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w600,
                                            fontSize: screenHeight * 0.020,
                                          ),
                                        ),
                                        Icon(
                                          FontAwesomeIcons.chevronDown,
                                          color: Colors.grey.shade600,
                                          size: screenHeight * 0.020,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Destination phone number",
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Authtextfield(
                            hinttext: languagesController.tr("PASSWORD"),
                          ),
                          SizedBox(height: 12),
                          Container(
                            height: screenHeight * 0.065,
                            width: screenWidth,
                            decoration: BoxDecoration(
                              color: Color(0xff1F5DC1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                languagesController.tr("REGISTER"),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenHeight * 0.022,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(height: 1, color: Colors.grey),
                              ),
                              SizedBox(width: 5),
                              Text("OR"),
                              SizedBox(width: 5),
                              Expanded(
                                child: Container(height: 1, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          SocialButton(),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Have you already registered?",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: screenHeight * 0.018,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  " Login",
                                  style: TextStyle(
                                    color: Color(0xff1890FF),
                                    fontSize: screenHeight * 0.018,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

class languageBox extends StatelessWidget {
  const languageBox({super.key, this.lanName, this.onpressed});
  final String? lanName;
  final VoidCallback? onpressed;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: GestureDetector(
        onTap: onpressed,
        child: Container(
          margin: EdgeInsets.only(bottom: 6),
          height: 40,
          width: screenWidth,
          decoration: BoxDecoration(
            color: Colors.lightBlue,
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              lanName.toString(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
