import 'package:get/get.dart';

class FontController extends GetxController {
  final RxString? fontFamily = 'Iranfontregular'.obs;

  void setFont(String? font) {
    fontFamily!.value = font!;
  }

  String? get currentFont => fontFamily!.value;
}
