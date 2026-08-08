import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lottie/lottie.dart';
import 'package:teknurpay/accounting/pages/alltransactions.dart';
import 'package:teknurpay/accounting/pages/counter_party.dart';
import '../global_controller/languages_controller.dart';
import '../utils/colors.dart';
import 'controllers/accounting_currency_controller.dart';
import 'controllers/statistic_controller.dart';
import 'pages/accounts.dart';
import 'pages/offices.dart';

class AccountingBaseScreen extends StatefulWidget {
  const AccountingBaseScreen({super.key});

  @override
  State<AccountingBaseScreen> createState() => _AccountingBaseScreenState();
}

class _AccountingBaseScreenState extends State<AccountingBaseScreen> {
  final languagesController = Get.find<LanguagesController>();

  AccountingCurrencyController currencyController = Get.put(
    AccountingCurrencyController(),
  );
  StatisticController statisticController = Get.put(StatisticController());

  bool showMain = false;

  int currentIndex = 0;
  late Widget currentPage;

  final List<Widget> _pages = [
    Offices(),
    AccountsPage(),
    CounterParty(),
    Alltransactions(),
    // Inventory(),
  ];

  @override
  void initState() {
    super.initState();
    currentPage = Offices();
    _showIntroAnimation();
  }

  void _showIntroAnimation() {
    setState(() => showMain = false);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => showMain = true);
      }
    });
  }

  Future<bool> _onWillPop() async {
    setState(() => showMain = false);
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color(0xff3498db),
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 800),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: showMain ? _mainScaffold() : _introImage(),
        ),
      ),
    );
  }

  Widget _introImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/loties/accounting.json',
            key: ValueKey('intro'),
            width: 200,
            height: 300,
          ),
          Text(
            languagesController.tr("MY_ACCOUNTING"),
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainScaffold() {
    return Scaffold(
      body: currentPage,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Color(0xFFC5E3FF)),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: BottomAppBar(
                elevation: 7,
                padding: EdgeInsets.zero,
                shape: const CircularNotchedRectangle(),
                notchMargin: 10,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: _navItem(
                        icon: Icons.dashboard,
                        index: 0,
                        label: languagesController.tr("OFFICES"),
                      ),
                    ),
                    Expanded(
                      child: _navItem(
                        icon: Icons.account_balance,
                        index: 1,
                        label: languagesController.tr("ACCOUNTS"),
                      ),
                    ),
                    Expanded(
                      child: _navItem(
                        icon: Icons.people_alt,
                        index: 2,
                        label: languagesController.tr("COUNTER_PARTY"),
                      ),
                    ),
                    Expanded(
                      child: _navItem(
                        icon: Icons.swap_horiz,
                        index: 3,
                        label: languagesController.tr("TRANSACTIONS"),
                      ),
                    ),
                    // Expanded(
                    //   child: _navItem(
                    //     icon: Icons.inventory_2,
                    //     index: 4,
                    //     label: languagesController.tr("INVENTORY"),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Bottom nav item builder
  Widget _navItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final bool isActive = currentIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          currentIndex = index;
          currentPage = _pages[index];
        });
      },
      child: SizedBox.expand(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 21,
              color: isActive
                  ? AppColors.primaryColor
                  : const Color(0xFF667085),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  height: 1,
                  color: isActive
                      ? AppColors.primaryColor
                      : const Color(0xFF667085),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
