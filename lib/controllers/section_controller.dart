// lib/controllers/section_controller.dart

import 'package:get/get.dart';
import '../data/models/grade_model.dart';
import '../data/models/section_model.dart';
import '../data/repositories/payment_repository.dart';
import '../utils/helpers.dart';

class SectionController extends GetxController {
  final SectionRepository _repo = SectionRepository();
  final GradeRepository _gradeRepo = GradeRepository();

  // ==================== State ====================
  final isLoading = false.obs;
  final sections = <SectionModel>[].obs;
  final grades = <GradeModel>[].obs;
  final selectedGradeId = Rxn<int>();
  final errorMessage = ''.obs;

  // ==================== Init ====================
  @override
  void onInit() {
    super.onInit();
    loadAll();
    loadGrades();
  }

  // ==================== Load ====================
  Future<void> loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repo.getAll();
      sections.assignAll(result.data);
    } catch (e) {
      errorMessage.value =
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadByGrade(int gradeId) async {
    isLoading.value = true;
    selectedGradeId.value = gradeId;
    try {
      final result = await _repo.getByGrade(gradeId);
      sections.assignAll(result);
    } catch (e) {
      errorMessage.value =
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGrades() async {
    try {
      final result = await _gradeRepo.getAll();
      grades.assignAll(result.data);
    } catch (_) {}
  }

  // ==================== Filtered Sections ====================
  List<SectionModel> get filteredSections {
    if (selectedGradeId.value == null) return sections;
    return sections
        .where((s) => s.gradeId == selectedGradeId.value)
        .toList();
  }

  List<SectionModel> activeSections() =>
      sections.where((s) => s.isActive).toList();

  List<SectionModel> sectionsByGrade(int gradeId) =>
      sections.where((s) => s.gradeId == gradeId && s.isActive).toList();

  void filterByGrade(int? gradeId) {
    selectedGradeId.value = gradeId;
  }

  Future<void> refresh() => loadAll();
}


// ==================== lib/controllers/grade_controller.dart ====================

class GradeController extends GetxController {
  final GradeRepository _gradeRepo = GradeRepository();

  final isLoading = false.obs;
  final grades = <GradeModel>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadGrades();
  }

  Future<void> loadGrades() async {
    isLoading.value = true;
    try {
      final result = await _gradeRepo.getAll();
      grades.assignAll(result.data);
    } catch (e) {
      errorMessage.value =
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadGrades();
}