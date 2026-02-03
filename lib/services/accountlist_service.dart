import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../models/account_model.dart';
import '../models/branch_model.dart';

import '../utils/api_endpoints.dart';

class AccountlistApi {
  final box = GetStorage();
  Future<AccountModel> fetchaccountlist(id) async {
    final url = Uri.parse(
      ApiEndPoints.baseUrl + "offices/${id}?include=accounts",
    );

    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${box.read("userToken")}'},
    );

    if (response.statusCode == 200) {
      // print(response.body.toString());
      final accountlistModel = AccountModel.fromJson(
        json.decode(response.body),
      );

      return accountlistModel;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
