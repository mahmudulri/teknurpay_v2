import 'package:get/get.dart';
import '../models/allaccount_model.dart';
import '../services/all_accountlist_service.dart';

class AllAccountListController extends GetxController {
  var isLoading = false.obs;

  var accountlist = AllAccountsModel().obs;

  Future fetchaccount() async {
    try {
      isLoading(true);
      await AllAccountlistApi().fetchaccountlist().then((value) {
        accountlist.value = value;

        isLoading(false);
      });

      isLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }
}
