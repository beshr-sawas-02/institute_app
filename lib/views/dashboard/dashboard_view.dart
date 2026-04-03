import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/assessment_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/helpers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_widget.dart' as ew;

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.primary,
      expandedHeight: 120,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    final user = Get.find<AuthController>().currentUser.value;
                    return Text(
                      'dashboard_hello'.tr.replaceAll('@name', user?.firstName ?? ''),
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    );
                  }),
                  const SizedBox(height: 2),
                  Text(
                    Helpers.formatDateArabic(DateTime.now().toIso8601String()),
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
                  ),
                ],
              ),
              Obx(() {
                final att = controller.todayAttendance;
                if (att == null || att.total == 0) return const SizedBox.shrink();
                final rate = (att.present + att.late) / att.total * 100;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'dashboard_attendance_pct'.tr.replaceAll('@pct', rate.toStringAsFixed(0)),
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.only(top: 80),
          child: LoadingWidget(message: 'dashboard_loading'.tr),
        );
      }
      if (controller.errorMessage.value.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 80),
          child: ew.AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadStats,
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAttendanceCard(context),
          _buildQuickActions(context),
          _buildFinancialCard(context),
          _buildActivityFeed(context),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildAttendanceCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final att = controller.todayAttendance;
    if (att == null) return const SizedBox.shrink();

    final total = att.total;
    final rate = total > 0 ? (att.present + att.late) / total : 0.0;
    final rateColor = rate >= 0.9
        ? AppColors.success
        : rate >= 0.7
        ? AppColors.warning
        : AppColors.error;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: rateColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.today_outlined,
                          color: rateColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text('dashboard_today_attendance'.tr,
                        style: AppTextStyles.titleSmall
                            .copyWith(color: scheme.onSurface)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Get.find<MainController>().goToAttendance(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('dashboard_register_attendance'.tr,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                    child: PercentageBar(
                        value: rate, color: rateColor, height: 8)),
                const SizedBox(width: 10),
                Text(
                  '${(rate * 100).toStringAsFixed(0)}%',
                  style:
                  AppTextStyles.labelMedium.copyWith(color: rateColor),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                _attChip(att.present.toString(), 'status_present'.tr, AppColors.success),
                const SizedBox(width: 8),
                _attChip(att.absent.toString(), 'status_absent'.tr, AppColors.error),
                const SizedBox(width: 8),
                _attChip(att.late.toString(), 'status_late'.tr, AppColors.warning),
                const SizedBox(width: 8),
                _attChip(att.excused.toString(), 'status_excused'.tr, AppColors.info),
              ],
            ),
          ),
          if (total == 0)
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'dashboard_no_attendance_yet'.tr,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.warning),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        Get.find<MainController>().goToAttendance(),
                    child: Text('dashboard_register_now'.tr,
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _attChip(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(count,
                style: AppTextStyles.titleSmall.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.labelSmall
                    .copyWith(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('dashboard_quick_actions'.tr,
              style: AppTextStyles.titleSmall
                  .copyWith(color: scheme.onSurface)),
          const SizedBox(height: 10),
          Row(
            children: [
              _quickAction(
                context: context,
                icon: Icons.how_to_reg_outlined,
                label: 'dashboard_action_attendance'.tr,
                color: AppColors.primary,
                onTap: () => Get.find<MainController>().goToAttendance(),
              ),
              const SizedBox(width: 10),
              _quickAction(
                context: context,
                icon: Icons.assignment_outlined,
                label: 'dashboard_action_assessment'.tr,
                color: AppColors.success,
                onTap: () {
                  if (!Get.isRegistered<AssessmentController>()) {
                    Get.lazyPut(() => AssessmentController());
                  }
                  Get.find<AssessmentController>().clearForm();
                  Get.find<AssessmentController>().loadFormDropdowns();
                  Get.toNamed(AppRoutes.assessmentCreate);
                },
              ),
              const SizedBox(width: 10),
              _quickAction(
                context: context,
                icon: Icons.bar_chart_outlined,
                label: 'dashboard_action_reports'.tr,
                color: AppColors.info,
                onTap: () => Get.find<MainController>().changePage(3),
              ),
              const SizedBox(width: 10),
              _quickAction(
                context: context,
                icon: Icons.school_outlined,
                label: 'dashboard_action_assessments'.tr,
                color: AppColors.warning,
                onTap: () => Get.find<MainController>().goToAssessments(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                    color: scheme.onSurface, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final f = controller.financial;
    if (f == null) return const SizedBox.shrink();

    final totalIn = f.totalPaid;
    final totalOut = f.totalExpenses;
    final balance = f.netBalance;
    final usedPct = double.tryParse(f.budgetUsedPercentage) ?? 0;
    final balanceColor = balance >= 0 ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.account_balance_outlined,
                        color: AppColors.success, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text('dashboard_financial_summary'.tr,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: scheme.onSurface)),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: balanceColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Helpers.formatCurrency(balance),
                  style: AppTextStyles.labelSmall.copyWith(
                      color: balanceColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _financialItem(
                  label: 'dashboard_total_paid'.tr,
                  value: Helpers.formatCurrency(totalIn),
                  color: AppColors.success,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _financialItem(
                  label: 'dashboard_total_expenses'.tr,
                  value: Helpers.formatCurrency(totalOut),
                  color: AppColors.error,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PercentageBar(
                  value: (usedPct / 100).clamp(0.0, 1.0),
                  color: usedPct > 80
                      ? AppColors.error
                      : usedPct > 60
                      ? AppColors.warning
                      : AppColors.success,
                  height: 8,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'dashboard_spent_pct'.tr
                    .replaceAll('@pct', usedPct.toStringAsFixed(1)),
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.grey500),
              ),
            ],
          ),
          if (f.totalPending > 0 || f.totalPartial > 0) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Row(
              children: [
                if (f.totalPending > 0)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.pending_outlined,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'dashboard_pending'.tr.replaceAll(
                                '@amount', Helpers.formatCurrency(f.totalPending)),
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (f.totalPartial > 0)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.incomplete_circle_outlined,
                            size: 14, color: AppColors.info),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'dashboard_partial'.tr.replaceAll(
                                '@amount',
                                Helpers.formatCurrency(f.totalPartial)),
                            style: AppTextStyles.labelSmall
                                .copyWith(color: AppColors.info),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _financialItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.grey500)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.titleSmall
                  .copyWith(color: color, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildActivityFeed(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dist = controller.gradeDistribution;
    if (dist.isEmpty) return const SizedBox.shrink();

    final totalStudents =
    dist.fold<int>(0, (sum, g) => sum + g.studentCount);
    if (totalStudents == 0) return const SizedBox.shrink();

    final colors = [
      AppColors.primary,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      const Color(0xFF9C27B0),
    ];

    final icons = [
      Icons.school_outlined,
      Icons.class_outlined,
      Icons.auto_stories_outlined,
      Icons.science_outlined,
      Icons.calculate_outlined,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'dashboard_grade_distribution'.tr),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalStudents.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Cairo',
                      height: 1,
                    ),
                  ),
                  Text(
                    'dashboard_total_students'.tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'dashboard_grades_count'.tr
                    .replaceAll('@count', '${dist.length}'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemCount: dist.length,
            itemBuilder: (_, i) {
              final g = dist[i];
              final color = colors[i % colors.length];
              final icon = icons[i % icons.length];
              final pct = (g.studentCount / totalStudents * 100)
                  .toStringAsFixed(0);

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ],
                  border: Border(
                    bottom: BorderSide(color: color, width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 16),
                        ),
                        Text(
                          '$pct%',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      g.studentCount.toString(),
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                        height: 1,
                      ),
                    ),
                    Text(
                      g.gradeName,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.grey500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}