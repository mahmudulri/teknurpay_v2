import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/currency_controller.dart';
import '../controllers/recharge_config_controller.dart';

final CurrencyController currencyController = Get.find<CurrencyController>();

final RechargeConfigController configController =
    Get.find<RechargeConfigController>();

class AfghanRechargeController extends GetxController {
  final box = GetStorage();

  void reset() {
    afghanAmount.value = 0.0;
    convertedAmount.value = 0.0;

    buyingPrice.value = 0.0;
    sellingPrice.value = 0.0;
  }

  /// Amounts
  RxDouble afghanAmount = 0.0.obs;
  RxDouble convertedAmount = 0.0.obs;

  /// Buying & Selling
  RxDouble buyingPrice = 0.0.obs;
  RxDouble sellingPrice = 0.0.obs;

  double afghanRate = 1.0;
  double userRate = 1.0;

  @override
  void onInit() {
    super.onInit();

    /// 1️⃣ Ensure config API is called
    if (configController.allsettings.value.data == null) {
      configController.fetchrechargeConfig();
    }

    /// 2️⃣ Currency rate load listener
    ever(currencyController.isLoading, (loading) {
      if (loading == false) {
        _prepareRates();
      }
    });

    /// 3️⃣ Config load listener (🔥 THIS WAS MISSING)
    ever(configController.isLoading, (loading) {
      if (loading == false) {
        calculateBuyingAndSelling();
      }
    });
  }

  // ------------------ Currency Rates ------------------

  void _prepareRates() {
    final currencies =
        currencyController.allcurrencylist.value.data?.currencies;

    if (currencies == null || currencies.isEmpty) {
      print("❌ Currency list empty");
      return;
    }

    final afghan = currencies.firstWhere(
      (c) => c.code == "AFN",
      orElse: () => currencies.first,
    );

    afghanRate = double.parse(afghan.exchangeRatePerUsd!);

    final userSymbol = box.read("currency_symbol");

    final user = currencies.firstWhere(
      (c) => c.symbol == userSymbol,
      orElse: () => currencies.first,
    );

    userRate = double.parse(user.exchangeRatePerUsd!);

    print("✅ Rates Loaded: AFN=$afghanRate, USER=$userRate");
  }

  // ------------------ AFN Input ------------------

  void calculate(String input) {
    if (input.isEmpty) {
      convertedAmount.value = 0;
      buyingPrice.value = 0;
      sellingPrice.value = 0;
      return;
    }

    final afn = double.parse(input);

    /// AFN → TMN
    convertedAmount.value = (afn / afghanRate) * userRate;

    /// TMN → Buying & Selling
    calculateBuyingAndSelling();
  }

  // ------------------ Buying & Selling ------------------

  void calculateBuyingAndSelling() {
    final data = configController.allsettings.value.data;

    if (data == null) {
      print("❌ Config data null");
      return;
    }

    final double base = convertedAmount.value;

    /// BUYING
    final double adjustPercent = double.tryParse(data.adjustValue ?? "0") ?? 0;

    double buying = base;

    if (data.adjustMode == "percentage") {
      final double adjustAmount = base * adjustPercent / 100;

      if (data.adjustType == "increase") {
        buying = base + adjustAmount;
      } else if (data.adjustType == "decrease") {
        buying = base - adjustAmount;
      }
    }

    buyingPrice.value = buying;

    /// SELLING
    final double sellingPercent =
        double.tryParse(data.sellingAdjustValue ?? "0") ?? 0;

    double selling = buying;

    if (data.sellingAdjustMode == "percentage") {
      final double sellingAmount = buying * sellingPercent / 100;

      if (data.sellingAdjustType == "increase") {
        selling = buying + sellingAmount;
      } else if (data.sellingAdjustType == "decrease") {
        selling = buying - sellingAmount;
      }
    }

    sellingPrice.value = selling;

    print("✅ Buying=$buying | Selling=$selling");
  }
}
