import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/main_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../dashboard/dashboard_view.dart';
import '../attendance/attendance_view.dart';
import '../grades/grades_view.dart';
import '../reports/reports_view.dart';
import '../profile/profile_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          DashboardView(),
          AttendanceView(),
          GradesView(),
          ReportsView(),
          ProfileView(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(context, 0, Icons.dashboard_rounded,
                  Icons.dashboard_outlined, 'nav_home'.tr),
              _navItem(context, 1, Icons.fact_check_rounded,
                  Icons.fact_check_outlined, 'nav_attendance'.tr),
              _navItem(context, 2, Icons.bar_chart_rounded,
                  Icons.bar_chart_outlined, 'nav_assessments'.tr),
              _navItem(context, 3, Icons.description_rounded,
                  Icons.description_outlined, 'nav_reports'.tr),
              _navItem(context, 4, Icons.person_rounded,
                  Icons.person_outline_rounded, 'nav_profile'.tr),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index, IconData activeIcon,
      IconData inactiveIcon, String label) {
    return Obx(() {
      final isActive = controller.currentIndex.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.changePage(index),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isActive ? activeIcon : inactiveIcon,
                  size: 24,
                  color: isActive ? AppColors.primary : AppColors.grey400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 10,
                  color: isActive ? AppColors.primary : AppColors.grey400,
                  fontWeight:
                  isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}