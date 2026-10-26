import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../controllers/dashboard_controller.dart';
import '../helpers/api_headers.dart';
import '../models/transaction_model.dart';
import '../utils/api_endpoints.dart';

class TransactionPage {
  final TransactionModel model;
  final bool hasMore;
  TransactionPage(this.model, this.hasMore);
}

class TransactionApi {
  final box = GetStorage();

  // Existing filters are stored as "&filter_name=value" fragments.
  Map<String, String> captureFilters() {
    final result = <String, String>{'search': ''};
    for (final key in [
      'transactiontype',
      'category',
      'purpose',
      'startdate',
      'enddate',
    ]) {
      final fragment = box.read(key)?.toString() ?? '';
      if (fragment.isEmpty || fragment == 'null') continue;
      result.addAll(
        Uri.splitQueryString(
          fragment.startsWith('&') ? fragment.substring(1) : fragment,
        ),
      );
    }
    return result;
  }

  Future<TransactionModel> fetchTransaction(int pageNo) async {
    return (await fetchTransactionPage(pageNo)).model;
  }

  Future<TransactionPage> fetchTransactionPage(
    int pageNo, {
    int itemsPerPage = 20,
    Map<String, String>? filters,
  }) async {
    final base = Uri.parse(
      ApiEndPoints.baseUrl + ApiEndPoints.otherendpoints.transactions,
    );
    final url = base.replace(
      queryParameters: {
        ...base.queryParameters,
        ...(filters ?? captureFilters()),
        'page': pageNo.toString(),
        'items_per_page': itemsPerPage.toString(),
      },
    );
    final response = await http
        .get(url, headers: ApiHeaders.authenticated())
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 403) {
      final decoded = json.decode(response.body);
      final errors = decoded['errors'] ?? '';
      final message = decoded['message'] ?? '';
      Get.find<DashboardController>().setDeactivated(errors, message);
      Get.snackbar(
        errors.toString(),
        message.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
        icon: const Icon(Icons.block, color: Colors.white),
      );
      throw Exception('Account access denied');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch transactions');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    if (decoded['success'] == false) {
      throw Exception('Failed to fetch transactions');
    }
    final model = TransactionModel.fromJson(decoded);
    final count = model.data?.resellerBalanceTransactions?.length ?? 0;
    final payload = decoded['payload'];
    final pagination = payload is Map ? payload['pagination'] : null;
    final totalPages = pagination is Map
        ? int.tryParse(
            (pagination['total_pages'] ??
                    pagination['totalPages'] ??
                    pagination['last_page'] ??
                    '')
                .toString(),
          )
        : null;
    // Without pagination metadata, a short/empty page ends pagination.
    final hasMore =
        count > 0 &&
        (totalPages != null ? pageNo < totalPages : count >= itemsPerPage);
    return TransactionPage(model, hasMore);
  }
}
