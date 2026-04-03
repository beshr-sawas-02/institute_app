import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/assessment_controller.dart';
import '../../controllers/locale_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/empty_widget.dart';

class AssessmentDetailView extends GetView<AssessmentController> {
  const AssessmentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Obx(() {
      final a = controller.selectedAssessment.value;
      if (a == null)
        return const Scaffold(
            body: Center(child: Text('—')));

      final color = a.gradeColor ?? AppColors.grey400;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text('assessments_detail'.tr,
              style: AppTextStyles.titleSmall
                  .copyWith(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.white),
              onPressed: () {
                controller.populateForm(a);
                Get.toNamed(AppRoutes.assessmentEdit);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.white70),
              onPressed: () =>
                  controller.deleteAssessment(a.id),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Score card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.05)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(a.title,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: scheme.onSurface),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    if (a.score != null) ...[
                      Text(
                        '${a.score}/${a.maxScore}',
                        style: AppTextStyles.displayMedium
                            .copyWith(color: color),
                      ),
                      const SizedBox(height: 8),
                      PercentageBar(
                          value: (a.percentage ?? 0) / 100,
                          color: color,
                          height: 12),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                              Helpers.formatPercentage(
                                  a.percentage ?? 0),
                              style: AppTextStyles.titleMedium
                                  .copyWith(color: color)),
                          const SizedBox(width: 12),
                          StatusBadge(
                              label: a.grade ?? '—',
                              color: color),
                        ],
                      ),
                    ] else
                      Text('assessments_not_graded'.tr,
                          style: AppTextStyles.bodyMedium
                              .copyWith(
                              color: AppColors.grey500)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info card
              Container(
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
                child: Column(
                  children: [
                    InfoRow(
                        icon: Icons.category_outlined,
                        label: 'assessment_detail_type'.tr,
                        value: AppConstants.getAssessmentType(
                            a.type)),
                    if (a.student != null)
                      InfoRow(
                          icon: Icons.person_outline,
                          label: 'assessment_detail_student'.tr,
                          value:
                          '${a.student!.firstName} ${a.student!.lastName}'),
                    if (a.gradeSubject != null)
                      InfoRow(
                          icon: Icons.book_outlined,
                          label: 'assessment_detail_subject'.tr,
                          value: a.gradeSubject!.subject?.name ??
                              '—'),
                    InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'assessment_detail_date'.tr,
                        value:
                        Helpers.formatDate(a.assessmentDate)),
                    if (a.feedback != null)
                      InfoRow(
                          icon: Icons.comment_outlined,
                          label: 'assessment_detail_feedback'.tr,
                          value: a.feedback!),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ==================== Assessment Form ====================

class AssessmentFormView extends StatefulWidget {
  final bool isEdit;
  const AssessmentFormView({super.key, required this.isEdit});

  @override
  State<AssessmentFormView> createState() =>
      _AssessmentFormViewState();
}

class _AssessmentFormViewState extends State<AssessmentFormView> {
  late final AssessmentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AssessmentController>();
    if (!widget.isEdit) {
      controller.loadFormDropdowns();
    }
  }

  bool get isEdit => widget.isEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            controller.clearForm();
            Get.back();
          },
        ),
        title: Text(
          isEdit
              ? 'assessment_form_edit'.tr
              : 'assessment_form_create'.tr,
          style: AppTextStyles.titleMedium
              .copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEdit) ...[
                _label('assessment_form_student'.tr),
                const SizedBox(height: 8),
                Obx(() => controller.isLoadingDropdowns.value
                    ? LinearProgressIndicator(
                    color: AppColors.primary, minHeight: 2)
                    : const SizedBox.shrink()),
                const SizedBox(height: 4),
                _StudentDropdown(
                    controller: controller,
                    inputDeco: _inputDeco(context,
                        hint:
                        'assessment_form_student_hint'.tr)),
                const SizedBox(height: 16),
              ],
              if (!isEdit) ...[
                _label('assessment_form_subject'.tr),
                const SizedBox(height: 8),
                Obx(() => controller.isLoadingDropdowns.value
                    ? LinearProgressIndicator(
                    color: AppColors.primary, minHeight: 2)
                    : const SizedBox.shrink()),
                const SizedBox(height: 4),
                _SubjectDropdown(
                    controller: controller,
                    inputDeco: _inputDeco(context,
                        hint:
                        'assessment_form_subject_hint'.tr)),
                const SizedBox(height: 16),
              ],
              _label('assessment_form_title'.tr),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.titleController,
                validator: (v) => v == null || v.isEmpty
                    ? 'required_field'.tr
                    : null,
                decoration: _inputDeco(context,
                    hint: 'assessment_form_title_hint'.tr),
                style: AppTextStyles.inputText,
              ),
              const SizedBox(height: 16),
              _label('assessment_form_type'.tr),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _typeChip(context, 'exam', 'type_exam'.tr),
                  _typeChip(
                      context, 'quiz', 'type_quiz'.tr),
                  _typeChip(context, 'homework',
                      'type_homework'.tr),
                  _typeChip(context, 'midterm',
                      'type_midterm'.tr),
                  _typeChip(
                      context, 'final', 'type_final'.tr),
                ],
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _label(
                            'assessment_form_max_score'.tr),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller:
                          controller.maxScoreController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) =>
                              controller.onScoreOrMaxChanged(),
                          validator: (v) =>
                          v == null || v.isEmpty
                              ? 'required_field'.tr
                              : null,
                          decoration: _inputDeco(context,
                              hint: '100'),
                          style: AppTextStyles.inputText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _label('assessment_form_score'.tr),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller:
                          controller.scoreController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) =>
                              controller.onScoreOrMaxChanged(),
                          decoration: _inputDeco(context,
                              hint: 'optional'.tr),
                          style: AppTextStyles.inputText,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Obx(() {
                final pct =
                    controller.percentagePreview.value;
                if (pct == null) return const SizedBox.shrink();
                final color = AppColors.getAttendanceColor(
                    pct >= 80
                        ? 'present'
                        : pct >= 60
                        ? 'late'
                        : 'absent');
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: PercentageBar(
                              value: pct / 100,
                              color: color,
                              height: 8)),
                      const SizedBox(width: 10),
                      Text(Helpers.formatPercentage(pct),
                          style: AppTextStyles.labelMedium
                              .copyWith(color: color)),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              _label('assessment_form_date'.tr),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final localeCtrl =
                  Get.find<LocaleController>();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    locale: localeCtrl.currentLocale.value,
                  );
                  if (picked != null) {
                    controller.assessmentDateController.text =
                        picked.toIso8601String().split('T').first;
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller:
                    controller.assessmentDateController,
                    validator: (v) => v == null || v.isEmpty
                        ? 'required_field'.tr
                        : null,
                    decoration: _inputDeco(context,
                        hint: 'assessment_form_date_hint'.tr,
                        suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: AppColors.grey400)),
                    style: AppTextStyles.inputText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _label('assessment_form_feedback'.tr),
              const SizedBox(height: 6),
              TextFormField(
                controller: controller.feedbackController,
                maxLines: 3,
                decoration: _inputDeco(context,
                    hint: 'assessment_form_feedback_hint'.tr),
                style: AppTextStyles.inputText,
              ),
              const SizedBox(height: 32),
              Obx(() => ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () => isEdit
                    ? controller.updateAssessment(
                    controller.selectedAssessment
                        .value!.id)
                    : controller.createAssessment(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize:
                  const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12)),
                ),
                child: controller.isSubmitting.value
                    ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                    : Text(
                  isEdit
                      ? 'assessment_form_save_edit'.tr
                      : 'assessment_form_save_create'
                      .tr,
                  style: AppTextStyles.buttonLarge
                      .copyWith(color: Colors.white),
                ),
              )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(
      BuildContext context, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected =
        controller.selectedType.value == value;
    return GestureDetector(
      onTap: () =>
      controller.selectedType.value = value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border,
              width: isSelected ? 1.5 : 1),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey600,
            fontWeight: isSelected
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: AppTextStyles.inputLabel);

  InputDecoration _inputDeco(BuildContext context,
      {String? hint, Widget? suffixIcon}) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.inputHint,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppColors.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error)),
    );
  }
}

