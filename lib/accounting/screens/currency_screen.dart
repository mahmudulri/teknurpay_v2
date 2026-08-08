import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global_controller/languages_controller.dart';
import '../../utils/colors.dart';
import '../controllers/accounting_currency_controller.dart';
import '../controllers/add_currency_controller.dart';
import '../controllers/delete_currency_controller.dart';
import '../controllers/update_currency_controller.dart';
import '../models/account_currency_model.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final LanguagesController languagesController =
      Get.find<LanguagesController>();

  final AccountingCurrencyController currencyController =
      Get.isRegistered<AccountingCurrencyController>()
      ? Get.find<AccountingCurrencyController>()
      : Get.put(AccountingCurrencyController());

  final AddCurrencyController addCurrencyController =
      Get.isRegistered<AddCurrencyController>()
      ? Get.find<AddCurrencyController>()
      : Get.put(AddCurrencyController());

  final UpdateCurrencyController updateCurrencyController =
      Get.isRegistered<UpdateCurrencyController>()
      ? Get.find<UpdateCurrencyController>()
      : Get.put(UpdateCurrencyController());

  final DeleteCurrencyController deleteCurrencyController =
      Get.isRegistered<DeleteCurrencyController>()
      ? Get.find<DeleteCurrencyController>()
      : Get.put(DeleteCurrencyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.listbuilderboxColor,
        backgroundColor: AppColors.listbuilderboxColor,
        titleSpacing: 18,
        title: Row(
          children: [
            Text(
              languagesController.tr('CURRENCY'),
              style: const TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              height: 42,
              width: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Image.asset(
                'assets/icons/gridmenu.png',
                height: 23,
                width: 23,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.grid_view_rounded,
                    color: Color(0xFF506680),
                    size: 23,
                  );
                },
              ),
            ),
          ],
        ),
      ),

      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondaryColor, AppColors.primarycolor2],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primarycolor2],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Obx(() {
                final currencies =
                    currencyController.allcurrencylist.value.data?.currencies ??
                    [];

                final totalItems =
                    currencyController
                        .allcurrencylist
                        .value
                        .data
                        ?.pagination
                        ?.totalItems ??
                    currencies.length;

                return Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.currency_exchange_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languagesController.tr('ACCOUNTING_CURRENCIES'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalItems ${languagesController.tr('CURRENCIES_AVAILABLE')}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        currencyController.fetchCurrencyList();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              }),
            ),

            Expanded(
              child: Obx(() {
                if (currencyController.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryColor,
                    ),
                  );
                }

                final List<Currency> currencies =
                    currencyController.allcurrencylist.value.data?.currencies ??
                    [];

                if (currencies.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 82,
                            width: 82,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.currency_exchange_rounded,
                              color: AppColors.primaryColor,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 17),
                          Text(
                            languagesController.tr('NO_CURRENCIES_FOUND'),
                            style: TextStyle(
                              color: Color(0xFF172B4D),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            languagesController.tr(
                              'ADD_YOUR_FIRST_ACCOUNTING_CURRENCY',
                            ),
                            style: TextStyle(
                              color: Color(0xFF7A8999),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryColor,
                  onRefresh: currencyController.fetchCurrencyList,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 105),
                    itemCount: currencies.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 11);
                    },
                    itemBuilder: (context, index) {
                      final Currency currency = currencies[index];

                      return Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.listbuilderboxColor,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: AppColors.primarycolor2.withValues(
                              alpha: 0.28,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 49,
                                  width: 49,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    currency.symbol?.trim().isNotEmpty == true
                                        ? currency.symbol!
                                        : currency.code ?? '¤',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currency.name?.trim().isNotEmpty == true
                                            ? currency.name!
                                            : languagesController.tr(
                                                'UNNAMED_CURRENCY',
                                              ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF172B4D),
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: Text(
                                              currency.code ?? '---',
                                              style: const TextStyle(
                                                color: AppColors.primaryColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 7),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF2EDFF),
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                            ),
                                            child: Text(
                                              currency.symbol ?? '---',
                                              style: const TextStyle(
                                                color: Color(0xFF6941C6),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  color: AppColors.listbuilderboxColor,
                                  surfaceTintColor:
                                      AppColors.listbuilderboxColor,
                                  icon: const Icon(
                                    Icons.more_vert_rounded,
                                    color: Color(0xFF66788A),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  onSelected: (String value) {
                                    if (value == 'edit') {
                                      _showEditCurrencyDialog(currency);
                                    }

                                    if (value == 'delete') {
                                      _showDeleteCurrencyDialog(currency);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                              color: AppColors.primaryColor,
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              languagesController.tr('EDIT'),
                                              style: TextStyle(
                                                color: Color(0xFF172B4D),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              size: 20,
                                              color: Color(0xFFD92D20),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                              languagesController.tr('DELETE'),
                                              style: TextStyle(
                                                color: Color(0xFFD92D20),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(
                                  color: AppColors.primarycolor2.withValues(
                                    alpha: 0.24,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.currency_exchange_rounded,
                                      color: AppColors.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          languagesController.tr(
                                            'EXCHANGE_RATE_PER_USD',
                                          ),
                                          style: TextStyle(
                                            color: Color(0xFF7A8999),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          _formatExchangeRate(
                                            currency.exchangeRatePerUsd,
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF172B4D),
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
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryColor, AppColors.primarycolor2],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE74CD8).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _showAddCurrencyDialog,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 53),
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          icon: const Icon(Icons.add_rounded, size: 24),
          label: Text(
            languagesController.tr('ADD_NEW_CURRENCY'),
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCurrencyDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final TextEditingController symbolController = TextEditingController();
    final TextEditingController exchangeRateController =
        TextEditingController();

    addCurrencyController.errorMessage.value = '';

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.listbuilderboxColor,
            borderRadius: BorderRadius.circular(21),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add_card_rounded,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        languagesController.tr('ADD_NEW_CURRENCY'),
                        style: TextStyle(
                          color: Color(0xFF172B4D),
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: Get.back,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  languagesController.tr('CURRENCY_NAME'),
                  style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    hintText: languagesController.tr('EXAMPLE_AFGHANI'),
                    filled: true,
                    fillColor: AppColors.listbuilderboxColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 17,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  languagesController.tr('CURRENCY_CODE'),
                  style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,

                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    hintText: languagesController.tr('EXAMPLE_AFN'),

                    filled: true,
                    fillColor: AppColors.listbuilderboxColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 17,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  languagesController.tr('CURRENCY_SYMBOL'),
                  style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: symbolController,

                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    hintText: languagesController.tr('EXAMPLE_CURRENCY_SYMBOL'),

                    filled: true,
                    fillColor: AppColors.listbuilderboxColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 17,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  languagesController.tr('EXCHANGE_RATE_PER_USD'),
                  style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: exchangeRateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey.shade300),
                    hintText: languagesController.tr('EXAMPLE_EXCHANGE_RATE'),
                    filled: true,
                    fillColor: AppColors.listbuilderboxColor,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 17,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),

                Obx(() {
                  if (addCurrencyController.errorMessage.value.isEmpty) {
                    return const SizedBox(height: 20);
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 14),
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      addCurrencyController.errorMessage.value,
                      style: const TextStyle(
                        color: Color(0xFFD92D20),
                        fontSize: 12.5,
                      ),
                    ),
                  );
                }),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: Get.back,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 49),
                          foregroundColor: const Color(0xFF344054),
                          side: const BorderSide(color: Color(0xFFD7E0E9)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Text(
                          languagesController.tr('CANCEL'),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),

                    Expanded(
                      child: Obx(() {
                        final bool isLoading =
                            addCurrencyController.isLoading.value;

                        return Container(
                          height: 49,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isLoading
                                  ? [
                                      AppColors.primaryColor.withValues(
                                        alpha: 0.55,
                                      ),
                                      AppColors.primarycolor2.withValues(
                                        alpha: 0.55,
                                      ),
                                    ]
                                  : const [
                                      AppColors.primaryColor,
                                      AppColors.primarycolor2,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();

                                    final bool success =
                                        await addCurrencyController.addCurrency(
                                          name: nameController.text,
                                          code: codeController.text,
                                          symbol: symbolController.text,
                                          exchangeRatePerUsd:
                                              exchangeRateController.text,
                                        );

                                    if (success) {
                                      Get.back();
                                      await currencyController
                                          .fetchCurrencyList();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 49),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 21,
                                    width: 21,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppColors.listbuilderboxColor,
                                    ),
                                  )
                                : Text(
                                    languagesController.tr('ADD_CURRENCY'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showEditCurrencyDialog(Currency currency) async {
    final TextEditingController exchangeRateController = TextEditingController(
      text: _formatExchangeRate(currency.exchangeRatePerUsd),
    );

    updateCurrencyController.errorMessage.value = '';

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            color: AppColors.listbuilderboxColor,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${languagesController.tr('EDIT')} ${currency.name ?? languagesController.tr('CURRENCY')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF172B4D),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      currency.code ?? '---',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Color(0xFF98A2B3))),
                    const SizedBox(width: 8),
                    Text(
                      currency.symbol ?? '---',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              Text(
                languagesController.tr('EXCHANGE_RATE_PER_USD'),
                style: TextStyle(
                  color: Color(0xFF344054),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 7),

              TextField(
                controller: exchangeRateController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: languagesController.tr('ENTER_EXCHANGE_RATE'),
                  filled: true,
                  fillColor: AppColors.listbuilderboxColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 17,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: Color(0xFFDDE5ED)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: Color(0xFFDDE5ED)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.4,
                    ),
                  ),
                ),
              ),

              Obx(() {
                if (updateCurrencyController.errorMessage.value.isEmpty) {
                  return const SizedBox(height: 20);
                }

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    updateCurrencyController.errorMessage.value,
                    style: const TextStyle(
                      color: Color(0xFFD92D20),
                      fontSize: 12.5,
                    ),
                  ),
                );
              }),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: const Color(0xFF344054),
                        side: const BorderSide(color: Color(0xFFD7E0E9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(
                        languagesController.tr('CANCEL'),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: updateCurrencyController.isLoading.value
                            ? null
                            : () async {
                                FocusManager.instance.primaryFocus?.unfocus();

                                final bool success =
                                    await updateCurrencyController
                                        .updateCurrency(
                                          currencyId: currency.id,
                                          exchangeRatePerUsd:
                                              exchangeRateController.text,
                                        );

                                if (success) {
                                  Get.back();
                                  await currencyController.fetchCurrencyList();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primaryColor
                              .withValues(alpha: 0.55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: updateCurrencyController.isLoading.value
                            ? const SizedBox(
                                height: 21,
                                width: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.listbuilderboxColor,
                                ),
                              )
                            : Text(
                                languagesController.tr('UPDATE'),
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    exchangeRateController.dispose();
  }

  Future<void> _showDeleteCurrencyDialog(Currency currency) async {
    deleteCurrencyController.errorMessage.value = '';

    await Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 23),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.listbuilderboxColor,
            borderRadius: BorderRadius.circular(21),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 62,
                width: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9E7),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFD92D20),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                languagesController.tr('DELETE_CURRENCY_QUESTION'),
                style: TextStyle(
                  color: Color(0xFF172B4D),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${languagesController.tr('ARE_YOU_SURE_YOU_WANT_TO_DELETE')} ${currency.name ?? languagesController.tr('THIS_CURRENCY')}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),

              Obx(() {
                if (deleteCurrencyController.errorMessage.value.isEmpty) {
                  return const SizedBox(height: 21);
                }

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 14, bottom: 14),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    deleteCurrencyController.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFD92D20),
                      fontSize: 12.5,
                    ),
                  ),
                );
              }),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: Get.back,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        foregroundColor: const Color(0xFF344054),
                        side: const BorderSide(color: Color(0xFFD7E0E9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: Text(
                        languagesController.tr('CANCEL'),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: deleteCurrencyController.isLoading.value
                            ? null
                            : () async {
                                final bool success =
                                    await deleteCurrencyController
                                        .deleteCurrency(
                                          currencyId: currency.id,
                                        );

                                if (success) {
                                  Get.back();
                                  await currencyController.fetchCurrencyList();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          backgroundColor: const Color(0xFFD92D20),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFFD92D20,
                          ).withValues(alpha: 0.55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: deleteCurrencyController.isLoading.value
                            ? const SizedBox(
                                height: 21,
                                width: 21,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: AppColors.listbuilderboxColor,
                                ),
                              )
                            : Text(
                                languagesController.tr('DELETE'),
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  String _formatExchangeRate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '0';
    }

    final double? parsedValue = double.tryParse(value);

    if (parsedValue == null) {
      return value;
    }

    String formattedValue = parsedValue.toStringAsFixed(12);

    formattedValue = formattedValue.replaceFirst(RegExp(r'\.?0+$'), '');

    return formattedValue;
  }
}
