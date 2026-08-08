import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final dynamic transaction;

  TransactionDetailsScreen({super.key, required this.transaction});

  final LanguagesController languageController =
      Get.find<LanguagesController>();

  static const Color primaryColor = Color(0xFF075EAC);
  static const Color greenColor = Color(0xFF159A67);
  static const Color redColor = Color(0xFFE74C5E);
  static const Color orangeColor = Color(0xFFFF8A3D);

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

  String _formatTitle(dynamic value) {
    final String text = _text(value, fallback: "Transaction");

    return text
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

  Color _statusColor(dynamic value) {
    final String status = _text(value, fallback: "").toLowerCase();

    if (status == "posted") {
      return greenColor;
    }

    if (status == "reversed") {
      return redColor;
    }

    return orangeColor;
  }

  Widget _detailsRow({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 10),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currencyCode = _text(
      transaction?.currencyCode ?? transaction?.currency?.code,
      fallback: "",
    );

    final String transactionType = _formatTitle(transaction?.transactionType);

    final String status = _text(transaction?.status, fallback: "Unknown");

    final String description = _text(transaction?.description, fallback: "");

    final String notes = _text(transaction?.notes, fallback: "");

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: Text(
          languageController.tr("TRANSACTION_DETAILS"),
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(13),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F4FF),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: primaryColor,
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transactionType.toString() == "Payable"
                                        ? "I Received"
                                        : "I Paid",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFF1D2733),
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.10),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: _statusColor(status),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Divider(height: 1, color: Colors.grey.shade200),
                        const SizedBox(height: 13),
                        Text(
                          _money(transaction?.amount, currencyCode),
                          style: TextStyle(
                            color: _balanceColor(transaction?.balanceEffect),
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Transaction Amount",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _detailsRow(
                          title: "Transaction ID",
                          value: _text(transaction?.id),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Reference",
                          value: _text(transaction?.reference),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Category",
                          value: _formatTitle(transaction?.category),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Account",
                          value: _text(transaction?.counterpartyAccount?.name),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Counterparty",
                          value: _text(transaction?.counterparty?.name),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Currency",
                          value: currencyCode.isEmpty ? "--" : currencyCode,
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Exchange Rate",
                          value: _number(transaction?.exchangeRate),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Balance Effect",
                          value: _money(
                            transaction?.balanceEffect,
                            currencyCode,
                          ),
                          valueColor: _balanceColor(transaction?.balanceEffect),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Before Balance",
                          value: _money(
                            transaction?.balanceBefore,
                            currencyCode,
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "After Balance",
                          value: _money(
                            transaction?.balanceAfter,
                            currencyCode,
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Transaction Date",
                          value: _formatDate(transaction?.transactionDate),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Posted At",
                          value: _formatDate(transaction?.postedAt),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Created By",
                          value: _text(transaction?.creator?.name),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        _detailsRow(
                          title: "Posted By",
                          value: _text(transaction?.poster?.name),
                        ),
                      ],
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Description",
                            style: TextStyle(
                              color: const Color(0xFF1D2733),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Notes",
                            style: TextStyle(
                              color: const Color(0xFF1D2733),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notes,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
