// lib/data/repositories/auth_repository.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/api_endpoints.dart';
import '../../utils/constants.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';

class AuthRepository {
  final ApiProvider _api = ApiProvider.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ==================== Login ====================

  Future<AuthResponse> login(String email, String password) async {
    final response = await _api.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (!response.isSuccess) throw Exception(response.error);

    final data = response.responseData;
    final authData = data is Map ? data : (response.data['data'] ?? response.data);

    final auth = AuthResponse.fromJson(authData as Map<String, dynamic>);

    await _api.saveToken(auth.accessToken);
    await _saveUserData(auth.user);

    return auth;
  }

  // ==================== Register ====================

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? phone,
    required String role,
  }) async {
    final response = await _api.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
        'role': role,
      },
    );

    if (!response.isSuccess) throw Exception(response.error);

    final auth = AuthResponse.fromJson(
        response.responseData as Map<String, dynamic>);
    await _api.saveToken(auth.accessToken);
    await _saveUserData(auth.user);

    return auth;
  }

  // ==================== Create Reception User ====================

  Future<AuthResponse> createReceptionUser({
    required String email,
    required String password,
  }) async {
    // الـ endpoint الجديد بدون حماية: POST /auth/register-reception
    final response = await _api.post(
      ApiEndpoints.registerReception,
      data: {
        'email': email,
        'password': password,
        'role': 'reception',
      },
    );

    if (!response.isSuccess) throw Exception(response.error);

    // بعد إنشاء الحساب → login تلقائي
    final loginResponse = await login(email, password);
    return loginResponse;
  }

  // ==================== Get Profile ====================

  Future<UserModel> getProfile() async {
    final response = await _api.get(ApiEndpoints.profile);
    if (!response.isSuccess) throw Exception(response.error);

    final user = UserModel.fromJson(
        response.responseData as Map<String, dynamic>);
    await _saveUserData(user);
    return user;
  }

  // ==================== Change Password ====================

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _api.post(
      ApiEndpoints.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    if (!response.isSuccess) throw Exception(response.error);
  }

  // ==================== Logout ====================

  Future<void> logout() async {
    await _api.clearToken();
    await _storage.deleteAll();
  }

  // ==================== Check Auth ====================

  Future<bool> isLoggedIn() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<UserModel?> getCachedUser() async {
    try {
      final id = await _storage.read(key: AppConstants.userIdKey);
      final email = await _storage.read(key: AppConstants.userEmailKey);
      final role = await _storage.read(key: AppConstants.userRoleKey);

      if (id == null || email == null || role == null) return null;

      return UserModel(
        id: int.parse(id),
        email: email,
        role: role,
        isActive: true,
      );
    } catch (_) {
      return null;
    }
  }

  // ==================== Private ====================

  Future<void> _saveUserData(UserModel user) async {
    await _storage.write(
        key: AppConstants.userIdKey, value: user.id.toString());
    await _storage.write(
        key: AppConstants.userEmailKey, value: user.email);
    await _storage.write(
        key: AppConstants.userRoleKey, value: user.role);
    await _storage.write(
        key: AppConstants.isLoggedInKey, value: 'true');
  }
}