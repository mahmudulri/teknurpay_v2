import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teknurpay/helpers/language_changer.dart';

import '../../global_controller/languages_controller.dart';
import '../../utils/colors.dart';
import '../controllers/accounting_currency_controller.dart';
import '../controllers/allaccount_list_controller.dart';
import '../controllers/counter_party_controller.dart';
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

  final CounterPartyController counterPartyController =
      Get.isRegistered<CounterPartyController>()
      ? Get.find<CounterPartyController>()
      : Get.put(CounterPartyController());

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    searchController.text = accountListController.searchText.value;

    accountListController.initialpage = 1;
    accountListController.finalList.clear();

    await accountListController.fetchaccount();

    if ((currencyController.allcurrencylist.value.data?.currencies?.isEmpty ??
            true) &&
        !currencyController.isLoading.value) {
      currencyController.fetchCurrencyList();
    }

    if (counterPartyController.finalList.isEmpty &&
        !counterPartyController.isLoading.value) {
      counterPartyController.initialpage = 1;
      counterPartyController.fetchcounterpary();
    }

    if (officeListController.finalList.isEmpty &&
        !officeListController.isLoading.value) {
      officeListController.initialpage = 1;
      officeListController.fetchofficelist();
    }
  }

  /// Infinite scroll / load more
  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    if (position.extentAfter < 250) {
      _loadMoreAccounts();
    }
  }

  Future<void> _loadMoreAccounts() async {
    if (_isLoadingMore || accountListController.isLoading.value) return;

    final int totalPages =
        accountListController
            .accountlist
            .value
            .payload
            ?.pagination
            ?.totalPages ??
        0;

    final int currentPage = accountListController.initialpage;

    if (totalPages <= 0) return;

    if (currentPage >= totalPages) {
      debugPrint('Accounts: Last page reached');
      return;
    }

    final int nextPage = currentPage + 1;

    if (mounted) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      accountListController.initialpage = nextPage;
      await accountListController.fetchaccount();
    } catch (e) {
      accountListController.initialpage = currentPage;
      debugPrint('Accounts load more error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
                languagesController.tr('ACCOUNTS'),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.fontColor,
                  child: Image.asset('assets/icons/telecom.png', height: 25),
                ),
              ),
              const SizedBox(width: 5),
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
            final bool hasRawData = accountListController.finalList.isNotEmpty;
            final List<Account> visibleAccounts =
                accountListController.visibleAccounts;
            final bool hasVisibleData = visibleAccounts.isNotEmpty;
            final int activeFilterCount =
                accountListController.activeFilterCount;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  SizedBox(height: 10),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 28,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: TextField(
                                      controller: searchController,
                                      onChanged:
                                          accountListController.setSearchText,
                                      onSubmitted:
                                          accountListController.submitSearch,
                                      textInputAction: TextInputAction.search,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: languagesController.tr(
                                          'NAME',
                                        ),
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  if (accountListController
                                      .searchText
                                      .value
                                      .isNotEmpty)
                                    InkWell(
                                      onTap: () async {
                                        searchController.clear();
                                        await accountListController
                                            .clearSearch();
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _showFilterSheet,
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 50,
                                width: 55,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset('assets/icons/filter.png'),
                                ),
                              ),
                              if (activeFilterCount > 0)
                                Positioned(
                                  right: -3,
                                  top: -5,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 20,
                                      minHeight: 20,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      activeFilterCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
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

                  if (activeFilterCount > 0) ...[
                    const SizedBox(height: 7),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (accountListController
                                  .selectedCurrencyCode
                                  .value !=
                              null)
                            _activeFilterChip(
                              icon: Icons.currency_exchange_rounded,
                              label:
                                  accountListController
                                      .selectedCurrencyCode
                                      .value ??
                                  '',
                              onDeleted: () async {
                                await accountListController.applyFilters(
                                  currencyCode: null,
                                  counterpartyId: accountListController
                                      .selectedCounterpartyId
                                      .value,
                                  officeId: accountListController
                                      .selectedOfficeId
                                      .value,
                                  balanceStatus: accountListController
                                      .selectedBalanceStatus
                                      .value,
                                );
                              },
                            ),
                          if (accountListController
                                  .selectedCounterpartyId
                                  .value !=
                              null)
                            _activeFilterChip(
                              icon: Icons.person_outline_rounded,
                              label: _selectedCounterpartyName(),
                              onDeleted: () async {
                                await accountListController.applyFilters(
                                  currencyCode: accountListController
                                      .selectedCurrencyCode
                                      .value,
                                  counterpartyId: null,
                                  officeId: accountListController
                                      .selectedOfficeId
                                      .value,
                                  balanceStatus: accountListController
                                      .selectedBalanceStatus
                                      .value,
                                );
                              },
                            ),
                          if (accountListController.selectedOfficeId.value !=
                              null)
                            _activeFilterChip(
                              icon: Icons.business_outlined,
                              label: _selectedOfficeName(),
                              onDeleted: () async {
                                await accountListController.applyFilters(
                                  currencyCode: accountListController
                                      .selectedCurrencyCode
                                      .value,
                                  counterpartyId: accountListController
                                      .selectedCounterpartyId
                                      .value,
                                  officeId: null,
                                  balanceStatus: accountListController
                                      .selectedBalanceStatus
                                      .value,
                                );
                              },
                            ),
                          if (accountListController
                                  .selectedBalanceStatus
                                  .value !=
                              null)
                            _activeFilterChip(
                              icon: Icons.account_balance_wallet_outlined,
                              label: _selectedBalanceStatusLabel(),
                              onDeleted: () async {
                                await accountListController.applyFilters(
                                  currencyCode: accountListController
                                      .selectedCurrencyCode
                                      .value,
                                  counterpartyId: accountListController
                                      .selectedCounterpartyId
                                      .value,
                                  officeId: accountListController
                                      .selectedOfficeId
                                      .value,
                                  balanceStatus: null,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Expanded(
                    child: Builder(
                      builder: (context) {
                        /// First page loading
                        if (isLoading && !hasRawData) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          );
                        }

                        /// Empty data / no local search result
                        if (!hasVisibleData) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 72,
                                  width: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.listbuilderboxColor,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 34,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  languagesController.tr('NO_ACCOUNTS_FOUND'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        /// Account List + pagination loader
                        return ListView.builder(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 2, bottom: 8),
                          itemCount:
                              visibleAccounts.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            /// Bottom pagination loader
                            if (index == visibleAccounts.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    height: 23,
                                    width: 23,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final Account account = visibleAccounts[index];

                            final double balanceValue =
                                double.tryParse(
                                  account.currentBalance?.toString() ?? '0',
                                ) ??
                                0;

                            final bool isBalanceSettled = balanceValue == 0;
                            final bool heOwes = balanceValue < 0;

                            final String balanceRelationText = isBalanceSettled
                                ? languagesController.tr('BALANCE_SETTLED')
                                : heOwes
                                ? languagesController.tr('HE_OWE')
                                : languagesController.tr('HE_OWED');

                            final Color balanceColor = isBalanceSettled
                                ? const Color(0xFF667085)
                                : heOwes
                                ? const Color(0xFFD92D20)
                                : AppColors.greenColor;

                            final IconData balanceRelationIcon =
                                isBalanceSettled
                                ? Icons.check_circle_outline_rounded
                                : heOwes
                                ? Icons.south_west_rounded
                                : Icons.north_east_rounded;

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
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: Text(
                                        account.currencyCode ?? '--',
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
                                            account.name ?? '---',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_exchange_rounded,
                                                size: 14,
                                                color: Colors.grey.shade500,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                account.currencyCode ?? '---',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
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
                                        Text(
                                          '${account.currency?.symbol ?? account.currencyCode ?? ''} '
                                          '${_formatAmount(account.currentBalance)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: balanceColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              balanceRelationIcon,
                                              size: 12,
                                              color: balanceColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              balanceRelationText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: balanceColor,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
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
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 5),

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
                          languagesController.tr('ADD_NEW_ACCOUNT'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 3),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    if ((currencyController.allcurrencylist.value.data?.currencies?.isEmpty ??
            true) &&
        !currencyController.isLoading.value) {
      currencyController.fetchCurrencyList();
    }

    if (counterPartyController.finalList.isEmpty &&
        !counterPartyController.isLoading.value) {
      counterPartyController.initialpage = 1;
      counterPartyController.fetchcounterpary();
    }

    if (officeListController.finalList.isEmpty &&
        !officeListController.isLoading.value) {
      officeListController.initialpage = 1;
      officeListController.fetchofficelist();
    }

    String? tempCurrencyCode = accountListController.selectedCurrencyCode.value;
    int? tempCounterpartyId =
        accountListController.selectedCounterpartyId.value;
    int? tempOfficeId = accountListController.selectedOfficeId.value;
    String? tempBalanceStatus =
        accountListController.selectedBalanceStatus.value;

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return SafeArea(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: AppColors.listbuilderboxColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            languagesController.tr('FILTER'),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      languagesController.tr('CURRENCY'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),

                    Obx(() {
                      final currencies =
                          currencyController
                              .allcurrencylist
                              .value
                              .data
                              ?.currencies ??
                          [];

                      final Map<String, dynamic> uniqueCurrencyMap = {};

                      for (final currency in currencies) {
                        final String code = currency.code?.trim() ?? '';
                        if (code.isNotEmpty) {
                          uniqueCurrencyMap[code] = currency;
                        }
                      }

                      final List<dynamic> uniqueCurrencies = uniqueCurrencyMap
                          .values
                          .toList();

                      if (currencyController.isLoading.value &&
                          uniqueCurrencies.isEmpty) {
                        return _filterLoadingBox();
                      }

                      final String dropdownValue = tempCurrencyCode ?? '';

                      return DropdownButtonFormField<String>(
                        value: uniqueCurrencyMap.containsKey(dropdownValue)
                            ? dropdownValue
                            : '',
                        isExpanded: true,
                        decoration: _filterInputDecoration(),
                        items: [
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text(
                              languagesController.tr('SELECT_CURRENCY'),
                            ),
                          ),
                          ...uniqueCurrencies.map(
                            (currency) => DropdownMenuItem<String>(
                              value: currency.code.toString(),
                              child: Text(
                                '${currency.name ?? currency.code ?? ''} (${currency.code ?? ''})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setSheetState(() {
                            tempCurrencyCode = value == null || value.isEmpty
                                ? null
                                : value;
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 18),

                    Text(
                      languagesController.tr('COUNTER_PARTY'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),

                    Obx(() {
                      final counterparties = counterPartyController.finalList;

                      final Map<int, dynamic> uniqueCounterpartyMap = {};

                      for (final counterparty in counterparties) {
                        final int? id = counterparty.id;
                        if (id != null) {
                          uniqueCounterpartyMap[id] = counterparty;
                        }
                      }

                      final List<dynamic> uniqueCounterparties =
                          uniqueCounterpartyMap.values.toList();

                      if (counterPartyController.isLoading.value &&
                          uniqueCounterparties.isEmpty) {
                        return _filterLoadingBox();
                      }

                      final int dropdownValue = tempCounterpartyId ?? 0;

                      return DropdownButtonFormField<int>(
                        value: uniqueCounterpartyMap.containsKey(dropdownValue)
                            ? dropdownValue
                            : 0,
                        isExpanded: true,
                        decoration: _filterInputDecoration(),
                        items: [
                          DropdownMenuItem<int>(
                            value: 0,
                            child: Text(
                              languagesController.tr('SELECT_COUNTER_PARTY'),
                            ),
                          ),
                          ...uniqueCounterparties.map(
                            (counterparty) => DropdownMenuItem<int>(
                              value: counterparty.id,
                              child: Text(
                                counterparty.name ?? '---',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setSheetState(() {
                            tempCounterpartyId = value == null || value == 0
                                ? null
                                : value;
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 18),

                    Text(
                      languagesController.tr('OFFICE'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),

                    Obx(() {
                      final offices = officeListController.finalList;

                      final Map<int, dynamic> uniqueOfficeMap = {};

                      for (final office in offices) {
                        final int? id = office.id;
                        if (id != null) {
                          uniqueOfficeMap[id] = office;
                        }
                      }

                      final List<dynamic> uniqueOffices = uniqueOfficeMap.values
                          .toList();

                      if (officeListController.isLoading.value &&
                          uniqueOffices.isEmpty) {
                        return _filterLoadingBox();
                      }

                      final int dropdownValue = tempOfficeId ?? 0;

                      return DropdownButtonFormField<int>(
                        value: uniqueOfficeMap.containsKey(dropdownValue)
                            ? dropdownValue
                            : 0,
                        isExpanded: true,
                        decoration: _filterInputDecoration(),
                        items: [
                          DropdownMenuItem<int>(
                            value: 0,
                            child: Text(
                              languagesController.tr('SELECT_OFFICE'),
                            ),
                          ),
                          ...uniqueOffices.map(
                            (office) => DropdownMenuItem<int>(
                              value: office.id,
                              child: Text(
                                office.name ?? '---',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setSheetState(() {
                            tempOfficeId = value == null || value == 0
                                ? null
                                : value;
                          });
                        },
                      );
                    }),

                    const SizedBox(height: 18),

                    Text(
                      languagesController.tr('BALANCE_STATUS'),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),

                    DropdownButtonFormField<String>(
                      value: tempBalanceStatus ?? '',
                      isExpanded: true,
                      decoration: _filterInputDecoration(),
                      items: [
                        DropdownMenuItem<String>(
                          value: '',
                          child: Text(
                            languagesController.tr('SELECT_BALANCE_STATUS'),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'receivable',
                          child: Text(languagesController.tr('RECEIVABLE')),
                        ),
                        DropdownMenuItem<String>(
                          value: 'payable',
                          child: Text(languagesController.tr('PAYABLE')),
                        ),
                      ],
                      onChanged: (value) {
                        setSheetState(() {
                          tempBalanceStatus = value == null || value.isEmpty
                              ? null
                              : value;
                        });
                      },
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              Get.back();
                              await accountListController.clearFilters();
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              languagesController.tr('REMOVE_FILTER'),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Get.back();

                              await accountListController.applyFilters(
                                currencyCode: tempCurrencyCode,
                                counterpartyId: tempCounterpartyId,
                                officeId: tempOfficeId,
                                balanceStatus: tempBalanceStatus,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              elevation: 0,
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              languagesController.tr('APPLY_FILTER'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
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
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  InputDecoration _filterInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.secondaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
      ),
    );
  }

  Widget _filterLoadingBox() {
    return Container(
      height: 52,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _activeFilterChip({
    required IconData icon,
    required String label,
    required Future<void> Function() onDeleted,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 9, right: 4, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: AppColors.listbuilderboxColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 3),
          InkWell(
            onTap: () {
              onDeleted();
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(
                Icons.close_rounded,
                size: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _selectedCounterpartyName() {
    final int? selectedId = accountListController.selectedCounterpartyId.value;

    if (selectedId == null) {
      return '';
    }

    for (final counterparty in counterPartyController.finalList) {
      if (counterparty.id == selectedId) {
        return counterparty.name ?? selectedId.toString();
      }
    }

    return selectedId.toString();
  }

  String _selectedOfficeName() {
    final int? selectedId = accountListController.selectedOfficeId.value;

    if (selectedId == null) {
      return '';
    }

    for (final office in officeListController.finalList) {
      if (office.id == selectedId) {
        return office.name ?? selectedId.toString();
      }
    }

    return selectedId.toString();
  }

  String _selectedBalanceStatusLabel() {
    final String? status = accountListController.selectedBalanceStatus.value;

    if (status == 'receivable') {
      return languagesController.tr('RECEIVABLE');
    }

    if (status == 'payable') {
      return languagesController.tr('PAYABLE');
    }

    return status ?? '';
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
            physics: const BouncingScrollPhysics(),
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
                        account.currencyCode ?? '--',
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
                            account.name ?? '---',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            account.accountType ?? '---',
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
                  title: languagesController.tr('ACCOUNT_NAME'),
                  value: account.name ?? '---',
                ),
                _detailRow(
                  title: languagesController.tr('ACCOUNT_TYPE'),
                  value: account.accountType ?? '---',
                ),
                _detailRow(
                  title: languagesController.tr('CURRENCY'),
                  value:
                      '${account.currency?.name ?? '---'} (${account.currencyCode ?? '---'})',
                ),
                _detailRow(
                  title: languagesController.tr('OPENING_BALANCE'),
                  value:
                      '${account.currency?.symbol ?? account.currencyCode ?? ''} ${_formatAmount(account.openingBalance)}',
                ),
                _detailRow(
                  title: languagesController.tr('CURRENT_BALANCE'),
                  value:
                      '${account.currency?.symbol ?? account.currencyCode ?? ''} ${_formatAmount(account.currentBalance)}',
                ),
                _detailRow(
                  title: languagesController.tr('COUNTER_PARTY'),
                  value: account.counterparty?.name ?? '---',
                ),
                _detailRow(
                  title: languagesController.tr('PHONE'),
                  value: account.counterparty?.phone ?? '---',
                ),
                _detailRow(
                  title: languagesController.tr('EMAIL'),
                  value: account.counterparty?.email ?? '---',
                ),
                _detailRow(
                  title: languagesController.tr('OFFICE'),
                  value: account.office?.name ?? '---',
                ),
                _detailRow(
                  title: languagesController.tr('OFFICE_CODE'),
                  value: account.office?.code ?? '---',
                ),
                _detailRow(
                  title: languagesController.tr('LOCATION'),
                  value: account.office?.location ?? '---',
                ),
                _detailRow(
                  title: languagesController.tr('ADDRESS'),
                  value: account.office?.address ?? '---',
                ),
                _detailRow(
                  title: languagesController.tr('NOTES'),
                  value: account.notes ?? '---',
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
                  style: const TextStyle(
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
    final double amount = double.tryParse(value ?? '0') ?? 0;
    return amount.toStringAsFixed(2);
  }
}
