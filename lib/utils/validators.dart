// lib/utils/validators.dart

import 'package:get/get.dart';

class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_email_required'.tr;
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'validation_email_invalid'.tr;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation_password_required'.tr;
    }
    if (value.length < 6) {
      return 'validation_password_min'.tr;
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'validation_confirm_required'.tr;
      }
      if (value != original) {
        return 'validation_confirm_mismatch'.tr;
      }
      return null;
    };
  }

  static String? required(String? value, {String fieldName = ''}) {
    if (value == null || value.trim().isEmpty) {
      if (fieldName.isNotEmpty) {
        return 'validation_required'.tr.replaceAll('@field', fieldName);
      }
      return 'required_field'.tr;
    }
    return null;
  }

  static String? name(String? value, {String fieldName = ''}) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_required'.tr.replaceAll('@field', fieldName);
    }
    if (value.trim().length < 2) {
      return 'validation_name_min'.tr.replaceAll('@field', fieldName);
    }
    if (value.trim().length > 50) {
      return 'validation_name_max'.tr.replaceAll('@field', fieldName);
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_phone_required'.tr;
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'validation_phone_invalid'.tr;
    }
    return null;
  }

  static String? optionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return phone(value);
  }

  static String? number(String? value, {String fieldName = ''}) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_number_required'.tr.replaceAll('@field', fieldName);
    }
    if (double.tryParse(value) == null) {
      return 'validation_number_invalid'.tr.replaceAll('@field', fieldName);
    }
    return null;
  }

  static String? positiveNumber(String? value, {String fieldName = ''}) {
    final numError = number(value, fieldName: fieldName);
    if (numError != null) return numError;
    final num = double.parse(value!);
    if (num <= 0) {
      return 'validation_positive'.tr.replaceAll('@field', fieldName);
    }
    return null;
  }

  static String? Function(String?) numberRange(double min, double max, {String fieldName = ''}) {
    return (String? value) {
      final numError = number(value, fieldName: fieldName);
      if (numError != null) return numError;
      final num = double.parse(value!);
      if (num < min || num > max) {
        return 'validation_range'.tr
            .replaceAll('@field', fieldName)
            .replaceAll('@min', '$min')
            .replaceAll('@max', '$max');
      }
      return null;
    };
  }

  static String? Function(String?) score(double maxScore) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'validation_score_required'.tr;
      }
      final score = double.tryParse(value);
      if (score == null) {
        return 'validation_score_invalid'.tr;
      }
      if (score < 0) {
        return 'validation_score_min'.tr;
      }
      if (score > maxScore) {
        return 'validation_score_max'.tr.replaceAll('@max', '$maxScore');
      }
      return null;
    };
  }

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_date_required'.tr;
    }
    return null;
  }

  static String? time(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'validation_time_required'.tr;
    }
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):([0-5][0-9])$');
    if (!timeRegex.hasMatch(value)) {
      return 'validation_time_invalid'.tr;
    }
    return null;
  }

  static String? Function(String?) maxLength(int max, {String fieldName = ''}) {
    return (String? value) {
      if (value != null && value.length > max) {
        return 'validation_max_length'.tr
            .replaceAll('@field', fieldName)
            .replaceAll('@max', '$max');
      }
      return null;
    };
  }

  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  static String? confirmPasswordDirect(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'validation_confirm_required'.tr;
    }
    if (value != original) {
      return 'validation_confirm_mismatch'.tr;
    }
    return null;
  }
}