import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/accounting_currency_controller.dart';
import '../controllers/create_counter_party_controller.dart';
import '../global_controller/languages_controller.dart';
import '../widgets/accountextfield.dart';

class CreateCounterparyScreen extends StatefulWidget {
  CreateCounterparyScreen({super.key});

  @override
  State<CreateCounterparyScreen> createState() =>
      _CreateCounterparyScreenState();
}

class _CreateCounterparyScreenState extends State<CreateCounterparyScreen> {
  CreateCounterPartyController formController = Get.put(
    CreateCounterPartyController(),
  );

  AccountingCurrencyController currencyController = Get.put(
    AccountingCurrencyController(),
  );

  final languageController = Get.find<LanguagesController>();

  List accountTypeOptions = [];

  List typeOptions = [];

  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    currencyController.fetchCurrencyList();
    accountTypeOptions = [
      {"title": languageController.tr("SAVING"), "value": "saving"},
      {"title": languageController.tr("CURRENT"), "value": "current"},
      {"title": languageController.tr("FIXED"), "value": "fixed"},
    ];

    typeOptions = [
      {"title": languageController.tr("SUPPLIER"), "value": "supplier"},
      {"title": languageController.tr("CUSTOMER"), "value": "customer"},
      {"title": languageController.tr("DISTRIBUTOR"), "value": "distributor"},
    ];
  }

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          languageController.tr("CREATE_COUNTER_PARTY"),
          style: GoogleFonts.rubik(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.white,
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 13),
            child: ListView(
              children: [
                SizedBox(height: 15),
                Accountextfield(
                  controller: formController.nameController,
                  label: languageController.tr("NAME"),
                  hint: languageController.tr("COUNTER_PARTY_NAME"),

                  height: 55,
                ),

                SizedBox(height: 15),

                Accountextfield(
                  keyboardType: TextInputType.number,
                  controller: formController.phoneController,
                  label: languageController.tr("PHONE_NUMBER"),
                  hint: languageController.tr("ENTER_PHONE_NUMBER"),

                  height: 55,
                ),

                SizedBox(height: 15),

                Accountextfield(
                  controller: formController.emailController,
                  label: languageController.tr("EMAIL"),
                  hint: languageController.tr("ENTER_EMAIL_ADDRESS"),

                  height: 55,
                ),

                SizedBox(height: 15),

                SizedBox(
                  height: 55,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: languageController.tr("TYPE"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: box.read("direction") == "rtl" ? 12 : 15,
                        horizontal: 12,
                      ),
                    ),
                    value: formController.selectedType.value.isEmpty
                        ? null
                        : formController.selectedType.value,
                    items: typeOptions.map((item) {
                      return DropdownMenuItem(
                        value: item["value"],
                        child: Text(item["title"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      formController.selectedType.value = value.toString();
                    },
                  ),
                ),

                SizedBox(height: 20),
                SizedBox(
                  height: 55,
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: languageController.tr("ACCOUNT_TYPE"),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: box.read("direction") == "rtl" ? 12 : 15,
                        horizontal: 12,
                      ),
                    ),
                    value: formController.selectedAccountType.value.isEmpty
                        ? null
                        : formController.selectedAccountType.value,
                    items: accountTypeOptions.map((item) {
                      return DropdownMenuItem(
                        value: item["value"],
                        child: Text(item["title"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      formController.selectedAccountType.value = value
                          .toString();
                    },
                  ),
                ),

                SizedBox(height: 10),

                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        languageController.tr("CREATE_DEFAULT_ACCOUNT"),
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Switch(
                        value: formController.createDefaultAccount.value,
                        onChanged: (val) =>
                            formController.createDefaultAccount.value = val,
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  languageController.tr("CURRENCY"),
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
                                    formController.currencyController.text =
                                        data.code.toString();
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
                  controller: formController.balanceController,
                  label: languageController.tr("OPENING_BALANCE"),
                  hint: languageController.tr("ENTER_OPENING_BALANCE"),

                  height: 55,
                ),

                SizedBox(height: 20),
                Obx(
                  () => GestureDetector(
                    onTap: () {
                      final c = Get.find<CreateCounterPartyController>();

                      if (c.nameController.text.trim().isEmpty) {
                        Fluttertoast.showToast(
                          msg: languageController.tr("NAME_IS_REQUIRED"),
                          backgroundColor: Colors.red,
                          textColor: Colors.white,

                          gravity: ToastGravity.CENTER,
                        );
                        return;
                      }

                      if (c.phoneController.text.trim().isEmpty) {
                        Fluttertoast.showToast(
                          msg: languageController.tr(
                            "PHONE_NUMBER_IS_REQUIRED",
                          ),
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        );
                        return;
                      }

                      // Phone validation
                      final phone = c.phoneController.text.trim();
                      if (!RegExp(r'^[0-9]{6,15}$').hasMatch(phone)) {
                        Fluttertoast.showToast(
                          msg: languageController.tr(
                            "ENTER_A_VALID_PHONE_NUMBER",
                          ),
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          gravity: ToastGravity.CENTER,
                        );
                        return;
                      }

                      if (c.emailController.text.trim().isEmpty) {
                        Fluttertoast.showToast(
                          msg: languageController.tr("EMAIL_IS_REQUIRED"),
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          gravity: ToastGravity.CENTER,
                        );
                        return;
                      }

                      // Email validation
                      final email = c.emailController.text.trim();
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(email)) {
                        Fluttertoast.showToast(
                          msg: languageController.tr(
                            "ENTER_A_VALID_EMAIL_ADDRESS",
                          ),
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          gravity: ToastGravity.CENTER,
                        );
                        return;
                      }

                      if (c.currencyController == null ||
                          c.currencyController.text.trim().isEmpty) {
                        Fluttertoast.showToast(
                          msg: languageController.tr(
                            "PLEASE_SELECT_A_CURRENCY",
                          ),
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          gravity: ToastGravity.CENTER,
                        );
                        return;
                      }

                      // -------------------------
                      // IF ALL OK → SEND API
                      // -------------------------
                      c.createNow();
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
                          formController.isLoading.value == false
                              ? languageController.tr("CREATE_NOW")
                              : languageController.tr("PLEASE_WAIT"),
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
    );
  }

  Widget textfield(double width, TextEditingController controller) {
    return Container(
      height: 55,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 13),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }
}
