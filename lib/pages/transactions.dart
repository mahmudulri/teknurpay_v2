import 'package:teknurpay/widgets/button.dart';
import 'package:teknurpay/widgets/custom_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/controllers/transaction_controller.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/bottomsheet.dart';
import 'package:teknurpay/widgets/drawer.dart';
import 'package:intl/intl.dart';

import '../controllers/dashboard_controller.dart';
import '../controllers/drawer_controller.dart';
import '../global_controller/font_controller.dart';
import '../global_controller/page_controller.dart';
import '../screens/welcomescreen.dart';

class Transactions extends StatefulWidget {
  Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final ScrollController _transactionScrollController = ScrollController();

  void _onTransactionScroll() {
    if (!_transactionScrollController.hasClients) return;
    if (_transactionScrollController.position.extentAfter < 200 &&
        transactionController.errorMessage.value.isEmpty) {
      transactionController.loadMoreTransactions();
    }
  }

  @override
  void dispose() {
    _transactionScrollController.removeListener(_onTransactionScroll);
    _transactionScrollController.dispose();
    super.dispose();
  }

  final RxString selectedOrderStatus = "".obs;

  final List<Map<String, String>> orderStatus = [
    {"titleKey": "CREDIT", "value": "credit"},
    {"titleKey": "DEBIT", "value": "debit"},
  ];

  final RxString selectedCategoryType = "".obs;

  final List<Map<String, String>> categoryType = [
    {"titleKey": "ADMIN_TO_RESELLER", "value": "admin-reseller"},
    {"titleKey": "RESELLER_TO_ADMIN", "value": "reseller-subreseller"},
  ];
  final RxString selectedPurposeType = "".obs;
  final List<Map<String, String>> purposeType = [
    {"titleKey": "ORDER", "value": "order"},
    {"titleKey": "MONEY_TRANSFER", "value": "money"},
  ];

  final box = GetStorage();

  bool isFilterOpen = false;

  // String defaultValue = "";

  // String secondDropDown = "";

  Rx<DateTime?> startDate = Rx<DateTime?>(null);
  Rx<DateTime?> endDate = Rx<DateTime?>(null);

  Future<void> pickStartDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      startDate.value = picked;
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      print("Selected Start Date: $formattedDate");
      box.write("startdate", "&filter_startdate=$formattedDate");

