import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teknurpay/accounting/create_counterpary_screen.dart';
import 'package:teknurpay/helpers/language_changer.dart';

import '../../global_controller/languages_controller.dart';
import '../../utils/colors.dart';
import '../controllers/accounting_currency_controller.dart';
import '../controllers/counter_party_controller.dart';
import '../controllers/delete_counterparty_controller.dart';
import '../update_counterparty_screen.dart';
import '../view_counter_party_screen.dart';

class CounterParty extends StatefulWidget {
  const CounterParty({super.key});

  @override
  State<CounterParty> createState() => _CounterPartyState();
}

class _CounterPartyState extends State<CounterParty> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final CounterPartyController counterPartyController = Get.put(
    CounterPartyController(),
  );

  final AccountingCurrencyController accountingCurrencyController =
      Get.find<AccountingCurrencyController>();

  final DeleteCounterpartyController deleteCounterpartyController = Get.put(
    DeleteCounterpartyController(),
  );

  @override
  void initState() {
    super.initState();

    counterPartyController.initialpage = 1;
    counterPartyController.finalList.clear();
    counterPartyController.fetchcounterpary();
  }

  String getDisplayValue(dynamic value, {String fallback = 'N/A'}) {
    if (value == null) {
      return fallback;
    }

    final String text = value.toString().trim();

    if (text.isEmpty || text.toLowerCase() == 'null') {
      return fallback;
    }

    return text;
  }

  Color getTypeColor(String type) {
    switch (type.trim().toLowerCase()) {
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

  IconData getTypeIcon(String type) {
    switch (type.trim().toLowerCase()) {
      case 'customer':
        return Icons.person_outline_rounded;

      case 'supplier':
        return Icons.inventory_2_outlined;

      case 'both':
        return Icons.people_alt_outlined;

      default:
        return Icons.account_circle_outlined;
    }
  }

  void openCounterPartyDetails(dynamic data) {
    Get.to(
      () => ViewCounterPartyScreen(
        partyID: data.id.toString(),
        partyName: data.name.toString(),
        partyType: data.type.toString(),
        phoneNumber: data.phone.toString(),
        emailaddress: data.email.toString(),
        defaultCurrency: data.defaultCurrencyCode.toString(),
      ),
    );
  }

  void openActionDialog(BuildContext context, dynamic data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryColor,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.listbuilderboxColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 42,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9E0E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.business_center_outlined,
                          color: Color(0xFF2584F4),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getDisplayValue(data.name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1D2939),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              getDisplayValue(data.phone),
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF7A8794),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    Get.to(
                      () => UpdateCounterpartyScreen(
                        partyID: data.id.toString(),
                        partyName: data.name.toString(),
                        partyType: data.type.toString(),
                        phoneNumber: data.phone.toString(),
                        emailaddress: data.email.toString(),
                        currency: data.defaultCurrencyCode.toString(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF2584F4),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          languagesController.tr("EDIT"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF263445),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF98A2B3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    deleteCounterpartyController.deleteparty(
                      data.id.toString(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFE5484D),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          languagesController.tr("DELETE"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFE5484D),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFFE5484D),
                        ),
                      ],
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

  Widget buildCounterPartyCard({
    required BuildContext context,
    required dynamic data,
  }) {
    final String name = getDisplayValue(data.name);
    final String type = getDisplayValue(data.type);
    final String phone = getDisplayValue(data.phone);

    final Color typeColor = getTypeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.listbuilderboxColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primarycolor2.withValues(alpha: 0.30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF40566B).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            openCounterPartyDetails(data);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 13, 7, 13),
            child: Row(
              children: [
                Container(
                  height: 68,
                  width: 4,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E2936),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  getTypeIcon(type),
                                  size: 14,
                                  color: typeColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  type.capitalizeFirst ?? type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: typeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 16,
                                  color: Color(0xFF7C8B99),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    phone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF687684),
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
                const SizedBox(width: 4),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      splashRadius: 20,
                      onPressed: () {
                        openActionDialog(context, data);
                      },
                      icon: Container(
                        height: 34,
                        width: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.more_horiz_rounded,
                          size: 21,
                          color: Color(0xFF5F6C79),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: Color(0xFFADB6BF),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 78,
              width: 78,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.80),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 36,
                color: Color(0xFF83919F),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No counterparty found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF536170),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                counterPartyController.fetchcounterpary();
              },
              child: Text(
                languagesController.tr("COUNTER_PARTY"),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),

            const LanguageSelectorButton(size: 42, iconSize: 25),
          ],
        ),
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.listbuilderboxColor,
        elevation: 0,
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
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  size: 28,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      hintText: languagesController.tr("NAME"),
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset("assets/icons/filter.png"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(() {
                    if (counterPartyController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    if (counterPartyController.finalList.isEmpty) {
                      return buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 2, bottom: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: counterPartyController.finalList.length,
                      itemBuilder: (context, index) {
                        final data = counterPartyController.finalList[index];

                        return buildCounterPartyCard(
                          context: context,
                          data: data,
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Get.to(() => CreateCounterparyScreen());
                  },
                  child: Container(
                    height: 55,
                    width: screenWidth,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primarycolor2,
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        languagesController.tr("ADD_COUNTER_PARTY"),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
