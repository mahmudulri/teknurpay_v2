import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:teknurpay/models/province_model.dart';
import '../utils/api_endpoints.dart';

class ProvinceApi {
  final box = GetStorage();
  Future<ProvincesModel> fetchProvince() async {
    final url = Uri.parse(
      ApiEndPoints.baseUrl + ApiEndPoints.otherendpoints.province,
    );

    var response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${box.read("userToken")}'},
    );

    if (response.statusCode == 200) {
      // print(response.body.toString());
      final provinceModel = ProvincesModel.fromJson(json.decode(response.body));

      return provinceModel;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
