// lib/utils/constants.dart

import 'package:get/get.dart';

class AppConstants {
  AppConstants._();

  // --- تسمية التطبيق ---
  static const String appName = 'نظام إدارة المعهد';
  static const String appVersion = '1.0.0';

  // --- Storage Keys ---
  static const String tokenKey = 'access_token';
  static const String userKey = 'user_data';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String isLoggedInKey = 'is_logged_in';

  // --- Pagination ---
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // --- Timeouts ---
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // --- Animation Durations ---
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // --- Border Radius ---
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusCircle = 100.0;

  // --- Padding / Spacing ---
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // --- Elevation ---
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // --- Icon Sizes ---
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // ==================== دوال ترجمة ديناميكية ====================

  /// ترجمة أيام الأسبوع
  static String getDayName(String dayEnglish) {
    final key = 'day_${dayEnglish.toLowerCase()}';
    return key.tr;
  }

  /// ترجمة حالات الحضور
  static String getAttendanceStatus(String status) {
    return 'status_$status'.tr;
  }

  /// ترجمة أنواع التقييم
  static String getAssessmentType(String type) {
    return 'type_$type'.tr;
  }

  /// ترجمة حالات الدفع
  static String getPaymentStatus(String status) {
    return 'payment_$status'.tr;
  }

  /// ترجمة أدوار المستخدمين
  static String getUserRole(String role) {
    return 'role_$role'.tr;
  }

  /// ترجمة المراحل الدراسية
  static String getGradeLevel(String level) {
    switch (level) {
      case 'اعدادي': return 'level_preparatory'.tr;
      case 'ثانوي': return 'level_secondary'.tr;
      default: return level;
    }
  }

  /// ترجمة فئات المصاريف
  static String getExpenseCategory(String category) {
    return 'expense_$category'.tr;
  }

  /// ترجمة أنواع التقارير
  static String getReportType(String type) {
    return 'report_type_$type'.tr;
  }

  /// ترجمة اسم الشهر
  static String getMonthName(int month) {
    return 'month_$month'.tr;
  }

  // ==================== Maps الثابتة (للتوافق مع الكود القديم) ====================

  static Map<String, String> get daysOfWeek => {
    'Sunday': 'day_sunday'.tr,
    'Monday': 'day_monday'.tr,
    'Tuesday': 'day_tuesday'.tr,
    'Wednesday': 'day_wednesday'.tr,
    'Thursday': 'day_thursday'.tr,
    'Friday': 'day_friday'.tr,
    'Saturday': 'day_saturday'.tr,
  };

  static Map<String, String> get attendanceStatuses => {
    'present': 'status_present'.tr,
    'absent': 'status_absent'.tr,
    'late': 'status_late'.tr,
    'excused': 'status_excused'.tr,
  };

  static Map<String, String> get assessmentTypes => {
    'quiz': 'type_quiz'.tr,
    'exam': 'type_exam'.tr,
    'homework': 'type_homework'.tr,
    'midterm': 'type_midterm'.tr,
    'final': 'type_final'.tr,
  };

  static Map<String, String> get paymentStatuses => {
    'paid': 'payment_paid'.tr,
    'pending': 'payment_pending'.tr,
    'partial': 'payment_partial'.tr,
  };

  static Map<String, String> get gradeLevels => {
    'اعدادي': 'level_preparatory'.tr,
    'ثانوي': 'level_secondary'.tr,
  };

  static Map<String, String> get userRoles => {
    'admin': 'role_admin'.tr,
    'reception': 'role_reception'.tr,
    'teacher': 'role_teacher'.tr,
    'student': 'role_student'.tr,
    'parent': 'role_parent'.tr,
  };

  static Map<String, String> get expenseCategories => {
    'salary': 'expense_salary'.tr,
    'maintenance': 'expense_maintenance'.tr,
    'supplies': 'expense_supplies'.tr,
    'utilities': 'expense_utilities'.tr,
    'other': 'expense_other'.tr,
  };
}