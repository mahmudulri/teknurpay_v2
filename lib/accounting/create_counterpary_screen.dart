import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teknurpay/global_controller/languages_controller.dart';
import 'package:teknurpay/utils/colors.dart';
import '../widgets/accountextfield.dart';
import 'controllers/accounting_currency_controller.dart';
import 'controllers/create_counter_party_controller.dart';
import 'controllers/office_list_controller.dart';
import 'models/office_list_model.dart';

class CreateCounterparyScreen extends StatefulWidget {
  const CreateCounterparyScreen({super.key});

  @override
  State<CreateCounterparyScreen> createState() =>
      _CreateCounterparyScreenState();
}

class _CreateCounterparyScreenState extends State<CreateCounterparyScreen> {
  late final CreateCounterPartyController formController;
  late final AccountingCurrencyController currencyController;
  late final OfficeListController officeListController;
  late final LanguagesController languageController;

  final GetStorage box = GetStorage();

  final List<Map<String, String>> accountTypeOptions = [];
  final List<Map<String, String>> typeOptions = [];

  int selectedCurrencyIndex = -1;

  @override
  void initState() {
    super.initState();

    formController = Get.isRegistered<CreateCounterPartyController>()
        ? Get.find<CreateCounterPartyController>()
        : Get.put(CreateCounterPartyController());

    currencyController = Get.find<AccountingCurrencyController>();

    languageController = Get.find<LanguagesController>();

    officeListController = Get.isRegistered<OfficeListController>()
        ? Get.find<OfficeListController>()
        : Get.put(OfficeListController());

    accountTypeOptions.addAll([
      {'title': languageController.tr('SAVING'), 'value': 'saving'},
      {'title': languageController.tr('CURRENT'), 'value': 'current'},
      {'title': languageController.tr('FIXED'), 'value': 'fixed'},
    ]);

    typeOptions.addAll([
      {'title': languageController.tr('SUPPLIER'), 'value': 'supplier'},
      {'title': languageController.tr('CUSTOMER'), 'value': 'customer'},
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOfficeList();
      _restoreCurrencySelection();
    });
  }

  Future<void> _loadOfficeList() async {
    if (officeListController.isLoading.value) {
      return;
    }

    if (officeListController.finalList.isNotEmpty) {
      return;
    }

    officeListController.initialpage = 1;
    await officeListController.fetchofficelist();
  }

  void _restoreCurrencySelection() {
    final currencies =
        currencyController.allcurrencylist.value.data?.currencies ?? [];

    final String selectedCode = formController.selectedCurrencyCode.value;

    if (selectedCode.isEmpty) {
      return;
    }

    final int index = currencies.indexWhere(
      (item) => item.code?.toString() == selectedCode,
    );

    if (index != -1 && mounted) {
      setState(() {
        selectedCurrencyIndex = index;
      });
    }
  }

