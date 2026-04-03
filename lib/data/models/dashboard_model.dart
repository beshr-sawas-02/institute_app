// lib/data/models/dashboard_model.dart

class DashboardStats {
  final OverviewStats overview;
  final TodayAttendance todayAttendance;
  final FinancialStats financial;
  final AssessmentStats assessments;
  final NotificationStats notifications;
  final List<GradeDistribution> gradeDistribution;
  final List<RecentPayment> recentPayments;
  final List<RecentAbsence> recentAbsences;

  const DashboardStats({
    required this.overview,
    required this.todayAttendance,
    required this.financial,
    required this.assessments,
    required this.notifications,
    required this.gradeDistribution,
    required this.recentPayments,
    required this.recentAbsences,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      overview: OverviewStats.fromJson(
          json['overview'] as Map<String, dynamic>? ?? {}),
      todayAttendance: TodayAttendance.fromJson(
          json['todayAttendance'] as Map<String, dynamic>? ?? {}),
      financial: FinancialStats.fromJson(
          json['financial'] as Map<String, dynamic>? ?? {}),
      assessments: AssessmentStats.fromJson(
          json['assessments'] as Map<String, dynamic>? ?? {}),
      notifications: NotificationStats.fromJson(
          json['notifications'] as Map<String, dynamic>? ?? {}),
      gradeDistribution: (json['gradeDistribution'] as List<dynamic>? ?? [])
          .map((e) => GradeDistribution.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentPayments: (json['recentPayments'] as List<dynamic>? ?? [])
          .map((e) => RecentPayment.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentAbsences: (json['recentAbsences'] as List<dynamic>? ?? [])
          .map((e) => RecentAbsence.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OverviewStats {
  final StudentCount students;
  final TeacherCount teachers;
  final int parents;
  final int sections;

  const OverviewStats({
    required this.students,
    required this.teachers,
    required this.parents,
    required this.sections,
  });

  factory OverviewStats.fromJson(Map<String, dynamic> json) {
    return OverviewStats(
      students: StudentCount.fromJson(
          json['students'] as Map<String, dynamic>? ?? {}),
      teachers: TeacherCount.fromJson(
          json['teachers'] as Map<String, dynamic>? ?? {}),
      parents: json['parents'] as int? ?? 0,
      sections: json['sections'] as int? ?? 0,
    );
  }
}

class StudentCount {
  final int total;
  final int active;
  const StudentCount({required this.total, required this.active});
  factory StudentCount.fromJson(Map<String, dynamic> json) => StudentCount(
    total: json['total'] as int? ?? 0,
    active: json['active'] as int? ?? 0,
  );
}

class TeacherCount {
  final int total;
  final int active;
  const TeacherCount({required this.total, required this.active});
  factory TeacherCount.fromJson(Map<String, dynamic> json) => TeacherCount(
    total: json['total'] as int? ?? 0,
    active: json['active'] as int? ?? 0,
  );
}

class TodayAttendance {
  final int present;
  final int absent;
  final int late;
  final int excused;
  final int total;

  const TodayAttendance({
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.total,
  });

  double get attendanceRate {
    if (total == 0) return 0;
    return ((present + late) / total) * 100;
  }

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      present: json['present'] as int? ?? 0,
      absent: json['absent'] as int? ?? 0,
      late: json['late'] as int? ?? 0,
      excused: json['excused'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }
}

class FinancialStats {
  final double totalPaid;
  final double totalPending;
  final double totalPartial;
  final double totalExpenses;
  final double netBalance;
  final String budgetUsedPercentage;

  const FinancialStats({
    required this.totalPaid,
    required this.totalPending,
    required this.totalPartial,
    required this.totalExpenses,
    required this.netBalance,
    required this.budgetUsedPercentage,
  });

  factory FinancialStats.fromJson(Map<String, dynamic> json) {
    return FinancialStats(
      totalPaid: double.tryParse(json['totalPaid'].toString()) ?? 0,
      totalPending: double.tryParse(json['totalPending'].toString()) ?? 0,
      totalPartial: double.tryParse(json['totalPartial'].toString()) ?? 0,
      totalExpenses: double.tryParse(json['totalExpenses'].toString()) ?? 0,
      netBalance: double.tryParse(json['netBalance'].toString()) ?? 0,
      budgetUsedPercentage: json['budgetUsedPercentage']?.toString() ?? '0',
    );
  }
}

class AssessmentStats {
  final int total;
  final String averagePercentage;
  final List<GradeCount> gradeDistribution;

  const AssessmentStats({
    required this.total,
    required this.averagePercentage,
    required this.gradeDistribution,
  });

  factory AssessmentStats.fromJson(Map<String, dynamic> json) {
    return AssessmentStats(
      total: json['total'] as int? ?? 0,
      averagePercentage: json['averagePercentage']?.toString() ?? '0',
      gradeDistribution: (json['gradeDistribution'] as List<dynamic>? ?? [])
          .map((e) => GradeCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GradeCount {
  final String grade;
  final int count;

  const GradeCount({required this.grade, required this.count});

  factory GradeCount.fromJson(Map<String, dynamic> json) {
    return GradeCount(
      grade: json['grade'] as String? ?? '—',
      count: (json['_count'] as int?) ?? 0,
    );
  }
}

class NotificationStats {
  final int unread;
  const NotificationStats({required this.unread});

  factory NotificationStats.fromJson(Map<String, dynamic> json) =>
      NotificationStats(unread: json['unread'] as int? ?? 0);
}

class GradeDistribution {
  final String gradeName;
  final int studentCount;

  const GradeDistribution({required this.gradeName, required this.studentCount});

  factory GradeDistribution.fromJson(Map<String, dynamic> json) {
    return GradeDistribution(
      gradeName: json['gradeName'] as String? ?? '',
      studentCount: json['studentCount'] as int? ?? 0,
    );
  }
}

class RecentPayment {
  final int id;
  final double? finalAmount;
  final String status;
  final String? createdAt;
  final String? studentFirstName;
  final String? studentLastName;

  const RecentPayment({
    required this.id,
    this.finalAmount,
    required this.status,
    this.createdAt,
    this.studentFirstName,
    this.studentLastName,
  });

  String get studentName =>
      '${studentFirstName ?? ''} ${studentLastName ?? ''}'.trim();

  factory RecentPayment.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    return RecentPayment(
      id: json['id'] as int,
      finalAmount: json['finalAmount'] != null
          ? double.tryParse(json['finalAmount'].toString())
          : null,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] as String?,
      studentFirstName: student?['firstName'] as String?,
      studentLastName: student?['lastName'] as String?,
    );
  }
}

class RecentAbsence {
  final int id;
  final String date;
  final String? studentFirstName;
  final String? studentLastName;

  const RecentAbsence({
    required this.id,
    required this.date,
    this.studentFirstName,
    this.studentLastName,
  });

  String get studentName =>
      '${studentFirstName ?? ''} ${studentLastName ?? ''}'.trim();

  factory RecentAbsence.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    return RecentAbsence(
      id: json['id'] as int,
      date: json['date'] as String? ?? '',
      studentFirstName: student?['firstName'] as String?,
      studentLastName: student?['lastName'] as String?,
    );
  }
}

// ==================== Financial Summary (Dashboard) ====================

class FinancialSummary {
  final int month;
  final int year;
  final double income;
  final double expenses;
  final double net;
  final List<ExpenseByCategory> expensesByCategory;

  const FinancialSummary({
    required this.month,
    required this.year,
    required this.income,
    required this.expenses,
    required this.net,
    required this.expensesByCategory,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      month: json['month'] as int? ?? 0,
      year: json['year'] as int? ?? 0,
      income: double.tryParse(json['income'].toString()) ?? 0,
      expenses: double.tryParse(json['expenses'].toString()) ?? 0,
      net: double.tryParse(json['net'].toString()) ?? 0,
      expensesByCategory:
      (json['expensesByCategory'] as List<dynamic>? ?? [])
          .map((e) =>
          ExpenseByCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ExpenseByCategory {
  final String category;
  final double total;

  const ExpenseByCategory({required this.category, required this.total});

  factory ExpenseByCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseByCategory(
      category: json['category'] as String? ?? 'other',
      total: double.tryParse(
          (json['_sum']?['amount'] ?? 0).toString()) ??
          0,
    );
  }
}