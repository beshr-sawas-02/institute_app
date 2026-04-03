// lib/widgets/language_switch.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/locale_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// زر تبديل اللغة — يظهر في صفحة الملف الشخصي
class LanguageSwitchTile extends StatelessWidget {
  const LanguageSwitchTile({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();

    return Obx(() {
      final isAr = localeCtrl.isArabic;

      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.translate_rounded,
            color: AppColors.primary, size: 22),
        title: Text('language'.tr,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.text)),
        trailing: _LanguageToggle(
          isArabic: isAr,
          onToggle: () => localeCtrl.toggleLocale(),
        ),
      );
    });
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onToggle;

  const _LanguageToggle({
    required this.isArabic,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // نثبّت الاتجاه LTR دائماً للـ toggle عشان ما ينعكس بالـ RTL
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          width: 130,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // المؤشر المتحرك — يستخدم AnimatedAlign بدل AnimatedPositioned
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                // عربي = يسار (المؤشر على "عربي")
                // EN = يمين (المؤشر على "EN")
                alignment: isArabic
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: 65,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // النصوص — ثابتة المكان: "عربي" يسار، "EN" يمين
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'عربي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight:
                          isArabic ? FontWeight.w700 : FontWeight.w500,
                          color: isArabic ? Colors.white : AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'EN',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight:
                          !isArabic ? FontWeight.w700 : FontWeight.w500,
                          color: !isArabic ? Colors.white : AppColors.grey500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// نسخة مصغرة لشريط التطبيق — أيقونة فقط
class LanguageSwitchIcon extends StatelessWidget {
  const LanguageSwitchIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();

    return Obx(() {
      final isAr = localeCtrl.isArabic;
      return GestureDetector(
        onTap: () => localeCtrl.toggleLocale(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.translate_rounded,
                  color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                isAr ? 'EN' : 'عربي',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}