  void showValidationToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: AppColors.primaryColor,
      textColor: Colors.white,
      gravity: ToastGravity.CENTER,
    );
  }

  Future<void> validateAndCreate() async {
    FocusScope.of(context).unfocus();

    final String name = formController.nameController.text.trim();

    final String phone = formController.phoneController.text.trim();

    final String email = formController.emailController.text.trim();

    final String currency = formController.selectedCurrencyCode.value.trim();

    if (name.isEmpty) {
      showValidationToast(languageController.tr('NAME_IS_REQUIRED'));
      return;
    }

    if (phone.isEmpty) {
      showValidationToast(languageController.tr('PHONE_NUMBER_IS_REQUIRED'));
      return;
    }

    if (!RegExp(r'^[0-9]{6,15}$').hasMatch(phone)) {
      showValidationToast(languageController.tr('ENTER_A_VALID_PHONE_NUMBER'));
      return;
    }

    if (email.isEmpty) {
      showValidationToast(languageController.tr('EMAIL_IS_REQUIRED'));
      return;
    }

    final RegExp emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      showValidationToast(languageController.tr('ENTER_A_VALID_EMAIL_ADDRESS'));
      return;
    }

    if (currency.isEmpty) {
      showValidationToast(languageController.tr('PLEASE_SELECT_A_CURRENCY'));
      return;
    }

    if (formController.createDefaultAccount.value &&
        formController.selectedOfficeId.value == null) {
      showValidationToast(languageController.tr('PLEASE_SELECT_AN_OFFICE'));
      return;
    }

    final bool success = await formController.createNow();

    if (!mounted) {
      return;
    }

    if (success) {
      setState(() {
        selectedCurrencyIndex = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.listbuilderboxColor,
      appBar: AppBar(
        title: Text(
          languageController.tr('CREATE_COUNTER_PARTY'),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.secondaryColor, AppColors.primarycolor2],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
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
                      label: languageController.tr('NAME'),
                      hint: languageController.tr('COUNTER_PARTY_NAME'),
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
                      keyboardType: TextInputType.phone,
                      controller: formController.phoneController,
                      label: languageController.tr('PHONE_NUMBER'),
                      hint: languageController.tr('ENTER_PHONE_NUMBER'),
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
                      keyboardType: TextInputType.emailAddress,
                      controller: formController.emailController,
                      label: languageController.tr('EMAIL'),
                      hint: languageController.tr('ENTER_EMAIL_ADDRESS'),
                      height: 68,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Obx(
                  () => SizedBox(
                    height: 55,
                    child: DropdownButtonFormField<String>(
                      value: formController.selectedType.value,
                      isExpanded: true,
                      decoration: dropdownDecoration(
                        languageController.tr('TYPE'),
                      ),
                      items: typeOptions.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['value'],
                          child: Text(
                            item['title'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value == null) {
                          return;
                        }

                        formController.selectedType.value = value;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Obx(
                  () => SizedBox(
                    height: 55,
                    child: DropdownButtonFormField<String>(
                      value: formController.selectedAccountType.value,
                      isExpanded: true,
                      decoration: dropdownDecoration(
                        languageController.tr('ACCOUNT_TYPE'),
                      ),
                      items: accountTypeOptions.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['value'],
                          child: Text(
                            item['title'] ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value == null) {
                          return;
                        }

                        formController.selectedAccountType.value = value;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: Text(
                          languageController.tr('CREATE_DEFAULT_ACCOUNT'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Switch(
                        value: formController.createDefaultAccount.value,
                        onChanged: (bool value) {
                          formController.changeDefaultAccountStatus(value);

                          if (value) {
                            _loadOfficeList();
                          }
                        },
                        activeColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),

                Obx(() {
                  if (!formController.createDefaultAccount.value) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 15),
                    child: buildOfficeDropdown(),
                  );
                }),

                Text(
                  languageController.tr('CURRENCY'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  height: 42,
                  width: screenWidth,
                  child: Obx(() {
                    if (currencyController.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      );
                    }

                    final currencies =
                        currencyController
                            .allcurrencylist
                            .value
                            .data
                            ?.currencies ??
                        [];

                    if (currencies.isEmpty) {
                      return Center(
                        child: Text(languageController.tr('NO_CURRENCY_FOUND')),
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: currencies.length,
                      itemBuilder: (context, index) {
                        final currency = currencies[index];

                        final bool isSelected = selectedCurrencyIndex == index;

                        return GestureDetector(
                          onTap: () {
                            final String code =
                                currency.code?.toString().trim() ?? '';

                            formController.selectCurrency(
                              id: currency.id,
                              code: code,
                            );

                            setState(() {
                              selectedCurrencyIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsetsDirectional.only(end: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 13),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor.withValues(
                                      alpha: 0.10,
                                    )
                                  : AppColors.listbuilderboxColor,
                              border: Border.all(
                                width: isSelected ? 1.5 : 1,
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : AppColors.primarycolor2.withValues(
                                        alpha: 0.35,
                                      ),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              currency.code?.toString() ?? '',
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.grey.shade700,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 20),

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
                      ),
                      controller: formController.balanceController,
                      label: languageController.tr('OPENING_BALANCE'),
                      hint: languageController.tr('ENTER_OPENING_BALANCE'),
                      height: 68,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Obx(
                  () => GestureDetector(
                    onTap: formController.isLoading.value
                        ? null
                        : validateAndCreate,
                    child: Opacity(
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
                        alignment: Alignment.center,
                        child: formController.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
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

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOfficeDropdown() {
    return Obx(() {
      if (officeListController.isLoading.value &&
          officeListController.finalList.isEmpty) {
        return Container(
          height: 55,
          decoration: BoxDecoration(
            color: AppColors.listbuilderboxColor,
            border: Border.all(
              color: AppColors.primarycolor2.withValues(alpha: 0.45),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 23,
            height: 23,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
        );
      }

      final List<Office> offices = officeListController.finalList
          .where((office) => office.id != null)
          .toList();

      if (offices.isEmpty) {
        return Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.listbuilderboxColor,
            border: Border.all(
              color: AppColors.primarycolor2.withValues(alpha: 0.45),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: Text(languageController.tr('NO_OFFICE_FOUND'))),
              IconButton(
                onPressed: () {
                  officeListController.initialpage = 1;
                  officeListController.finalList.clear();
                  officeListController.fetchofficelist();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        );
      }

      final int? selectedOfficeId = formController.selectedOfficeId.value;

      final bool selectedOfficeExists = offices.any(
        (office) => office.id == selectedOfficeId,
      );

      return DropdownButtonFormField<int>(
        value: selectedOfficeExists ? selectedOfficeId : null,
        isExpanded: true,
        decoration: dropdownDecoration(languageController.tr('SELECT_OFFICE')),
        hint: Text(
          languageController.tr('PLEASE_SELECT_AN_OFFICE'),
          overflow: TextOverflow.ellipsis,
        ),
        items: offices.map((Office office) {
          final String name = office.name?.trim().isNotEmpty == true
              ? office.name!.trim()
              : 'Office #${office.id}';

          final String code = office.code?.trim() ?? '';

          return DropdownMenuItem<int>(
            value: office.id,
            child: Text(
              code.isEmpty ? name : '$name ($code)',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (int? officeId) {
          formController.selectOffice(officeId);
        },
      );
    });
  }

  InputDecoration dropdownDecoration(String label) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.listbuilderboxColor,
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: box.read('direction') == 'rtl' ? 12 : 15,
        horizontal: 12,
      ),
    );
  }
}
