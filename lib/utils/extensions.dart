// lib/utils/extensions.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';
import 'constants.dart';

// ==================== String Extensions ====================

extension StringExtension on String {
  /// تحويل التاريخ من String إلى DateTime
  DateTime? toDateTime() {
    try {
      return DateTime.parse(this);
    } catch (_) {
      return null;
    }
  }

  /// تنسيق التاريخ
  String toFormattedDate() {
    try {
      final date = DateTime.parse(this);
      return DateFormat('yyyy/MM/dd').format(date);
    } catch (_) {
      return this;
    }
  }

  /// التحقق من أن النص بريد إلكتروني
  bool get isEmail {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(trim());
  }

  /// التحقق من أن النص رقم
  bool get isNumeric => double.tryParse(this) != null;

  /// التحويل الآمن إلى double
  double toDoubleOrZero() => double.tryParse(this) ?? 0.0;

  /// التحويل الآمن إلى int
  int toIntOrZero() => int.tryParse(this) ?? 0;

  /// اقتطاع النص مع إضافة ...
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// الحرف الأول كبير
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

// ==================== Nullable String Extensions ====================

extension NullableStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  String get orEmpty => this ?? '';
  String orDefault(String defaultValue) => isNullOrEmpty ? defaultValue : this!;
}

// ==================== DateTime Extensions ====================

extension DateTimeExtension on DateTime {
  String toApiFormat() => DateFormat('yyyy-MM-dd').format(this);
  String toDisplayFormat() => DateFormat('yyyy/MM/dd').format(this);
  String toDisplayArabic() => DateFormat('d MMMM yyyy', 'ar').format(this);
  String toTimeFormat() => DateFormat('hh:mm a').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  String get relativeLabel {
    if (isToday) return 'اليوم';
    if (isYesterday) return 'أمس';
    final diff = DateTime.now().difference(this).inDays;
    if (diff < 7) return 'منذ $diff أيام';
    return toDisplayFormat();
  }
}

// ==================== double Extensions ====================

extension DoubleExtension on double {
  String get formatted {
    final formatter = NumberFormat('#,##0.##');
    return formatter.format(this);
  }

  String toPercentage({int decimals = 1}) => '${toStringAsFixed(decimals)}%';

  String toCurrency({String symbol = 'ل.س'}) {
    final formatter = NumberFormat('#,##0.##');
    return '${formatter.format(this)} $symbol';
  }
}

// ==================== int Extensions ====================

extension IntExtension on int {
  String get formatted {
    final formatter = NumberFormat('#,##0');
    return formatter.format(this);
  }
}

// ==================== List Extensions ====================

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}

// ==================== BuildContext Extensions ====================

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isSmallScreen => screenWidth < 360;
  bool get isMediumScreen => screenWidth >= 360 && screenWidth < 600;

  void hideKeyboard() => FocusScope.of(this).unfocus();
}

// ==================== Widget Extensions ====================

extension WidgetExtension on Widget {
  Widget paddingAll(double value) => Padding(
    padding: EdgeInsets.all(value),
    child: this,
  );

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
    child: this,
  );

  Widget withCard({double? borderRadius, Color? color, EdgeInsets? padding}) => Container(
    decoration: BoxDecoration(
      color: color ?? AppColors.white,
      borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.radiusLarge),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    padding: padding ?? const EdgeInsets.all(AppConstants.paddingMedium),
    child: this,
  );

  Widget centered() => Center(child: this);

  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);
}