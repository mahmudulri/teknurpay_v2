import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:teknurpay/models/bundle_model.dart';
import '../helpers/api_headers.dart';
import '../utils/api_endpoints.dart';

class BundlesApi {
  final GetStorage box = GetStorage();

  Map<String, String> _filters(int pageNo) => {
    'page': pageNo.toString(),
    'per_page': '15',
    'country_id': box.read('country_id')?.toString() ?? '',
    'validity_type': box.read('validity_type')?.toString() ?? '',
    'service_category_id': box.read('service_category_id')?.toString() ?? '',
    'search_tag': box.read('search_tag')?.toString() ?? '',
  };

  Future<BundleModel> _fetch(Map<String, String> parameters) async {
    final url = Uri.parse(
      '${ApiEndPoints.baseUrl}bundles',
    ).replace(queryParameters: parameters);

    // print(url);
    final response = await http.get(url, headers: ApiHeaders.authenticated());
    if (response.statusCode == 200) {
      return BundleModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to fetch bundles: ${response.statusCode}');
  }

  Future<BundleModel> fetchBundles(int pageNo) {
    return _fetch({
      ..._filters(pageNo),
      'company_id': box.read('company_id')?.toString() ?? '',
    });
  }

  Future<BundleModel> fetchlookupBundles(String phoneNumber, {int pageNo = 1}) {
    final number = phoneNumber.trim().replaceAll(RegExp(r'[\s()\-]'), '');
    if (number.isEmpty) {
      throw Exception('Phone number is required for operator lookup.');
    }
    // Let the lookup resolve the current operator, including ported numbers.
    // A manually selected company_id must not override this resolution.
    return _fetch({..._filters(pageNo), 'rechargeable_account': number});
  }
}
