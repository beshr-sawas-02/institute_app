// lib/data/models/assessment_model.dart

import '../../utils/app_colors.dart';
import 'student_model.dart';
import 'subject_model.dart';

class AssessmentModel {
  final int id;
  final int studentId;
  final int gradeSubjectId;
  final String type;
  final String title;
  final double maxScore;
  final double? score;
  final double? percentage;
  final String? grade;
  final String? feedback;
  final String assessmentDate;
  final String? createdAt;

  // Relations
  final StudentModel? student;
  final GradeSubjectModel? gradeSubject;

  const AssessmentModel({
    required this.id,
    required this.studentId,
    required this.gradeSubjectId,
    required this.type,
    required this.title,
    required this.maxScore,
    this.score,
    this.percentage,
    this.grade,
    this.feedback,
    required this.assessmentDate,
    this.createdAt,
    this.student,
    this.gradeSubject,
  });

  String get typeLabel {
    switch (type) {
      case 'quiz': return 'اختبار قصير';
      case 'exam': return 'اختبار';
      case 'homework': return 'واجب';
      case 'midterm': return 'مذاكرة';
      case 'final': return 'نهائي';
      default: return type;
    }
  }

  String get gradeLabel => grade ?? '—';

  dynamic get gradeColor => AppColors.getGradeColor(grade);

  bool get hasScore => score != null;

  String get scoreDisplay {
    if (score == null) return '—';
    return '${_formatNum(score!)} / ${_formatNum(maxScore)}';
  }

  String get percentageDisplay {
    if (percentage == null) return '—';
    return '${percentage!.toStringAsFixed(1)}%';
  }

  String _formatNum(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    return AssessmentModel(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      gradeSubjectId: json['gradeSubjectId'] as int,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      maxScore: double.tryParse(json['maxScore'].toString()) ?? 0,
      score: json['score'] != null
          ? double.tryParse(json['score'].toString())
          : null,
      percentage: json['percentage'] != null
          ? double.tryParse(json['percentage'].toString())
          : null,
      grade: json['grade'] as String?,
      feedback: json['feedback'] as String?,
      assessmentDate: json['assessmentDate'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      student: json['student'] != null
          ? StudentModel.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      gradeSubject: json['gradeSubject'] != null
          ? GradeSubjectModel.fromJson(
          json['gradeSubject'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'gradeSubjectId': gradeSubjectId,
    'type': type,
    'title': title,
    'maxScore': maxScore,
    if (score != null) 'score': score,
    if (feedback != null) 'feedback': feedback,
    'assessmentDate': assessmentDate,
  };

  @override
  String toString() =>
      'AssessmentModel(id: $id, title: $title, grade: $gradeLabel)';
}

// ==================== DTOs ====================

class CreateAssessmentDto {
  final int studentId;
  final int gradeSubjectId;
  final String type;
  final String title;
  final double maxScore;
  final double? score;
  final String? feedback;
  final String assessmentDate;

  const CreateAssessmentDto({
    required this.studentId,
    required this.gradeSubjectId,
    required this.type,
    required this.title,
    required this.maxScore,
    this.score,
    this.feedback,
    required this.assessmentDate,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'gradeSubjectId': gradeSubjectId,
    'type': type,
    'title': title,
    'maxScore': maxScore,
    if (score != null) 'score': score,
    if (feedback != null) 'feedback': feedback,
    'assessmentDate': assessmentDate,
  };
}

class UpdateAssessmentDto {
  final String? type;
  final String? title;
  final double? maxScore;
  final double? score;
  final String? feedback;
  final String? assessmentDate;

  const UpdateAssessmentDto({
    this.type,
    this.title,
    this.maxScore,
    this.score,
    this.feedback,
    this.assessmentDate,
  });

  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
    if (title != null) 'title': title,
    if (maxScore != null) 'maxScore': maxScore,
    if (score != null) 'score': score,
    if (feedback != null) 'feedback': feedback,
    if (assessmentDate != null) 'assessmentDate': assessmentDate,
  };
}