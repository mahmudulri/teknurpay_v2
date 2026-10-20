import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../helpers/api_headers.dart';
import '../models/hawala_list_model.dart';
import '../utils/api_endpoints.dart';

class HawalalistApi {
  final box = GetStorage();
  Future<HawalaModel> fetchhawala(int pageNo) async {
    final url = Uri.parse(
      ApiEndPoints.baseUrl +
          ApiEndPoints.otherendpoints.hawalalist +
          "?page=$pageNo",
    );
    // print("hawala $url");

    final response = await http.get(url, headers: ApiHeaders.authenticated());

    if (response.statusCode == 200) {
      print(response.statusCode.toString());

      final hawalamodel = HawalaModel.fromJson(json.decode(response.body));

      return hawalamodel;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
