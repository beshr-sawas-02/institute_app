// lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_text_styles.dart';
import 'constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final primary    = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final bg         = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final surface    = isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFFFF);
    final surface2   = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final textColor  = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
    final textMuted  = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol  = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final errorCol   = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
    final secondaryC = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);
    final accentC    = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

    // ══ AppBar ══
    // فاتح: أزرق primary
    // داكن: surface داكن عشان يتناسق مع باقي الشاشة
    final appBarBg = isDark ? const Color(0xFF0F172A) : const Color(0xFF2563EB);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Cairo',

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primary.withOpacity(0.15),
        onPrimaryContainer: primary,
        secondary: secondaryC,
        onSecondary: Colors.white,
        secondaryContainer: secondaryC.withOpacity(0.15),
        onSecondaryContainer: secondaryC,
        tertiary: accentC,
        onTertiary: Colors.white,
        error: errorCol,
        onError: Colors.white,
        surface: surface,
        onSurface: textColor,
        surfaceContainerHighest: surface2,
        onSurfaceVariant: textMuted,
        outline: borderCol,
        shadow: const Color(0x14000000),
      ),

      scaffoldBackgroundColor: bg,

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
         // statusBarBrightness: isDark ? Brightness.dark : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          side: BorderSide(color: borderCol, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingSmall),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
          textStyle: AppTextStyles.buttonLarge,
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingLarge,
              vertical: AppConstants.paddingMedium),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium)),
          textStyle: AppTextStyles.buttonLarge.copyWith(color: primary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingMedium),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide(color: borderCol, width: 1)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide(color: borderCol, width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide(color: primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide(color: errorCol, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            borderSide: BorderSide(color: errorCol, width: 1.5)),
        hintStyle: AppTextStyles.inputHint.copyWith(color: textMuted),
        labelStyle: AppTextStyles.inputLabel.copyWith(color: textMuted),
        errorStyle: AppTextStyles.inputError,
        prefixIconColor: textMuted,
        suffixIconColor: textMuted,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 10, fontWeight: FontWeight.w400),
      ),

      dividerTheme: DividerThemeData(
          color: borderCol.withOpacity(0.5), thickness: 0.5, space: 1),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge)),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(color: textColor),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: textMuted),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
        contentTextStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall)),
        behavior: SnackBarBehavior.floating,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? Colors.white : textMuted),
        trackColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? primary : borderCol),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.selected) ? primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: borderCol, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: primary.withOpacity(0.15),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: textColor),
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSmall,
            vertical: AppConstants.paddingXSmall),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall)),
        side: BorderSide(color: borderCol, width: 0.5),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: AppConstants.paddingXSmall),
        titleTextStyle: AppTextStyles.titleSmall.copyWith(color: textColor),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(color: textMuted),
        iconColor: primary,
        tileColor: surface,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withOpacity(0.15),
        circularTrackColor: primary.withOpacity(0.15),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: Colors.white,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white, width: 2)),
      ),

      // ── PopupMenu ──
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),

      // ── BottomSheet ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}