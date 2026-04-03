// lib/data/models/subject_model.dart

import 'grade_model.dart';
import 'section_model.dart';
import 'teacher_model.dart';

class SubjectModel {
  final int id;
  final String name;
  final String? description;
  final String? createdAt;

  const SubjectModel({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (description != null) 'description': description,
  };

  @override
  String toString() => 'SubjectModel(id: $id, name: $name)';
}

// ==================== GradeSubject ====================

// lib/data/models/grade_subject_model.dart


class GradeSubjectModel {
  final int id;
  final int gradeId;
  final int subjectId;
  final int teacherId;
  final int? sectionId;
  final String? createdAt;

  // Relations
  final GradeModel? grade;
  final SubjectModel? subject;
  final TeacherModel? teacher;
  final SectionModel? section;

  const GradeSubjectModel({
    required this.id,
    required this.gradeId,
    required this.subjectId,
    required this.teacherId,
    this.sectionId,
    this.createdAt,
    this.grade,
    this.subject,
    this.teacher,
    this.section,
  });

  String get displayName {
    final subjectName = subject?.name ?? 'مادة #$subjectId';
    final teacherName = teacher?.fullName ?? 'معلم #$teacherId';
    return '$subjectName - $teacherName';
  }

  factory GradeSubjectModel.fromJson(Map<String, dynamic> json) {
    return GradeSubjectModel(
      id: json['id'] as int,
      gradeId: json['gradeId'] as int,
      subjectId: json['subjectId'] as int,
      teacherId: json['teacherId'] as int,
      sectionId: json['sectionId'] as int?,
      createdAt: json['createdAt'] as String?,
      grade: json['grade'] != null
          ? GradeModel.fromJson(json['grade'] as Map<String, dynamic>)
          : null,
      subject: json['subject'] != null
          ? SubjectModel.fromJson(json['subject'] as Map<String, dynamic>)
          : null,
      teacher: json['teacher'] != null
          ? TeacherModel.fromJson(json['teacher'] as Map<String, dynamic>)
          : null,
      section: json['section'] != null
          ? SectionModel.fromJson(json['section'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gradeId': gradeId,
    'subjectId': subjectId,
    'teacherId': teacherId,
    if (sectionId != null) 'sectionId': sectionId,
  };
}