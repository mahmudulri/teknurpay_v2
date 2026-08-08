import 'package:get/get.dart';
import 'package:teknurpay/accounting/models/party_accounts_model.dart';
import 'package:teknurpay/accounting/services/party_accounts_service.dart';

class PartyAccountslistController extends GetxController {
  var isLoading = false.obs;

  RxList<Datum> accountlist = <Datum>[].obs;

  void fetchaccount(id) async {
    try {
      isLoading(true);
      await PartyAccountsApi().fetchaccounts(id).then((value) {
        accountlist.value = value;

        isLoading(false);
      });

      isLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }
}
