// lib/utils/enums.dart

// --- حالات التحميل ---
enum LoadingState { idle, loading, success, error }

// --- حالات الحضور ---
enum AttendanceStatus {
  present,
  absent,
  late,
  excused;

  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'حاضر';
      case AttendanceStatus.absent:
        return 'غائب';
      case AttendanceStatus.late:
        return 'متأخر';
      case AttendanceStatus.excused:
        return 'معذور';
    }
  }

  String get value {
    return name;
  }

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => AttendanceStatus.present,
    );
  }
}

// --- أنواع التقييم ---
enum AssessmentType {
  quiz,
  exam,
  homework,
  midterm,
  final_;

  String get label {
    switch (this) {
      case AssessmentType.quiz:
        return 'اختبار قصير';
      case AssessmentType.exam:
        return 'اختبار';
      case AssessmentType.homework:
        return 'واجب';
      case AssessmentType.midterm:
        return 'مذاكرة';
      case AssessmentType.final_:
        return 'نهائي';
    }
  }

  String get apiValue {
    if (this == AssessmentType.final_) return 'final';
    return name;
  }

  static AssessmentType fromString(String value) {
    if (value == 'final') return AssessmentType.final_;
    return AssessmentType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => AssessmentType.exam,
    );
  }
}

// --- حالات الدفع ---
enum PaymentStatus {
  paid,
  pending,
  partial;

  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.pending:
        return 'معلق';
      case PaymentStatus.partial:
        return 'جزئي';
    }
  }

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

// --- المراحل الدراسية ---
enum GradeLevel {
  preparatory,
  secondary;

  String get label {
    switch (this) {
      case GradeLevel.preparatory:
        return 'إعدادي';
      case GradeLevel.secondary:
        return 'ثانوي';
    }
  }

  String get apiValue {
    switch (this) {
      case GradeLevel.preparatory:
        return 'اعدادي';
      case GradeLevel.secondary:
        return 'ثانوي';
    }
  }

  static GradeLevel fromString(String value) {
    if (value == 'اعدادي') return GradeLevel.preparatory;
    if (value == 'ثانوي') return GradeLevel.secondary;
    return GradeLevel.preparatory;
  }
}

// --- حالات الشعبة ---
enum SectionStatus {
  active,
  inactive;

  String get label {
    switch (this) {
      case SectionStatus.active:
        return 'نشطة';
      case SectionStatus.inactive:
        return 'غير نشطة';
    }
  }
}

// --- حالات الطالب ---
enum StudentStatus {
  active,
  inactive,
  graduated;

  String get label {
    switch (this) {
      case StudentStatus.active:
        return 'نشط';
      case StudentStatus.inactive:
        return 'غير نشط';
      case StudentStatus.graduated:
        return 'متخرج';
    }
  }
}

// --- الجنس ---
enum Gender {
  male,
  female;

  String get label {
    switch (this) {
      case Gender.male:
        return 'ذكر';
      case Gender.female:
        return 'أنثى';
    }
  }

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
          (e) => e.name == value,
      orElse: () => Gender.male,
    );
  }
}

// --- أدوار المستخدمين ---
enum UserRole {
  admin,
  reception,
  teacher,
  student,
  parent;

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'مدير';
      case UserRole.reception:
        return 'استقبال';
      case UserRole.teacher:
        return 'معلم';
      case UserRole.student:
        return 'طالب';
      case UserRole.parent:
        return 'ولي أمر';
    }
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
          (e) => e.name == value,
      orElse: () => UserRole.reception,
    );
  }
}

// --- أيام الأسبوع ---
enum DayOfWeek {
  Sunday,
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday;

  String get label {
    switch (this) {
      case DayOfWeek.Sunday:
        return 'الأحد';
      case DayOfWeek.Monday:
        return 'الاثنين';
      case DayOfWeek.Tuesday:
        return 'الثلاثاء';
      case DayOfWeek.Wednesday:
        return 'الأربعاء';
      case DayOfWeek.Thursday:
        return 'الخميس';
      case DayOfWeek.Friday:
        return 'الجمعة';
      case DayOfWeek.Saturday:
        return 'السبت';
    }
  }
}

// --- أنواع الإشعارات ---
enum NotificationType {
  info,
  warning,
  alert,
  success;

  String get label {
    switch (this) {
      case NotificationType.info:
        return 'معلومة';
      case NotificationType.warning:
        return 'تحذير';
      case NotificationType.alert:
        return 'تنبيه';
      case NotificationType.success:
        return 'نجاح';
    }
  }
}

// --- أنواع التقارير ---
enum ReportType {
  attendance,
  financial,
  performance,
  comparison;

  String get label {
    switch (this) {
      case ReportType.attendance:
        return 'تقرير الحضور';
      case ReportType.financial:
        return 'تقرير مالي';
      case ReportType.performance:
        return 'تقرير الأداء';
      case ReportType.comparison:
        return 'تقرير مقارنة';
    }
  }
}

// --- فئات المصاريف ---
enum ExpenseCategory {
  salary,
  maintenance,
  supplies,
  utilities,
  other;

  String get label {
    switch (this) {
      case ExpenseCategory.salary:
        return 'رواتب';
      case ExpenseCategory.maintenance:
        return 'صيانة';
      case ExpenseCategory.supplies:
        return 'مستلزمات';
      case ExpenseCategory.utilities:
        return 'خدمات';
      case ExpenseCategory.other:
        return 'أخرى';
    }
  }
}

// --- صلة القرابة ---
enum Relationship {
  father,
  mother,
  guardian;

  String get label {
    switch (this) {
      case Relationship.father:
        return 'أب';
      case Relationship.mother:
        return 'أم';
      case Relationship.guardian:
        return 'وصي';
    }
  }
}

// --- حالة المعلم ---
enum TeacherStatus {
  active,
  inactive;

  String get label {
    switch (this) {
      case TeacherStatus.active:
        return 'نشط';
      case TeacherStatus.inactive:
        return 'غير نشط';
    }
  }
}