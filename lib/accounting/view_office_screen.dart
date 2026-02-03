import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/account_list_controller.dart';
import '../controllers/balance_controller.dart';
import '../controllers/counter_party_controller.dart';
import '../controllers/create_transaction_controller.dart';
import '../controllers/office_transactions_controller.dart';
import '../global_controller/languages_controller.dart';
import '../helpers/localtime_helper.dart';
import '../widgets/accountextfield.dart';

class ViewOfficeScreen extends StatefulWidget {
  final String? officeName;
  final String? officeId;
  final String? location;
  final String? phone;
  final String? address;
  final String? defaultName;
  final String? isactive;
  final String? notes;
  final String? currency;
  final String? openingbalance;
  final String? id;
  ViewOfficeScreen({
    super.key,
    this.officeId,
    this.officeName,
    this.phone,
    this.address,
    this.currency,
    this.defaultName,
    this.isactive,
    this.location,
    this.notes,
    this.openingbalance,
    this.id,
  });

  @override
  State<ViewOfficeScreen> createState() => _ViewOfficeScreenState();
}

class _ViewOfficeScreenState extends State<ViewOfficeScreen> {
  final languagesController = Get.find<LanguagesController>();

  OfficeTransactionsListController transactionsListController = Get.put(
    OfficeTransactionsListController(),
  );

  BalanceController balanceController = Get.put(BalanceController());

