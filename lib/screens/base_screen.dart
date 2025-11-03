import 'dart:io'; // for exit(0)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:teknurpay/utils/colors.dart';

import '../controllers/slider_controller.dart';
import '../global_controller/languages_controller.dart';
import '../global_controller/page_controller.dart';

class BaseScreen extends StatefulWidget {
  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final Mypagecontroller mypagecontroller = Get.put(Mypagecontroller());
  LanguagesController languagesController = Get.put(LanguagesController());
  final sliderController = Get.find<SliderController>();

  final List<String> namesKeys = ["HOME", "TRANSACTIONS", "ORDERS", "NETWORK"];

  final List<String> imagedata = [
    "assets/icons/home.png",
    "assets/icons/transactiontype.png",
    "assets/icons/orders.png",
    "assets/icons/network.png",
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    sliderController.fetchSliderData();
    mypagecontroller.setUpdateIndexCallback((index) {
      setState(() {
        selectedIndex = index;
      });
    });
  }

  // Future<bool> showExitPopup() async {
  //   final shouldExit = mypagecontroller.goBack();
  //   if (shouldExit) {
  //     return await showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             title: Text(languagesController.tr("EXIT_APP")),
  //             content: Text(languagesController.tr("DO_YOU_WANT_TO_EXIT_APP")),
  //             actions: [
  //               ElevatedButton(
  //                 onPressed: () => Navigator.of(context).pop(false),
  //                 child: Text(languagesController.tr("NO")),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () => exit(0),
  //                 child: Text(languagesController.tr("YES")),
  //               ),
  //             ],
  //           ),
  //         ) ??
  //         false;
  //   }
  //   setState(() {}); // rebuild if page stack updated
  //   return false;
  // }

  Future<bool> handleBackPressed() async {
    // If current page is one of the main pages
    if (mypagecontroller.pageStack.length == 1 &&
        mypagecontroller.lastSelectedIndex >= 0 &&
        mypagecontroller.lastSelectedIndex <= 3) {
      if (Platform.isAndroid) {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return false; // prevent default back behavior
      }
      return true; // let iOS handle normally
    }

    // Otherwise, pop the top page from stack
    mypagecontroller.goBack();
    return false; // prevent default back behavior
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: handleBackPressed,
      child: Obx(
        () => Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          extendBody: true,
          body: mypagecontroller.pageStack.last,
          floatingActionButton: SizedBox(
            width: 60,
            height: 60,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.primarycolor2,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(Icons.add, size: 32, color: Colors.white),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xffD3EAFF),
                borderRadius: BorderRadius.circular(35),
              ),
              height: 70,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ...List.generate(imagedata.length, (index) {
                      bool isSelected =
                          mypagecontroller.lastSelectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          mypagecontroller.goToMainPageByIndex(index);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // horizontal line above icon
                            Container(
                              width: 25,
                              height: 3,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primarycolor2
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(height: 3),
                            Image.asset(
                              imagedata[index],
                              width: 25,
                              height: 25,
                              color: isSelected
                                  ? AppColors.primarycolor2
                                  : Colors.grey,
                            ),
                            Text(
                              languagesController.tr(namesKeys[index]),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? AppColors.primarycolor2
                                    : Colors.grey,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).asMap().entries.expand((entry) {
                      if (entry.key == 1) {
                        return [entry.value, SizedBox(width: 20)];
                      }
                      return [entry.value];
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
