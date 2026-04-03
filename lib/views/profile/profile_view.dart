import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/language_switch.dart';

class ProfileView extends GetView<AuthController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('profile_title'.tr,
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
      ),
      body: Obx(() {
        final user = controller.currentUser.value;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    InitialsAvatar(
                      name: '${user.firstName} ${user.lastName}',
                      size: 80,
                      color: scheme.surface,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(
                      label: AppConstants.getUserRole(user.role),
                      color: scheme.surface,
                      bgColor: Colors.white.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _card(context, [
                      InfoRow(
                          icon: Icons.email_outlined,
                          label: 'profile_email'.tr,
                          value: user.email),
                      if (user.phone != null)
                        InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'profile_phone'.tr,
                            value: user.phone!),
                    ]),
                    const SizedBox(height: 12),
                    _card(context, [
                      _action(
                        icon: Icons.lock_outline,
                        label: 'profile_change_password'.tr,
                        onTap: () =>
                            Get.toNamed(AppRoutes.changePassword),
                      ),
                      const AppDivider(
                          margin: EdgeInsets.symmetric(horizontal: 0)),
                      const LanguageSwitchTile(),
                      const AppDivider(
                          margin: EdgeInsets.symmetric(horizontal: 0)),
                      _action(
                        icon: Icons.logout_rounded,
                        label: 'profile_logout'.tr,
                        color: AppColors.error,
                        onTap: controller.logout,
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _card(BuildContext context, List<Widget> children) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.primary, size: 22),
      title: Text(label,
          style: AppTextStyles.bodyMedium
              .copyWith(color: color ?? AppColors.text)),
      trailing:
      const Icon(Icons.chevron_left_rounded, color: AppColors.grey400),
      onTap: onTap,
    );
  }
}

class ChangePasswordView extends GetView<AuthController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('change_password_title'.tr,
            style:
            AppTextStyles.titleMedium.copyWith(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: controller.changePasswordFormKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Obx(() => TextFormField(
                controller: controller.currentPasswordController,
                obscureText: controller.obscureCurrent.value,
                decoration: InputDecoration(
                  labelText: 'change_password_current'.tr,
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(controller.obscureCurrent.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: controller.toggleCurrentVisibility,
                  ),
                ),
                validator: (v) => v == null || v.isEmpty
                    ? 'required_field'.tr
                    : null,
              )),
              const SizedBox(height: 16),
              Obx(() => TextFormField(
                controller: controller.newPasswordController,
                obscureText: controller.obscureNew.value,
                decoration: InputDecoration(
                  labelText: 'change_password_new'.tr,
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(controller.obscureNew.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: controller.toggleNewVisibility,
                  ),
                ),
                validator: (v) => v == null || v.length < 6
                    ? 'change_password_min'.tr
                    : null,
              )),
              const SizedBox(height: 16),
              Obx(() => TextFormField(
                controller: controller.confirmPasswordController,
                obscureText: controller.obscureConfirm.value,
                decoration: InputDecoration(
                  labelText: 'change_password_confirm'.tr,
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(controller.obscureConfirm.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: controller.toggleConfirmVisibility,
                  ),
                ),
                validator: (v) =>
                v != controller.newPasswordController.text
                    ? 'change_password_mismatch'.tr
                    : null,
              )),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value
                    ? CircularProgressIndicator(
                    color: scheme.surface, strokeWidth: 2)
                    : Text('change_password_save'.tr,
                    style: TextStyle(
                        color: scheme.surface, fontSize: 16)),
              )),
            ],
          ),
        ),
      ),
    );
  }
}