// lib/utils/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _f = 'Cairo';

  // --- Display ---
  static TextStyle get displayLarge  => TextStyle(fontFamily: _f, fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4);
  static TextStyle get displayMedium => TextStyle(fontFamily: _f, fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4);

  // --- Headlines ---
  static TextStyle get headlineLarge  => TextStyle(fontFamily: _f, fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.4);
  static TextStyle get headlineMedium => TextStyle(fontFamily: _f, fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4);
  static TextStyle get headlineSmall  => TextStyle(fontFamily: _f, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4);

  // --- Title ---
  static TextStyle get titleLarge  => TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.5);
  static TextStyle get titleMedium => TextStyle(fontFamily: _f, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.5);
  static TextStyle get titleSmall  => TextStyle(fontFamily: _f, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.5);

  // --- Body ---
  static TextStyle get bodyLarge   => TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,   height: 1.6);
  static TextStyle get bodyMedium  => TextStyle(fontFamily: _f, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,   height: 1.6);
  static TextStyle get bodySmall   => TextStyle(fontFamily: _f, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.6);

  // --- Label ---
  static TextStyle get labelLarge  => TextStyle(fontFamily: _f, fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary,   height: 1.4);
  static TextStyle get labelMedium => TextStyle(fontFamily: _f, fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4);
  static TextStyle get labelSmall  => TextStyle(fontFamily: _f, fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4);

  // --- Caption ---
  static TextStyle get caption => TextStyle(fontFamily: _f, fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textHint, height: 1.4);

  // --- Button ---
  static const TextStyle buttonLarge  = TextStyle(fontFamily: _f, fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4, letterSpacing: 0.5);
  static const TextStyle buttonMedium = TextStyle(fontFamily: _f, fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4);

  // --- Form ---
  static TextStyle get inputText  => TextStyle(fontFamily: _f, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,   height: 1.5);
  static TextStyle get inputHint  => TextStyle(fontFamily: _f, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textHint,      height: 1.5);
  static TextStyle get inputLabel => TextStyle(fontFamily: _f, fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.4);
  static TextStyle get inputError => TextStyle(fontFamily: _f, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.error,         height: 1.4);

  // --- Card ---
  static TextStyle get cardTitle    => TextStyle(fontFamily: _f, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary,   height: 1.4);
  static TextStyle get cardSubtitle => TextStyle(fontFamily: _f, fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.4);
  static TextStyle get cardValue    => TextStyle(fontFamily: _f, fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary,       height: 1.2);

  // --- AppBar ---
  static const TextStyle appBarTitle = TextStyle(fontFamily: _f, fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, height: 1.4);

  // --- Badge ---
  static const TextStyle badge = TextStyle(fontFamily: _f, fontSize: 11, fontWeight: FontWeight.w600, height: 1.2);

  // --- Helpers ---
  static TextStyle white(TextStyle style)   => style.copyWith(color: Colors.white);
  static TextStyle primary(TextStyle style) => style.copyWith(color: AppColors.primary);
}