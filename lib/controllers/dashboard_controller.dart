// lib/controllers/dashboard_controller.dart

import 'package:get/get.dart';
import '../data/models/dashboard_model.dart';
import '../data/repositories/payment_repository.dart';
import '../utils/helpers.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repo = DashboardRepository();

  // ==================== State ====================
  final isLoading = false.obs;
  final isFinancialLoading = false.obs;
  final stats = Rxn<DashboardStats>();
  final financialSummary = Rxn<FinancialSummary>();
  final errorMessage = ''.obs;

  // Selected month/year for financial
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  // ==================== Init ====================
  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadFinancialSummary();
  }


  // ==================== Load Stats ====================
  Future<void> loadStats({bool showLoader = true}) async {
    if (showLoader) isLoading.value = true;
    errorMessage.value = '';
    try {
      final data = await _repo.getStats();
      stats.value = data;
    } catch (e) {
      errorMessage.value = Helpers.parseApiError(
          e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Load Financial ====================
  Future<void> loadFinancialSummary() async {
    isFinancialLoading.value = true;
    try {
      final data = await _repo.getFinancialSummary(
        month: selectedMonth.value,
        year: selectedYear.value,
      );
      financialSummary.value = data;
    } catch (_) {
      // silent
    } finally {
      isFinancialLoading.value = false;
    }
  }

  // ==================== Change Month ====================
  void changeMonth(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadFinancialSummary();
  }

  // ==================== Refresh ====================
  Future<void> refresh() async {
    await Future.wait([
      loadStats(showLoader: false),
      loadFinancialSummary(),
    ]);
  }

  // ==================== Getters ====================
  TodayAttendance? get todayAttendance => stats.value?.todayAttendance;
  FinancialStats? get financial => stats.value?.financial;
  OverviewStats? get overview => stats.value?.overview;
  AssessmentStats? get assessments => stats.value?.assessments;
  List<GradeDistribution> get gradeDistribution =>
      stats.value?.gradeDistribution ?? [];
  List<RecentPayment> get recentPayments =>
      stats.value?.recentPayments ?? [];
  List<RecentAbsence> get recentAbsences =>
      stats.value?.recentAbsences ?? [];
  int get unreadNotifications =>
      stats.value?.notifications.unread ?? 0;
}