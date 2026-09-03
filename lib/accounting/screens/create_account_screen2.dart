import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/accounting/controllers/accounting_currency_controller.dart';
import 'package:teknurpay/accounting/controllers/counter_party_controller.dart';
import 'package:teknurpay/accounting/controllers/create_account_controller2.dart';
import 'package:teknurpay/accounting/create_counterpary_screen.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/accountextfield.dart';

class CreateAccountScreen2 extends StatefulWidget {
  final int officeId;

  const CreateAccountScreen2({super.key, required this.officeId});

  @override
  State<CreateAccountScreen2> createState() => _CreateAccountScreen2State();
}

class _CreateAccountScreen2State extends State<CreateAccountScreen2> {
  late final String controllerTag;

  late final CreateAccountController2 formController;

  final AccountingCurrencyController currencyController =
      Get.find<AccountingCurrencyController>();

  final CounterPartyController counterPartyController = Get.put(
    CounterPartyController(),
  );

  final LanguagesController languageController =
      Get.find<LanguagesController>();

  final GetStorage box = GetStorage();

  @override
  void initState() {
    super.initState();
    counterPartyController.fetchcounterpary();

    /// A unique tag prevents conflict with another create-account screen.
    controllerTag =
        'create_account_${widget.officeId}_${identityHashCode(this)}';

    formController = Get.put(
      CreateAccountController2(officeId: widget.officeId),
    );
  }

  List<Map<String, dynamic>> get accountTypeOptions {
    return [
      {
        'title': languageController.tr('WORK'),
        'value': 'work',
        'icon': Icons.work_outline_rounded,
      },
      {
        'title': languageController.tr('SAVING'),
        'value': 'saving',
        'icon': Icons.savings_outlined,
      },
      {
        'title': languageController.tr('CURRENT'),
        'value': 'current',
        'icon': Icons.account_balance_wallet_outlined,
      },
      {
        'title': languageController.tr('FIXED'),
        'value': 'fixed',
        'icon': Icons.lock_outline_rounded,
      },
    ];
  }

