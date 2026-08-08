import 'package:get/get.dart';

import '../models/hawala_list_model.dart';
import '../models/withdraw_list_model.dart';
import '../services/hawala_list_service.dart';
import '../services/withdraw_list_service.dart';

class WithdrawlistController extends GetxController {
  var isLoading = false.obs;

  var allwithdrawlist = WithdrawListModel().obs;

  void fetchlist() async {
    try {
      isLoading(true);
      await WithdrawListApi().fetchData().then((value) {
        allwithdrawlist.value = value;

        isLoading(false);
      });

      isLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }
}
