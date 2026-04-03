// lib/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../routes/app_routes.dart';
import '../utils/helpers.dart';

class AuthController extends GetxController {
  final AuthRepository _repo = AuthRepository();

  // ==================== State ====================
  final isLoading = false.obs;
  final currentUser = Rxn<UserModel>();

  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final obscurePassword = true.obs;

  // Change Password
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final obscureCurrent = true.obs;
  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  final loginFormKey = GlobalKey<FormState>();
  final changePasswordFormKey = GlobalKey<FormState>();

  // ==================== Getters ====================
  bool get isLoggedIn => currentUser.value != null;
  String get userRole => currentUser.value?.role ?? '';
  String get userEmail => currentUser.value?.email ?? '';
  bool get isAdmin => userRole == 'admin';
  bool get isReception => userRole == 'reception';
  bool get isTeacher => userRole == 'teacher';

  // ==================== Init ====================
  @override
  void onInit() {
    super.onInit();
    _loadCachedUser();
  }

  Future<void> _loadCachedUser() async {
    final user = await _repo.getCachedUser();
    if (user != null) currentUser.value = user;
  }

  // ==================== Login ====================
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final auth = await _repo.login(
        emailController.text.trim(),
        passwordController.text,
      );
      currentUser.value = auth.user;
      _clearLoginForm();
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Register Reception ====================
  Future<void> registerReception({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    try {
      final auth = await _repo.createReceptionUser(
        email: email,
        password: password,
      );
      currentUser.value = auth.user;
      Helpers.showSuccess('register_success'.tr);
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('No reception found')) {
        Helpers.showError('register_error_not_found'.tr);
      } else if (errorMsg.contains('already has a user account')) {
        Helpers.showError('register_error_exists'.tr);
      } else if (errorMsg.contains('Email already exists')) {
        Helpers.showError('register_error_email_taken'.tr);
      } else {
        Helpers.showError(Helpers.parseApiError(errorMsg));
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Logout ====================
  Future<void> logout() async {
    final confirmed = await Helpers.showConfirmDialog(
      title: 'profile_logout_title'.tr,
      message: 'profile_logout_msg'.tr,
      confirmText: 'profile_logout_button'.tr,
      cancelText: 'cancel'.tr,
      isDanger: true,
    );
    if (confirmed != true) return;

    await _repo.logout();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  // ==================== Get Profile ====================
  Future<void> refreshProfile() async {
    try {
      final user = await _repo.getProfile();
      currentUser.value = user;
    } catch (e) {
      // silent fail
    }
  }

  // ==================== Change Password ====================
  Future<void> changePassword() async {
    if (!changePasswordFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _repo.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );
      Helpers.showSuccess('change_password_success'.tr);
      _clearChangePasswordForm();
      Get.back();
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Helpers ====================
  void togglePasswordVisibility() => obscurePassword.toggle();
  void toggleCurrentVisibility() => obscureCurrent.toggle();
  void toggleNewVisibility() => obscureNew.toggle();
  void toggleConfirmVisibility() => obscureConfirm.toggle();

  void _clearLoginForm() {
    emailController.clear();
    passwordController.clear();
  }

  void _clearChangePasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}