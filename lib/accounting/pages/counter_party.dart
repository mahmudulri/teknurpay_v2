import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/accounting_currency_controller.dart';
import '../../controllers/counter_party_controller.dart';
import '../../global_controller/languages_controller.dart';
import '../create_counterpary_screen.dart';

class CounterParty extends StatefulWidget {
  CounterParty({super.key});

  @override
  State<CounterParty> createState() => _CounterPartyState();
}

class _CounterPartyState extends State<CounterParty> {
  final languagesController = Get.find<LanguagesController>();

  CounterPartyController counterPartyController = Get.put(
    CounterPartyController(),
  );

  AccountingCurrencyController accountingCurrencyController = Get.put(
    AccountingCurrencyController(),
  );

  @override
  void initState() {
    super.initState();
    counterPartyController.initialpage = 1;
    counterPartyController.finalList.clear();
    counterPartyController.fetchtransactions();
    accountingCurrencyController.fetchCurrencyList();
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
            Text(
              languagesController.tr("COUNTER_PARTY"),
              style: GoogleFonts.rubik(
                color: Colors.black,
                fontSize: 18,
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
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: screenWidth,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 30,
                                    color: Colors.grey.shade500,
                                  ),

                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: languagesController.tr(
                                          "NAME",
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
                      SizedBox(width: 8),
                      Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Image.asset("assets/icons/filter.png"),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                Expanded(
                  child: Obx(
                    () => counterPartyController.isLoading.value == false
                        ? ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: counterPartyController.finalList.length,
                            itemBuilder: (context, index) {
                              final data =
                                  counterPartyController.finalList[index];

                              return Container(
                                margin: EdgeInsets.only(bottom: 5),
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                width: screenWidth,
                                child: Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        spacing: 5.0,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "ID Number",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                ": ",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                data.id.toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Name",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                ": ",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                data.name.toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Type",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                ": ",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                data.type.toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Phone Number",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                ": ",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                data.phone.toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Email",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                ": ",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                data.email.toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Default Currency",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                ": ",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                data.defaultCurrencyCode
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Total Accounts",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                ": ",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                "N/A",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Balance Summary",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Text(
                                                ": ",
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                              Spacer(),
                                              Text(
                                                "N/A",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Image.asset(
                                      "assets/icons/more.png",
                                      height: 25,
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(child: CircularProgressIndicator()),
                  ),
                ),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Get.to(() => CreateCounterparyScreen());
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
                        languagesController.tr("ADD_NEW_COUNTER_PARTY"),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
