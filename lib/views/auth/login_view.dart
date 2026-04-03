import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 64),
              // Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.school_rounded,
                    size: 44, color: Colors.white),
              ),
              const SizedBox(height: 28),
              Text('login_welcome'.tr,
                  style: AppTextStyles.displayMedium
                      .copyWith(color: AppColors.primary)),
              const SizedBox(height: 6),
              Text('login_subtitle'.tr,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.grey500)),
              const SizedBox(height: 40),

              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: controller.loginFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'login_email'.tr,
                        hint: 'login_email_hint'.tr,
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        prefixIcon: const Icon(Icons.email_outlined,
                            size: 20, color: AppColors.grey400),
                      ),
                      const SizedBox(height: 20),
                      Obx(() => CustomTextField(
                        label: 'login_password'.tr,
                        hint: 'login_password_hint'.tr,
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        onSubmitted: (_) => controller.login(),
                        prefixIcon: const Icon(Icons.lock_outline,
                            size: 20, color: AppColors.grey400),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.grey400,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      )),
                      const SizedBox(height: 28),
                      Obx(() => CustomButton(
                        label: 'login_button'.tr,
                        onPressed: controller.login,
                        isLoading: controller.isLoading.value,
                        icon: Icons.login_rounded,
                      )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // زر إنشاء حساب استقبال
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.registerReception),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.badge_outlined,
                                color: AppColors.secondary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('login_new_reception'.tr,
                                    style: AppTextStyles.titleSmall
                                        .copyWith(color: scheme.onSurface)),
                                const SizedBox(height: 2),
                                Text('login_new_reception_desc'.tr,
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: AppColors.grey500)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              color: AppColors.grey400, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'login_footer'.tr,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.grey400),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}