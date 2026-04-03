// lib/controllers/assessment_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/assessment_model.dart';
import '../data/models/student_model.dart';
import '../data/models/subject_model.dart';
import '../data/repositories/assessment_repository.dart';
import '../data/repositories/student_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../utils/helpers.dart';

class AssessmentController extends GetxController {
  final AssessmentRepository _repo = AssessmentRepository();
  final StudentRepository _studentRepo = StudentRepository();
  final GradeRepository _gradeRepo = GradeRepository();

  // ==================== State ====================
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final assessments = <AssessmentModel>[].obs;
  final studentAssessments = <AssessmentModel>[].obs;
  final selectedAssessment = Rxn<AssessmentModel>();
  final errorMessage = ''.obs;

  final currentPage = 1.obs;
  final hasMore = false.obs;

  final allStudents = <StudentModel>[].obs;
  final allGradeSubjects = <GradeSubjectModel>[].obs;
  final isLoadingDropdowns = false.obs;

  // Form
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final maxScoreController = TextEditingController();
  final scoreController = TextEditingController();
  final feedbackController = TextEditingController();
  final assessmentDateController = TextEditingController();
  final selectedType = 'exam'.obs;
  final selectedStudentId = Rxn<int>();
  final selectedGradeSubjectId = Rxn<int>();
  final selectedGradeSubject = Rxn<GradeSubjectModel>();

