import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/utils/colors.dart';
import 'controllers/party_accountslist_controller.dart';

class ViewCounterPartyScreen extends StatefulWidget {
  final String? partyID;
  final String? partyName;
  final String? partyType;
  final String? phoneNumber;
  final String? emailaddress;
  final String? defaultCurrency;
  final String? notes;

  const ViewCounterPartyScreen({
    super.key,
    this.partyID,
    this.partyName,
    this.phoneNumber,
    this.partyType,
    this.emailaddress,
    this.defaultCurrency,
    this.notes,
  });

  @override
  State<ViewCounterPartyScreen> createState() => _ViewCounterPartyScreenState();
}

class _ViewCounterPartyScreenState extends State<ViewCounterPartyScreen> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final PartyAccountslistController accountslistController = Get.put(
    PartyAccountslistController(),
  );

  @override
  void initState() {
    super.initState();

    accountslistController.fetchaccount(widget.partyID.toString());
  }

  String _displayValue(dynamic value, {String fallback = '-'}) {
    if (value == null) {
      return fallback;
    }

    final String text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  Color _getTypeColor() {
    final String type = _displayValue(widget.partyType).toLowerCase();

    switch (type) {
      case 'customer':
        return AppColors.primaryColor;

      case 'supplier':
        return AppColors.primarycolor2;

      case 'both':
        return AppColors.primarycolor2;

      default:
        return AppColors.primaryColor;
    }
  }

  Color _getBalanceColor(dynamic balance) {
    final double parsedBalance =
        double.tryParse(balance?.toString() ?? '0') ?? 0;

    if (parsedBalance < 0) {
      return const Color(0xFFDC4146);
    }

    if (parsedBalance > 0) {
      return AppColors.primaryColor;
    }

    return const Color(0xFF536170);
  }

  Widget _buildHeaderIcon(String assetPath) {
    return Container(
      height: 40,
      width: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(assetPath, height: 23, width: 23),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
    Color? iconBackground,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.primarycolor2.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  iconBackground ??
                  AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? const Color(0xFF2678E9),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8995A2),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF263442),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterPartyDetails() {
    final Color typeColor = _getTypeColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.listbuilderboxColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primarycolor2.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF41617D).withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayValue(
                        widget.partyName,
                        fallback: 'Unnamed counterparty',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E2A36),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: typeColor.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            _displayValue(widget.partyType).capitalizeFirst ??
                                _displayValue(widget.partyType),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0D8A63,
                              ).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${accountslistController.isLoading.value ? '...' : accountslistController.accountlist.length} ${languagesController.tr("TOTAL_ACCOUNTS")}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  accountslistController.fetchaccount(
                    widget.partyID.toString(),
                  );
                },
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF4F7FA),
                  fixedSize: const Size(42, 42),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF5B6875),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: languagesController.tr("PHONE"),
                  value: _displayValue(widget.phoneNumber),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _buildInfoTile(
                  icon: Icons.payments_outlined,
                  label: languagesController.tr("CURRENCY"),
                  value: _displayValue(widget.defaultCurrency),
                  iconColor: AppColors.primaryColor,
                  iconBackground: AppColors.primarycolor2.withValues(
                    alpha: 0.08,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          _buildInfoTile(
            icon: Icons.email_outlined,
            label: languagesController.tr("EMAIL_ADDRESS"),
            value: _displayValue(widget.emailaddress),
            iconColor: const Color(0xFF7557D5),
            iconBackground: const Color(0xFF7557D5).withValues(alpha: 0.08),
          ),
          const SizedBox(height: 9),
          _buildInfoTile(
            icon: Icons.notes_rounded,
            label: languagesController.tr("NOTES"),
            value: _displayValue(widget.notes, fallback: '-----'),
            maxLines: 2,
            iconColor: const Color(0xFFE78A24),
            iconBackground: const Color(0xFFE78A24).withValues(alpha: 0.09),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 19,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            languagesController.tr("ACCOUNTS"),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF263442),
            ),
          ),
          const Spacer(),
          Obx(
            () => Text(
              accountslistController.isLoading.value
                  ? ''
                  : accountslistController.accountlist.length.toString(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF788593),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAccounts() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 76,
              width: 76,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 37,
                color: Color(0xFF8C98A4),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No accounts found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF596775),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(dynamic data) {
    final String balance = _displayValue(data.currentBalance, fallback: '0.00');

    final String currency = _displayValue(data.currencyCode);

    final Color balanceColor = _getBalanceColor(data.currentBalance);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.listbuilderboxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarycolor2.withValues(alpha: 0.24),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 43,
                    width: 43,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 22,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      _displayValue(data.name, fallback: 'Unnamed Account'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF243240),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$balance $currency',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: balanceColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        languagesController.tr("BALANCE"),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: const Color(0xFF8A96A3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Container(
                height: 1,
                color: AppColors.primarycolor2.withValues(alpha: 0.18),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          size: 16,
                          color: Color(0xFF85919D),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            currency,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: const Color(0xFF657381),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 18,
                    width: 1,
                    color: const Color(0xFFE2E8EE),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 16,
                          color: Color(0xFF85919D),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _displayValue(data.accountType),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: const Color(0xFF657381),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildAccountsSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.listbuilderboxColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primarycolor2.withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF41617D).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          children: [
            _buildAccountsHeader(),
            Expanded(
              child: Obx(() {
                if (accountslistController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                if (accountslistController.accountlist.isEmpty) {
                  return _buildEmptyAccounts();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 2, bottom: 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: accountslistController.accountlist.length,
                  itemBuilder: (context, index) {
                    final data = accountslistController.accountlist[index];

                    return _buildAccountCard(data);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.listbuilderboxColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.listbuilderboxColor,
        surfaceTintColor: AppColors.listbuilderboxColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: 13,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: 39,
                width: 39,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: Color(0xFF354250),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  accountslistController.fetchaccount(
                    widget.partyID.toString(),
                  );
                },
                child: Text(
                  languagesController.tr("COUNTER_PARTY_DETAILS"),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF1D2935),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            _buildHeaderIcon("assets/icons/gridmenu.png"),
          ],
        ),
      ),
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondaryColor, AppColors.primarycolor2],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
            child: Column(
              children: [
                _buildCounterPartyDetails(),
                const SizedBox(height: 10),
                Expanded(child: _buildAccountsSection()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
