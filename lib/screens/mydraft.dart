import 'package:get/get.dart';

class BranchlistController extends GetxController {
  List branchlist = [
    {"id": "5", "name": "Dhaka"},
    {"id": "6", "name": "Khulna"},
    {"id": "7", "name": "Kustia"},
  ];
}

class HaawalaListController extends GetxController {
  List branchlist = [
    {"id": "1", "name": "rasel", "branch_id": "5"},
    {"id": "2", "name": "kader", "branch_id": "6"},
    {"id": "3", "name": "shuvo", "branch_id": "7"},
  ];
}
