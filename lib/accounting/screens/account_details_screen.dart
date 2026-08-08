import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/utils/colors.dart';
import '../controllers/account_details_controller.dart';
import '../controllers/make_transaction_controller.dart';
import '../controllers/transactions_of_account_controller.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key, this.accountID});

  final String? accountID;

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final LanguagesController languageController =
      Get.find<LanguagesController>();

  final TransactionsOfAccountController transactionListController = Get.put(
    TransactionsOfAccountController(),
  );

  final AccountDetailsController accountDetailsController = Get.put(
    AccountDetailsController(),
  );

  final MakeTransactionController makeTransactionController = Get.put(
    MakeTransactionController(),
  );
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    final accountId = widget.accountID;

    if (accountId == null || accountId.trim().isEmpty) {
      return;
    }

    await Future.wait([
      accountDetailsController.fetchdata(accountId),
      transactionListController.fetchdata(accountId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.listbuilderboxColor,
        appBar: AppBar(
          title: Text(
            languageController.tr("ACCOUNT_DETAILS"),
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppColors.listbuilderboxColor,
          surfaceTintColor: AppColors.listbuilderboxColor,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.secondaryColor, AppColors.primarycolor2],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Column(
              children: [
                Obx(() {
                  if (accountDetailsController.isLoading.value) {
                    return Container(
                      height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.listbuilderboxColor,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  final data = accountDetailsController.alldata.value.data;
                  final account = data?.account;
                  final statistics = data?.statistics;

                  if (account == null) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.listbuilderboxColor,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 54,
                            width: 54,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.primaryColor,
                              size: 27,
                            ),
                          ),
                          const SizedBox(height: 11),
                          Text(
                            languagesController.tr(
                              "ACCOUNT_INFORMATION_NOT_FOUND",
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final String currencyCode =
                      account.currencyCode?.toString() ?? "--";

                  final double currentBalance = _toDouble(
                    account.currentBalance ?? statistics?.currentBalance,
                  );

                  final double receivableAmount = _toDouble(
                    statistics?.receivablesCreated,
                  );

                  final double payableAmount = _toDouble(
                    statistics?.payablesCreated,
                  );

                  final String counterpartyName =
                      account.counterparty?.name
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                      ? account.counterparty!.name.toString().trim()
                      : languagesController.tr("COUNTERPARTY");

                  final String accountName =
                      account.name?.toString().trim().isNotEmpty == true
                      ? account.name.toString().trim()
                      : languagesController.tr("UNNAMED_ACCOUNT");

                  final String balanceStatus =
                      account.balanceStatus?.toString().trim().toLowerCase() ??
                      statistics?.status?.toString().trim().toLowerCase() ??
                      '';

                  final bool isBalanceSettled =
                      currentBalance == 0 ||
                      balanceStatus == 'settled' ||
                      balanceStatus == 'balanced';

                  final bool youOweCounterparty =
                      !isBalanceSettled &&
                      (balanceStatus == 'receivable' ||
                          (balanceStatus.isEmpty && currentBalance > 0));

                  final bool counterpartyOwesYou =
                      !isBalanceSettled &&
                      (balanceStatus == 'payable' ||
                          (balanceStatus.isEmpty && currentBalance < 0));

                  final String balanceRelationText;
                  final Color balanceRelationColor;
                  final IconData balanceRelationIcon;

                  if (isBalanceSettled) {
                    balanceRelationText = languagesController.tr(
                      "BALANCE_SETTLED",
                    );
                    balanceRelationColor = const Color(0xFF667085);
                    balanceRelationIcon = Icons.check_circle_outline_rounded;
                  } else if (youOweCounterparty) {
                    balanceRelationText = languagesController.tr("YOU_OWE");
                    balanceRelationColor = const Color(0xFFD92D20);
                    balanceRelationIcon = Icons.north_east_rounded;
                  } else {
                    balanceRelationText = languagesController.tr(
                      "YOU_ARE_OWED",
                    );
                    balanceRelationColor = AppColors.primaryColor;
                    balanceRelationIcon = Icons.south_west_rounded;
                  }

                  final String formattedCurrentBalance =
                      "$currencyCode ${_formatAmount(currentBalance.abs())}";

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.listbuilderboxColor,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 42,
                              width: 42,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    accountName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFF344054),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    account.counterparty?.name ?? "--",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () {
                                  _showAccountDetailsDialog(
                                    account: account,
                                    statistics: statistics,
                                  );
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: const SizedBox(
                                  height: 38,
                                  width: 38,
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFF475467),
                                    size: 21,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
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
                                formattedCurrentBalance,
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
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.south_west_rounded,
                                        color: AppColors.primaryColor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${languagesController.tr("TOTAL_I_PAID_TO")} $accountName",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 10,
                                                height: 1.25,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              "$currencyCode ${_formatAmount(payableAmount.abs())}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: AppColors.primaryColor,
                                                fontSize: 12,
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
                              Container(
                                height: 44,
                                width: 1,
                                color: Colors.grey.shade300,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.north_east_rounded,
                                        color: Color(0xFFE08A00),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${languagesController.tr("TOTAL_I_RECEIVED_FROM")} $accountName",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 10,
                                                height: 1.25,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              "$currencyCode ${_formatAmount(receivableAmount.abs())}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: AppColors.primaryColor,
                                                fontSize: 12,
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
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Obx(() {
                  final transactions =
                      transactionListController
                          .alltransactions
                          .value
                          .data
                          ?.transactions ??
                      [];

                  final totalItems =
                      transactionListController
                          .alltransactions
                          .value
                          .payload
                          ?.pagination
                          ?.totalItems ??
                      transactions.length;

                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          languageController.tr("TRANSACTIONS"),
                          style: TextStyle(
                            color: const Color(0xFF344054),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          totalItems.toString(),
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(() {
                    if (transactionListController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    final transactions =
                        transactionListController
                            .alltransactions
                            .value
                            .data
                            ?.transactions ??
                        [];

                    if (transactions.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.listbuilderboxColor,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 54,
                              width: 54,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: AppColors.primaryColor,
                                size: 27,
                              ),
                            ),
                            const SizedBox(height: 11),
                            Text(
                              languagesController.tr("NO_TRANSACTIONS_FOUND"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];

                        final String transactionType =
                            transaction.transactionType?.toString() ??
                            "TRANSACTION";

                        final double balanceEffect = _toDouble(
                          transaction.balanceEffect,
                        );
                        final double amount = _toDouble(transaction.amount);
                        final bool isPositive = balanceEffect >= 0;
                        final String currencyCode =
                            transaction.currencyCode?.toString() ?? "--";

                        final visual = _getTransactionVisual(
                          transactionType,
                          isPositive,
                        );

                        final String status =
                            transaction.status?.toString() ?? "--";
                        final String normalizedStatus = status.toLowerCase();

                        Color statusBackgroundColor;
                        Color statusTextColor;

                        switch (normalizedStatus) {
                          case "posted":
                            statusBackgroundColor = const Color(0xFFE9F9F0);
                            statusTextColor = const Color(0xFF159455);
                            break;
                          case "pending":
                            statusBackgroundColor = const Color(0xFFFFF4E5);
                            statusTextColor = const Color(0xFFE08A00);
                            break;
                          case "reversed":
                          case "cancelled":
                          case "failed":
                            statusBackgroundColor = const Color(0xFFFFEDEC);
                            statusTextColor = const Color(0xFFD92D20);
                            break;
                          default:
                            statusBackgroundColor = const Color(0xFFF2F4F7);
                            statusTextColor = const Color(0xFF667085);
                        }

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 7),
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.listbuilderboxColor,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.025),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: visual.backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  visual.icon,
                                  color: visual.iconColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            transactionType == "PAYABLE"
                                                ? "${languagesController.tr("I_PAID_TO")} ${_currentAccountName()}"
                                                : "${languagesController.tr("I_RECEIVED_FROM")} ${_currentAccountName()}",
                                            style: const TextStyle(
                                              color: Color(0xFF344054),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "${isPositive ? '+' : '-'}$currencyCode ${_formatAmount(amount.abs())}",
                                          style: TextStyle(
                                            color: isPositive
                                                ? const Color(0xFF159455)
                                                : const Color(0xFFD92D20),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      transaction.description
                                                  ?.toString()
                                                  .trim()
                                                  .isNotEmpty ==
                                              true
                                          ? transaction.description.toString()
                                          : languagesController.tr(
                                              "NO_DESCRIPTION",
                                            ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 13,
                                          color: Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            _formatDate(
                                              transaction.transactionDate,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusBackgroundColor,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            _formatText(status),
                                            style: TextStyle(
                                              color: statusTextColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryColor,
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  languagesController.tr(
                                                    "BEFORE",
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  "$currencyCode ${_formatAmount(_toDouble(transaction.balanceBefore).abs())}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF344054,
                                                    ),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 27,
                                            color: Colors.grey.shade300,
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Text(
                                                  languagesController.tr(
                                                    "AFTER",
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  "$currencyCode ${_formatAmount(_toDouble(transaction.balanceAfter).abs())}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: const Color(
                                                      0xFF344054,
                                                    ),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (transaction.reference != null &&
                                        transaction.reference
                                            .toString()
                                            .trim()
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            "${languagesController.tr("REFERENCE")}: ",
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 10,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              transaction.reference.toString(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: const Color(0xFF667085),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),
                Obx(
                  () => Container(
                    height: 56,
                    width: screenWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primarycolor2,
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.30,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  _showMakeTransactionDialog(
                                    initialTransactionType: 'PAYABLE',
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 52,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.north_east_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "${languagesController.tr("I_PAY")}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryColor.withOpacity(0.75),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(
                                    0.30,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  _showMakeTransactionDialog(
                                    initialTransactionType: 'RECEIVABLE',
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  height: 52,
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.south_west_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${languagesController.tr("I_RECEIVE")}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
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
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _currentAccountName() {
    final account = accountDetailsController.alldata.value.data?.account;
    final String? name = account?.name?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return languagesController.tr("UNNAMED_ACCOUNT");
  }

  Future<void> _showMakeTransactionDialog({
    required String initialTransactionType,
  }) async {
    final String? accountId = widget.accountID;

    if (accountId == null || accountId.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Counterparty account ID was not found.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEDEC),
        colorText: const Color(0xFFD92D20),
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    final String selectedTransactionType =
        initialTransactionType.toUpperCase() == 'PAYABLE'
        ? 'PAYABLE'
        : 'RECEIVABLE';

    final account = accountDetailsController.alldata.value.data?.account;
    final String currencyCode = account?.currencyCode?.toString() ?? '--';
    final bool isPayable = selectedTransactionType == 'PAYABLE';

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.40),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 24,
          ),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: AppColors.listbuilderboxColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: isPayable
                                ? const Color(0xFFFFF4E5)
                                : const Color(0xFFE9F9F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPayable
                                ? Icons.north_east_rounded
                                : Icons.south_west_rounded,
                            color: isPayable
                                ? const Color(0xFFE08A00)
                                : const Color(0xFF159455),
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languagesController.tr("MAKE_TRANSACTION"),
                                style: TextStyle(
                                  color: const Color(0xFF344054),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                account?.name?.toString() ??
                                    languagesController.tr(
                                      "COUNTER_PARTY_ACCOUNT",
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFF667085),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (!makeTransactionController.isLoading.value) {
                              Navigator.pop(dialogContext);
                            }
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      languagesController.tr("TRANSACTION_TYPE"),
                      style: TextStyle(
                        color: const Color(0xFF344054),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isPayable
                            ? const Color(0xFFFFF4E5)
                            : const Color(0xFFE9F9F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPayable
                              ? const Color(0xFFE08A00)
                              : const Color(0xFF159455),
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 34,
                            width: 34,
                            decoration: BoxDecoration(
                              color: isPayable
                                  ? const Color(0xFFFFF4E5)
                                  : const Color(0xFFE9F9F0),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              isPayable
                                  ? Icons.north_east_rounded
                                  : Icons.south_west_rounded,
                              color: isPayable
                                  ? const Color(0xFFE08A00)
                                  : const Color(0xFF159455),
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isPayable
                                      ? languagesController.tr("I_PAY")
                                      : languagesController.tr("I_RECEIVE"),
                                  style: TextStyle(
                                    color: isPayable
                                        ? const Color(0xFFE08A00)
                                        : const Color(0xFF159455),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isPayable
                                      ? languagesController.tr("RECEIVEABLE")
                                      : languagesController.tr("PAYABLE"),
                                  style: TextStyle(
                                    color: const Color(0xFF667085),
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle_rounded,
                            color: isPayable
                                ? const Color(0xFFE08A00)
                                : const Color(0xFF159455),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      languagesController.tr("AMOUNT"),
                      style: TextStyle(
                        color: const Color(0xFF344054),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,6}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        hintText: languagesController.tr("ENTER_AMOUNT"),
                        prefixIcon: const Icon(
                          Icons.payments_outlined,
                          color: Color(0xFF667085),
                          size: 21,
                        ),
                        suffixText: currencyCode,
                        suffixStyle: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: AppColors.secondaryColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 1.3,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: Color(0xFFD92D20),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: Color(0xFFD92D20),
                            width: 1.3,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final String amountText = value?.trim() ?? '';

                        if (amountText.isEmpty) {
                          return languagesController.tr("ENTER_AMOUNT");
                        }

                        final double? amount = double.tryParse(amountText);

                        if (amount == null) {
                          return languagesController.tr("ENTER_A_VALID_AMOUNT");
                        }

                        if (amount <= 0) {
                          return languagesController.tr(
                            "AMOUNT_MUST_BE_GREATER_THAN_ZERO",
                          );
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languagesController.tr("DESCRIPTION"),
                          style: TextStyle(
                            color: const Color(0xFF344054),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          languagesController.tr("OPTIONAL"),
                          style: TextStyle(
                            color: const Color(0xFF344054),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descriptionController,
                      minLines: 3,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: languagesController.tr(
                          "WRITE_TRANSACTION_DESCRIPTION",
                        ),
                        filled: true,
                        fillColor: AppColors.secondaryColor,
                        contentPadding: const EdgeInsets.all(14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      final bool isSubmitting =
                          makeTransactionController.isLoading.value;

                      return Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 47,
                              child: OutlinedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () {
                                        Navigator.pop(dialogContext);
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF475467),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: Text(
                                  languagesController.tr("CANCEL"),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 47,
                              child: ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        final bool isValid =
                                            formKey.currentState?.validate() ??
                                            false;

                                        if (!isValid) {
                                          return;
                                        }

                                        final bool success =
                                            await makeTransactionController
                                                .makeTransaction(
                                                  counterpartyAccountId:
                                                      widget.accountID,
                                                  transactionType:
                                                      selectedTransactionType,
                                                  amount: amountController.text
                                                      .trim(),
                                                  description:
                                                      descriptionController.text
                                                          .trim(),
                                                );

                                        if (!context.mounted) {
                                          return;
                                        }

                                        if (success) {
                                          Navigator.pop(dialogContext);
                                          await _fetchData();
                                        } else {
                                          final String transactionError =
                                              makeTransactionController
                                                  .errorMessage
                                                  .value
                                                  .trim();

                                          Get.snackbar(
                                            languagesController.tr(
                                              "TRANSACTION_FAILED",
                                            ),
                                            transactionError.isNotEmpty
                                                ? transactionError
                                                : languagesController.tr(
                                                    "UNABLE_TO_CREATE_TRANSACTION",
                                                  ),
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: const Color(
                                              0xFFFFEDEC,
                                            ),
                                            colorText: const Color(0xFFD92D20),
                                            margin: const EdgeInsets.all(12),
                                            duration: const Duration(
                                              seconds: 4,
                                            ),
                                            icon: const Icon(
                                              Icons.error_outline_rounded,
                                              color: Color(0xFFD92D20),
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: isPayable
                                      ? AppColors.primarycolor2
                                      : AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        height: 21,
                                        width: 21,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.3,
                                          color: AppColors.listbuilderboxColor,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isPayable
                                                ? Icons.north_east_rounded
                                                : Icons.south_west_rounded,
                                            size: 19,
                                          ),
                                          const SizedBox(width: 7),
                                          Text(
                                            isPayable
                                                ? languagesController.tr(
                                                    "CONFIRM_PAYMENT",
                                                  )
                                                : languagesController.tr(
                                                    "CONFIRM_RECEIVED",
                                                  ),
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAccountDetailsDialog({
    required dynamic account,
    required dynamic statistics,
  }) {
    final String currencyCode = account.currencyCode?.toString() ?? "--";

    final List<Map<String, dynamic>> details = [
      {
        'icon': Icons.person_outline_rounded,
        'label': 'Account Name',
        'value': account.name ?? '--',
      },
      {
        'icon': Icons.people_outline_rounded,
        'label': 'Counterparty',
        'value': account.counterparty?.name ?? '--',
      },
      {
        'icon': Icons.business_outlined,
        'label': 'Office',
        'value': account.office?.name ?? '--',
      },
      {
        'icon': Icons.category_outlined,
        'label': 'Account Type',
        'value': _formatText(account.accountType),
      },
      {
        'icon': Icons.currency_exchange_rounded,
        'label': 'Currency',
        'value': currencyCode,
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Opening Balance',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(account.openingBalance).abs())}",
      },
      {
        'icon': Icons.payments_outlined,
        'label': 'Current Balance',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(account.currentBalance).abs())}",
      },
      {
        'icon': Icons.receipt_long_outlined,
        'label': 'Total Transactions',
        'value': "${statistics?.totalTransactions ?? 0}",
      },
      {
        'icon': Icons.add_chart_rounded,
        'label': 'Positive Effect',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(statistics?.positiveEffect).abs())}",
      },
      {
        'icon': Icons.trending_down_rounded,
        'label': 'Negative Effect',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(statistics?.negativeEffect).abs())}",
      },
      {
        'icon': Icons.analytics_outlined,
        'label': 'Net Effect',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(statistics?.netEffect).abs())}",
      },
      {
        'icon': Icons.south_west_rounded,
        'label': 'Receivables Created',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(statistics?.receivablesCreated).abs())}",
      },
      {
        'icon': Icons.payment_rounded,
        'label': 'Receivable Payments',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(statistics?.receivablePayments).abs())}",
      },
      {
        'icon': Icons.north_east_rounded,
        'label': 'Payables Created',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(statistics?.payablesCreated).abs())}",
      },
      {
        'icon': Icons.credit_card_rounded,
        'label': 'Payable Payments',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(statistics?.payablePayments).abs())}",
      },
      {
        'icon': Icons.tune_rounded,
        'label': 'Adjustment Effect',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(statistics?.adjustmentEffect).abs())}",
      },
      {
        'icon': Icons.undo_rounded,
        'label': 'Reversal Effect',
        'value':
            "$currencyCode ${_formatAmount(_toDouble(statistics?.reversalEffect).abs())}",
      },
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 620),
            decoration: BoxDecoration(
              color: AppColors.listbuilderboxColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primaryColor,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          "Account Details",
                          style: TextStyle(
                            color: const Color(0xFF344054),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: List.generate(details.length, (index) {
                        final item = details[index];

                        return Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryColor,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Icon(
                                    item['icon'] as IconData,
                                    color: const Color(0xFF667085),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Text(
                                    item['label'].toString(),
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    item['value'].toString(),
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFF344054),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (index != details.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 46,
                                  top: 9,
                                  bottom: 9,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TransactionVisual _getTransactionVisual(
    String transactionType,
    bool isPositive,
  ) {
    switch (transactionType.toUpperCase()) {
      case "OPENING_BALANCE":
        return const TransactionVisual(
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.primaryColor,
          backgroundColor: AppColors.secondaryColor,
        );
      case "RECEIVABLE":
        return TransactionVisual(
          icon: Icons.south_west_rounded,
          iconColor: AppColors.primaryColor,
          backgroundColor: AppColors.primaryColor.withOpacity(0.10),
        );
      case "RECEIVABLE_PAYMENT":
        return const TransactionVisual(
          icon: Icons.payments_outlined,
          iconColor: Color(0xFF7A5AF8),
          backgroundColor: Color(0xFFF1EEFF),
        );
      case "PAYABLE":
        return const TransactionVisual(
          icon: Icons.north_east_rounded,
          iconColor: AppColors.primarycolor2,
          backgroundColor: Color(0xFFFFF4E5),
        );
      case "PAYABLE_PAYMENT":
        return const TransactionVisual(
          icon: Icons.payment_rounded,
          iconColor: AppColors.primaryColor,
          backgroundColor: AppColors.secondaryColor,
        );
      case "ADJUSTMENT":
        return const TransactionVisual(
          icon: Icons.tune_rounded,
          iconColor: Color(0xFF7A5AF8),
          backgroundColor: Color(0xFFF1EEFF),
        );
      case "REVERSAL":
        return const TransactionVisual(
          icon: Icons.undo_rounded,
          iconColor: Color(0xFFD92D20),
          backgroundColor: Color(0xFFFFEDEC),
        );
      default:
        return TransactionVisual(
          icon: isPositive
              ? Icons.add_card_rounded
              : Icons.credit_card_off_outlined,
          iconColor: isPositive
              ? const Color(0xFF159455)
              : const Color(0xFFD92D20),
          backgroundColor: isPositive
              ? const Color(0xFFE9F9F0)
              : const Color(0xFFFFEDEC),
        );
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  String _formatAmount(double amount) {
    final bool isWholeNumber = amount == amount.roundToDouble();

    final String rawValue = isWholeNumber
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);

    final List<String> parts = rawValue.split(".");
    final String integerPart = parts.first;

    final String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ",",
    );

    if (parts.length == 1) {
      return formattedInteger;
    }

    final String decimalPart = parts[1].replaceFirst(RegExp(r'0+$'), '');

    return decimalPart.isEmpty
        ? formattedInteger
        : "$formattedInteger.$decimalPart";
  }

  String _formatText(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return "--";
    }

    return value
        .toString()
        .replaceAll("_", " ")
        .toLowerCase()
        .split(" ")
        .where((word) => word.isNotEmpty)
        .map((word) => "${word[0].toUpperCase()}${word.substring(1)}")
        .join(" ");
  }

  String _formatDate(dynamic date) {
    if (date == null) {
      return "--";
    }

    DateTime? parsedDate;

    if (date is DateTime) {
      parsedDate = date;
    } else {
      parsedDate = DateTime.tryParse(date.toString());
    }

    if (parsedDate == null) {
      return "--";
    }

    final DateTime localDate = parsedDate.toLocal();

    final String day = localDate.day.toString().padLeft(2, "0");
    final String month = localDate.month.toString().padLeft(2, "0");
    final String year = localDate.year.toString();

    return "$day/$month/$year";
  }
}

class TransactionVisual {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const TransactionVisual({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
