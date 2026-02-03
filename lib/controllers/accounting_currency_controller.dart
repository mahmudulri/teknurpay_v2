import 'package:get/get.dart';
import '../models/account_currency_model.dart';
import '../services/accounting_currency_service.dart';

class AccountingCurrencyController extends GetxController {
  var isLoading = false.obs;

  var allcurrencylist = AccountCurrencyModel().obs;

  void fetchCurrencyList() async {
    try {
      isLoading(true);
      await AccountingCurrencyApi().fetchCurrency().then((value) {
        allcurrencylist.value = value;

        isLoading(false);
      });

      isLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }
}
