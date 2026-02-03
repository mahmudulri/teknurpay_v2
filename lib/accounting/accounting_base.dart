import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../global_controller/languages_controller.dart';
import '../utils/colors.dart';
import 'pages/alltransactions.dart';
import 'pages/counter_party.dart';
import 'pages/inventory.dart';
import 'pages/offices.dart';

class AccountingBaseScreen extends StatefulWidget {
  const AccountingBaseScreen({super.key});

  @override
  State<AccountingBaseScreen> createState() => _AccountingBaseScreenState();
}

class _AccountingBaseScreenState extends State<AccountingBaseScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final languagesController = Get.find<LanguagesController>();

  final List<Widget> _pages = [
    Offices(),
    CounterParty(),
    Alltransactions(),
    Inventory(),
  ];

  int currentIndex = 0;

  // void onTabTapped(int index) {
  //   setState(() => _currentIndex = index);
  //   _pageController.animateToPage(
  //     index,
  //     duration: Duration(milliseconds: 300),
  //     curve: Curves.easeInOut,
  //   );
  // }

  late Widget currentPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentPage = Offices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPage,
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFC5E3FF),
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [Color(0xFFFFFFFF), Color(0xFFC5E3FF)],
            // ),
          ),
          height: 67,
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomAppBar(
              elevation: 7.0,
              shape: CircularNotchedRectangle(),
              notchMargin: 10,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentPage = Offices();

                        currentIndex = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dashboard,
                          color: currentIndex == 0
                              ? AppColors.primaryColor
                              : Colors.black,
                        ),
                        Text(
                          languagesController.tr("OFFICES"),
                          style: TextStyle(
                            fontSize: 10,
                            color: currentIndex == 0
                                ? AppColors.primaryColor
                                : Colors.black,
                            fontWeight: currentIndex == 0
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentPage = CounterParty();
                        currentIndex = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_alt,
                          color: currentIndex == 1
                              ? AppColors.primaryColor
                              : Colors.black,
                        ),
                        Text(
                          languagesController.tr("COUNTER_PARTY"),
                          style: TextStyle(
                            fontSize: 10,
                            color: currentIndex == 1
                                ? AppColors.primaryColor
                                : Colors.black,
                            fontWeight: currentIndex == 1
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentPage = Alltransactions();
                        currentIndex = 2;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swap_horiz,
                          color: currentIndex == 2
                              ? AppColors.primaryColor
                              : Colors.black,
                        ),

                        Text(
                          languagesController.tr("TRANSACTIONS"),
                          style: TextStyle(
                            fontSize: 10,
                            color: currentIndex == 2
                                ? AppColors.primaryColor
                                : Colors.black,
                            fontWeight: currentIndex == 2
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentPage = Inventory();
                        currentIndex = 3;

                        // print(orderlistController.initialpage);
                        // print(orderlistController.finalList.length);
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2,
                          color: currentIndex == 3
                              ? AppColors.primaryColor
                              : Colors.black,
                        ),

                        Text(
                          languagesController.tr("INVENTORY"),
                          style: TextStyle(
                            fontSize: 10,
                            color: currentIndex == 3
                                ? AppColors.primaryColor
                                : Colors.black,
                            fontWeight: currentIndex == 3
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
