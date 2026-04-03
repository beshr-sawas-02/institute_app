// lib/controllers/assessment_browse_controller.dart

import 'package:get/get.dart';
import '../data/models/grade_model.dart';
import '../data/models/section_model.dart';
import '../data/models/subject_model.dart';
import '../data/models/assessment_model.dart';
import '../data/repositories/payment_repository.dart';
import '../data/repositories/assessment_repository.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class AssessmentBrowseController extends GetxController {
  final GradeRepository _gradeRepo = GradeRepository();
  final SectionRepository _sectionRepo = SectionRepository();
  final AssessmentRepository _assessmentRepo = AssessmentRepository();

  // ==================== Grades level ====================
  final grades = <GradeModel>[].obs;
  final isLoadingGrades = false.obs;

  // ==================== Sections level ====================
  // gradeId -> sections
  final sectionsMap = <int, List<SectionModel>>{}.obs;
  final loadingSections = <int, bool>{}.obs;

  // ==================== GradeSubjects level ====================
  // sectionId -> gradeSubjects (filtered by gradeId of that section)
  final subjectsMap = <int, List<GradeSubjectModel>>{}.obs;
  final loadingSubjects = <int, bool>{}.obs;

  // ==================== Assessments level ====================
  // key: "sectionId_gradeSubjectId" -> assessments
  final assessmentsMap = <String, List<AssessmentModel>>{}.obs;
  final loadingAssessments = <String, bool>{}.obs;

  // ==================== Expansion state ====================
  final expandedGrades = <int>{}.obs;
  final expandedSections = <int>{}.obs;
  final expandedSubjects = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadGrades();
  }

  // ==================== Load grades ====================
  Future<void> loadGrades() async {
    isLoadingGrades.value = true;
    try {
      final result = await _gradeRepo.getAll(limit: 100);
      grades.assignAll(result.data);
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isLoadingGrades.value = false;
    }
  }

  // ==================== Toggle grade ====================
  Future<void> toggleGrade(int gradeId) async {
    if (expandedGrades.contains(gradeId)) {
      expandedGrades.remove(gradeId);
      return;
    }
    expandedGrades.add(gradeId);
    if (sectionsMap.containsKey(gradeId)) return;

    loadingSections[gradeId] = true;
    try {
      final sections = await _sectionRepo.getByGrade(gradeId);
      sectionsMap[gradeId] = sections;
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      loadingSections[gradeId] = false;
    }
  }

  // ==================== Toggle section ====================
  Future<void> toggleSection(int gradeId, int sectionId) async {
    if (expandedSections.contains(sectionId)) {
      expandedSections.remove(sectionId);
      return;
    }
    expandedSections.add(sectionId);
    if (subjectsMap.containsKey(sectionId)) return;

    loadingSubjects[sectionId] = true;
    try {
      // نجيب gradeSubjects الخاصة بهذا الصف
      final allSubjects = await _gradeRepo.getGradeSubjectsForGrade(gradeId);
      subjectsMap[sectionId] = allSubjects;
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      loadingSubjects[sectionId] = false;
    }
  }

  // ==================== Toggle subject ====================
  Future<void> toggleSubject(int sectionId, int gradeSubjectId) async {
    final key = '${sectionId}_$gradeSubjectId';
    if (expandedSubjects.contains(key)) {
      expandedSubjects.remove(key);
      return;
    }
    expandedSubjects.add(key);
    if (assessmentsMap.containsKey(key)) return;

    loadingAssessments[key] = true;
    try {
      final result = await _assessmentRepo.getAllFiltered(
        sectionId: sectionId,
        gradeSubjectId: gradeSubjectId,
      );
      assessmentsMap[key] = result;
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      loadingAssessments[key] = false;
    }
  }

  // ==================== Refresh assessment list ====================
  Future<void> refreshAssessments(int sectionId, int gradeSubjectId) async {
    final key = '${sectionId}_$gradeSubjectId';
    loadingAssessments[key] = true;
    try {
      final result = await _assessmentRepo.getAllFiltered(
        sectionId: sectionId,
        gradeSubjectId: gradeSubjectId,
      );
      assessmentsMap[key] = result;
    } catch (_) {
    } finally {
      loadingAssessments[key] = false;
    }
  }

  // ==================== Helpers ====================
  List<SectionModel> sectionsForGrade(int gradeId) =>
      sectionsMap[gradeId] ?? [];

  List<GradeSubjectModel> subjectsForSection(int sectionId) =>
      subjectsMap[sectionId] ?? [];

  List<AssessmentModel> assessmentsFor(int sectionId, int gradeSubjectId) =>
      assessmentsMap['${sectionId}_$gradeSubjectId'] ?? [];

  bool isGradeExpanded(int gradeId) => expandedGrades.contains(gradeId);
  bool isSectionExpanded(int sectionId) => expandedSections.contains(sectionId);
  bool isSubjectExpanded(int sectionId, int gradeSubjectId) =>
      expandedSubjects.contains('${sectionId}_$gradeSubjectId');

  bool isLoadingSection(int gradeId) => loadingSections[gradeId] ?? false;
  bool isLoadingSubject(int sectionId) => loadingSubjects[sectionId] ?? false;
  bool isLoadingAssessment(int sectionId, int gradeSubjectId) =>
      loadingAssessments['${sectionId}_$gradeSubjectId'] ?? false;
}