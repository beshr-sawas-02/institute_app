// lib/data/models/grade_model.dart

class GradeModel {
  final int id;
  final String name;
  final String level;
  final String? description;
  final String? createdAt;

  const GradeModel({
    required this.id,
    required this.name,
    required this.level,
    this.description,
    this.createdAt,
  });

  String get levelLabel {
    switch (level) {
      case 'اعدادي': return 'إعدادي';
      case 'ثانوي': return 'ثانوي';
      default: return level;
    }
  }

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      level: json['level'] as String? ?? '',
      description: json['description'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    if (description != null) 'description': description,
  };

  @override
  String toString() => 'GradeModel(id: $id, name: $name)';
}

// ==================== DTOs ====================

class CreateGradeDto {
  final String name;
  final String level;
  final String? description;

  const CreateGradeDto({
    required this.name,
    required this.level,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'level': level,
    if (description != null) 'description': description,
  };
}