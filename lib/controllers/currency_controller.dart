import 'package:get/get.dart';
import '../models/currency_model.dart';
import '../services/currency_service.dart';

class CurrencyController extends GetxController {
  @override
  void onInit() {
    fetchCurrencyList();
    super.onInit();
  }

  var isLoading = false.obs;

  var allcurrencylist = CurrencyModel().obs;

  void fetchCurrencyList() async {
    try {
      isLoading(true);
      await CurrencyApi().fetchcurrency().then((value) {
        allcurrencylist.value = value;

        isLoading(false);
      });

      isLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }
}
