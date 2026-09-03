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

  @override
  void initState() {
    super.initState();

    controller.initialpage = 1;
    controller.finalList.clear();
    controller.fetchtransactions();
    scrollController.addListener(_onScroll);
  }

  /// Load and refresh more
  Future<void> _refreshCounterParties() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      controller.initialpage = 1;
      controller.finalList.clear();

      await controller.fetchtransactions();
    } catch (e) {
      debugPrint("Counterparty refresh error: $e");
    } finally {
      _isRefreshing = false;
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    // Bottom-এর একটু আগে next page load হবে
    if (position.extentAfter < 250) {
      _loadMoreCounterParties();
    }
  }

  Future<void> _loadMoreCounterParties() async {
    if (_isLoadingMore) return;

    final int totalPages =
        controller.alltransactions.value.payload?.pagination?.totalPages ?? 0;

    final int currentPage = controller.initialpage;

    if (totalPages <= 0) return;

    // Last page
    if (currentPage >= totalPages) {
      debugPrint("Counterparty: Last page reached");
      return;
    }

    final int nextPage = currentPage + 1;

    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      controller.initialpage = nextPage;

      await controller.fetchtransactions();
    } catch (e) {
      // Error হলে আগের page-এ ফিরে যাবে
      controller.initialpage = currentPage;

      debugPrint("Counterparty load more error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  final ScrollController scrollController = ScrollController();

  /// Load and refresh more

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  bool _isLoadingMore = false;
  bool _isRefreshing = false;

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
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.fontColor,
                child: Image.asset("assets/icons/telecom.png", height: 25),
              ),
            ),
            SizedBox(width: 5),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondaryColor, AppColors.primarycolor2],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              SizedBox(
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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

                    const SizedBox(width: 8),

                    Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset("assets/icons/filter.png"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.listbuilderboxColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        Obx(() {
                          final bool hasData = controller.finalList.isNotEmpty;

                          if (!hasData) {
                            return const SizedBox();
                          }

                          return Row(
                            children: [
                              Text(
                                "${languagesController.tr("TRANSACTIONS")}: ",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                controller
                                        .alltransactions
                                        .value
                                        .payload
                                        ?.pagination
                                        ?.totalItems
                                        ?.toString() ??
                                    "0",
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 5),

                        Expanded(
                          child: Obx(() {
                            final bool isLoading = controller.isLoading.value;

                            final bool hasData =
                                controller.finalList.isNotEmpty;

                            /// ============================
                            /// FIRST PAGE LOADING
                            /// ============================
                            if (isLoading && !hasData) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              );
                            }

                            /// transactionType null হলে list-এ দেখানো হবে না
                            final visibleTransactions = controller.finalList
                                .where((item) {
                                  final String type =
                                      item.transactionType?.toString().trim() ??
                                      '';

                                  return type.isNotEmpty &&
                                      type.toLowerCase() != 'null';
                                })
                                .toList();

                            /// ============================
                            /// EMPTY STATE
                            /// ============================
                            if (visibleTransactions.isEmpty) {
                              return Center(
                                child: Text(
                                  languagesController.tr(
                                    "NO_TRANSACTIONS_FOUND",
                                  ),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }

                            /// ============================
                            /// TRANSACTION LIST
                            /// ============================
                            return ListView.builder(
                              controller: scrollController,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(top: 2, bottom: 8),

                              itemCount:
                                  visibleTransactions.length +
                                  (_isLoadingMore ? 1 : 0),

                              itemBuilder: (context, index) {
                                /// ============================
                                /// LOAD MORE BOTTOM LOADER
                                /// ============================
                                if (index == visibleTransactions.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Center(
                                      child: SizedBox(
                                        height: 23,
                                        width: 23,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  );
                                }

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

                                final Color transactionColor = isReceivable
                                    ? const Color(0xFFDC2626)
                                    : isPayable
                                    ? const Color(0xFF16A34A)
                                    : Colors.grey.shade700;

                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 7),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.listbuilderboxColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 0.8,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.025),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      /// ================= ICON =================
                                      Container(
                                        height: 42,
                                        width: 42,
                                        decoration: BoxDecoration(
                                          color: transactionColor.withOpacity(
                                            0.09,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            11,
                                          ),
                                        ),
                                        child: Icon(
                                          isReceivable
                                              ? Icons.north_east_rounded
                                              : isPayable
                                              ? Icons.south_west_rounded
                                              : Icons.receipt_long_outlined,
                                          color: transactionColor,
                                          size: 21,
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      /// ================= INFO =================
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.counterpartyAccount?.name
                                                      ?.toString() ??
                                                  "--",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xFF344054),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),

                                            const SizedBox(height: 4),

                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: transactionColor
                                                        .withOpacity(0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    transactionTitle,
                                                    style: TextStyle(
                                                      color: transactionColor,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 7),

                                                Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 10,
                                                  color: Colors.grey.shade500,
                                                ),

                                                const SizedBox(width: 4),

                                                Expanded(
                                                  child: Text(
                                                    convertToDate(
                                                      data.createdAt.toString(),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: 9.5,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      /// ================= AMOUNT =================
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            _formatAmount(data.amount),
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: transactionColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),

                                          const SizedBox(height: 3),

                                          Icon(
                                            isReceivable
                                                ? Icons.arrow_upward_rounded
                                                : isPayable
                                                ? Icons.arrow_downward_rounded
                                                : Icons.swap_vert_rounded,
                                            color: transactionColor.withOpacity(
                                              0.70,
                                            ),
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ],
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

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatAmount(dynamic value) {
  final double amount = double.tryParse(value?.toString() ?? '0') ?? 0;

  return amount.toStringAsFixed(2);
}
