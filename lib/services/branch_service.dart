import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../helpers/api_headers.dart';
import '../models/branch_model.dart';

import '../utils/api_endpoints.dart';

class BranchApi {
  final box = GetStorage();
  Future<BranchModel> fetchBranch() async {
    final url = Uri.parse(
      ApiEndPoints.baseUrl + ApiEndPoints.otherendpoints.branch,
    );

    final response = await http.get(url, headers: ApiHeaders.authenticated());

    if (response.statusCode == 200) {
      // print(response.body.toString());
      final branchModel = BranchModel.fromJson(json.decode(response.body));

      return branchModel;
    } else {
      throw Exception('Failed to fetch gateway');
    }
  }
}
