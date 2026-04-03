// lib/controllers/report_controller.dart

import 'package:get/get.dart';
import '../data/models/report_model.dart';
import '../data/models/section_model.dart';
import '../data/repositories/report_repository.dart';
import '../data/repositories/payment_repository.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class ReportController extends GetxController {
  final ReportRepository _repo = ReportRepository();
  final SectionRepository _sectionRepo = SectionRepository();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final reports = <ReportModel>[].obs;
  final selectedReport = Rxn<ReportModel>();
  final errorMessage = ''.obs;

  final selectedType = 'attendance'.obs;
  String? periodStart;
  String? periodEnd;

  // ==================== Monthly Report State ====================
  final isMonthlyLoading = false.obs;
  final isMonthlySubmitting = false.obs;
  final monthlyData = Rxn<Map<String, dynamic>>();
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  final sections = <SectionModel>[].obs;
  final selectedSectionId = Rxn<int>();
  final isSectionsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
    loadSections();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repo.getAll();
      reports.assignAll(result.data);
    } catch (e) {
      errorMessage.value = Helpers.parseApiError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createReport({
    required String type,
    required String title,
    required String start,
    required String end,
  }) async {
    isSubmitting.value = true;
    try {
      final dto = CreateReportDto(
        type: type,
        title: title,
        periodStart: start,
        periodEnd: end,
      );
      final created = await _repo.create(dto);
      reports.insert(0, created);
      Helpers.showSuccess('reports_created'.tr);
      Get.back();
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteReport(int id) async {
    final confirmed = await Helpers.showConfirmDialog(
      title: 'reports_delete_title'.tr,
      message: 'reports_delete_msg'.tr,
      confirmText: 'delete'.tr,
      isDanger: true,
    );
    if (confirmed != true) return;
    try {
      await _repo.delete(id);
      reports.removeWhere((r) => r.id == id);
      Helpers.showSuccess('reports_deleted'.tr);
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  // ==================== Monthly Reports ====================

  Future<void> loadSections() async {
    isSectionsLoading.value = true;
    try {
      final result = await _sectionRepo.getAll(limit: 100);
      sections.assignAll(result.data.where((s) => s.isActive));
    } catch (_) {}
    finally {
      isSectionsLoading.value = false;
    }
  }

  Future<void> loadMonthlySectionReport(int sectionId, int month, int year) async {
    isMonthlyLoading.value = true;
    monthlyData.value = null;
    try {
      final data = await _repo.getMonthlySectionReport(sectionId, month, year);
      monthlyData.value = data;
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isMonthlyLoading.value = false;
    }
  }

  Future<void> sendMonthlySectionReport(int sectionId, int month, int year) async {
    isMonthlySubmitting.value = true;
    try {
      final result = await _repo.generateAndNotifySection(sectionId, month, year);
      final notified = result['notifiedParents'] ?? 0;
      final total = result['totalStudents'] ?? 0;
      Helpers.showSuccess(
        'reports_sent_success'.tr
            .replaceAll('@notified', '$notified')
            .replaceAll('@total', '$total'),
      );
      await loadAll();
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isMonthlySubmitting.value = false;
    }
  }

  Future<void> sendMonthlyAllSections(int month, int year) async {
    isMonthlySubmitting.value = true;
    try {
      final result = await _repo.generateAndNotifyAll(month, year);
      final notified = result['totalNotified'] ?? 0;
      final totalSections = result['totalSections'] ?? 0;
      Helpers.showSuccess(
        'reports_sent_all_success'.tr
            .replaceAll('@sections', '$totalSections')
            .replaceAll('@notified', '$notified'),
      );
      await loadAll();
    } catch (e) {
      Helpers.showError(Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isMonthlySubmitting.value = false;
    }
  }

  // ==================== Helpers ====================

  String monthName(int month) => AppConstants.getMonthName(month);
}