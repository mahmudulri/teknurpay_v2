import 'package:get/get.dart';
import '../models/account_model.dart';
import '../models/branch_model.dart';
import '../services/accountlist_service.dart';
import '../services/branch_service.dart';

class AccountListController extends GetxController {
  var isLoading = false.obs;

  var accountlist = AccountModel().obs;

  void fetchaccount(id) async {
    try {
      isLoading(true);
      await AccountlistApi().fetchaccountlist(id).then((value) {
        accountlist.value = value;

        isLoading(false);
      });

      isLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }
}