  AccountListController accountListController = Get.put(
    AccountListController(),
  );
  final box = GetStorage();
  @override
  void initState() {
    super.initState();
    accountListController.fetchaccount(widget.id);
    box.write("officeID", widget.id.toString());
    balanceController.fetchbalance(widget.id);
  }

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
            GestureDetector(
              onTap: () {
                print(transactionsListController.finalList.length.toString());
              },
              child: Text(
                widget.officeName.toString(),
                style: GoogleFonts.rubik(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
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
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade100,

              child: Image.asset("assets/icons/gridmenu.png", height: 25),
            ),
          ],
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFC5E3FF)],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        // Container(
                        //   height: 40,
                        //   width: screenWidth,
                        //   decoration: BoxDecoration(
                        //     border: Border.all(
                        //       width: 1,
                        //       color: Colors.grey.shade300,
                        //     ),
                        //     borderRadius: BorderRadius.circular(8),
                        //   ),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: [
                        //       Icon(Icons.edit, color: Colors.grey, size: 20),
                        //       SizedBox(width: 5),
                        //       Text(
                        //         languagesController.tr("EDIT"),
                        //         style: TextStyle(
                        //           color: Colors.black,
                        //           fontSize: 15,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languagesController.tr("ID_NUMBER"),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.officeId.toString(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languagesController.tr("NAME"),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.officeName.toString(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languagesController.tr("PHONE"),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              widget.phone.toString(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languagesController.tr("LOCATION"),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),

                            Text(
                              widget.location.toString(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languagesController.tr("ADDRESS"),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.address.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languagesController.tr("NOTES"),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                widget.notes.toString(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 40,
                  width: screenWidth,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffFFC107),

                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Obx(
                              () => balanceController.isLoading.value == false
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          balanceController
                                              .balance
                                              .value
                                              .data!
                                              .office!
                                              .summary!
                                              .overall!
                                              .totalPayable
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          languagesController.tr("PAYABLE"),
                                          style: TextStyle(
                                            fontSize: 14,

                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 2, height: 50, color: Colors.black),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xffF5F6F8),

                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: Obx(
                              () => balanceController.isLoading.value == false
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          balanceController
                                              .balance
                                              .value
                                              .data!
                                              .office!
                                              .summary!
                                              .overall!
                                              .totalReceivable
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          languagesController.tr("RECEIVABLE"),
                                          style: TextStyle(
                                            fontSize: 14,

                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Obx(
                        () =>
                            transactionsListController.isLoading.value == false
                            ? ListView.builder(
                                itemCount:
                                    transactionsListController.finalList.length,
                                itemBuilder: (context, index) {
                                  final data = transactionsListController
                                      .finalList[index];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    height: 80,
                                    width: screenWidth,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor:
                                                Colors.grey.shade100,
                                            child: Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(15.0),
                                                child: Image.asset(
                                                  "assets/icons/transicon.png",
                                                  color:
                                                      data.transactionType
                                                              .toString() ==
                                                          "CREDIT"
                                                      ? Color(0xff8E59FF)
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,

                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      data
                                                          .counterpartyAccount!
                                                          .name
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      data.transactionType
                                                                  .toString() ==
                                                              "null"
                                                          ? "N/A"
                                                          : data.transactionType
                                                                .toString(),
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            data.transactionType
                                                                    .toString() ==
                                                                "CREDIT"
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      data.amount.toString(),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(
                                                          0xffD850E7,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),

                                                    Text(
                                                      convertToDate(
                                                        data.createdAt
                                                            .toString(),
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      data.description
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
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
                              )
                            : Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,

                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: EdgeInsets.zero,

                          content: ClipRRect(
                            borderRadius: BorderRadius.circular(16),

                            child: NewTransaction(),
                          ),
                        );
                      },
                    );
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
                        languagesController.tr("NEW_TRANSACTION"),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
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
}

class NewTransaction extends StatefulWidget {
  const NewTransaction({super.key});

  @override
  State<NewTransaction> createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  CounterPartyController counterPartyController = Get.put(
    CounterPartyController(),
  );

  CreateTransactionController createTransactionController = Get.put(
    CreateTransactionController(),
  );

  AccountListController accountListController = Get.put(
    AccountListController(),
  );
  final box = GetStorage();
  final languagesController = Get.find<LanguagesController>();
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 500,
      width: screenWidth,
      decoration: BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              languagesController.tr("NEW_TRANSACTION"),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),

            SizedBox(
              height: 55,
              child: Obx(
                () => DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: languagesController.tr("SELECT_ACCOUNT"),
                    hintText: languagesController.tr("COUNTER_PARTY_ACCOUNT"),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: box.read("direction") == "rtl" ? 12 : 15,
                      horizontal: 12,
                    ),
                  ),
                  value:
                      createTransactionController
                          .accountidController
                          .text
                          .isNotEmpty
                      ? int.tryParse(
                          createTransactionController.accountidController.text,
                        )
                      : null,
                  items: accountListController
                      .accountlist
                      .value
                      .data!
                      .office!
                      .accounts!
                      .data!
                      .map(
                        (item) => DropdownMenuItem<int>(
                          value: item.id,
                          child: Text(item.counterparty?.name ?? ""),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      print("Selected Account ID: $value");
                      createTransactionController.accountidController.text =
                          value.toString();
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languagesController.tr("SELECT_TYPE"),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10),

                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: createTransactionController.typeController,
                  builder: (context, value, child) {
                    String selectedType = value.text;

                    return Row(
                      children: [
                        // CREDIT
                        GestureDetector(
                          onTap: () =>
                              createTransactionController.typeController.text =
                                  "CREDIT",
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedType == "CREDIT"
                                        ? Colors.green
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: selectedType == "CREDIT"
                                    ? Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                languagesController.tr("CREDIT"),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 40),

                        // DEBIT
                        GestureDetector(
                          onTap: () =>
                              createTransactionController.typeController.text =
                                  "DEBIT",
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedType == "DEBIT"
                                        ? Colors.red
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: selectedType == "DEBIT"
                                    ? Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                languagesController.tr("DEBIT"),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 20),

            Accountextfield(
              keyboardType: TextInputType.number,
              controller: createTransactionController.amountController,
              label: languagesController.tr("AMOUNT"),
              hint: languagesController.tr("ENTER_AMOUNT"),

              height: 55,
            ),
            SizedBox(height: 20),

            Accountextfield(
              controller: createTransactionController.descriptionController,
              label: languagesController.tr("DESCRIPTION"),
              hint: languagesController.tr("ENTER_DESCRIPTION"),

              height: 55,
            ),
            SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                if (createTransactionController
                    .accountidController
                    .text
                    .isEmpty) {
                  Fluttertoast.showToast(
                    msg: languagesController.tr("SELECT_ACCOUNT"),
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }

                if (createTransactionController.amountController.text.isEmpty ||
                    double.tryParse(
                          createTransactionController.amountController.text,
                        ) ==
                        null ||
                    double.parse(
                          createTransactionController.amountController.text,
                        ) <=
                        0) {
                  Fluttertoast.showToast(
                    msg: languagesController.tr("SELECT_AMOUNT"),
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }

                if (createTransactionController.typeController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: languagesController.tr("SELECT_TYPE"),
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                  return;
                }

                // All validations passed
                createTransactionController.createnow();
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
                  child: Obx(
                    () => Text(
                      createTransactionController.isLoading.value == false
                          ? languagesController.tr("CREATE_NOW")
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
    );
  }
}
