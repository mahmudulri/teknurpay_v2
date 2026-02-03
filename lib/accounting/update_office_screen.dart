import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/accounting_currency_controller.dart';

import '../controllers/create_office_controller.dart';
import '../global_controller/languages_controller.dart';
import '../widgets/accountextfield.dart';
import '../widgets/drawer.dart';

class UpdateOfficeScreen extends StatefulWidget {
  UpdateOfficeScreen({
    super.key,
    this.officeName,
    this.defaultAccountName,
    this.phoneNumber,
    this.codeNumber,
    this.location,
    this.address,
    this.isActive,
    this.notes,
    this.currencyCode,
    this.openingBalance,
  });

  String? officeName;
  String? defaultAccountName;
  String? phoneNumber;
  String? codeNumber;
  String? location;
  String? address;
  String? isActive;
  String? notes;
  String? currencyCode;
  String? openingBalance;

  @override
  State<UpdateOfficeScreen> createState() => _UpdateOfficeScreenState();
}

class _UpdateOfficeScreenState extends State<UpdateOfficeScreen> {
  final languagesController = Get.find<LanguagesController>();

  AccountingCurrencyController currencyController = Get.put(
    AccountingCurrencyController(),
  );

  CreateOfficeController createOfficeController = Get.put(
    CreateOfficeController(),
  );

  bool isActive = false;

