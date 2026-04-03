// lib/data/models/attendance_model.dart

import '../../utils/app_colors.dart';
import 'student_model.dart';

class AttendanceModel {
  final int id;
  final int studentId;
  final String date;
  final String status;
  final int lateMinutes;
  final String? notes;
  final bool parentNotified;
  final String? notificationSentAt;
  final String? createdAt;

  // Relations
  final StudentModel? student;

  const AttendanceModel({
    required this.id,
    required this.studentId,
    required this.date,
    required this.status,
    required this.lateMinutes,
    this.notes,
    required this.parentNotified,
    this.notificationSentAt,
    this.createdAt,
    this.student,
  });

  String get statusLabel {
    switch (status) {
      case 'present': return 'حاضر';
      case 'absent': return 'غائب';
      case 'late': return 'متأخر';
      case 'excused': return 'معذور';
      default: return status;
    }
  }

  dynamic get statusColor => AppColors.getAttendanceColor(status);
  dynamic get statusBgColor => AppColors.getAttendanceBgColor(status);

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLate => status == 'late';
  bool get isExcused => status == 'excused';

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      lateMinutes: json['lateMinutes'] as int? ?? 0,
      notes: json['notes'] as String?,
      parentNotified: json['parentNotified'] as bool? ?? false,
      notificationSentAt: json['notificationSentAt'] as String?,
      createdAt: json['createdAt'] as String?,
      student: json['student'] != null
          ? StudentModel.fromJson(json['student'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'date': date,
    'status': status,
    'lateMinutes': lateMinutes,
    if (notes != null) 'notes': notes,
  };

  AttendanceModel copyWith({
    String? status,
    int? lateMinutes,
    String? notes,
  }) {
    return AttendanceModel(
      id: id,
      studentId: studentId,
      date: date,
      status: status ?? this.status,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      notes: notes ?? this.notes,
      parentNotified: parentNotified,
      notificationSentAt: notificationSentAt,
      createdAt: createdAt,
      student: student,
    );
  }

  @override
  String toString() => 'AttendanceModel(id: $id, studentId: $studentId, status: $status)';
}

// ==================== Section Sheet ====================

/// يمثل سجل طالب واحد في كشف الحضور
class AttendanceSheetEntry {
  final int order;
  final int studentId;
  final String name;
  final AttendanceModel? attendance; // null = لم يُسجَّل بعد

  const AttendanceSheetEntry({
    required this.order,
    required this.studentId,
    required this.name,
    this.attendance,
  });

  bool get isRegistered => attendance != null;
  String get currentStatus => attendance?.status ?? '';