// ==================== Student Assessments ====================

class StudentAssessmentsView
    extends GetView<AssessmentController> {
  const StudentAssessmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final args = Get.arguments as Map?;
    final studentId = args?['studentId'] as int?;
    final studentName =
        args?['studentName'] as String? ?? 'student'.tr;

    if (studentId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
              (_) => controller.loadByStudent(studentId));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('assessments_title'.tr,
                style: AppTextStyles.titleSmall
                    .copyWith(color: Colors.white)),
            Text(studentName,
                style: AppTextStyles.bodySmall
                    .copyWith(color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              controller.clearForm();
              controller.selectedStudentId.value = studentId;
              Get.toNamed(AppRoutes.assessmentCreate);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary));
        }
        if (controller.studentAssessments.isEmpty) {
          return EmptyWidget(
              title: 'assessments_no_student_assessments'.tr,
              icon: Icons.bar_chart_outlined);
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.studentAssessments.length,
          itemBuilder: (_, i) => _AssessmentCard(
              assessment: controller.studentAssessments[i]),
        );
      }),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final assessment;
  const _AssessmentCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = assessment.gradeColor ?? AppColors.grey400;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(right: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Center(
              child: Text(
                assessment.grade ?? '—',
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Cairo'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assessment.title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(children: [
                  StatusBadge(
                      label: AppConstants.getAssessmentType(
                          assessment.type),
                      color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    Helpers.formatDate(
                        assessment.assessmentDate),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.grey500),
                  ),
                ]),
                if (assessment.score != null) ...[
                  const SizedBox(height: 6),
                  PercentageBar(
                      value:
                      (assessment.percentage ?? 0) / 100,
                      color: color,
                      height: 6),
                ],
              ],
            ),
          ),
          if (assessment.score != null)
            Text(
              '${assessment.score}/${assessment.maxScore}',
              style: AppTextStyles.labelMedium
                  .copyWith(color: color),
            ),
        ],
      ),
    );
  }
}

