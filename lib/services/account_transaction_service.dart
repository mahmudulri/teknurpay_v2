import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../helpers/api_headers.dart';
import '../models/account_transactions_model.dart';
import '../utils/api_endpoints.dart';

class AccountTransactionApi {
  final box = GetStorage();
  Future<AccountTransactionsModel> fetchtransactions(int pageNo) async {
    final url = Uri.parse(
      "${ApiEndPoints.baseUrl}accounting-transactions?page=${pageNo}",
    );
    // print("order Url : " + url.toString());

    final response = await http.get(url, headers: ApiHeaders.authenticated());

    if (response.statusCode == 200) {
      // print(response.body.toString());
      final alltransactions = AccountTransactionsModel.fromJson(
        json.decode(response.body),
      );

      return alltransactions;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
