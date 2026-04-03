// lib/utils/app_colors.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  AppColors._();

  // ══════════════════════════════════════════════
  //  Raw palette — Light
  // ══════════════════════════════════════════════
  static const Color _pL  = Color(0xFF2563EB);
  static const Color _bgL = Color(0xFFF8FAFC);
  static const Color _sfL = Color(0xFFFFFFFF);
  static const Color _s2L = Color(0xFFF1F5F9);
  static const Color _txL = Color(0xFF0F172A);
  static const Color _muL = Color(0xFF64748B);
  static const Color _seL = Color(0xFF0D9488);
  static const Color _acL = Color(0xFFD97706);
  static const Color _suL = Color(0xFF16A34A);
  static const Color _daL = Color(0xFFDC2626);
  static const Color _boL = Color(0xFFCBD5E1);

  // ══════════════════════════════════════════════
  //  Raw palette — Dark
  // ══════════════════════════════════════════════
  static const Color _pD  = Color(0xFF60A5FA);
  static const Color _bgD = Color(0xFF020617);
  static const Color _sfD = Color(0xFF0F172A);
  static const Color _s2D = Color(0xFF1E293B);
  static const Color _txD = Color(0xFFE2E8F0);
  static const Color _muD = Color(0xFF94A3B8);
  static const Color _seD = Color(0xFF2DD4BF);
  static const Color _acD = Color(0xFFFBBF24);
  static const Color _suD = Color(0xFF4ADE80);
  static const Color _daD = Color(0xFFF87171);
  static const Color _boD = Color(0xFF334155);

  // ══════════════════════════════════════════════
  //  Helper
  // ══════════════════════════════════════════════
  static bool get _dark {
    try { return Get.isDarkMode; } catch (_) { return false; }
  }
  static Color _c(Color l, Color d) => _dark ? d : l;

  // ══════════════════════════════════════════════
  //  Dynamic getters
  // ══════════════════════════════════════════════
  static Color get primary      => _c(_pL,  _pD);
  static Color get background   => _c(_bgL, _bgD);
  static Color get surface      => _c(_sfL, _sfD);
  static Color get surface2     => _c(_s2L, _s2D);
  static Color get textPrimary  => _c(_txL, _txD);
  static Color get text         => _c(_txL, _txD);
  static Color get textSecondary=> _c(_muL, _muD);
  static Color get textMuted    => _c(_muL, _muD);
  static Color get textHint     => _dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color get secondary    => _c(_seL, _seD);
  static Color get accent       => _c(_acL, _acD);
  static Color get warning      => _c(_acL, _acD);
  static Color get success      => _c(_suL, _suD);
  static Color get error        => _c(_daL, _daD);
  static Color get border       => _c(_boL, _boD);
  static Color get divider      => _c(_boL.withOpacity(0.5), _boD.withOpacity(0.5));
  static Color get shadow       => _dark ? const Color(0x33000000) : const Color(0x14000000);
  static Color get info         => secondary;

  static Color get successLight   => _c(const Color(0xFFF0FDF4), const Color(0xFF052E16));
  static Color get warningLight   => _c(const Color(0xFFFFFBEB), const Color(0xFF1C1200));
  static Color get errorLight     => _c(const Color(0xFFFEF2F2), const Color(0xFF2D0707));
  static Color get infoLight      => _c(const Color(0xFFF0FDFA), const Color(0xFF021A17));
  static Color get primarySurface => _c(const Color(0xFFEFF6FF), const Color(0xFF0C1A3D));
  static Color get primaryLight   => _c(const Color(0xFF3B82F6), const Color(0xFF93C5FD));
  static Color get primaryDark    => _c(const Color(0xFF1D4ED8), const Color(0xFF2563EB));

  static Color get cardBackground  => surface;
  static Color get successSurface  => successLight;
  static Color get warningSurface  => warningLight;
  static Color get errorSurface    => errorLight;
  static Color get infoSurface     => infoLight;

  // ══════════════════════════════════════════════
  //  Greys — ثابتة
  // ══════════════════════════════════════════════
  static const Color white   = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // ══════════════════════════════════════════════
  //  Status — ثابتة
  // ══════════════════════════════════════════════
  static const Color present = _suL;
  static const Color absent  = _daL;
  static const Color late    = _acL;
  static const Color excused = _seL;
  static const Color paid    = _suL;
  static const Color pending = _acL;
  static const Color partial = _seL;

  static const Color gradeExcellent  = Color(0xFF15803D);
  static const Color gradeVeryGood   = Color(0xFF16A34A);
  static const Color gradeGood       = Color(0xFF0D9488);
  static const Color gradeAcceptable = Color(0xFFD97706);
  static const Color gradeWeak       = Color(0xFFEA580C);
  static const Color gradeFail       = Color(0xFFDC2626);

  // ══════════════════════════════════════════════
  //  Helpers
  // ══════════════════════════════════════════════
  static Color getAttendanceColor(String status) {
    switch (status) {
      case 'present': return present;
      case 'absent':  return absent;
      case 'late':    return late;
      case 'excused': return excused;
      default:        return grey500;
    }
  }

  static Color attendanceColor(String status) => getAttendanceColor(status);

  static Color getAttendanceBgColor(String status) {
    switch (status) {
      case 'present': return successLight;
      case 'absent':  return errorLight;
      case 'late':    return warningLight;
      case 'excused': return infoLight;
      default:        return grey100;
    }
  }

  static Color getGradeColor(String? grade) {
    switch (grade) {
      case 'ممتاز':    return gradeExcellent;
      case 'جيد جداً': return gradeVeryGood;
      case 'جيد':     return gradeGood;
      case 'مقبول':   return gradeAcceptable;
      case 'ضعيف':    return gradeWeak;
      case 'راسب':    return gradeFail;
      default:        return grey500;
    }
  }

  static Color getPaymentColor(String status) {
    switch (status) {
      case 'paid':    return paid;
      case 'pending': return pending;
      case 'partial': return partial;
      default:        return grey500;
    }
  }
}