  factory AttendanceSheetEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceSheetEntry(
      order: json['order'] as int,
      studentId: json['studentId'] as int,
      name: json['name'] as String? ?? '',
      attendance: json['attendance'] != null
          ? AttendanceModel.fromJson(json['attendance'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// الكشف الكامل لشعبة في يوم معين
class AttendanceSheet {
  final int sectionId;
  final String date;
  final int totalStudents;
  final int registered;
  final bool isComplete;
  final List<AttendanceSheetEntry> students;

  const AttendanceSheet({
    required this.sectionId,
    required this.date,
    required this.totalStudents,
    required this.registered,
    required this.isComplete,
    required this.students,
  });

  factory AttendanceSheet.fromJson(Map<String, dynamic> json) {
    final studentsList = (json['students'] as List<dynamic>? ?? [])
        .map((e) => AttendanceSheetEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return AttendanceSheet(
      sectionId: json['sectionId'] as int,
      date: json['date'] as String? ?? '',
      totalStudents: json['totalStudents'] as int,
      registered: json['registered'] as int,
      isComplete: json['isComplete'] as bool? ?? false,
      students: studentsList,
    );
  }

  double get completionPercentage {
    if (totalStudents == 0) return 0;
    return (registered / totalStudents) * 100;
  }
}

// ==================== Stats ====================

class AttendanceStats {
  final int studentId;
  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double attendanceRate;

  const AttendanceStats({
    required this.studentId,
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.attendanceRate,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      studentId: json['studentId'] as int,
      total: json['total'] as int? ?? 0,
      present: json['present'] as int? ?? 0,
      absent: json['absent'] as int? ?? 0,
      late: json['late'] as int? ?? 0,
      excused: json['excused'] as int? ?? 0,
      attendanceRate: double.tryParse(json['attendanceRate'].toString()) ?? 0.0,
    );
  }
}

// ==================== DTOs ====================

class CreateAttendanceDto {
  final int studentId;
  final String date;
  final String status;
  final int? lateMinutes;
  final String? notes;

  const CreateAttendanceDto({
    required this.studentId,
    required this.date,
    required this.status,
    this.lateMinutes,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'date': date,
    'status': status,
    if (lateMinutes != null && lateMinutes! > 0) 'lateMinutes': lateMinutes,
    if (notes != null) 'notes': notes,
  };
}

class BulkStudentAttendanceItem {
  final int studentId;
  final String status;
  final int? lateMinutes;
  final String? notes;

  const BulkStudentAttendanceItem({
    required this.studentId,
    required this.status,
    this.lateMinutes,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'status': status,
    if (lateMinutes != null && lateMinutes! > 0) 'lateMinutes': lateMinutes,
    if (notes != null) 'notes': notes,
  };
}

class BulkAttendanceDto {
  final int sectionId;
  final String date;
  final List<BulkStudentAttendanceItem> students;

  const BulkAttendanceDto({
    required this.sectionId,
    required this.date,
    required this.students,
  });

  Map<String, dynamic> toJson() => {
    'sectionId': sectionId,
    'date': date,
    'students': students.map((s) => s.toJson()).toList(),
  };
}

class SmartBulkException {
  final int studentId;
  final String status;
  final int? lateMinutes;
  final String? notes;

  const SmartBulkException({
    required this.studentId,
    required this.status,
    this.lateMinutes,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'status': status,
    if (lateMinutes != null && lateMinutes! > 0) 'lateMinutes': lateMinutes,
    if (notes != null) 'notes': notes,
  };
}

class SmartBulkAttendanceDto {
  final int sectionId;
  final String date;
  final List<SmartBulkException> exceptions;

  const SmartBulkAttendanceDto({
    required this.sectionId,
    required this.date,
    this.exceptions = const [],
  });

  Map<String, dynamic> toJson() => {
    'sectionId': sectionId,
    'date': date,
    'exceptions': exceptions.map((e) => e.toJson()).toList(),
  };
}

class UpdateAttendanceDto {
  final String? status;
  final int? lateMinutes;
  final String? notes;

  const UpdateAttendanceDto({this.status, this.lateMinutes, this.notes});

  Map<String, dynamic> toJson() => {
    if (status != null) 'status': status,
    if (lateMinutes != null) 'lateMinutes': lateMinutes,
    if (notes != null) 'notes': notes,
  };
}

// ==================== Smart Bulk Result ====================

class SmartBulkResult {
  final String message;
  final String date;
  final int sectionId;
  final SmartBulkSummary summary;
  final List<SmartBulkEntry> data;

  const SmartBulkResult({
    required this.message,
    required this.date,
    required this.sectionId,
    required this.summary,
    required this.data,
  });

  factory SmartBulkResult.fromJson(Map<String, dynamic> json) {
    return SmartBulkResult(
      message: json['message'] as String? ?? '',
      date: json['date'] as String? ?? '',
      sectionId: json['sectionId'] as int,
      summary: SmartBulkSummary.fromJson(json['summary'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SmartBulkEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SmartBulkSummary {
  final int total;
  final int present;
  final int absent;
  final int late;
  final int excused;

  const SmartBulkSummary({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
  });

  factory SmartBulkSummary.fromJson(Map<String, dynamic> json) {
    return SmartBulkSummary(
      total: json['total'] as int? ?? 0,
      present: json['present'] as int? ?? 0,
      absent: json['absent'] as int? ?? 0,
      late: json['late'] as int? ?? 0,
      excused: json['excused'] as int? ?? 0,
    );
  }
}

class SmartBulkEntry {
  final int order;
  final int studentId;
  final String name;
  final String status;
  final int lateMinutes;

  const SmartBulkEntry({
    required this.order,
    required this.studentId,
    required this.name,
    required this.status,
    required this.lateMinutes,
  });

  factory SmartBulkEntry.fromJson(Map<String, dynamic> json) {
    return SmartBulkEntry(
      order: json['order'] as int,
      studentId: json['studentId'] as int,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      lateMinutes: json['lateMinutes'] as int? ?? 0,
    );
  }
}