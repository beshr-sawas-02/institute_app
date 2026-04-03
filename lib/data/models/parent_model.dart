// lib/data/models/parent_model.dart

class ParentModel {
  final int id;
  final int? userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? address;
  final String relationship;
  final String? createdAt;

  const ParentModel({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.address,
    required this.relationship,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  String get relationshipLabel {
    switch (relationship) {
      case 'father': return 'أب';
      case 'mother': return 'أم';
      case 'guardian': return 'وصي';
      default: return relationship;
    }
  }

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    return ParentModel(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      relationship: json['relationship'] as String? ?? 'father',
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    if (email != null) 'email': email,
    if (address != null) 'address': address,
    'relationship': relationship,
  };

  @override
  String toString() => 'ParentModel(id: $id, name: $fullName)';
}

// ==================== DTOs ====================

class CreateParentDto {
  final int? userId;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final String? address;
  final String relationship;

  const CreateParentDto({
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    this.address,
    required this.relationship,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    if (userId != null) 'userId': userId,
    if (email != null) 'email': email,
    if (address != null) 'address': address,
    'relationship': relationship,
  };
}

class UpdateParentDto {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? address;

  const UpdateParentDto({
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (address != null) 'address': address,
  };
}