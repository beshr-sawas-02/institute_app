// lib/data/models/student_model.dart

import 'parent_model.dart';
import 'section_model.dart';

class StudentModel {
  final int id;
  final int? userId;
  final int? parentId;
  final int? sectionId;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? academicYear;
  final String status;
  final String? registrationDate;
  final String? createdAt;
  final String? updatedAt;

  // Relations
  final ParentModel? parent;
  final SectionModel? section;

  const StudentModel({
    required this.id,
    this.userId,
    this.parentId,
    this.sectionId,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.academicYear,
    required this.status,
    this.registrationDate,
    this.createdAt,
    this.updatedAt,
    this.parent,
    this.section,
  });

  String get fullName => '$firstName $lastName';

  bool get isActive => status == 'active';

  String get genderArabic => gender == 'male' ? 'ذكر' : gender == 'female' ? 'أنثى' : '—';

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      parentId: json['parentId'] as int?,
      sectionId: json['sectionId'] as int?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      academicYear: json['academicYear'] as String?,
      status: json['status'] as String? ?? 'active',
      registrationDate: json['registrationDate'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      parent: json['parent'] != null
          ? ParentModel.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      section: json['section'] != null
          ? SectionModel.fromJson(json['section'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (gender != null) 'gender': gender,
    'status': status,
    if (parentId != null) 'parentId': parentId,
    if (sectionId != null) 'sectionId': sectionId,
    if (address != null) 'address': address,
    if (academicYear != null) 'academicYear': academicYear,
  };

  StudentModel copyWith({
    int? parentId,
    int? sectionId,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? academicYear,
    String? status,
    ParentModel? parent,
    SectionModel? section,
  }) {
    return StudentModel(
      id: id,
      userId: userId,
      parentId: parentId ?? this.parentId,
      sectionId: sectionId ?? this.sectionId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      academicYear: academicYear ?? this.academicYear,
      status: status ?? this.status,
      registrationDate: registrationDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      parent: parent ?? this.parent,
      section: section ?? this.section,
    );
  }

  @override
  String toString() => 'StudentModel(id: $id, name: $fullName, status: $status)';
}

// ==================== Create / Update DTOs ====================

class CreateStudentDto {
  final int? parentId;
  final int? sectionId;
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String? address;
  final String? academicYear;

  const CreateStudentDto({
    this.parentId,
    this.sectionId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.address,
    this.academicYear,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    if (parentId != null) 'parentId': parentId,
    if (sectionId != null) 'sectionId': sectionId,
    if (address != null) 'address': address,
    if (academicYear != null) 'academicYear': academicYear,
  };
}

class UpdateStudentDto {
  final int? parentId;
  final int? sectionId;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? academicYear;
  final String? status;

  const UpdateStudentDto({
    this.parentId,
    this.sectionId,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.academicYear,
    this.status,
  });

  Map<String, dynamic> toJson() => {
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (gender != null) 'gender': gender,
    if (parentId != null) 'parentId': parentId,
    if (sectionId != null) 'sectionId': sectionId,
    if (address != null) 'address': address,
    if (academicYear != null) 'academicYear': academicYear,
    if (status != null) 'status': status,
  };
}