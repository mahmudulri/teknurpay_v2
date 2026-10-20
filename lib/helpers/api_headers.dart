import 'package:get_storage/get_storage.dart';

class ApiHeaders {
  static final GetStorage _box = GetStorage();

  /// ============================================================
  /// AUTHENTICATED HEADERS
  /// ============================================================

  static Map<String, String> authenticated() {
    final String token = _box.read("userToken") ?? "";

    final String languageIso = _box.read("language_iso") ?? "en";

    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Accept-Language': languageIso,
    };
  }

  /// ============================================================
  /// PUBLIC HEADERS
  /// ============================================================

  static Map<String, String> public() {
    final String languageIso = _box.read("language_iso") ?? "en";

    return {'Accept': 'application/json', 'Accept-Language': languageIso};
  }

  /// ============================================================
  /// CURRENT LANGUAGE ISO
  /// ============================================================

  static String get languageIso {
    return _box.read("language_iso") ?? "en";
  }
}
