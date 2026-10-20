import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:teknurpay/models/service_category_model.dart';

import '../helpers/api_headers.dart';
import '../utils/api_endpoints.dart';

class CategoriesListApi {
  final box = GetStorage();
  Future<CategoriesModel> fetchcategoriesList() async {
    final url = Uri.parse(
      ApiEndPoints.baseUrl + ApiEndPoints.otherendpoints.servicecategories,
    );
    final response = await http.get(url, headers: ApiHeaders.authenticated());

    if (response.statusCode == 200) {
      // print(response.body.toString());
      final categorieslistModel = CategoriesModel.fromJson(
        json.decode(response.body),
      );

      return categorieslistModel;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
