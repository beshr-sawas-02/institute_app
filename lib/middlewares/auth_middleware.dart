// lib/middlewares/auth_middleware.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../data/repositories/auth_repository.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  final AuthRepository _repo = AuthRepository();

  @override
  RouteSettings? redirect(String? route) {
    // سيتم التحقق في onPageCalled بشكل async
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    return page;
  }

  @override
  Widget onPageBuilt(Widget page) {
    return page;
  }
}

// ==================== Auth Guard للصفحات المحمية ====================
class AuthGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // نتحقق من الـ AuthController
    try {
      final authController = Get.find<AuthController>();
      if (authController.currentUser.value == null) {
        return const RouteSettings(name: AppRoutes.login);
      }
    } catch (_) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

// ==================== Guest Guard (صفحات تسجيل الدخول فقط) ====================
class GuestGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();
      if (authController.currentUser.value != null) {
        return const RouteSettings(name: AppRoutes.main);
      }
    } catch (_) {}
    return null;
  }
}

// ==================== Role Guard ====================
class RoleGuard extends GetMiddleware {
  final List<String> allowedRoles;

  RoleGuard({required this.allowedRoles});

  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();
      final role = authController.userRole;

      if (!allowedRoles.contains(role)) {
        // إعادة توجيه للصفحة الرئيسية مع رسالة خطأ
        Future.delayed(Duration.zero, () {
          Get.snackbar(
            'غير مصرح',
            'ليس لديك صلاحية للوصول إلى هذه الصفحة',
            snackPosition: SnackPosition.TOP,
          );
        });
        return const RouteSettings(name: AppRoutes.main);
      }
    } catch (_) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}