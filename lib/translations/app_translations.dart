// lib/translations/app_translations.dart

import 'package:get/get.dart';
import 'ar.dart';
import 'en.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar_SA': ar,
    'en_US': en,
  };
}