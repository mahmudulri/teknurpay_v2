import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/accounting/controllers/office_details_controller.dart';
import 'package:teknurpay/accounting/screens/account_details_screen.dart';
import '../global_controller/languages_controller.dart';
import '../utils/colors.dart';
import 'controllers/accounts_of_office_controller.dart';
import 'controllers/transactions_of_office_controller.dart';
import 'screens/create_account_screen2.dart';
import 'screens/transaction_details_screen.dart';

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

  const ViewOfficeScreen({
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
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final AccountsofOfficeController accountsofOfficeController = Get.put(
    AccountsofOfficeController(),
  );

  final TransactionsOfOfficeController transactionlistController = Get.put(
    TransactionsOfOfficeController(),
  );

  final OfficeDetailsController officeDetailsController = Get.put(
    OfficeDetailsController(),
  );

  final GetStorage box = GetStorage();

  static const Color primaryColor = AppColors.primaryColor;
  static const Color backgroundBlue = AppColors.primarycolor2;
  static const Color softBlue = AppColors.secondaryColor;
  static const Color greenColor = AppColors.primaryColor;
  static const Color redColor = Color(0xFFE74C5E);
  static const Color orangeColor = Color(0xFFFF8A3D);

  final RxInt selectedBalanceCurrencyIndex = 0.obs;

  @override
  void initState() {
    super.initState();

    accountsofOfficeController.fetchdata(widget.id);
    transactionlistController.fetchdata(widget.id);
    officeDetailsController.fetchdata(widget.id.toString());

    box.write("officeID", widget.id?.toString() ?? "");
  }

  String _text(dynamic value, {String fallback = "--"}) {
    if (value == null) {
      return fallback;
    }

    final String result = value.toString().trim();

    if (result.isEmpty || result.toLowerCase() == "null") {
      return fallback;
    }

    return result;
  }

  String _number(dynamic value, {String fallback = "0"}) {
    if (value == null) {
      return fallback;
    }

    final String rawValue = value.toString().trim();

    if (rawValue.isEmpty || rawValue.toLowerCase() == "null") {
      return fallback;
    }

    final double? amount = double.tryParse(rawValue);

    if (amount == null) {
      return rawValue;
    }

    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
  }

  String _money(dynamic value, dynamic currencyCode) {
    final String amount = _number(value);
    final String code = _text(currencyCode, fallback: "");

    return code.isEmpty ? amount : "$amount $code";
  }

  String _formatTransactionType(dynamic value) {
    final String type = _text(value, fallback: "Transaction");

    return type
        .replaceAll("_", " ")
        .toLowerCase()
        .split(" ")
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}",
        )
        .join(" ");
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return "--";
    }

    DateTime? date;

    if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(value.toString());
    }

    if (date == null) {
      return _text(value);
    }

    final DateTime localDate = date.toLocal();

    const List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    final String day = localDate.day.toString().padLeft(2, "0");
    final String month = months[localDate.month - 1];
    final String year = localDate.year.toString();

    final int hour = localDate.hour == 0
        ? 12
        : localDate.hour > 12
        ? localDate.hour - 12
        : localDate.hour;

    final String minute = localDate.minute.toString().padLeft(2, "0");
    final String period = localDate.hour >= 12 ? "PM" : "AM";

    return "$day $month $year, $hour:$minute $period";
  }

  Color _balanceColor(dynamic value) {
    final double amount = double.tryParse(value?.toString() ?? "0") ?? 0;

    if (amount > 0) {
      return greenColor;
    }

    if (amount < 0) {
      return redColor;
    }

    return Colors.grey.shade700;
  }

  Color _transactionTypeColor(dynamic value) {
    final String type = _text(value, fallback: "").toUpperCase();

    if (type.contains("RECEIVABLE")) {
      return greenColor;
    }

    if (type.contains("PAYABLE")) {
      return redColor;
    }

    if (type.contains("OPENING")) {
      return primaryColor;
    }

    if (type.contains("REVERSAL")) {
      return orangeColor;
    }

    return const Color(0xFF7556D8);
  }

  IconData _transactionTypeIcon(dynamic value) {
    final String type = _text(value, fallback: "").toUpperCase();

    if (type.contains("RECEIVABLE")) {
      return Icons.south_west_rounded;
    }

    if (type.contains("PAYABLE")) {
      return Icons.north_east_rounded;
    }

    if (type.contains("OPENING")) {
      return Icons.account_balance_wallet_outlined;
    }

    if (type.contains("REVERSAL")) {
      return Icons.undo_rounded;
    }

    return Icons.swap_horiz_rounded;
  }

  void _showOfficeDetails(dynamic office) {
    final String officeName = _text(
      office?.name ?? widget.officeName,
      fallback: "Office",
    );

    final String officeCode = _text(office?.code ?? widget.officeId);

    final String phone = _text(office?.phone ?? widget.phone);

    final String location = _text(office?.location ?? widget.location);

    final String address = _text(office?.address ?? widget.address);

    final String notes = _text(office?.notes ?? widget.notes);

    final String accountsCount = _number(office?.accountsCount);

    final String transactionsCount = _number(office?.transactionsCount);

    final bool isActive = office?.isActive ?? false;

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.listbuilderboxColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: AppColors.primaryColor,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            officeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1D2733),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            officeCode,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 14),
                _dialogInfoRow(
                  icon: Icons.circle,
                  title: languagesController.tr("STATUS"),
                  value: isActive ? "Active" : "Inactive",
                  valueColor: isActive ? greenColor : redColor,
                ),
                const SizedBox(height: 12),
                _dialogInfoRow(
                  icon: Icons.phone_outlined,
                  title: languagesController.tr("PHONE"),
                  value: phone,
                ),
                const SizedBox(height: 12),
                _dialogInfoRow(
                  icon: Icons.location_on_outlined,
                  title: languagesController.tr("LOCATION"),
                  value: location,
                ),
                const SizedBox(height: 12),
                _dialogInfoRow(
                  icon: Icons.home_work_outlined,
                  title: languagesController.tr("ADDRESS"),
                  value: address,
                ),
                const SizedBox(height: 12),
                _dialogInfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: languagesController.tr("ACCOUNTS"),
                  value: accountsCount,
                ),
                const SizedBox(height: 12),
                _dialogInfoRow(
                  icon: Icons.receipt_long_outlined,
                  title: languagesController.tr("TRANSACTIONS"),
                  value: transactionsCount,
                ),
                if (notes != "--") ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notes_rounded,
                              size: 17,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              languagesController.tr("NOTES"),
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          notes,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(dynamic transaction) {
    final String currencyCode = _text(
      transaction?.currencyCode ?? transaction?.currency?.code,
      fallback: "",
    );

    final String status = _text(transaction?.status, fallback: "Unknown");

    final bool isPosted = status.toLowerCase() == "posted";

    final Color transactionColor = _transactionTypeColor(
      transaction?.transactionType,
    );

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: AppColors.listbuilderboxColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 8, 12),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: transactionColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        _transactionTypeIcon(transaction?.transactionType),
                        color: transactionColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatTransactionType(
                              transaction?.transactionType,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1D2733),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _text(
                              transaction?.counterparty?.name,
                              fallback: "Unknown Counterparty",
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black54,
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
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: transactionColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "Amount",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _money(transaction?.amount, currencyCode),
                              style: TextStyle(
                                color: _balanceColor(
                                  transaction?.balanceEffect,
                                ),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 13),
                      _transactionDialogRow(
                        title: "Transaction ID",
                        value: _text(transaction?.id),
                      ),
                      _transactionDialogRow(
                        title: "Status",
                        value: status,
                        valueColor: isPosted ? greenColor : orangeColor,
                      ),
                      _transactionDialogRow(
                        title: "Reference",
                        value: _text(transaction?.reference),
                      ),
                      _transactionDialogRow(
                        title: "Category",
                        value: _formatTransactionType(transaction?.category),
                      ),
                      _transactionDialogRow(
                        title: "Account",
                        value: _text(transaction?.counterpartyAccount?.name),
                      ),
                      _transactionDialogRow(
                        title: "Counterparty",
                        value: _text(transaction?.counterparty?.name),
                      ),
                      _transactionDialogRow(
                        title: "Currency",
                        value: currencyCode.isEmpty ? "--" : currencyCode,
                      ),
                      _transactionDialogRow(
                        title: "Exchange Rate",
                        value: _number(transaction?.exchangeRate),
                      ),
                      _transactionDialogRow(
                        title: "Balance Effect",
                        value: _money(transaction?.balanceEffect, currencyCode),
                        valueColor: _balanceColor(transaction?.balanceEffect),
                      ),
                      _transactionDialogRow(
                        title: "Before Balance",
                        value: _money(transaction?.balanceBefore, currencyCode),
                      ),
                      _transactionDialogRow(
                        title: "After Balance",
                        value: _money(transaction?.balanceAfter, currencyCode),
                      ),
                      _transactionDialogRow(
                        title: "Transaction Date",
                        value: _formatDate(transaction?.transactionDate),
                      ),
                      _transactionDialogRow(
                        title: "Posted At",
                        value: _formatDate(transaction?.postedAt),
                      ),
                      _transactionDialogRow(
                        title: "Created By",
                        value: _text(transaction?.creator?.name),
                      ),
                      _transactionDialogRow(
                        title: "Posted By",
                        value: _text(transaction?.poster?.name),
                      ),
                      if (_text(
                        transaction?.description,
                        fallback: "",
                      ).isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Description",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _text(transaction?.description),
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_text(
                        transaction?.notes,
                        fallback: "",
                      ).isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Notes",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _text(transaction?.notes),
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: icon == Icons.circle ? 10 : 18,
          color: icon == Icons.circle
              ? valueColor ?? primaryColor
              : primaryColor,
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 95,
          child: Text(
            title,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _transactionDialogRow({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? Colors.grey.shade800,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.listbuilderboxColor,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.secondaryColor, AppColors.primarycolor2],
              ),
            ),
            child: Obx(() {
              if (accountsofOfficeController.isLoading.value ||
                  officeDetailsController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              final accountModel =
                  accountsofOfficeController.accountsdetails.value;

              final accountData = accountModel.data;
              final office = accountData?.office;

              final officeDetailsData =
                  officeDetailsController.allofficedata.value.data;
              final officeDetails = officeDetailsData?.office;
              final officeBalanceSummary =
                  officeDetailsData?.summary?.balanceSummary ?? [];

              if (accountData == null || officeDetailsData == null) {
                return _buildErrorView();
              }

              return RefreshIndicator(
                color: AppColors.primaryColor,
                onRefresh: () async {
                  await Future.wait([
                    accountsofOfficeController.fetchdata(widget.id),
                    transactionlistController.fetchdata(widget.id),
                    officeDetailsController.fetchdata(widget.id.toString()),
                  ]);
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 8, 13, 0),
                  child: Column(
                    children: [
                      _buildBalanceSummaryCard(
                        officeDetails ?? office,
                        officeBalanceSummary,
                        officeDetailsData?.summary?.counts,
                      ),
                      const SizedBox(height: 12),
                      _buildTabBar(),
                      const SizedBox(height: 10),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAccountsTab(office?.accounts ?? []),
                            Obx(() {
                              if (transactionlistController.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryColor,
                                  ),
                                );
                              }

                              final transactionModel = transactionlistController
                                  .alltransactions
                                  .value;

                              final transactions =
                                  transactionModel.data?.office?.transactions ??
                                  [];

                              return _buildTransactionsTab(transactions);
                            }),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(
                            () => CreateAccountScreen2(
                              officeId: int.parse(widget.id.toString()),
                            ),
                          );
                        },
                        child: Container(
                          height: 55,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primarycolor2,
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor.withOpacity(0.28),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              languagesController.tr("ADD_NEW_ACCOUNT"),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
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
              );
            }),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: AppColors.listbuilderboxColor,
      backgroundColor: AppColors.listbuilderboxColor,
      leading: IconButton(
        onPressed: Get.back,
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Colors.black87,
        ),
      ),
      titleSpacing: 0,
      title: Text(
        widget.officeName?.trim().isNotEmpty == true
            ? widget.officeName!
            : languagesController.tr("OFFICE_DETAILS"),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBalanceSummaryCard(
    dynamic office,
    List<dynamic> balanceSummary,
    dynamic counts,
  ) {
    if (balanceSummary.isEmpty) {
      final int accountsCount = counts?.accounts ?? 0;
      final int counterpartiesCount = counts?.counterparties ?? 0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFF667085),
                  size: 21,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    languagesController.tr("BALANCE_SETTLED"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Material(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _showOfficeDetails(office),
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      width: 38,
                      height: 38,
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
            const SizedBox(height: 8),
            Text(
              "$accountsCount ${languagesController.tr("ACCOUNTS")}  •  "
              "$counterpartiesCount ${languagesController.tr("COUNTER_PARTY")}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                      color: AppColors.primaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.18),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languagesController.tr("TOTAL_I_RECEIVED"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "0",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languagesController.tr("TOTAL_I_PAID"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "0",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
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
            const SizedBox(height: 10),
            Text(
              languagesController.tr("NO_BALANCE_SUMMARY_FOUND"),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Obx(() {
      if (selectedBalanceCurrencyIndex.value >= balanceSummary.length) {
        selectedBalanceCurrencyIndex.value = 0;
      }

      final selectedBalance =
          balanceSummary[selectedBalanceCurrencyIndex.value];

      final String currencyCode = _text(
        selectedBalance.currencyCode,
        fallback: "",
      );

      final double netBalance =
          double.tryParse(selectedBalance.netBalance?.toString() ?? "0") ?? 0;

      final double receivableBalance =
          double.tryParse(
            selectedBalance.receivableBalance?.toString() ?? "0",
          ) ??
          0;

      final double payableBalance =
          double.tryParse(selectedBalance.payableBalance?.toString() ?? "0") ??
          0;

      final bool isSettled = netBalance == 0;
      final bool youAreOwed = netBalance > 0;

      final String formattedNetBalance = currencyCode.isEmpty
          ? _number(netBalance.abs())
          : "${_number(netBalance.abs())} $currencyCode";

      final String balanceRelationText;
      final Color balanceRelationColor;
      final IconData balanceRelationIcon;

      if (isSettled) {
        balanceRelationText = languagesController.tr("BALANCE_SETTLED");
        balanceRelationColor = const Color(0xFF667085);
        balanceRelationIcon = Icons.check_circle_outline_rounded;
      } else if (youAreOwed) {
        balanceRelationText = languagesController.tr("YOU_ARE_OWED");
        balanceRelationColor = const Color(0xFF159455);
        balanceRelationIcon = Icons.south_west_rounded;
      } else {
        balanceRelationText = languagesController.tr("YOU_OWE");
        balanceRelationColor = const Color(0xFFD92D20);
        balanceRelationIcon = Icons.north_east_rounded;
      }

      final int accountsCount =
          counts?.accounts ??
          int.tryParse(_number(selectedBalance.accountsCount)) ??
          0;

      final int counterpartiesCount = counts?.counterparties ?? 0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
                    isSettled ? formattedNetBalance : formattedNetBalance,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: balanceRelationColor,
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Material(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => _showOfficeDetails(office),
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      width: 38,
                      height: 38,
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
            const SizedBox(height: 8),
            Text(
              "$accountsCount ${languagesController.tr("ACCOUNTS")}  •  "
              "$counterpartiesCount ${languagesController.tr("COUNTER_PARTY")}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                      color: AppColors.primaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.18),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languagesController.tr("TOTAL_I_RECEIVED"),
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
                                    ? _number(receivableBalance.abs())
                                    : "$currencyCode ${_number(receivableBalance.abs())}",
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languagesController.tr("TOTAL_I_PAID"),
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
                                    ? _number(payableBalance.abs())
                                    : "$currencyCode ${_number(payableBalance.abs())}",
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
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(balanceSummary.length, (index) {
                          final balance = balanceSummary[index];
                          final bool isSelected =
                              selectedBalanceCurrencyIndex.value == index;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () {
                                selectedBalanceCurrencyIndex.value = index;
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryColor
                                        : AppColors.primarycolor2.withOpacity(
                                            0.35,
                                          ),
                                  ),
                                ),
                                child: Text(
                                  _text(balance.currencyCode, fallback: "--"),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.primaryColor,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.primaryColor, AppColors.primarycolor2],
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE74CD8).withOpacity(0.30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        tabs: [
          Tab(text: languagesController.tr("ACCOUNTS")),
          Tab(text: languagesController.tr("TRANSACTIONS")),
        ],
      ),
    );
  }

  Widget _buildAccountsTab(List<dynamic> accounts) {
    if (accounts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 35),
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 55,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            languagesController.tr("NO_ACCOUNTS_FOUNDS"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];

        final String accountName = _text(
          account.name,
          fallback: "Unnamed Account",
        );

        final String counterpartyName = _text(
          account.counterparty?.name,
          fallback: "Unknown Counterparty",
        );

        final String currencyCode = _text(
          account.currencyCode ?? account.currency?.code,
          fallback: "--",
        );

        final String accountType = _text(account.accountType, fallback: "--");

        return GestureDetector(
          onTap: () {
            print(account.id.toString());
            Get.to(
              () => AccountDetailsScreen(accountID: account.id.toString()),
            );
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.listbuilderboxColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.listbuilderboxColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      currencyCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
                        style: const TextStyle(
                          color: Color(0xFF1D2733),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        counterpartyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        accountType.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(account.currentBalance, currencyCode),
                      style: TextStyle(
                        color: _balanceColor(account.currentBalance),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Opening: ${_money(account.openingBalance, currencyCode)}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionsTab(List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 35),
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 55,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
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
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];

        final String currencyCode = _text(
          transaction.currencyCode ?? transaction.currency?.code,
          fallback: "--",
        );

        final String status = _text(transaction.status, fallback: "Unknown");

        final bool isPosted = status.toLowerCase() == "posted";

        final Color transactionColor = _transactionTypeColor(
          transaction.transactionType,
        );

        return InkWell(
          onTap: () {
            Get.to(() => TransactionDetailsScreen(transaction: transaction));
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.listbuilderboxColor.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.listbuilderboxColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: transactionColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _transactionTypeIcon(transaction.transactionType),
                    color: transactionColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.transactionType.toString() == "PAYABLE"
                            ? "I Received"
                            : "I Paid",
                        style: const TextStyle(
                          color: Color(0xFF1D2733),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Text(
                      //   _formatTransactionType(transaction.transactionType),
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: const TextStyle(
                      //     color: Color(0xFF1D2733),
                      //     fontSize: 13,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                      const SizedBox(height: 4),
                      Text(
                        _text(
                          transaction.counterparty?.name,
                          fallback: "Unknown Counterparty",
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(transaction.transactionDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _money(transaction.amount, currencyCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _balanceColor(transaction.balanceEffect),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPosted
                            ? const Color(0xFFE5F8F0)
                            : const Color(0xFFFFF0E7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: isPosted ? greenColor : orangeColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward,
                  size: 17,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorView() {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () async {
        await Future.wait([
          accountsofOfficeController.fetchdata(widget.id),
          transactionlistController.fetchdata(widget.id),
          officeDetailsController.fetchdata(widget.id.toString()),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(25),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEAED),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: redColor,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  languagesController.tr("NO_OFFICE_DETAILS_FOUND"),
                  style: TextStyle(
                    color: Color(0xFF1D2733),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    accountsofOfficeController.fetchdata(widget.id);
                    transactionlistController.fetchdata(widget.id);
                    officeDetailsController.fetchdata(widget.id.toString());
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(languagesController.tr("TRY_AGAIN")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
