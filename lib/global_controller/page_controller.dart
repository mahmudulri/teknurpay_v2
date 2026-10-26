import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teknurpay/pages/network.dart';
import 'package:teknurpay/pages/orders.dart';
import 'package:teknurpay/pages/transaction_type.dart';
import 'package:teknurpay/pages/transactions.dart';

import '../pages/homepages.dart';

class Mypagecontroller extends GetxController {
  // Reuse the exact same main-page Widget objects throughout navigation.
  late final List<Widget> mainPages = [
    Homepages(),
    TransactionsType(),
    Orders(),
    Network(),
  ];

  late final RxList<Widget> pageStack = <Widget>[mainPages[0]].obs;

  int lastSelectedIndex = 0;
  Function(int)? updateIndexCallback;

  void setUpdateIndexCallback(Function(int) callback) {
    updateIndexCallback = callback;
  }

  void changePage(Widget page, {bool isMainPage = true}) {
    if (isMainPage) {
      final index = mainPages.indexWhere(
        (element) => element.runtimeType == page.runtimeType,
      );

      if (index >= 0) {
        lastSelectedIndex = index;
        pageStack.assignAll([mainPages[index]]);
      } else {
        pageStack.assignAll([page]);
      }
    } else {
      pageStack.add(page);
    }

    updateIndexCallback?.call(isMainPage ? lastSelectedIndex : -1);
  }

  void goBack() {
    if (pageStack.length <= 1) return;

    pageStack.removeLast();
    updateIndexCallback?.call(pageStack.length == 1 ? lastSelectedIndex : -1);
  }

  void goToMainPageByIndex(int index) {
    if (index < 0 || index >= mainPages.length) return;
    changePage(mainPages[index], isMainPage: true);
  }
}