  final percentagePreview = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    ever(scoreController.obs, (_) => _updatePreview());
  }

  Future<void> loadAll({bool reset = true}) async {
    if (reset) {
      currentPage.value = 1;
      assessments.clear();
    }
    isLoading.value = reset;
    errorMessage.value = '';
    try {
      final result = await _repo.getAll(page: currentPage.value);
      if (reset) {
        assessments.assignAll(result.data);
      } else {
        assessments.addAll(result.data);
      }
      hasMore.value = result.meta.hasNextPage;
    } catch (e) {
      errorMessage.value =
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadFormDropdowns() async {
    isLoadingDropdowns.value = true;
    try {
      final results = await Future.wait([
        _studentRepo.getAll(limit: 100),
        _gradeRepo.getGradeSubjects(),
      ]);
      allStudents.assignAll((results[0] as dynamic).data);
      allGradeSubjects.assignAll(results[1] as List<GradeSubjectModel>);
    } catch (e) {
      // silent fail
    } finally {
      isLoadingDropdowns.value = false;
    }
  }

  Future<void> loadByStudent(int studentId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repo.getByStudent(studentId);
      studentAssessments.assignAll(result);
    } catch (e) {
      errorMessage.value =
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAssessment() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedStudentId.value == null) {
      Helpers.showWarning('assessment_form_select_student_warning'.tr);
      return;
    }
    if (selectedGradeSubjectId.value == null) {
      Helpers.showWarning('assessment_form_select_subject_warning'.tr);
      return;
    }

    isSubmitting.value = true;
    try {
      final maxScore = double.parse(maxScoreController.text);
      final score = scoreController.text.isEmpty
          ? null
          : double.tryParse(scoreController.text);

      final dto = CreateAssessmentDto(
        studentId: selectedStudentId.value!,
        gradeSubjectId: selectedGradeSubjectId.value!,
        type: selectedType.value,
        title: titleController.text.trim(),
        maxScore: maxScore,
        score: score,
        feedback: feedbackController.text.trim().isEmpty
            ? null
            : feedbackController.text.trim(),
        assessmentDate: assessmentDateController.text.trim(),
      );

      final created = await _repo.create(dto);
      assessments.insert(0, created);

      if (studentAssessments.isNotEmpty &&
          studentAssessments.first.studentId == selectedStudentId.value) {
        studentAssessments.insert(0, created);
      }

      Helpers.showSuccess('assessment_created'.tr);
      clearForm();
      Get.back();
    } catch (e) {
      Helpers.showError(
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateAssessment(int id) async {
    if (!formKey.currentState!.validate()) return;
    isSubmitting.value = true;
    try {
      final maxScore = double.tryParse(maxScoreController.text);
      final score = scoreController.text.isEmpty
          ? null
          : double.tryParse(scoreController.text);

      final dto = UpdateAssessmentDto(
        title: titleController.text.trim().isEmpty
            ? null
            : titleController.text.trim(),
        type: selectedType.value,
        maxScore: maxScore,
        score: score,
        feedback: feedbackController.text.trim().isEmpty
            ? null
            : feedbackController.text.trim(),
        assessmentDate: assessmentDateController.text.trim().isEmpty
            ? null
            : assessmentDateController.text.trim(),
      );

      final updated = await _repo.update(id, dto);
      _replaceInList(assessments, updated);
      _replaceInList(studentAssessments, updated);
      if (selectedAssessment.value?.id == id) {
        selectedAssessment.value = updated;
      }

      Helpers.showSuccess('assessment_updated'.tr);
      Get.back();
    } catch (e) {
      Helpers.showError(
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteAssessment(int id) async {
    final confirmed = await Helpers.showConfirmDialog(
      title: 'assessment_delete_title'.tr,
      message: 'assessment_delete_msg'.tr,
      confirmText: 'delete'.tr,
      isDanger: true,
    );
    if (confirmed != true) return;

    isSubmitting.value = true;
    try {
      await _repo.delete(id);
      assessments.removeWhere((a) => a.id == id);
      studentAssessments.removeWhere((a) => a.id == id);
      if (selectedAssessment.value?.id == id) selectedAssessment.value = null;
      Helpers.showSuccess('assessment_deleted'.tr);
      if (Get.currentRoute.contains('detail')) Get.back();
    } catch (e) {
      Helpers.showError(
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== Form Helpers ====================
  void populateForm(AssessmentModel a) {
    titleController.text = a.title;
    maxScoreController.text = a.maxScore.toString();
    scoreController.text = a.score?.toString() ?? '';
    feedbackController.text = a.feedback ?? '';
    assessmentDateController.text = a.assessmentDate.split('T').first;
    selectedType.value = a.type;
    selectedStudentId.value = a.studentId;
    selectedGradeSubjectId.value = a.gradeSubjectId;
    selectedGradeSubject.value = a.gradeSubject;
    _updatePreview();
  }

  void clearForm() {
    titleController.clear();
    maxScoreController.clear();
    scoreController.clear();
    feedbackController.clear();
    assessmentDateController.clear();
    selectedType.value = 'exam';
    selectedStudentId.value = null;
    selectedGradeSubjectId.value = null;
    selectedGradeSubject.value = null;
    percentagePreview.value = null;
  }

  void _updatePreview() {
    final score = double.tryParse(scoreController.text);
    final max = double.tryParse(maxScoreController.text);
    if (score != null && max != null && max > 0) {
      percentagePreview.value = (score / max) * 100;
    } else {
      percentagePreview.value = null;
    }
  }

  void onScoreOrMaxChanged() => _updatePreview();

  void _replaceInList(RxList<AssessmentModel> list, AssessmentModel updated) {
    final idx = list.indexWhere((a) => a.id == updated.id);
    if (idx != -1) list[idx] = updated;
  }

  Map<String, dynamic> computeStudentStats(List<AssessmentModel> list) {
    if (list.isEmpty) return {};
    final withScore = list.where((a) => a.percentage != null).toList();
    if (withScore.isEmpty) return {'count': list.length};

    final avg =
        withScore.map((a) => a.percentage!).reduce((a, b) => a + b) /
            withScore.length;

    final Map<String, int> gradeCount = {};
    for (final a in withScore) {
      final g = a.grade ?? '—';
      gradeCount[g] = (gradeCount[g] ?? 0) + 1;
    }

    return {
      'count': list.length,
      'average': avg,
      'averageLabel': Helpers.calcGrade(avg),
      'gradeCount': gradeCount,
    };
  }

  @override
  void onClose() {
    titleController.dispose();
    maxScoreController.dispose();
    scoreController.dispose();
    feedbackController.dispose();
    assessmentDateController.dispose();
    super.onClose();
  }
}