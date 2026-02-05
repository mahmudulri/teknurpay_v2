import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import '../utils/api_endpoints.dart';

class TransactionApi {
  final box = GetStorage();

  Future<TransactionModel> fetchTransaction(int pageNo) async {
    // final url = Uri.parse(
    //   ApiEndPoints.baseUrl +
    //       ApiEndPoints.otherendpoints.transactions +
    //       "?page=$pageNo&items_per_page=300&search=&filter_transactiontype=debit&filter_transactioncategory=reseller-subreseller&filter_transactionpurpose=order&filter_startdate=2026-02-04&filter_enddate=2026-02-12",
    // );
    final url = Uri.parse(
      ApiEndPoints.baseUrl +
          ApiEndPoints.otherendpoints.transactions +
          "?page=$pageNo&items_per_page=300&search=${box.read("transactiontype")}${box.read("category")}${box.read("purpose")}${box.read("startdate")}${box.read("enddate")}",
    );

    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${box.read("userToken")}'},
    );
    print(url);

    if (response.statusCode == 200) {
      print(response.statusCode.toString());

      // print(response.body.toString());
      final transactionModel = TransactionModel.fromJson(
        json.decode(response.body),
      );

      return transactionModel;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
