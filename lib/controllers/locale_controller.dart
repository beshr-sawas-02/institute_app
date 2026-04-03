// lib/controllers/locale_controller.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends GetxController {
  static const String _storageKey = 'app_locale';

  final currentLocale = const Locale('ar', 'SA').obs;

  bool get isArabic => currentLocale.value.languageCode == 'ar';
  bool get isEnglish => currentLocale.value.languageCode == 'en';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// يُستدعى من main() قبل runApp
  /// يقرأ اللغة المحفوظة ويرجعها — أو العربية كافتراضي
  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved == 'en') return const Locale('en', 'US');
    return const Locale('ar', 'SA');
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final locale = await getSavedLocale();
    currentLocale.value = locale;
  }

  Future<void> changeLocale(Locale locale) async {
    currentLocale.value = locale;
    Get.updateLocale(locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);
  }

  Future<void> toggleLocale() async {
    if (isArabic) {
      await changeLocale(const Locale('en', 'US'));
    } else {
      await changeLocale(const Locale('ar', 'SA'));
    }
  }
}