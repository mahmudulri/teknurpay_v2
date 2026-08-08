import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/utils/colors.dart';
import 'package:teknurpay/widgets/accountextfield.dart';
import 'controllers/accounting_currency_controller.dart';
import 'controllers/counter_party_controller.dart';
import 'controllers/create_account_controller.dart';
import 'controllers/office_list_controller.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final CreateAccountController formController = Get.put(
    CreateAccountController(),
  );

  final AccountingCurrencyController currencyController =
      Get.find<AccountingCurrencyController>();

  final OfficeListController officeListController =
      Get.find<OfficeListController>();

  // final CounterPartyController counterPartyController =
  //     Get.find<CounterPartyController>();

  final CounterPartyController counterPartyController = Get.put(
    CounterPartyController(),
  );

  final LanguagesController languageController =
      Get.find<LanguagesController>();

  final GetStorage box = GetStorage();

  late final List<Map<String, String>> accountTypeOptions;

  @override
  void initState() {
    super.initState();

    accountTypeOptions = [
      {"title": languageController.tr("WORK"), "value": "work"},
      {"title": languageController.tr("SAVING"), "value": "saving"},
      {"title": languageController.tr("CURRENT"), "value": "current"},
      {"title": languageController.tr("FIXED"), "value": "fixed"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.listbuilderboxColor,
      appBar: AppBar(
        title: Text(
          languageController.tr("CREATE_NEW_ACCOUNT"),
          style: TextStyle(
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
              _buildCounterpartyDropdown(),

              const SizedBox(height: 15),

              _buildOfficeDropdown(),

              const SizedBox(height: 15),

              _buildCurrencyDropdown(),

              const SizedBox(height: 15),

              _buildAccountTypeDropdown(),

              const SizedBox(height: 15),

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
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                  child: Accountextfield(
                    controller: formController.nameController,
                    label: languageController.tr("ACCOUNT_NAME"),
                    hint: languageController.tr("ENTER_ACCOUNT_NAME"),
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
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                  child: Accountextfield(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: false,
                    ),
                    controller: formController.openingBalanceController,
                    label: languageController.tr("OPENING_BALANCE"),
                    hint: languageController.tr("ENTER_OPENING_BALANCE"),
                    height: 68,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _buildNotesField(),

              const SizedBox(height: 25),

              Obx(
                () => GestureDetector(
                  onTap: formController.isLoading.value
                      ? null
                      : formController.createAccount,
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
                          color: AppColors.primaryColor.withOpacity(0.28),
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
                              languageController.tr("CREATE_NOW"),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
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
        return _loadingDropdown(label: languageController.tr("COUNTER_PARTY"));
      }

      final counterpartyList = counterPartyController.finalList;

      return DropdownButtonFormField<int>(
        value: formController.selectedCounterpartyId.value == 0
            ? null
            : formController.selectedCounterpartyId.value,
        isExpanded: true,
        menuMaxHeight: 350,
        decoration: _dropdownDecoration(
          label: languageController.tr("COUNTER_PARTY"),
          hint: languageController.tr("SELECT_COUNTER_PARTY"),
        ),
        items: counterpartyList.map((counterparty) {
          return DropdownMenuItem<int>(
            value: counterparty.id,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.secondaryColor,
                  child: Text(
                    _firstLetter(counterparty.name?.toString()),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    counterparty.name?.toString() ?? "--",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
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

  Widget _buildOfficeDropdown() {
    return Obx(() {
      if (officeListController.isLoading.value &&
          officeListController.finalList.isEmpty) {
        return _loadingDropdown(label: languageController.tr("OFFICE"));
      }

      final officeList = officeListController.finalList;

      return DropdownButtonFormField<int>(
        value: formController.selectedOfficeId.value == 0
            ? null
            : formController.selectedOfficeId.value,
        isExpanded: true,
        menuMaxHeight: 350,
        decoration: _dropdownDecoration(
          label: languageController.tr("OFFICE"),
          hint: languageController.tr("SELECT_OFFICE"),
        ),
        items: officeList.map((office) {
          return DropdownMenuItem<int>(
            value: office.id,
            child: Row(
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    size: 19,
                    color: AppColors.primaryColor,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    office.name?.toString() ?? "--",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
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

          formController.selectOffice(id);
        },
      );
    });
  }

  Widget _buildCurrencyDropdown() {
    return Obx(() {
      if (currencyController.isLoading.value) {
        return _loadingDropdown(label: languageController.tr("CURRENCY"));
      }

      final currencies =
          currencyController.allcurrencylist.value.data?.currencies ?? [];

      return DropdownButtonFormField<int>(
        value: formController.selectedCurrencyId.value == 0
            ? null
            : formController.selectedCurrencyId.value,
        isExpanded: true,
        menuMaxHeight: 350,
        decoration: _dropdownDecoration(
          label: languageController.tr("CURRENCY"),
          hint: languageController.tr("SELECT_CURRENCY"),
        ),
        items: currencies.map((currency) {
          return DropdownMenuItem<int>(
            value: currency.id,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    currency.code ?? "--",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    currency.name ?? "--",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (int? id) {
          if (id == null) return;

          final selectedCurrency = currencies.firstWhere(
            (currency) => currency.id == id,
          );

          formController.selectCurrency(
            id: selectedCurrency.id ?? 0,
            code: selectedCurrency.code ?? "",
          );
        },
      );
    });
  }

  Widget _buildAccountTypeDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: formController.selectedAccountType.value.isEmpty
            ? null
            : formController.selectedAccountType.value,
        isExpanded: true,
        decoration: _dropdownDecoration(
          label: languageController.tr("ACCOUNT_TYPE"),
          hint: languageController.tr("SELECT_ACCOUNT_TYPE"),
        ),
        items: accountTypeOptions.map((item) {
          return DropdownMenuItem<String>(
            value: item["value"],
            child: Text(
              item["title"] ?? "",
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          formController.selectedAccountType.value = value ?? "";
        },
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: formController.notesController,
      minLines: 3,
      maxLines: 5,
      textInputAction: TextInputAction.newline,
      style: TextStyle(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.listbuilderboxColor,
        labelText: languageController.tr("NOTES"),
        hintText: languageController.tr("ENTER_ACCOUNT_NOTES"),
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
            color: AppColors.primarycolor2.withOpacity(0.55),
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
        vertical: box.read("direction") == "rtl" ? 12 : 15,
        horizontal: 12,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primarycolor2.withOpacity(0.55),
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
        border: Border.all(color: Colors.grey.shade400),
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
    final String text = value?.trim() ?? "";

    if (text.isEmpty) return "?";

    return text.substring(0, 1).toUpperCase();
  }
}
