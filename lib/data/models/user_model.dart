// lib/data/models/user_model.dart

class UserModel {
  final int id;
  final String email;
  final String? phone;
  final String role;
  final bool isActive;
  final String? firstName;
  final String? lastName;
  final String? lastLogin;
  final String? createdAt;
  final String? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    this.firstName,
    this.lastName,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName {
    final f = firstName ?? '';
    final l = lastName ?? '';
    final name = '$f $l'.trim();
    return name.isNotEmpty ? name : email;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      lastLogin: json['lastLogin'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'phone': phone,
    'role': role,
    'isActive': isActive,
    'firstName': firstName,
    'lastName': lastName,
  };

  UserModel copyWith({
    int? id,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
    String? firstName,
    String? lastName,
    String? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, email: $email, role: $role)';
}

// ==================== Auth Response ====================

class AuthResponse {
  final UserModel user;
  final String accessToken;

  const AuthResponse({required this.user, required this.accessToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String? ?? '',
    );
  }
}