// ==================== Dropdown helpers ====================

class _StudentDropdown extends StatefulWidget {
  final AssessmentController controller;
  final InputDecoration inputDeco;
  const _StudentDropdown(
      {required this.controller, required this.inputDeco});

  @override
  State<_StudentDropdown> createState() =>
      _StudentDropdownState();
}

class _StudentDropdownState extends State<_StudentDropdown> {
  int? _selected;
  Worker? _w1, _w2;

  @override
  void initState() {
    super.initState();
    _selected = widget.controller.selectedStudentId.value;
    _w1 = ever(widget.controller.selectedStudentId, (val) {
      if (mounted) setState(() => _selected = val);
    });
    _w2 = ever(widget.controller.allStudents, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _w1?.dispose();
    _w2?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = widget.controller.allStudents
        .map((s) => DropdownMenuItem<int>(
        value: s.id, child: Text(s.fullName)))
        .toList();
    final validValue =
    items.any((i) => i.value == _selected) ? _selected : null;
    return DropdownButtonFormField<int>(
      value: validValue,
      decoration: widget.inputDeco,
      dropdownColor: scheme.surface,
      isExpanded: true,
      validator: (v) => v == null
          ? 'assessment_form_student_required'.tr
          : null,
      items: items,
      onChanged: (val) {
        setState(() => _selected = val);
        widget.controller.selectedStudentId.value = val;
      },
    );
  }
}

class _SubjectDropdown extends StatefulWidget {
  final AssessmentController controller;
  final InputDecoration inputDeco;
  const _SubjectDropdown(
      {required this.controller, required this.inputDeco});

  @override
  State<_SubjectDropdown> createState() =>
      _SubjectDropdownState();
}

class _SubjectDropdownState extends State<_SubjectDropdown> {
  int? _selected;
  Worker? _w1, _w2;

  @override
  void initState() {
    super.initState();
    _selected =
        widget.controller.selectedGradeSubjectId.value;
    _w1 =
        ever(widget.controller.selectedGradeSubjectId, (val) {
          if (mounted) setState(() => _selected = val);
        });
    _w2 = ever(widget.controller.allGradeSubjects, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _w1?.dispose();
    _w2?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = widget.controller.allGradeSubjects
        .map((gs) => DropdownMenuItem<int>(
        value: gs.id, child: Text(gs.displayName)))
        .toList();
    final validValue =
    items.any((i) => i.value == _selected) ? _selected : null;
    return DropdownButtonFormField<int>(
      value: validValue,
      decoration: widget.inputDeco,
      dropdownColor: scheme.surface,
      isExpanded: true,
      validator: (v) => v == null
          ? 'assessment_form_subject_required'.tr
          : null,
      items: items,
      onChanged: (val) {
        setState(() => _selected = val);
        widget.controller.selectedGradeSubjectId.value = val;
        widget.controller.selectedGradeSubject.value = widget
            .controller.allGradeSubjects
            .firstWhereOrNull((gs) => gs.id == val);
      },
    );
  }
}