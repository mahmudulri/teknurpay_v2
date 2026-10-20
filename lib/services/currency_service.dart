import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../helpers/api_headers.dart';
import '../models/country_list_model.dart';
import '../models/currency_model.dart';
import '../utils/api_endpoints.dart';

class CurrencyApi {
  final box = GetStorage();
  Future<CurrencyModel> fetchcurrency() async {
    final url = Uri.parse(ApiEndPoints.publicUrl + "currencies");

    // print(url);

    final response = await http.get(url, headers: ApiHeaders.authenticated());

    if (response.statusCode == 200) {
      final currencyModel = CurrencyModel.fromJson(json.decode(response.body));

      return currencyModel;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