  @override
  void dispose() {
    if (Get.isRegistered<CreateAccountController2>(tag: controllerTag)) {
      Get.delete<CreateAccountController2>(tag: controllerTag);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.listbuilderboxColor,
      appBar: AppBar(
        title: Text(
          languageController.tr('CREATE_NEW_ACCOUNT'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
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
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
            children: [
              /// Counterparty dropdown.
              Row(
                children: [
                  Expanded(child: _buildCounterpartyDropdown()),

                  const SizedBox(width: 10),

                  GestureDetector(
                    onTap: () async {
                      final bool? created = await Get.bottomSheet<bool>(
                        const CreateCounterparyScreen(isPopup: true),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        ignoreSafeArea: false,
                      );

                      if (created == true) {
                        counterPartyController.finalList.clear();
                        await counterPartyController.fetchcounterpary();
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 50,

                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// Currency dropdown.
              _buildCurrencyDropdown(),

              const SizedBox(height: 18),

              /// Selectable account type row.
              _buildAccountTypeSelector(),

              const SizedBox(height: 18),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.listbuilderboxColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: const InputDecorationTheme(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                  child: Accountextfield(
                    controller: formController.nameController,
                    label: languageController.tr('ACCOUNT_NAME'),
                    hint: languageController.tr('ENTER_ACCOUNT_NAME'),
                    height: 68,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.listbuilderboxColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: const InputDecorationTheme(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                  child: Accountextfield(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    controller: formController.openingBalanceController,
                    label: languageController.tr('OPENING_BALANCE'),
                    hint: languageController.tr('ENTER_OPENING_BALANCE'),
                    height: 68,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              _buildNotesField(),

              const SizedBox(height: 25),

              Obx(
                () => GestureDetector(
                  onTap: formController.isLoading.value
                      ? null
                      : formController.createAccount,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: formController.isLoading.value ? 0.65 : 1,
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
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.28,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: formController.isLoading.value
                            ? const SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                languageController.tr('CREATE_NOW'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterpartyDropdown() {
    return Obx(() {
      if (counterPartyController.isLoading.value &&
          counterPartyController.finalList.isEmpty) {
        return _loadingDropdown(label: languageController.tr('COUNTER_PARTY'));
      }

      // Original list
      final originalList = counterPartyController.finalList;

      // Remove duplicate counterparty IDs
      final Map<int, dynamic> uniqueMap = {};

      for (final item in originalList) {
        final int? id = item.id;

        if (id != null && !uniqueMap.containsKey(id)) {
          uniqueMap[id] = item;
        }
      }

      final counterpartyList = uniqueMap.values.toList();

      final int selectedId = formController.selectedCounterpartyId.value;

      final int matchCount = counterpartyList
          .where((item) => item.id == selectedId)
          .length;

      final int? selectedValue = selectedId > 0 && matchCount == 1
          ? selectedId
          : null;

      return DropdownButtonFormField<int>(
        value: selectedValue,
        isExpanded: true,
        menuMaxHeight: 350,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: _dropdownDecoration(
          label: languageController.tr('COUNTER_PARTY'),
          hint: languageController.tr('SELECT_COUNTER_PARTY'),
        ),
        items: counterpartyList.map<DropdownMenuItem<int>>((counterparty) {
          return DropdownMenuItem<int>(
            value: counterparty.id,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.secondaryColor,
                  child: Text(
                    _firstLetter(counterparty.name?.toString()),
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    counterparty.name?.toString() ?? '--',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        onChanged: (int? id) {
          if (id == null) return;

          formController.selectCounterparty(id);
        },
      );
    });
  }

  Widget _buildCurrencyDropdown() {
    return Obx(() {
      if (currencyController.isLoading.value) {
        return _loadingDropdown(label: languageController.tr('CURRENCY'));
      }

      final currencies =
          currencyController.allcurrencylist.value.data?.currencies ?? [];

      final int? selectedValue =
          formController.selectedCurrencyId.value > 0 &&
              currencies.any(
                (item) => item.id == formController.selectedCurrencyId.value,
              )
          ? formController.selectedCurrencyId.value
          : null;

      return DropdownButtonFormField<int>(
        value: selectedValue,
        isExpanded: true,
        menuMaxHeight: 350,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        decoration: _dropdownDecoration(
          label: languageController.tr('CURRENCY'),
          hint: languageController.tr('SELECT_CURRENCY'),
        ),
        items: currencies.map((currency) {
          return DropdownMenuItem<int>(
            value: currency.id,
            child: Row(
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 42),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F2FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    currency.code ?? '--',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    currency.name ?? '--',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (int? id) {
          if (id == null) return;

          final selectedCurrency = currencies.firstWhereOrNull(
            (currency) => currency.id == id,
          );

          if (selectedCurrency == null) return;

          formController.selectCurrency(
            id: selectedCurrency.id ?? 0,
            code: selectedCurrency.code ?? '',
          );
        },
      );
    });
  }

  Widget _buildAccountTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageController.tr('ACCOUNT_TYPE'),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 10),

        Obx(() {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(accountTypeOptions.length, (index) {
                final Map<String, dynamic> item = accountTypeOptions[index];

                final String value = item['value']?.toString() ?? '';

                final String title = item['title']?.toString() ?? '';

                final IconData icon = item['icon'] as IconData;

                final bool isSelected =
                    formController.selectedAccountType.value == value;

                return Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index == accountTypeOptions.length - 1 ? 0 : 10,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      formController.selectAccountType(value);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      constraints: const BoxConstraints(minWidth: 105),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.listbuilderboxColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.primarycolor2.withValues(alpha: 0.45),
                          width: isSelected ? 1.4 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 19,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryColor,
                          ),

                          const SizedBox(width: 7),

                          Text(
                            title,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          if (isSelected) ...[
                            const SizedBox(width: 7),
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.listbuilderboxColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: formController.notesController,
      minLines: 3,
      maxLines: 5,
      textInputAction: TextInputAction.newline,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.listbuilderboxColor,
        labelText: languageController.tr('NOTES'),
        hintText: languageController.tr('ENTER_ACCOUNT_NOTES'),
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 15,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primarycolor2.withValues(alpha: 0.45),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.listbuilderboxColor,
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: EdgeInsets.symmetric(
        vertical: box.read('direction') == 'rtl' ? 12 : 15,
        horizontal: 12,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primarycolor2.withValues(alpha: 0.45),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.4),
      ),
    );
  }

  Widget _loadingDropdown({required String label}) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: AppColors.listbuilderboxColor,
        border: Border.all(
          color: AppColors.primarycolor2.withValues(alpha: 0.45),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
          const SizedBox(
            height: 21,
            width: 21,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _firstLetter(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) return '?';

    return text.substring(0, 1).toUpperCase();
  }
}
