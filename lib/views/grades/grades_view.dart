import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/assessment_browse_controller.dart';
import '../../controllers/assessment_controller.dart';
import '../../data/models/grade_model.dart';
import '../../data/models/section_model.dart';
import '../../data/models/subject_model.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/loading_widget.dart';

class GradesView extends StatefulWidget {
  const GradesView({super.key});

  @override
  State<GradesView> createState() => _GradesViewState();
}

class _GradesViewState extends State<GradesView> {
  late final AssessmentBrowseController ctrl;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AssessmentBrowseController>()) {
      Get.put(AssessmentBrowseController());
    }
    ctrl = Get.find<AssessmentBrowseController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text('assessments_title'.tr,
            style: AppTextStyles.titleMedium
                .copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              if (!Get.isRegistered<AssessmentController>()) {
                Get.lazyPut(() => AssessmentController());
              }
              Get.find<AssessmentController>().clearForm();
              Get.find<AssessmentController>().loadFormDropdowns();
              Get.toNamed(AppRoutes.assessmentCreate);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoadingGrades.value) {
          return ListView.builder(
            itemCount: 4,
            itemBuilder: (_, __) => const ShimmerCard(),
          );
        }
        if (ctrl.grades.isEmpty) {
          return EmptyWidget(
            title: 'assessments_empty'.tr,
            icon: Icons.school_outlined,
            actionLabel: 'refresh'.tr,
            onAction: ctrl.loadGrades,
          );
        }
        return RefreshIndicator(
          onRefresh: ctrl.loadGrades,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ctrl.grades.length,
            itemBuilder: (_, i) => _GradeTile(
              grade: ctrl.grades[i],
              ctrl: ctrl,
            ),
          ),
        );
      }),
    );
  }
}

class _GradeTile extends StatelessWidget {
  final GradeModel grade;
  final AssessmentBrowseController ctrl;

  const _GradeTile({required this.grade, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isExpanded = ctrl.isGradeExpanded(grade.id);
      final isLoading = ctrl.isLoadingSection(grade.id);
      final sections = ctrl.sectionsForGrade(grade.id);

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
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
          children: [
            InkWell(
              onTap: () => ctrl.toggleGrade(grade.id),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.school_outlined,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(grade.name,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(
                                  fontWeight: FontWeight.w700)),
                          Text(
                              AppConstants.getGradeLevel(
                                  grade.level),
                              style: AppTextStyles.bodySmall
                                  .copyWith(
                                  color: AppColors.grey500)),
                        ],
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary),
                      )
                    else
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.grey500),
                      ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(height: 1, color: AppColors.border),
              if (sections.isEmpty && !isLoading)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('assessments_no_sections'.tr,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey400)),
                )
              else
                ...sections.map((s) => _SectionTile(
                  section: s,
                  grade: grade,
                  ctrl: ctrl,
                )),
            ],
          ],
        ),
      );
    });
  }
}

class _SectionTile extends StatelessWidget {
  final SectionModel section;
  final GradeModel grade;
  final AssessmentBrowseController ctrl;

  const _SectionTile(
      {required this.section,
        required this.grade,
        required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final isExpanded = ctrl.isSectionExpanded(section.id);
      final isLoading = ctrl.isLoadingSubject(section.id);
      final subjects = ctrl.subjectsForSection(section.id);

      return Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          border: Border(
            right: BorderSide(
                color: AppColors.primary.withOpacity(0.3),
                width: 3),
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () =>
                  ctrl.toggleSection(grade.id, section.id),
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(24, 12, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.door_front_door_outlined,
                          color: AppColors.info, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(section.name,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(
                                  fontWeight: FontWeight.w600)),
                          Text(
                              'attendance_student_count'.tr
                                  .replaceAll('@count',
                                  '${section.studentCount ?? 0}'),
                              style: AppTextStyles.bodySmall
                                  .copyWith(
                                  color: AppColors.grey500)),
                        ],
                      ),
                    ),
                    if (isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.info),
                      )
                    else
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.grey400,
                            size: 20),
                      ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              if (subjects.isEmpty && !isLoading)
                Padding(
                  padding:
                  const EdgeInsets.fromLTRB(32, 8, 16, 12),
                  child: Text('assessments_no_subjects'.tr,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.grey400)),
                )
              else
                ...subjects.map((gs) => _SubjectTile(
                  gradeSubject: gs,
                  section: section,
                )),
            ],
            Divider(
                height: 1,
                indent: 16,
                color: AppColors.border),
          ],
        ),
      );
    });
  }
}

class _SubjectTile extends StatelessWidget {
  final GradeSubjectModel gradeSubject;
  final SectionModel section;

  const _SubjectTile(
      {required this.gradeSubject, required this.section});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(
        AppRoutes.subjectAssessments,
        arguments: {
          'sectionId': section.id,
          'gradeSubjectId': gradeSubject.id,
          'gradeSubject': gradeSubject,
          'sectionName':
          '${section.grade?.name ?? ''} - ${section.name}',
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
                color: AppColors.success.withOpacity(0.4),
                width: 3),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(36, 11, 16, 11),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.book_outlined,
                  color: AppColors.success, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gradeSubject.subject?.name ?? '—',
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  if (gradeSubject.teacher != null)
                    Text(
                      gradeSubject.teacher!.fullName,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500, fontSize: 11),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.grey400, size: 20),
          ],
        ),
      ),
    );
  }
}