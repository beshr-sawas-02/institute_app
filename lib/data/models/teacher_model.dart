// lib/data/models/teacher_model.dart

class TeacherModel {
  final int id;
  final int? userId;
  final String firstName;
  final String lastName;
  final String specialization;
  final String? qualifications;
  final int? experienceYears;
  final String? bio;
  final double? salary;
  final String status;
  final String? hireDate;
  final String? createdAt;

  const TeacherModel({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.specialization,
    this.qualifications,
    this.experienceYears,
    this.bio,
    this.salary,
    required this.status,
    this.hireDate,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  bool get isActive => status == 'active';

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      qualifications: json['qualifications'] as String?,
      experienceYears: json['experienceYears'] as int?,
      bio: json['bio'] as String?,
      salary: json['salary'] != null
          ? double.tryParse(json['salary'].toString())
          : null,
      status: json['status'] as String? ?? 'active',
      hireDate: json['hireDate'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'specialization': specialization,
    'status': status,
    if (qualifications != null) 'qualifications': qualifications,
    if (experienceYears != null) 'experienceYears': experienceYears,
    if (salary != null) 'salary': salary,
    if (hireDate != null) 'hireDate': hireDate,
  };

  @override
  String toString() => 'TeacherModel(id: $id, name: $fullName)';
}