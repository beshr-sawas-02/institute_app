// lib/utils/helpers.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'constants.dart';

class Helpers {
  Helpers._();

  // ==================== التاريخ والوقت ====================

  static String get _localeLang {
    try {
      return Get.locale?.languageCode ?? 'ar';
    } catch (_) {
      return 'ar';
    }
  }

  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '—';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy/MM/dd', _localeLang).format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String formatDateArabic(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '—';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMMM yyyy', _localeLang).format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String formatDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '—';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy/MM/dd - hh:mm a', _localeLang).format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '—';
    try {
      if (timeString.contains('T')) {
        final dt = DateTime.parse(timeString);
        return DateFormat('hh:mm a', _localeLang).format(dt);
      }
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final dt = DateTime(2000, 1, 1, hour, minute);
        return DateFormat('hh:mm a', _localeLang).format(dt);
      }
      return timeString;
    } catch (_) {
      return timeString;
    }
  }

  static String toApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String todayApiDate() => toApiDate(DateTime.now());

  static String formatRelativeDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '—';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) return 'today'.tr;
      if (diff.inDays == 1) return 'yesterday'.tr;
      if (diff.inDays < 7) return 'days_ago'.tr.replaceAll('@count', '${diff.inDays}');
      return formatDate(dateString);
    } catch (_) {
      return dateString ?? '—';
    }
  }

  // ==================== الأرقام والمبالغ ====================

  static String formatCurrency(dynamic amount, {String? currency}) {
    final cur = currency ?? 'currency'.tr;
    if (amount == null) return '0 $cur';
    final num = double.tryParse(amount.toString()) ?? 0;
    final formatter = NumberFormat('#,##0.##', _localeLang);
    return '${formatter.format(num)} $cur';
  }

  static String formatNumber(dynamic number) {
    if (number == null) return '0';
    final num = double.tryParse(number.toString()) ?? 0;
    final formatter = NumberFormat('#,##0.##', _localeLang);
    return formatter.format(num);
  }

  static String formatPercentage(dynamic value, {int decimals = 1}) {
    if (value == null) return '0%';
    final num = double.tryParse(value.toString()) ?? 0;
    return '${num.toStringAsFixed(decimals)}%';
  }

  // ==================== Snackbars ====================

  static void showSuccess(String message, {String? title}) {
    Get.snackbar(
      title ?? 'success'.tr,
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      icon: const Icon(Icons.check_circle_outline, color: AppColors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      borderRadius: AppConstants.radiusMedium,
      duration: const Duration(seconds: 3),
      animationDuration: AppConstants.shortAnimation,
    );
  }

  static void showError(String message, {String? title}) {
    Get.snackbar(
      title ?? 'error'.tr,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      icon: const Icon(Icons.error_outline, color: AppColors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      borderRadius: AppConstants.radiusMedium,
      duration: const Duration(seconds: 4),
      animationDuration: AppConstants.shortAnimation,
    );
  }

  static void showWarning(String message, {String? title}) {
    Get.snackbar(
      title ?? 'warning'.tr,
      message,
      backgroundColor: AppColors.warning,
      colorText: AppColors.white,
      icon: const Icon(Icons.warning_amber_outlined, color: AppColors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      borderRadius: AppConstants.radiusMedium,
      duration: const Duration(seconds: 3),
      animationDuration: AppConstants.shortAnimation,
    );
  }

  static void showInfo(String message, {String? title}) {
    Get.snackbar(
      title ?? 'info'.tr,
      message,
      backgroundColor: AppColors.info,
      colorText: AppColors.white,
      icon: const Icon(Icons.info_outline, color: AppColors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      borderRadius: AppConstants.radiusMedium,
      duration: const Duration(seconds: 3),
      animationDuration: AppConstants.shortAnimation,
    );
  }

  // ==================== Dialogs ====================

  static Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDanger = false,
  }) async {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title, style: AppTextStyles.headlineSmall),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText ?? 'cancel'.tr,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.grey600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? AppColors.error : AppColors.primary,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingSmall,
              ),
            ),
            child: Text(confirmText ?? 'confirm'.tr, style: AppTextStyles.buttonMedium),
          ),
        ],
      ),
    );
  }

  // ==================== حساب نسبة الحضور ====================

  static double calcAttendanceRate(int present, int late, int total) {
    if (total == 0) return 0;
    return ((present + late) / total) * 100;
  }

  // ==================== حساب الدرجة النصية ====================

  static String calcGrade(double percentage) {
    if (percentage >= 90) return 'grade_excellent'.tr;
    if (percentage >= 80) return 'grade_very_good'.tr;
    if (percentage >= 70) return 'grade_good'.tr;
    if (percentage >= 60) return 'grade_acceptable'.tr;
    if (percentage >= 50) return 'grade_weak'.tr;
    return 'grade_fail'.tr;
  }

  // ==================== String Helpers ====================

  static String getInitials(String firstName, String lastName) {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l';
  }

  static String fullName(String? firstName, String? lastName) {
    final f = firstName ?? '';
    final l = lastName ?? '';
    return '$f $l'.trim();
  }

  // ==================== Error Parsing ====================

  static String parseApiError(dynamic error) {
    if (error == null) return 'unknown_error'.tr;
    if (error is String) return error;
    try {
      if (error is Map) {
        final msg = error['message'];
        if (msg is String) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
      }
    } catch (_) {}
    return 'unknown_error'.tr;
  }
}