import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../helpers/api_headers.dart';
import '../models/office_withtransaction_model.dart';
import '../utils/api_endpoints.dart';

class OfficeTransactionApi {
  final box = GetStorage();
  Future<OfficeTransactionModel> fetchtransactions(int pageNo, int id) async {
    final url = Uri.parse(
      "${ApiEndPoints.baseUrl}offices/${id}?page=${pageNo}&include=transactions",
    );
    // print("order Url : " + url.toString());

    final response = await http.get(url, headers: ApiHeaders.authenticated());

    if (response.statusCode == 200) {
      // print(response.body.toString());
      final transactionsModel = OfficeTransactionModel.fromJson(
        json.decode(response.body),
      );

      return transactionsModel;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
