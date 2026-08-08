import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teknurpay/helpers/language_changer.dart';
import '../../global_controller/languages_controller.dart';
import '../../utils/colors.dart';
import '../controllers/accounting_currency_controller.dart';
import '../controllers/allaccount_list_controller.dart';
import '../controllers/office_list_controller.dart';
import '../create_account_screen.dart';
import '../models/allaccount_model.dart';
import '../screens/account_details_screen.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final AllAccountListController accountListController =
      Get.isRegistered<AllAccountListController>()
      ? Get.find<AllAccountListController>()
      : Get.put(AllAccountListController());

  final OfficeListController officeListController =
      Get.isRegistered<OfficeListController>()
      ? Get.find<OfficeListController>()
      : Get.put(OfficeListController());

  final AccountingCurrencyController currencyController =
      Get.isRegistered<AccountingCurrencyController>()
      ? Get.find<AccountingCurrencyController>()
      : Get.put(AccountingCurrencyController());

  @override
  void initState() {
    super.initState();
    accountListController.fetchaccount();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: AppColors.listbuilderboxColor,

        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.listbuilderboxColor,
          surfaceTintColor: AppColors.listbuilderboxColor,
          titleSpacing: 15,

          title: Row(
            children: [
              Text(
                languagesController.tr("ACCOUNTS"),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              const LanguageSelectorButton(size: 42, iconSize: 25),
            ],
          ),
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

          child: Obx(() {
            final bool isLoading = accountListController.isLoading.value;

            final List<Account> accounts =
                accountListController.accountlist.value.data?.accounts ?? [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : accounts.isEmpty
                        ? RefreshIndicator(
                            onRefresh: () async {
                              await accountListController.fetchaccount();
                            },
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.42,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 72,
                                          width: 72,
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.listbuilderboxColor,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: AppColors.secondaryColor,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons
                                                .account_balance_wallet_outlined,
                                            size: 34,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          languagesController.tr(
                                            "NO_ACCOUNTS_FOUND",
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              await accountListController.fetchaccount();
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),

                              itemCount: accounts.length,

                              itemBuilder: (context, index) {
                                final Account account = accounts[index];

                                return InkWell(
                                  onTap: () {
                                    Get.to(
                                      () => AccountDetailsScreen(
                                        accountID: account.id.toString(),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 7),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.listbuilderboxColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.secondaryColor,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryColor,
                                            borderRadius: BorderRadius.circular(
                                              11,
                                            ),
                                          ),
                                          child: Text(
                                            account.currencyCode ?? "--",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(width: 11),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                account.name ?? "---",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),

                                              const SizedBox(height: 5),

                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .currency_exchange_rounded,
                                                    size: 14,
                                                    color: Colors.grey.shade500,
                                                  ),

                                                  const SizedBox(width: 4),

                                                  Text(
                                                    account.currencyCode ??
                                                        "---",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Text(
                                            //   languagesController.tr("BALANCE"),
                                            //   style: TextStyle(
                                            //     color: Colors.grey.shade500,
                                            //     fontSize: 10,
                                            //     fontWeight: FontWeight.w400,
                                            //   ),
                                            // ),

                                            // const SizedBox(height: 5),
                                            Text(
                                              "${account.currency?.symbol ?? account.currencyCode ?? ""} "
                                              "${_formatAmount(account.currentBalance)}",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: AppColors.primaryColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(width: 4),

                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 21,
                                          color: Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => CreateAccountScreen());
                    },
                    child: Container(
                      height: 55,
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          languagesController.tr("ADD_NEW_ACCOUNT"),
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
            );
          }),
        ),
      ),
    );
  }

  void _showAccountDetails(Account account) {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.80,
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 25),

          decoration: const BoxDecoration(
            color: AppColors.listbuilderboxColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),

          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.secondaryColor,

                      child: Text(
                        account.currencyCode ?? "--",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name ?? "---",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            account.accountType ?? "---",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _detailRow(
                  title: languagesController.tr("ACCOUNT_NAME"),
                  value: account.name ?? "---",
                ),

                _detailRow(
                  title: languagesController.tr("ACCOUNT_TYPE"),
                  value: account.accountType ?? "---",
                ),

                _detailRow(
                  title: languagesController.tr("CURRENCY"),
                  value:
                      "${account.currency?.name ?? "---"} (${account.currencyCode ?? "---"})",
                ),

                _detailRow(
                  title: languagesController.tr("OPENING_BALANCE"),
                  value:
                      "${account.currency?.symbol ?? account.currencyCode ?? ""} ${_formatAmount(account.openingBalance)}",
                ),

                _detailRow(
                  title: languagesController.tr("CURRENT_BALANCE"),
                  value:
                      "${account.currency?.symbol ?? account.currencyCode ?? ""} ${_formatAmount(account.currentBalance)}",
                ),

                _detailRow(
                  title: languagesController.tr("COUNTER_PARTY"),
                  value: account.counterparty?.name ?? "---",
                ),

                _detailRow(
                  title: languagesController.tr("PHONE"),
                  value: account.counterparty?.phone ?? "---",
                ),

                _detailRow(
                  title: languagesController.tr("EMAIL"),
                  value: account.counterparty?.email ?? "---",
                ),

                _detailRow(
                  title: languagesController.tr("OFFICE"),
                  value: account.office?.name ?? "---",
                ),

                _detailRow(
                  title: languagesController.tr("OFFICE_CODE"),
                  value: account.office?.code ?? "---",
                ),

                _detailRow(
                  title: languagesController.tr("LOCATION"),
                  value: account.office?.location ?? "---",
                ),

                _detailRow(
                  title: languagesController.tr("ADDRESS"),
                  value: account.office?.address ?? "---",
                ),

                _detailRow(
                  title: languagesController.tr("NOTES"),
                  value: account.notes ?? "---",
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _detailRow({
    required String title,
    required String value,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 125,
                child: Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),

              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (showDivider) Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  String _formatAmount(String? value) {
    final double amount = double.tryParse(value ?? "0") ?? 0;

    return amount.toStringAsFixed(2);
  }
}
