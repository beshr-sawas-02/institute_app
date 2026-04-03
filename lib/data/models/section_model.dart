// lib/data/models/section_model.dart

import 'grade_model.dart';

class SectionModel {
  final int id;
  final int gradeId;
  final String name;
  final String academicYear;
  final int? maxStudents;
  final String status;
  final String? createdAt;

  // Relations
  final GradeModel? grade;
  final int? studentCount; // from _count

  const SectionModel({
    required this.id,
    required this.gradeId,
    required this.name,
    required this.academicYear,
    this.maxStudents,
    required this.status,
    this.createdAt,
    this.grade,
    this.studentCount,
  });

  String get fullName {
    if (grade != null) return '${grade!.name} - $name';
    return name;
  }

  bool get isActive => status == 'active';

  bool get isFull {
    if (maxStudents == null || studentCount == null) return false;
    return studentCount! >= maxStudents!;
  }

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    // Handle _count object from Prisma
    int? count;
    if (json['_count'] != null) {
      count = json['_count']['students'] as int?;
    }

    return SectionModel(
      id: json['id'] as int,
      gradeId: json['gradeId'] as int,
      name: json['name'] as String? ?? '',
      academicYear: json['academicYear'] as String? ?? '',
      maxStudents: json['maxStudents'] as int?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['createdAt'] as String?,
      grade: json['grade'] != null
          ? GradeModel.fromJson(json['grade'] as Map<String, dynamic>)
          : null,
      studentCount: count,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gradeId': gradeId,
    'name': name,
    'academicYear': academicYear,
    'status': status,
    if (maxStudents != null) 'maxStudents': maxStudents,
  };

  SectionModel copyWith({
    String? name,
    String? academicYear,
    int? maxStudents,
    String? status,
    GradeModel? grade,
    int? studentCount,
  }) {
    return SectionModel(
      id: id,
      gradeId: gradeId,
      name: name ?? this.name,
      academicYear: academicYear ?? this.academicYear,
      maxStudents: maxStudents ?? this.maxStudents,
      status: status ?? this.status,
      createdAt: createdAt,
      grade: grade ?? this.grade,
      studentCount: studentCount ?? this.studentCount,
    );
  }

  @override
  String toString() => 'SectionModel(id: $id, name: $fullName)';
}

// ==================== DTOs ====================

class CreateSectionDto {
  final int gradeId;
  final String name;
  final String academicYear;
  final int? maxStudents;

  const CreateSectionDto({
    required this.gradeId,
    required this.name,
    required this.academicYear,
    this.maxStudents,
  });

  Map<String, dynamic> toJson() => {
    'gradeId': gradeId,
    'name': name,
    'academicYear': academicYear,
    if (maxStudents != null) 'maxStudents': maxStudents,
  };
}