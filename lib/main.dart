// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'bindings/app_bindings.dart';
import 'controllers/locale_controller.dart';
import 'routes/app_pages.dart';
import 'translations/app_translations.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // نقرأ اللغة المحفوظة قبل runApp
  final savedLocale = await LocaleController.getSavedLocale();

  Get.put<LocaleController>(LocaleController(), permanent: true);

  runApp(InstituteApp(initialLocale: savedLocale));
}

class InstituteApp extends StatelessWidget {
  final Locale initialLocale;
  const InstituteApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'نظام إدارة المعهد',
      debugShowCheckedModeBanner: false,

      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('ar', 'SA'),

      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),

      builder: (context, child) {
        return Obx(() {
          final localeCtrl = Get.find<LocaleController>();
          return Directionality(
            textDirection: localeCtrl.textDirection,
            child: child!,
          );
        });
      },
    );
  }
}



