import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teknurpay/helpers/language_changer.dart';
import '../../global_controller/languages_controller.dart';
import '../../utils/colors.dart';
import '../../helpers/localtime_helper.dart';
import '../controllers/account_transaction_controller.dart';
import '../controllers/counter_party_controller.dart';

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
    counterPartyController.fetchcounterpary();
    controller.initialpage = 1;
    controller.finalList.clear();
    controller.fetchtransactions();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              languagesController.tr("TRANSACTIONS"),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            const LanguageSelectorButton(size: 42, iconSize: 25),
          ],
        ),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: AppColors.listbuilderboxColor,
        elevation: 0.0,
        backgroundColor: AppColors.listbuilderboxColor,
        centerTitle: true,
      ),

      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondaryColor, AppColors.primarycolor2],
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
                            color: AppColors.secondaryColor,
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
                          color: AppColors.secondaryColor,
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
                      color: AppColors.listbuilderboxColor,
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
                            child: Obx(() {
                              if (controller.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                );
                              }

                              // transactionType null হলে আপাতত list-এ দেখানো হবে না।
                              final visibleTransactions = controller.finalList
                                  .where((item) {
                                    final String type =
                                        item.transactionType
                                            ?.toString()
                                            .trim() ??
                                        '';

                                    return type.isNotEmpty &&
                                        type.toLowerCase() != 'null';
                                  })
                                  .toList();

                              return ListView.builder(
                                itemCount: visibleTransactions.length,
                                itemBuilder: (context, index) {
                                  final data = visibleTransactions[index];

                                  final String transactionType =
                                      data.transactionType
                                          ?.toString()
                                          .trim()
                                          .toUpperCase() ??
                                      '';

                                  final bool isReceivable =
                                      transactionType == 'RECEIVABLE';

                                  final bool isPayable =
                                      transactionType == 'PAYABLE';

                                  final String transactionTitle = isReceivable
                                      ? languagesController.tr('I_PAID')
                                      : isPayable
                                      ? languagesController.tr('I_RECEIVED')
                                      : transactionType;

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    height: 80,
                                    width: screenWidth,
                                    decoration: BoxDecoration(
                                      color: AppColors.listbuilderboxColor,
                                      border: Border.all(
                                        width: 1,
                                        color: AppColors.primarycolor2
                                            .withOpacity(0.35),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 7,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
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
                                                AppColors.secondaryColor,
                                            child: Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(15.0),
                                                child: Image.asset(
                                                  "assets/icons/transicon.png",
                                                  color: isReceivable
                                                      ? AppColors.primaryColor
                                                      : isPayable
                                                      ? AppColors.primarycolor2
                                                      : AppColors.primarycolor2,
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
                                                      transactionTitle,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isReceivable
                                                            ? AppColors
                                                                  .primaryColor
                                                            : isPayable
                                                            ? AppColors
                                                                  .primaryColor
                                                            : Colors
                                                                  .grey
                                                                  .shade700,
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
                                                        color: AppColors
                                                            .primaryColor,
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
                                                // Row(
                                                //   children: [
                                                //     Text(
                                                //       data.description
                                                //           .toString(),
                                                //       style: TextStyle(
                                                //         fontSize: 13,
                                                //         color: Colors
                                                //             .grey
                                                //             .shade500,
                                                //       ),
                                                //     ),
                                                //   ],
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                // GestureDetector(
                //   onTap: () {
                //     Get.to(() => CreateTransactionScreen());
                //   },
                //   child: Container(
                //     height: 55,
                //     width: screenWidth,
                //     decoration: BoxDecoration(
                //       image: DecorationImage(
                //         image: AssetImage("assets/svg/abutton.webp"),
                //       ),
                //     ),
                //     child: Center(
                //       child: Text(
                //         languagesController.tr("NEW_TRANSACTION"),
                //         style: TextStyle(
                //           color: AppColors.listbuilderboxColor,
                //           fontWeight: FontWeight.w600,
                //           fontSize: 18,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(height: 5),
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
