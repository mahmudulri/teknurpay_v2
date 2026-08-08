import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/withdraw_list_model.dart';
import '../utils/api_endpoints.dart';

class WithdrawListApi {
  final box = GetStorage();
  Future<WithdrawListModel> fetchData() async {
    final url = Uri.parse(
      ApiEndPoints.baseUrl + ApiEndPoints.otherendpoints.withdrawrequests,
    );

    print(url);

    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${box.read("userToken")}'},
    );

    if (response.statusCode == 200) {
      // print(response.statusCode.toString());
      print(response.body.toString());
      final withdrawlistModel = WithdrawListModel.fromJson(
        json.decode(response.body),
      );

      return withdrawlistModel;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
