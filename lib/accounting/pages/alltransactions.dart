import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/account_transaction_controller.dart';
import '../../controllers/counter_party_controller.dart';
import '../../global_controller/languages_controller.dart';
import '../../helpers/localtime_helper.dart';

class Alltransactions extends StatefulWidget {
  Alltransactions({super.key});

  @override
  State<Alltransactions> createState() => _AlltransactionsState();
}

class _AlltransactionsState extends State<Alltransactions> {
  final languagesController = Get.find<LanguagesController>();

  AccountTransactionController controller = Get.put(
    AccountTransactionController(),
  );

  CounterPartyController counterPartyController = Get.put(
    CounterPartyController(),
  );

  @override
  void initState() {
    super.initState();
    counterPartyController.initialpage = 1;
    counterPartyController.finalList.clear();
    counterPartyController.fetchtransactions();
    controller.initialpage = 1;
    controller.finalList.clear();
    controller.fetchtransactions();
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
              languagesController.tr("TRANSACTIONS"),
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
                                          "SEARCH_AMOUNT",
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Obx(
                            () => controller.isLoading.value == false
                                ? Row(
                                    children: [
                                      Text(
                                        languagesController.tr("TRANSACTIONS") +
                                            ": ",
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        controller
                                            .alltransactions
                                            .value
                                            .payload!
                                            .pagination!
                                            .totalItems
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                          ),
                          SizedBox(height: 5),
                          Expanded(
                            child: Obx(
                              () => controller.isLoading.value == false
                                  ? ListView.builder(
                                      itemCount: controller.finalList.length,
                                      itemBuilder: (context, index) {
                                        final data =
                                            controller.finalList[index];

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 5),
                                          height: 80,
                                          width: screenWidth,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                                      padding: EdgeInsets.all(
                                                        15.0,
                                                      ),
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
                                                        MainAxisAlignment
                                                            .spaceEvenly,
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
                                                                  FontWeight
                                                                      .bold,
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
                                                                  FontWeight
                                                                      .w600,
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
                                                            data.amount
                                                                .toString(),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                0xffD850E7,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
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
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _amountBox(String title, String? value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      SizedBox(height: 4),
      Text(
        value ?? "0",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
