import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/helpers/language_changer.dart';
import 'package:teknurpay/utils/colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../controllers/delete_office_controller.dart';
import '../controllers/office_list_controller.dart';
import '../controllers/office_transactions_controller.dart';
import '../controllers/statistic_controller.dart';
import '../create_counterpary_screen.dart';
import '../create_office_screen.dart';
import '../screens/currency_screen.dart';
import '../update_office_screen.dart';
import '../view_office_screen.dart';

class Offices extends StatefulWidget {
  Offices({super.key});

  @override
  State<Offices> createState() => _OfficesState();
}

class _OfficesState extends State<Offices> {
  final languagesController = Get.find<LanguagesController>();

  final statisticController = Get.find<StatisticController>();

  OfficeListController officeListController = Get.put(OfficeListController());

  final ScrollController scrollController = ScrollController();

  OfficeTransactionsListController transactionsListController = Get.put(
    OfficeTransactionsListController(),
  );
  final dashboardController = Get.find<DashboardController>();

  DeleteOfficeController deleteOfficeController = Get.put(
    DeleteOfficeController(),
  );

  Future<void> refresh() async {
    final int totalItems =
        officeListController.allofficelist.value.data?.pagination?.totalItems ??
        0;

    if (officeListController.finalList.length >= totalItems) {
      print(
        "End..........................................End.....................",
      );
    } else {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        officeListController.initialpage++;
        // print(orderlistController.initialpage);
        print("Load More...................");
        officeListController.fetchofficelist();
      } else {
        // print("nothing");
      }
    }
  }

  bool isQuickMenuOpen = false;
  @override
  void initState() {
    super.initState();
    officeListController.initialpage = 1;
    officeListController.finalList.clear();
    officeListController.fetchofficelist();
    statisticController.fetchstatistic();
  }

  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       isQuickMenuOpen = !isQuickMenuOpen;
      //     });
      //   },
      //   elevation: 8,
      //   backgroundColor: AppColors.secondaryColor,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //   child: AnimatedSwitcher(
      //     duration: const Duration(milliseconds: 200),
      //     child: isQuickMenuOpen
      //         ? Container(
      //             key: const ValueKey("close"),
      //             height: double.infinity,
      //             width: double.infinity,
      //             decoration: BoxDecoration(
      //               color: const Color(0xFFFF4343),
      //               borderRadius: BorderRadius.circular(16),
      //             ),
      //             child: const Icon(
      //               Icons.close_rounded,
      //               color: AppColors.listbuilderboxColor,
      //               size: 30,
      //             ),
      //           )
      //         : ClipRRect(
      //             key: const ValueKey("image"),
      //             borderRadius: BorderRadius.circular(16),
      //             child: SizedBox.expand(
      //               child: Image.asset(
      //                 "assets/icons/float.png",
      //                 fit: BoxFit.cover,
      //               ),
      //             ),
      //           ),
      //   ),
      // ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,

              child: Icon(Icons.person, color: Colors.black),
            ),
            SizedBox(width: 5),
            Obx(
              () => dashboardController.isLoading.value == false
                  ? Text(
                      dashboardController
                              .alldashboardData
                              .value
                              .data
                              ?.userInfo
                              ?.resellerName
                              ?.toString() ??
                          '',
                      style: TextStyle(
                        color: Colors.black,

                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : SizedBox(),
            ),

            // Text(
            //   languagesController.tr("OFFICES"),
            //   style: TextStyle(
            //     color: Colors.black,
            //     fontSize: 20,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            Spacer(),

            // CircleAvatar(
            //   radius: 20,
            //   backgroundColor: Colors.grey.shade100,

            //   child: Image.asset("assets/icons/bell.png", height: 25),
            // ),
            // SizedBox(width: 5),
            const LanguageSelectorButton(size: 42, iconSize: 25),
          ],
        ),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.white,
        elevation: 0.0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
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
                    SizedBox(height: 10),
                    Obx(() {
                      if (statisticController.isLoading.value) {
                        return SizedBox(
                          height: 300,
                          width: screenWidth,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      }

                      final currencies = statisticController.currencyList;
                      final selectedData =
                          statisticController.selectedCurrencyData;

                      final double netBalance =
                          double.tryParse(
                            selectedData?.netBalance?.toString() ?? '0',
                          ) ??
                          0;

                      final double totalReceivable =
                          double.tryParse(
                            selectedData?.totalReceivable?.toString() ?? '0',
                          ) ??
                          0;

                      final double totalPayable =
                          double.tryParse(
                            selectedData?.totalPayable?.toString() ?? '0',
                          ) ??
                          0;

                      final int accountsCount =
                          int.tryParse(
                            selectedData?.accountsCount?.toString() ?? '0',
                          ) ??
                          0;

                      final int counterpartiesCount =
                          int.tryParse(
                            selectedData?.counterpartiesCount?.toString() ??
                                '0',
                          ) ??
                          0;

                      final String selectedCurrencyCode =
                          selectedData?.currencyCode?.toString().trim() ?? '';

                      final String firstCurrencyCode = currencies.isNotEmpty
                          ? (currencies.first.currencyCode?.toString().trim() ??
                                '')
                          : '';

                      final String currencyCode =
                          selectedCurrencyCode.isNotEmpty
                          ? selectedCurrencyCode
                          : firstCurrencyCode;

                      final String balanceStatus =
                          selectedData?.status
                              ?.toString()
                              .trim()
                              .toLowerCase() ??
                          '';

                      final bool isBalanceSettled =
                          netBalance == 0 ||
                          balanceStatus == 'settled' ||
                          balanceStatus == 'balanced';

                      final bool iWillReceive =
                          !isBalanceSettled &&
                          (balanceStatus == 'receivable' ||
                              (balanceStatus.isEmpty && netBalance > 0));

                      final bool iOwe =
                          !isBalanceSettled &&
                          (balanceStatus == 'payable' ||
                              (balanceStatus.isEmpty && netBalance < 0));

                      final String formattedNetBalance = currencyCode.isEmpty
                          ? _formatAmount(netBalance.abs())
                          : '${_formatAmount(netBalance.abs())} $currencyCode';

                      final String balanceRelationText;
                      final Color balanceRelationColor;
                      final IconData balanceRelationIcon;

                      if (isBalanceSettled) {
                        balanceRelationText = languagesController.tr(
                          'BALANCE_SETTLED',
                        );
                        balanceRelationColor = const Color(0xFF667085);
                        balanceRelationIcon =
                            Icons.check_circle_outline_rounded;
                      } else if (iWillReceive) {
                        balanceRelationText = languagesController.tr(
                          'YOU_ARE_OWED',
                        );
                        balanceRelationColor = AppColors.primaryColor;
                        balanceRelationIcon = Icons.south_west_rounded;
                      } else {
                        balanceRelationText = languagesController.tr('YOU_OWE');
                        balanceRelationColor = const Color(0xFFD92D20);
                        balanceRelationIcon = Icons.north_east_rounded;
                      }

                      return Container(
                        width: screenWidth,
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: AppColors.listbuilderboxColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  balanceRelationIcon,
                                  color: balanceRelationColor,
                                  size: 21,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  balanceRelationText,
                                  style: TextStyle(
                                    color: balanceRelationColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    formattedNetBalance,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: balanceRelationColor,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$accountsCount ${languagesController.tr('ACCOUNTS')}  •  '
                              '$counterpartiesCount ${languagesController.tr('COUNTER_PARTY')}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 72,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.10,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryColor
                                                .withOpacity(0.18),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.south_west_rounded,
                                            color: AppColors.primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                languagesController.tr(
                                                  'TOTAL_I_RECEIVED',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                currencyCode.isEmpty
                                                    ? _formatAmount(
                                                        totalReceivable.abs(),
                                                      )
                                                    : '$currencyCode ${_formatAmount(totalReceivable.abs())}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 72,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFEFF1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFDBDE),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.north_east_rounded,
                                            color: Color(0xFFEF4444),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                languagesController.tr(
                                                  'TOTAL_I_PAID',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                currencyCode.isEmpty
                                                    ? _formatAmount(
                                                        totalPayable.abs(),
                                                      )
                                                    : '$currencyCode ${_formatAmount(totalPayable.abs())}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFFDC2626),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 42,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ...List.generate(currencies.length, (
                                            index,
                                          ) {
                                            final currency = currencies[index];
                                            final bool isSelected =
                                                statisticController
                                                    .selectedCurrencyIndex
                                                    .value ==
                                                index;

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onTap: () {
                                                  statisticController
                                                      .selectCurrency(index);
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 22,
                                                        vertical: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? AppColors.primaryColor
                                                        : const Color(
                                                            0xFFF1F4F8,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? AppColors
                                                                .primarycolor2
                                                          : Colors
                                                                .grey
                                                                .shade300,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    currency.currencyCode ??
                                                        '--',
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? Colors.white
                                                          : AppColors
                                                                .primaryColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                          SizedBox(width: 4),
                                          InkWell(
                                            onTap: () {
                                              Get.to(() => CurrencyScreen());
                                            },
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Container(
                                              width: 58,
                                              height: 42,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.add_rounded,
                                                size: 22,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: _buildStatisticAction(
                                      icon: Icons.add_business_rounded,
                                      title: languagesController.tr('OFFICE'),
                                      onTap: () {
                                        Get.to(() => CreateOfficeScreen());
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: _buildStatisticAction(
                                      icon: Icons.person_add_alt_1_rounded,
                                      title: languagesController.tr(
                                        'COUNTER_PARTY',
                                      ),
                                      onTap: () {
                                        Get.to(() => CreateCounterparyScreen());
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: _buildStatisticAction(
                                      icon: Icons.bar_chart_rounded,
                                      title: languagesController.tr('REPORTS'),
                                      onTap: () {
                                        // Reports screen navigation এখানে দাও
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: _buildStatisticAction(
                                      icon: Icons.add_rounded,
                                      title: languagesController.tr('CURRENCY'),
                                      onTap: () {
                                        Get.to(() => const CurrencyScreen());
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 8),

                    Expanded(
                      child: Obx(
                        () => officeListController.isLoading.value == false
                            ? ListView.builder(
                                padding: EdgeInsets.all(0.0),
                                physics: BouncingScrollPhysics(),
                                itemCount:
                                    officeListController.finalList.length,
                                itemBuilder: (context, index) {
                                  final data =
                                      officeListController.finalList[index];

                                  return GestureDetector(
                                    onTap: () {
                                      transactionsListController.finalList
                                          .clear();
                                      transactionsListController.initialpage =
                                          1;
                                      transactionsListController
                                          .fetchtransactions(
                                            int.parse(data.id.toString()),
                                          );
                                      Get.to(
                                        () => ViewOfficeScreen(
                                          id: data.id.toString(),
                                          officeId: data.code,
                                          officeName: data.name,
                                          location: data.location,
                                          phone: data.phone,
                                          address: data.address,
                                          notes: data.notes,
                                          isactive: data.isActive.toString(),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: screenWidth,
                                      margin: EdgeInsets.only(bottom: 5),
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.listbuilderboxColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data.name.toString(),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Text(
                                                      languagesController.tr(
                                                        "ACCOUNTS",
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      ":",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      data.accountsCount
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Text(
                                                      languagesController.tr(
                                                        "TRANSACTIONS",
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      ":",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                      ),
                                                    ),
                                                    SizedBox(width: 2),
                                                    Text(
                                                      data.transactionCount
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontSize: 14,
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
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.zero,

                                                    content: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      child: Container(
                                                        height: 130,
                                                        width: screenWidth,
                                                        color: AppColors
                                                            .listbuilderboxColor,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                vertical: 8,
                                                              ),
                                                          child: Column(
                                                            children: [
                                                              Expanded(
                                                                child: Container(
                                                                  color: Colors
                                                                      .green,
                                                                  child: Column(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Container(
                                                                          color:
                                                                              Colors.white,
                                                                          child: GestureDetector(
                                                                            onTap: () {
                                                                              Get.back();
                                                                              Get.to(
                                                                                () => UpdateOfficeScreen(
                                                                                  officeid: data.id.toString(),
                                                                                  officeName: data.name,
                                                                                  phoneNumber: data.phone,
                                                                                  codeNumber: data.code.toString(),
                                                                                  location: data.location,
                                                                                  address: data.address,
                                                                                  isActive: data.isActive.toString(),
                                                                                  notes: data.notes,
                                                                                ),
                                                                              );
                                                                            },
                                                                            child: Center(
                                                                              child: Text(
                                                                                languagesController.tr(
                                                                                  "EDIT_OFFICE",
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            1,
                                                                        width:
                                                                            screenWidth,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade200,
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            deleteOfficeController.deleteoffice(
                                                                              data.id.toString(),
                                                                            );
                                                                            Navigator.pop(
                                                                              context,
                                                                            );
                                                                          },
                                                                          child: Container(
                                                                            color:
                                                                                Colors.white,
                                                                            child: Center(
                                                                              child: Text(
                                                                                languagesController.tr(
                                                                                  "DELETE_OFFICE",
                                                                                ),
                                                                                style: TextStyle(
                                                                                  color: Colors.red,
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
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Image.asset(
                                              "assets/icons/more.png",
                                              height: 25,
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

          if (isQuickMenuOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    isQuickMenuOpen = false;
                  });
                },
                child: Container(color: Colors.black.withOpacity(0.18)),
              ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            right: isQuickMenuOpen ? 16 : -320,
            bottom: 85,
            child: _buildQuickActionMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionMenu() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: isQuickMenuOpen ? 1 : 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.72,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.listbuilderboxColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickMenuItem(
              title: "I Received Money",
              icon: Icons.south_west_rounded,
              startColor: AppColors.primaryColor,
              endColor: AppColors.primarycolor2,
              onTap: () {
                setState(() {
                  isQuickMenuOpen = false;
                });

                // Received Money screen
              },
            ),

            const SizedBox(height: 18),

            _buildQuickMenuItem(
              title: "I Gave Money",
              icon: Icons.north_east_rounded,
              startColor: AppColors.primarycolor2,
              endColor: AppColors.primaryColor,
              onTap: () {
                setState(() {
                  isQuickMenuOpen = false;
                });

                // Gave Money screen
              },
            ),

            const SizedBox(height: 18),

            _buildQuickMenuItem(
              title: "Product Purchased",
              icon: Icons.shopping_cart_checkout_rounded,
              startColor: AppColors.primaryColor,
              endColor: AppColors.primarycolor2,
              onTap: () {
                setState(() {
                  isQuickMenuOpen = false;
                });

                // Product Purchased screen
              },
            ),

            const SizedBox(height: 18),

            _buildQuickMenuItem(
              title: "Product Sold",
              icon: Icons.sell_outlined,
              startColor: AppColors.primarycolor2,
              endColor: AppColors.primaryColor,
              onTap: () {
                setState(() {
                  isQuickMenuOpen = false;
                });

                // Product Sold screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildQuickMenuItem({
  required String title,
  required IconData icon,
  required Color startColor,
  required Color endColor,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [startColor, endColor]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [startColor, endColor],
                  ).createShader(bounds);
                },
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildStatisticAction({
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.white.withOpacity(0.08),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 55,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 17),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

String _formatAmount(double amount) {
  if (amount == amount.roundToDouble()) {
    return amount.toStringAsFixed(0);
  }

  return amount.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}
