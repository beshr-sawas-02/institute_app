import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/assessment_browse_controller.dart';
import '../../controllers/assessment_controller.dart';
import '../../data/models/assessment_model.dart';
import '../../data/models/subject_model.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/loading_widget.dart';

class SubjectAssessmentsView extends StatefulWidget {
  const SubjectAssessmentsView({super.key});

  @override
  State<SubjectAssessmentsView> createState() => _SubjectAssessmentsViewState();
}

class _SubjectAssessmentsViewState extends State<SubjectAssessmentsView> {
  late final AssessmentBrowseController browseCtrl;
  late final int sectionId;
  late final int gradeSubjectId;
  late final GradeSubjectModel gradeSubject;
  late final String sectionName;

  @override
  void initState() {
    super.initState();
    browseCtrl = Get.find<AssessmentBrowseController>();

    final args = Get.arguments as Map;
    sectionId = args['sectionId'] as int;
    gradeSubjectId = args['gradeSubjectId'] as int;
    gradeSubject = args['gradeSubject'] as GradeSubjectModel;
    sectionName = args['sectionName'] as String? ?? '';

    final key = '${sectionId}_$gradeSubjectId';
    if (!browseCtrl.assessmentsMap.containsKey(key)) {
      browseCtrl.refreshAssessments(sectionId, gradeSubjectId);
    }
  }

  List<AssessmentModel> get assessments =>
      browseCtrl.assessmentsFor(sectionId, gradeSubjectId);

  bool get isLoading =>
      browseCtrl.isLoadingAssessment(sectionId, gradeSubjectId);

  void _openAddAssessment() {
    if (!Get.isRegistered<AssessmentController>()) {
      Get.lazyPut(() => AssessmentController());
    }
    final ac = Get.find<AssessmentController>();
    ac.clearForm();
    ac.selectedGradeSubjectId.value = gradeSubjectId;
    ac.selectedGradeSubject.value = gradeSubject;
    ac.loadFormDropdowns();
    Get.toNamed(AppRoutes.assessmentCreate)?.then((_) {
      browseCtrl.refreshAssessments(sectionId, gradeSubjectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gradeSubject.subject?.name ?? '—',
                style: AppTextStyles.titleSmall.copyWith(color: Colors.white)),
            Text(sectionName,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _openAddAssessment,
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (_, __) => const ShimmerCard(),
          );
        }

        if (assessments.isEmpty) {
          return EmptyWidget(
            title: 'assessments_no_assessments'.tr,
            icon: Icons.bar_chart_outlined,
            actionLabel: 'assessments_add'.tr,
            onAction: _openAddAssessment,
          );
        }

        final grouped = <String, List<AssessmentModel>>{};
        for (final a in assessments) {
          grouped.putIfAbsent(a.title, () => []).add(a);
        }

        return RefreshIndicator(
          onRefresh: () =>
              browseCtrl.refreshAssessments(sectionId, gradeSubjectId),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _StatsHeader(assessments: assessments),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final title = grouped.keys.elementAt(i);
                      final list = grouped[title]!;
                      return _AssessmentGroup(
                        title: title,
                        assessments: list,
                        onTapAssessment: (a) {
                          if (!Get.isRegistered<AssessmentController>()) {
                            Get.lazyPut(() => AssessmentController());
                          }

                          final controller = Get.find<AssessmentController>();
                          controller.selectedAssessment.value = a;

                          Get.toNamed(AppRoutes.assessmentDetail)?.then((_) {
                            browseCtrl.refreshAssessments(
                                sectionId, gradeSubjectId);
                          });
                        },
                      );
                    },
                    childCount: grouped.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ==================== Stats Header ====================

class _StatsHeader extends StatelessWidget {
  final List<AssessmentModel> assessments;

  const _StatsHeader({required this.assessments});

  @override
  Widget build(BuildContext context) {
    final withScore = assessments.where((a) => a.percentage != null).toList();
    final avg = withScore.isEmpty
        ? null
        : withScore.map((a) => a.percentage!).reduce((a, b) => a + b) /
            withScore.length;

    final passing = withScore.where((a) => a.percentage! >= 50).length;
    final failing = withScore.length - passing;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.9), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StatItem(
              label: 'assessment_stat_total'.tr,
              value: assessments.length.toString(),
              icon: Icons.assignment_outlined),
          _Divider(),
          _StatItem(
              label: 'assessment_stat_avg'.tr,
              value: avg != null ? '${avg.toStringAsFixed(1)}%' : '—',
              icon: Icons.percent),
          _Divider(),
          _StatItem(
              label: 'assessment_stat_pass'.tr,
              value: passing.toString(),
              icon: Icons.check_circle_outline,
              color: Colors.greenAccent),
          _Divider(),
          _StatItem(
              label: 'assessment_stat_fail'.tr,
              value: failing.toString(),
              icon: Icons.cancel_outlined,
              color: Colors.redAccent.shade100),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem(
      {required this.label,
      required this.value,
      required this.icon,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: c,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo')),
          Text(label,
              style: TextStyle(
                  color: Colors.white60, fontSize: 10, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 40, color: Colors.white.withOpacity(0.2));
  }
}

// ==================== Assessment Group ====================

class _AssessmentGroup extends StatelessWidget {
  final String title;
  final List<AssessmentModel> assessments;
  final void Function(AssessmentModel) onTapAssessment;

  const _AssessmentGroup(
      {required this.title,
      required this.assessments,
      required this.onTapAssessment});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.assignment_outlined,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(title,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700))),
                StatusBadge(
                  label: AppConstants.getAssessmentType(assessments.first.type),
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          ...assessments.map((a) =>
              _StudentScoreRow(assessment: a, onTap: () => onTapAssessment(a))),
        ],
      ),
    );
  }
}

// ==================== Student Score Row ====================

class _StudentScoreRow extends StatelessWidget {
  final AssessmentModel assessment;
  final VoidCallback onTap;

  const _StudentScoreRow({required this.assessment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = assessment.gradeColor ?? AppColors.grey400;
    final student = assessment.student;
    final name = student != null
        ? '${student.firstName} ${student.lastName}'
        : '${'student'.tr} #${assessment.studentId}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.08),
              child: Text(
                name.isNotEmpty ? name[0] : '؟',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(name,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w500)),
            ),
            if (assessment.hasScore) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(assessment.scoreDisplay,
                      style: AppTextStyles.labelMedium.copyWith(color: color)),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: 80,
                    child: PercentageBar(
                        value: (assessment.percentage ?? 0) / 100,
                        color: color,
                        height: 5),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  assessment.grade ?? '—',
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Cairo'),
                ),
              ),
            ] else
              Text('assessments_not_graded_short'.tr,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.grey400)),
          ],
        ),
      ),
    );
  }
}