  int selectedIndex = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currencyController.fetchCurrencyList();
  }

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              languagesController.tr("UPDATE_OFFICE"),
              style: GoogleFonts.rubik(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,

              child: Image.asset("assets/icons/headphone.png", height: 25),
            ),
            SizedBox(width: 5),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,

              child: Image.asset("assets/icons/bell.png", height: 25),
            ),
            SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(languagesController.tr("LANGUAGES")),
                      content: Container(
                        height: 350,
                        width: screenWidth,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: languagesController.alllanguagedata.length,
                          itemBuilder: (context, index) {
                            final data =
                                languagesController.alllanguagedata[index];
                            return GestureDetector(
                              onTap: () {
                                final languageName = data["name"].toString();

                                final matched = languagesController
                                    .alllanguagedata
                                    .firstWhere(
                                      (lang) => lang["name"] == languageName,
                                      orElse: () => {
                                        "isoCode": "en",
                                        "direction": "ltr",
                                      },
                                    );

                                final languageISO = matched["isoCode"]!;
                                final languageDirection = matched["direction"]!;

                                // Store selected language & direction
                                languagesController.changeLanguage(
                                  languageName,
                                );
                                box.write("language", languageName);
                                box.write("direction", languageDirection);

                                // Set locale based on ISO
                                Locale locale;
                                switch (languageISO) {
                                  case "fa":
                                    locale = Locale("fa", "IR");
                                    break;
                                  case "ar":
                                    locale = Locale("ar", "AE");
                                    break;
                                  case "ps":
                                    locale = Locale("ps", "AF");
                                    break;
                                  case "tr":
                                    locale = Locale("tr", "TR");
                                    break;
                                  case "bn":
                                    locale = Locale("bn", "BD");
                                    break;
                                  case "en":
                                  default:
                                    locale = Locale("en", "US");
                                }

                                // Set app locale
                                setState(() {
                                  EasyLocalization.of(
                                    context,
                                  )!.setLocale(locale);
                                });

                                // Pop dialog
                                Navigator.pop(context);

                                print(
                                  "🌐 Language changed to $languageName ($languageISO), Direction: $languageDirection",
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 5),
                                height: 45,
                                width: screenWidth,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Center(
                                        child: Text(
                                          languagesController
                                              .alllanguagedata[index]["fullname"]
                                              .toString(),
                                        ),
                                      ),
                                    ],
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
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade100,

                child: Image.asset("assets/icons/gridmenu.png", height: 25),
              ),
            ),
          ],
        ),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.white,
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFC5E3FF)],
          ),
        ),

        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          child: Container(
            margin: EdgeInsets.only(bottom: 60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 8, left: 8, right: 8),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  SizedBox(height: 10),
                  Accountextfield(
                    controller: createOfficeController.nameController,
                    label: languagesController.tr("NAME"),
                    hint: languagesController.tr("NAME_OF_THE_OFFICE"),

                    height: 55,
                  ),
                  SizedBox(height: 20),
                  Accountextfield(
                    controller: createOfficeController.defaultnameController,
                    label: languagesController.tr("DEFAULT_ACCOUNT_NAME"),
                    hint: languagesController.tr("ENTER_DEFAULT_ACCOUNT_NAME"),

                    height: 55,
                  ),

                  SizedBox(height: 20),

                  Accountextfield(
                    keyboardType: TextInputType.number,
                    controller: createOfficeController.phoneController,
                    label: languagesController.tr("PHONE_NUMBER"),
                    hint: languagesController.tr("ENTER_PHONE_NUMBER"),

                    height: 55,
                  ),

                  SizedBox(height: 20),

                  Accountextfield(
                    controller: createOfficeController.idController,
                    label: languagesController.tr("ID_NUMBER"),
                    hint: languagesController.tr("ENTER_ID_NUMBER"),

                    height: 55,
                  ),

                  SizedBox(height: 20),

                  Accountextfield(
                    controller: createOfficeController.locationController,
                    label: languagesController.tr("LOCATION"),
                    hint: languagesController.tr("ENTER_LOCATION"),

                    height: 55,
                  ),

                  SizedBox(height: 20),

                  Accountextfield(
                    controller: createOfficeController.addressController,
                    label: languagesController.tr("ADDRESS"),
                    hint: languagesController.tr("ENTER_ADDRESS"),

                    height: 55,
                  ),

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        languagesController.tr("IN_ACTIVE"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5),
                      Transform.scale(
                        scale: 1.3,
                        child: Switch(
                          activeThumbColor: Colors.green,
                          value: createOfficeController.isactive.value,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                              createOfficeController.isactive.value = value;
                              print(
                                createOfficeController.isactive.value
                                    .toString(),
                              );
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        languagesController.tr("ACTIVE"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Accountextfield(
                    controller: createOfficeController.notesController,
                    label: languagesController.tr("NOTES"),
                    hint: languagesController.tr("ENTER_NOTES"),

                    height: 55,
                  ),

                  SizedBox(height: 8),
                  Text(
                    languagesController.tr("CURRENCY"),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 40,
                    width: screenWidth,

                    child: Obx(
                      () => currencyController.isLoading.value == false
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: currencyController
                                  .allcurrencylist
                                  .value
                                  .data!
                                  .length,
                              itemBuilder: (context, index) {
                                final data = currencyController
                                    .allcurrencylist
                                    .value
                                    .data![index];

                                final bool isSelected = selectedIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedIndex = index;
                                      createOfficeController
                                          .currencyController
                                          .text = data.code
                                          .toString();
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: isSelected
                                            ? Color(0xffD850E7)
                                            : Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),

                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      child: Center(
                                        child: Text(
                                          data.code.toString(),
                                          style: TextStyle(
                                            fontSize: 15,

                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : SizedBox(),
                    ),
                  ),
                  SizedBox(height: 20),

                  Accountextfield(
                    keyboardType: TextInputType.number,
                    controller: createOfficeController.amountController,
                    label: languagesController.tr("OPENING_BALANCE"),
                    hint: languagesController.tr("ENTER_OPENING_BALANCE"),

                    height: 55,
                  ),

                  SizedBox(height: 10),
                  Obx(
                    () => GestureDetector(
                      onTap: () {
                        createOfficeController.createnow();
                      },
                      child: Container(
                        height: 55,
                        width: screenWidth,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/svg/abutton.webp"),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            createOfficeController.isLoading.value == false
                                ? languagesController.tr("UPDATE_OFFICE_NOW")
                                : languagesController.tr("PLEASE_WAIT"),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
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
      ),
    );
  }
}
