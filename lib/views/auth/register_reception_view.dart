import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterReceptionView extends StatefulWidget {
  const RegisterReceptionView({super.key});

  @override
  State<RegisterReceptionView> createState() => _RegisterReceptionViewState();
}

class _RegisterReceptionViewState extends State<RegisterReceptionView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _isLoading = false.obs;
  final _obscurePassword = true.obs;
  final _obscureConfirm = true.obs;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    _isLoading.value = true;
    try {
      final authCtrl = Get.find<AuthController>();
      await authCtrl.registerReception(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (_) {
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: scheme.onSurface, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(Icons.badge_outlined,
                    size: 44, color: AppColors.secondary),
              ),
              const SizedBox(height: 24),

              Text('register_title'.tr,
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: scheme.onSurface)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'register_desc'.tr,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.grey500),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // بطاقة التنبيه
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.warning.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.warning, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'register_warning'.tr,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // الفورم
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
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'register_email'.tr,
                        hint: 'login_email_hint'.tr,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        prefixIcon: const Icon(Icons.email_outlined,
                            size: 20, color: AppColors.grey400),
                      ),
                      const SizedBox(height: 18),

                      Obx(() => CustomTextField(
                        label: 'register_password'.tr,
                        hint: 'register_password_hint'.tr,
                        controller: _passwordController,
                        obscureText: _obscurePassword.value,
                        textInputAction: TextInputAction.next,
                        validator: Validators.password,
                        prefixIcon: const Icon(Icons.lock_outline,
                            size: 20, color: AppColors.grey400),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.grey400,
                          ),
                          onPressed: () => _obscurePassword.toggle(),
                        ),
                      )),
                      const SizedBox(height: 18),

                      Obx(() => CustomTextField(
                        label: 'register_confirm_password'.tr,
                        hint: 'register_confirm_hint'.tr,
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm.value,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _register(),
                        validator: (v) =>
                            Validators.confirmPasswordDirect(
                                v, _passwordController.text),
                        prefixIcon: const Icon(Icons.lock_outline,
                            size: 20, color: AppColors.grey400),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.grey400,
                          ),
                          onPressed: () => _obscureConfirm.toggle(),
                        ),
                      )),
                      const SizedBox(height: 28),

                      Obx(() => CustomButton(
                        label: 'register_button'.tr,
                        onPressed: _register,
                        isLoading: _isLoading.value,
                        icon: Icons.person_add_outlined,
                      )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('register_has_account'.tr,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey500)),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('register_login'.tr,
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}