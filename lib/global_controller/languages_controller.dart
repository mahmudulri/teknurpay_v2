import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguagesController extends GetxController {
  final GetStorage box = GetStorage();

  RxString selectedlan = "En".obs;

  RxMap<String, String> currentlanguage = <String, String>{}.obs;

  final List<Map<String, String>> alllanguagedata = [
    {
      "name": "En",
      "fullname": "English",
      "isoCode": "en",
      "region": "US",
      "direction": "ltr",
    },
    {
      "name": "Fa",
      "fullname": "فارسی",
      "isoCode": "fa",
      "region": "IR",
      "direction": "rtl",
    },
    {
      "name": "Ar",
      "fullname": "العربية",
      "isoCode": "ar",
      "region": "AE",
      "direction": "rtl",
    },
    {
      "name": "Tr",
      "fullname": "Türkçe",
      "isoCode": "tr",
      "region": "TR",
      "direction": "ltr",
    },
    {
      "name": "Ps",
      "fullname": "پښتو",
      "isoCode": "ps",
      "region": "AF",
      "direction": "rtl",
    },
    {
      "name": "Bn",
      "fullname": "বাংলা",
      "isoCode": "bn",
      "region": "BD",
      "direction": "ltr",
    },
  ];

  @override
  void onInit() {
    super.onInit();

    // Read saved language without overwriting storage.
    final savedLanguage = getSavedLanguage();

    selectedlan.value = savedLanguage["name"] ?? "En";

    debugPrint("🌐 Initial saved language: ${selectedlan.value}");
  }

  /// Find the previously selected language.
  Map<String, String> getSavedLanguage() {
    final String savedIso = (box.read("language_iso") ?? "")
        .toString()
        .trim()
        .toLowerCase();

    final String savedName = (box.read("language") ?? "").toString().trim();

    // Prefer saved ISO code.
    if (savedIso.isNotEmpty) {
      for (final lang in alllanguagedata) {
        if (lang["isoCode"] == savedIso) {
          return lang;
        }
      }
    }

    // Support old saved language format.
    if (savedName.isNotEmpty) {
      for (final lang in alllanguagedata) {
        if (lang["name"]?.toLowerCase() == savedName.toLowerCase()) {
          return lang;
        }
      }
    }

    // Default only for a new installation.
    return alllanguagedata.first;
  }

  /// Load translation JSON using locale.
  Future<void> loadLanguageByLocale(String isoCode, String regionCode) async {
    final String localeKey = "$isoCode-$regionCode";

    try {
      debugPrint("📂 Loading JSON: assets/langs/$localeKey.json");

      final String jsonString = await rootBundle.loadString(
        "assets/langs/$localeKey.json",
      );

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final Map<String, String> translations = jsonData.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      // Replace only after successful loading.
      currentlanguage.assignAll(translations);

      debugPrint("✅ Language JSON loaded: $localeKey");
    } catch (e) {
      debugPrint("❌ Error loading language JSON: $e");
    }
  }

  /// Change and permanently save selected language.
  Future<void> changeLanguage(String languageShortName) async {
    debugPrint("🔄 Changing language to: $languageShortName");

    final matchedLang = alllanguagedata.firstWhere(
      (lang) => lang["name"] == languageShortName,
      orElse: () => alllanguagedata.first,
    );

    final String name = matchedLang["name"] ?? "En";
    final String iso = matchedLang["isoCode"] ?? "en";
    final String region = matchedLang["region"] ?? "US";
    final String direction = matchedLang["direction"] ?? "ltr";

    // Save all language information.
    await box.write("language", name);
    await box.write("language_iso", iso);
    await box.write("direction", direction);

    // Update current selected language.
    selectedlan.value = name;

    // Load translation JSON.
    await loadLanguageByLocale(iso, region);

    debugPrint("✅ Language saved permanently");
    debugPrint("Language: $name");
    debugPrint("ISO: $iso");
    debugPrint("Direction: $direction");
  }

  /// Restore previously selected language.
  Future<Map<String, String>> restoreSavedLanguage() async {
    final savedLanguage = getSavedLanguage();

    await changeLanguage(savedLanguage["name"] ?? "En");

    return savedLanguage;
  }

  /// Translate a key.
  String tr(String key) {
    return currentlanguage[key] ?? key;
  }
}