      // Reset end date if it's before start date
      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = null;
      }
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    if (startDate.value == null) {
      Get.snackbar(
        languagesController.tr("WARNING"),
        languagesController.tr("SELECT_START_DATE_FIRST"),
      );
      return;
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value!,
      firstDate: startDate.value!, // 👈 important
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      endDate.value = picked;
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      print("Selected Start Date: $formattedDate");
      box.write("enddate", "&filter_enddate=$formattedDate");
    }
  }

  final transactionController = Get.find<TransactionController>();
  LanguagesController languagesController = Get.put(LanguagesController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final dashboardController = Get.find<DashboardController>();
  MyDrawerController drawerController = Get.put(MyDrawerController());

  @override
  void initState() {
    super.initState();
    _transactionScrollController.addListener(_onTransactionScroll);
    box.write("transactiontype", "");
    box.write("category", "");
    box.write("purpose", "");
    box.write("startdate", "");
    box.write("enddate", "");

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Status bar background color
        statusBarIconBrightness: Brightness.dark, // For Android
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );
    transactionController.fetchTransactionData();
  }

  final Mypagecontroller mypagecontroller = Get.find();

  String _label(String key, String fallback) {
    final value = languagesController.tr(key);
    return value == key || value.trim().isEmpty ? fallback : value;
  }

  String _money(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '') ?? 0;
    return NumberFormat('#,##0.00', 'en_US').format(amount);
  }

  String _currency(dynamic transaction) {
    final fromTransaction = transaction.currency?.code?.toString();
    if (fromTransaction != null && fromTransaction.isNotEmpty)
      return fromTransaction;
    final fromCode = transaction.currencyCode?.toString();
    if (fromCode != null && fromCode.isNotEmpty) return fromCode;
    return box.read('currency_code')?.toString() ?? '';
  }

  String _resellerName(dynamic transaction) {
    final name = transaction.reseller?.resellerName?.toString();
    if (name != null && name.trim().isNotEmpty) return name;
    final contact = transaction.reseller?.contactName?.toString();
    if (contact != null && contact.trim().isNotEmpty) return contact;
    final userName = transaction.reseller?.user?.name?.toString();
    return userName == null || userName.trim().isEmpty ? '—' : userName;
  }

  bool _isDebit(dynamic transaction) =>
      transaction.status?.toString().toLowerCase() == 'debit';

  Widget _detailRow(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8FA),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: const Color(0xFF159CAD), size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF94A0A9),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: valueColor ?? const Color(0xFF0D2E50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(dynamic transaction) {
    final debit = _isDebit(transaction);
    final accent = debit ? const Color(0xFFD94B61) : const Color(0xFF149A65);
    final pale = debit ? const Color(0xFFFFF0F2) : const Color(0xFFEDFAF3);
    final type = debit ? _label('DEBIT', 'Debit') : _label('CREDIT', 'Credit');
    final DateTime? date = transaction.createdAt;
    final name = _resellerName(transaction);
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 23),
                color: pale,
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        debit
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: accent,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 17),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${_money(transaction.amount)} ${_currency(transaction)}',
                        style: TextStyle(
                          color: accent,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(19, 10, 19, 19),
                child: Column(
                  children: [
                    _detailRow(
                      Icons.person_outline_rounded,
                      _label('NAME', 'Name'),
                      name,
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F2F4)),
                    _detailRow(
                      Icons.calendar_today_outlined,
                      _label('DATE', 'Date'),
                      date == null
                          ? '—'
                          : DateFormat('dd MMM yyyy').format(date.toLocal()),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F2F4)),
                    _detailRow(
                      Icons.access_time_rounded,
                      _label('TIME', 'Time'),
                      date == null
                          ? '—'
                          : DateFormat('hh:mm a').format(date.toLocal()),
                    ),
                    const Divider(height: 1, color: Color(0xFFF0F2F4)),
                    _detailRow(
                      Icons.swap_horiz_rounded,
                      _label('TRANSACTION_TYPE', 'Transaction Type'),
                      type,
                      valueColor: accent,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F8FA),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          _label('CLOSE', 'Close'),
                          style: const TextStyle(
                            color: Color(0xFF0D2E50),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _transactionItem(dynamic transaction) {
    final debit = _isDebit(transaction);
    final accent = debit ? const Color(0xFFD94B61) : const Color(0xFF149A65);
    final pale = debit ? const Color(0xFFFFF0F2) : const Color(0xFFEDFAF3);
    final type = debit ? _label('DEBIT', 'Debit') : _label('CREDIT', 'Credit');
    final DateTime? date = transaction.createdAt;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _showTransactionDetails(transaction),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEBEFF2)),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: pale,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  debit
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _resellerName(transaction),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D2E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date == null
                          ? '—'
                          : DateFormat(
                              'dd MMM yyyy • hh:mm a',
                            ).format(date.toLocal()),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF98A4AD),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_money(transaction.amount)} ${_currency(transaction)}',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_label('AMOUNT', 'Amount')} ($type)',
                    style: const TextStyle(
                      color: Color(0xFF98A4AD),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      bottom: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Container(
          height: screenHeight,
          width: screenWidth,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15, top: 0),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            mypagecontroller.goBack();
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              "assets/icons/backicon.png",
                              height: 40,
                            ),
                          ),
                        ),
                        Spacer(),
                        Obx(
                          () => KText(
                            text: languagesController.tr("TRANSACTIONS"),
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            CustomFullScreenSheet.show(context);
                          },
                          child: Image.asset(
                            "assets/icons/drawericon.png",
                            height: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          height: 50,
                          width: screenWidth,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  languagesController.tr("FILTER_TRANSACTION"),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isFilterOpen = !isFilterOpen;
                                    });
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: FaIcon(
                                      isFilterOpen
                                          ? FontAwesomeIcons.chevronUp
                                          : FontAwesomeIcons.chevronDown,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.40,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: isFilterOpen,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,

                                  width: screenWidth,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: isFilterOpen
                                      ? Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 10,
                                              ),
                                              child: Column(
                                                children: [
                                                  //............................Type............//
                                                  Row(
                                                    children: [
                                                      Text(
                                                        languagesController.tr(
                                                          "TYPE",
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                          ),
                                                      child: DropdownButtonHideUnderline(
                                                        child: Obx(
                                                          () => DropdownButton<String>(
                                                            value:
                                                                selectedOrderStatus
                                                                    .value
                                                                    .isEmpty
                                                                ? null
                                                                : selectedOrderStatus
                                                                      .value,
                                                            isExpanded: true,
                                                            hint: KText(
                                                              text:
                                                                  languagesController
                                                                      .tr(
                                                                        "ALL",
                                                                      ),
                                                              fontSize:
                                                                  screenWidth *
                                                                  0.040,
                                                            ),
                                                            items: [
                                                              // ALL option
                                                              DropdownMenuItem<
                                                                String
                                                              >(
                                                                value: "",
                                                                child: KText(
                                                                  text: languagesController
                                                                      .tr(
                                                                        "ALL",
                                                                      ),
                                                                  fontSize:
                                                                      screenWidth *
                                                                      0.040,
                                                                ),
                                                              ),

                                                              // Order status options
                                                              ...orderStatus.map<
                                                                DropdownMenuItem<
                                                                  String
                                                                >
                                                              >((data) {
                                                                return DropdownMenuItem<
                                                                  String
                                                                >(
                                                                  value:
                                                                      data['value'],
                                                                  child: KText(
                                                                    text: languagesController.tr(
                                                                      data['titleKey']!,
                                                                    ),
                                                                    fontSize:
                                                                        screenWidth *
                                                                        0.040,
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ],
                                                            onChanged: (value) {
                                                              selectedOrderStatus
                                                                      .value =
                                                                  value ?? "";

                                                              print(
                                                                value
                                                                    .toString(),
                                                              );
                                                              box.write(
                                                                "transactiontype",
                                                                "&filter_transactiontype=$value",
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  //............................Category............//
                                                  Row(
                                                    children: [
                                                      Text(
                                                        languagesController.tr(
                                                          "SELECT_CATEGORY",
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                          ),
                                                      child: DropdownButtonHideUnderline(
                                                        child: Obx(
                                                          () => DropdownButton<String>(
                                                            value:
                                                                selectedCategoryType
                                                                    .value
                                                                    .isEmpty
                                                                ? null
                                                                : selectedCategoryType
                                                                      .value,
                                                            isExpanded: true,
                                                            hint: KText(
                                                              text:
                                                                  languagesController
                                                                      .tr(
                                                                        "ALL",
                                                                      ),
                                                              fontSize:
                                                                  screenWidth *
                                                                  0.040,
                                                            ),
                                                            items: [
                                                              // ALL
                                                              DropdownMenuItem<
                                                                String
                                                              >(
                                                                value: "",
                                                                child: KText(
                                                                  text: languagesController
                                                                      .tr(
                                                                        "ALL",
                                                                      ),
                                                                  fontSize:
                                                                      screenWidth *
                                                                      0.040,
                                                                ),
                                                              ),

                                                              // Category Type items
                                                              ...categoryType.map<
                                                                DropdownMenuItem<
                                                                  String
                                                                >
                                                              >((data) {
                                                                return DropdownMenuItem<
                                                                  String
                                                                >(
                                                                  value:
                                                                      data['value'],
                                                                  child: KText(
                                                                    text: languagesController.tr(
                                                                      data['titleKey']!,
                                                                    ),
                                                                    fontSize:
                                                                        screenWidth *
                                                                        0.040,
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ],
                                                            onChanged: (value) {
                                                              selectedCategoryType
                                                                      .value =
                                                                  value ?? "";
                                                              print(
                                                                value
                                                                    .toString(),
                                                              );
                                                              box.write(
                                                                "category",
                                                                "&filter_transactioncategory=$value",
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  //............................Purpose............//
                                                  Row(
                                                    children: [
                                                      Text(
                                                        languagesController.tr(
                                                          "SELECT_PURPOSE",
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                          ),
                                                      child: DropdownButtonHideUnderline(
                                                        child: Obx(
                                                          () => DropdownButton<String>(
                                                            value:
                                                                selectedPurposeType
                                                                    .value
                                                                    .isEmpty
                                                                ? null
                                                                : selectedPurposeType
                                                                      .value,
                                                            isExpanded: true,
                                                            hint: KText(
                                                              text:
                                                                  languagesController
                                                                      .tr(
                                                                        "ALL",
                                                                      ),
                                                              fontSize:
                                                                  screenWidth *
                                                                  0.040,
                                                            ),
                                                            items: [
                                                              // ALL
                                                              DropdownMenuItem<
                                                                String
                                                              >(
                                                                value: "",
                                                                child: KText(
                                                                  text: languagesController
                                                                      .tr(
                                                                        "ALL",
                                                                      ),
                                                                  fontSize:
                                                                      screenWidth *
                                                                      0.040,
                                                                ),
                                                              ),

                                                              // Purpose Type options
                                                              ...purposeType.map<
                                                                DropdownMenuItem<
                                                                  String
                                                                >
                                                              >((data) {
                                                                return DropdownMenuItem<
                                                                  String
                                                                >(
                                                                  value:
                                                                      data['value'],
                                                                  child: KText(
                                                                    text: languagesController.tr(
                                                                      data['titleKey']!,
                                                                    ),
                                                                    fontSize:
                                                                        screenWidth *
                                                                        0.040,
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ],
                                                            onChanged: (value) {
                                                              selectedPurposeType
                                                                      .value =
                                                                  value ?? "";

                                                              print(
                                                                value
                                                                    .toString(),
                                                              );
                                                              box.write(
                                                                "purpose",
                                                                "&filter_transactionpurpose=$value",
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      /// START DATE
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            // open start date picker
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                  ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Obx(
                                                                    () => KText(
                                                                      text:
                                                                          startDate.value ==
                                                                              null
                                                                          ? languagesController.tr(
                                                                              "START_DATE",
                                                                            )
                                                                          : DateFormat(
                                                                              'yyyy/MM/dd',
                                                                            ).format(
                                                                              startDate.value!,
                                                                            ),

                                                                      fontSize:
                                                                          screenWidth *
                                                                          0.040,
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        pickStartDate(
                                                                          context,
                                                                        ),

                                                                    child: Icon(
                                                                      Icons
                                                                          .calendar_month,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 10),

                                                      /// END DATE
                                                      Expanded(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            // open end date picker
                                                          },
                                                          child: Container(
                                                            height: 50,
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .grey
                                                                    .shade300,
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                  ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Obx(
                                                                    () => KText(
                                                                      text:
                                                                          endDate.value ==
                                                                              null
                                                                          ? languagesController.tr(
                                                                              "END_DATE",
                                                                            )
                                                                          : DateFormat(
                                                                              'yyyy/MM/dd',
                                                                            ).format(
                                                                              endDate.value!,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        pickEndDate(
                                                                          context,
                                                                        ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .calendar_month,
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  // Container(
                                                  //   height: 50,
                                                  //   decoration: BoxDecoration(
                                                  //     borderRadius: BorderRadius.circular(
                                                  //       8,
                                                  //     ),
                                                  //     border: Border.all(
                                                  //       width: 1,
                                                  //       color: Colors.grey.shade300,
                                                  //     ),
                                                  //   ),
                                                  //   child: Padding(
                                                  //     padding: EdgeInsets.symmetric(
                                                  //       horizontal: 10,
                                                  //     ),
                                                  //     child: Row(
                                                  //       mainAxisAlignment:
                                                  //           MainAxisAlignment
                                                  //               .spaceBetween,
                                                  //       children: [
                                                  //         Icon(
                                                  //           Icons.search_sharp,
                                                  //           color: Colors.grey,
                                                  //           size: screenHeight * 0.040,
                                                  //         ),
                                                  //         SizedBox(width: 10),
                                                  //         Expanded(
                                                  //           child: Obx(
                                                  //             () => TextField(
                                                  //               decoration: InputDecoration(
                                                  //                 hintText:
                                                  //                     languagesController.tr(
                                                  //                       "SEARCH_BY_PHOENUMBER",
                                                  //                     ),
                                                  //                 border:
                                                  //                     InputBorder.none,
                                                  //                 hintStyle: TextStyle(
                                                  //                   color: Colors.grey,
                                                  //                   fontSize:
                                                  //                       screenWidth *
                                                  //                       0.040,
                                                  //                   fontFamily:
                                                  //                       box
                                                  //                               .read(
                                                  //                                 "language",
                                                  //                               )
                                                  //                               .toString() ==
                                                  //                           "Fa"
                                                  //                       ? Get.find<
                                                  //                               FontController
                                                  //                             >()
                                                  //                             .currentFont
                                                  //                       : null,
                                                  //                 ),
                                                  //               ),
                                                  //             ),
                                                  //           ),
                                                  //         ),
                                                  //       ],
                                                  //     ),
                                                  //   ),
                                                  // ),
                                                  SizedBox(height: 10),
                                                  Obx(
                                                    () => Container(
                                                      height: 45,
                                                      width: screenWidth,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 5,
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                transactionController
                                                                    .fetchTransactionData();
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                  border: Border.all(
                                                                    width: 1,
                                                                    color: Color(
                                                                      0xffFF6A60,
                                                                    ),
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: KText(
                                                                    text: languagesController.tr(
                                                                      "APPLY_FILTER",
                                                                    ),
                                                                    color: Color(
                                                                      0xffFF6A60,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize:
                                                                        screenWidth *
                                                                        0.035,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Expanded(
                                                            flex: 4,
                                                            child: DefaultButton1(
                                                              buttonName:
                                                                  languagesController.tr(
                                                                    "REMOVE_FILTER",
                                                                  ),
                                                              onpressed: () {
                                                                selectedOrderStatus
                                                                        .value =
                                                                    "";
                                                                selectedCategoryType
                                                                        .value =
                                                                    "";
                                                                selectedPurposeType
                                                                        .value =
                                                                    "";
                                                                startDate
                                                                        .value =
                                                                    null;
                                                                endDate.value =
                                                                    null;
                                                                box.write(
                                                                  "transactiontype",
                                                                  "",
                                                                );
                                                                box.write(
                                                                  "category",
                                                                  "",
                                                                );
                                                                box.write(
                                                                  "purpose",
                                                                  "",
                                                                );
                                                                box.write(
                                                                  "startdate",
                                                                  "",
                                                                );
                                                                box.write(
                                                                  "enddate",
                                                                  "",
                                                                );
                                                                transactionController
                                                                    .fetchTransactionData();
                                                              },
                                                              height: 45,
                                                              width: double
                                                                  .maxFinite,
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
                                        )
                                      : SizedBox(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: transactionController.fetchTransactionData,
                          child: ListView(
                            controller: _transactionScrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            children: [
                              Obx(() {
                                final loadingMore =
                                    transactionController.isLoadingMore.value;
                                final pageError =
                                    transactionController.errorMessage.value;
                                final moreAvailable =
                                    transactionController.hasMore.value;
                                if (transactionController.isLoading.value) {
                                  return const Padding(
                                    padding: EdgeInsets.all(35),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                final transactions =
                                    transactionController.transactions;
                                if (transactions.isEmpty &&
                                    transactionController
                                        .errorMessage
                                        .value
                                        .isNotEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: TextButton(
                                      onPressed: transactionController
                                          .fetchTransactionData,
                                      child: Text(
                                        transactionController
                                            .errorMessage
                                            .value,
                                      ),
                                    ),
                                  );
                                }
                                if (transactions.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: Center(
                                      child: Text(
                                        languagesController.tr('NO_DATA_FOUND'),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(bottom: 24),
                                    itemCount: transactions.length + 1,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      if (index < transactions.length) {
                                        return _transactionItem(
                                          transactions[index],
                                        );
                                      }
                                      if (loadingMore) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      if (pageError.isNotEmpty) {
                                        return TextButton(
                                          onPressed: transactionController
                                              .loadMoreTransactions,
                                          child: Text(
                                            transactionController
                                                .errorMessage
                                                .value,
                                          ),
                                        );
                                      }
                                      // Also allows fetching another page when the first
                                      // page is too short to fill the viewport.
                                      if (moreAvailable) {
                                        return TextButton(
                                          onPressed: transactionController
                                              .loadMoreTransactions,
                                          child: Text(
                                            _label('LOAD_MORE', 'Load more'),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
