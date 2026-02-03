import 'package:get/get.dart';
import '../models/counter_party_model.dart';
import '../services/counterparty_service.dart';

class CounterPartyController extends GetxController {
  int initialpage = 1;

  RxList<Counterparty> finalList = <Counterparty>[].obs;

  var isLoading = false.obs;

  var counterparties = CounterPartyModel().obs;

  void fetchtransactions() async {
    try {
      isLoading(true);
      await CounterpartyApi().fetchtransactions(initialpage).then((value) {
        counterparties.value = value;

        if (counterparties.value.data != null) {
          finalList.addAll(counterparties.value.data!.counterparties!);
        }
        // print(finalList.length.toString());
        // print(counterparties.toJson());

        isLoading(false);
      });

      isLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }
}
