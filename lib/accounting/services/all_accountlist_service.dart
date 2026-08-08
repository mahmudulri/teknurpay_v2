import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../utils/api_endpoints.dart';
import '../models/allaccount_model.dart';

class AllAccountlistApi {
  final box = GetStorage();
  Future<AllAccountsModel> fetchaccountlist() async {
    final url = Uri.parse(ApiEndPoints.baseUrl + "accounting/accounts");

    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${box.read("userToken")}'},
    );

    if (response.statusCode == 200) {
      // print(response.body.toString());
      final allaccountlistModel = AllAccountsModel.fromJson(
        json.decode(response.body),
      );

      return allaccountlistModel;
    } else {
      throw Exception('Failed to fetch all accountlist service');
    }
  }
}
