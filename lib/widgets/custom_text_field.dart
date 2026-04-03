import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? initialValue;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    // ── نقرأ الثيم من context مباشرة ──────────────────────────────────
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // لون الخلفية: يتغير تلقائياً مع الثيم
    final fillColor = enabled
        ? scheme.surfaceContainerHighest
        : scheme.surfaceContainerHighest.withOpacity(0.5);

    // لون النص: يتغير تلقائياً
    final textColor = scheme.onSurface;

    // لون الـ hint: أفتح من النص
    final hintColor = scheme.onSurface.withOpacity(0.45);

    // لون الـ border
    final borderColor = isDark
        ? AppColors.grey700
        : AppColors.grey300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.inputLabel.copyWith(
            color: scheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          onTap: onTap,
          onChanged: onChanged,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          textDirection: TextDirection.rtl,
          // ── لون النص يتبع الثيم ────────────────────────────────────
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textColor,
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: hintColor,
              height: 1.5,
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            // ── fillColor يتبع الثيم ───────────────────────────────
            filled: true,
            fillColor: fillColor,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: 14,
            ),
            // ── Borders تتبع الثيم ────────────────────────────────
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppConstants.radiusMedium),
              borderSide: BorderSide(
                  color: borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppConstants.radiusMedium),
              borderSide: BorderSide(
                  color: borderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppConstants.radiusMedium),
              borderSide: BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppConstants.radiusMedium),
              borderSide: BorderSide(
                  color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppConstants.radiusMedium),
              borderSide: BorderSide(
                  color: AppColors.error, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                  AppConstants.radiusMedium),
              borderSide: BorderSide(
                  color: borderColor.withOpacity(0.5),
                  width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== Search Field ====================

class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.controller,
    this.hint = 'بحث...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? AppColors.grey700
        : AppColors.grey300;

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: scheme.onSurface,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          color: scheme.onSurface.withOpacity(0.45),
          height: 1.5,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: scheme.onSurface.withOpacity(0.5),
          size: 22,
        ),
        suffixIcon: controller?.text.isNotEmpty == true
            ? IconButton(
          icon: Icon(
            Icons.close,
            color: scheme.onSurface.withOpacity(0.5),
            size: 20,
          ),
          onPressed: () {
            controller?.clear();
            onClear?.call();
            onChanged?.call('');
          },
        )
            : null,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
            vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              AppConstants.radiusLarge),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              AppConstants.radiusLarge),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
              AppConstants.radiusLarge),
          borderSide: BorderSide(
              color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}