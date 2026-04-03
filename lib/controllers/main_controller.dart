// lib/controllers/main_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_controller.dart';

class MainController extends GetxController {
  // ==================== State ====================
  final currentIndex = 0.obs;
  late final PageController pageController;

  final List<String> pageTitles = [
    'لوحة التحكم',
    'الحضور',
    'التقييمات',
    'التقارير',
    'حسابي',
  ];

  // ==================== Init ====================
  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  // ==================== Navigation ====================
  void changePage(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
    // تحديث الداشبورد تلقائياً لما نرجع إليه
    if (index == 0) {
      try {
        Get.find<DashboardController>().refresh();
      } catch (_) {}
    }
  }

  void goToDashboard() => changePage(0);
  void goToAttendance() => changePage(1);
  void goToAssessments() => changePage(2);

  String get currentTitle => pageTitles[currentIndex.value];

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}