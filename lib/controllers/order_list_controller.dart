import 'package:get/get.dart';
import 'package:teknurpay/models/orders_list_model.dart';
import 'package:teknurpay/services/order_list_service.dart';

class OrderlistController extends GetxController {
  String filterDate = "order_status=0";
  String orderstatus = "";
  int initialpage = 1;

  RxList finalList = <Order>[].obs;

  var isLoading = false.obs;

  var allorderlist = OrderListModel().obs;

  void fetchOrderlistdata() async {
    try {
      isLoading(true);
      await OrderListApi().fetchorderList(initialpage).then((value) {
        allorderlist.value = value;

        if (allorderlist.value.data != null) {
          finalList.addAll(allorderlist.value.data!.orders);
        }

        isLoading(false);
      });

      isLoading(false);
    } catch (e) {
      print(e.toString());
    }
  }
}
