// lib/bindings/app_bindings.dart

import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/assessment_controller.dart';
import '../controllers/assessment_browse_controller.dart';
import '../controllers/section_controller.dart';
import '../controllers/main_controller.dart';
import '../controllers/report_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<SectionController>(() => SectionController());
    Get.lazyPut<ReportController>(() => ReportController());
  }
}

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceController>(() => AttendanceController());
    if (!Get.isRegistered<SectionController>()) {
      Get.lazyPut<SectionController>(() => SectionController());
    }
  }
}

class AssessmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssessmentController>(() => AssessmentController());
    Get.lazyPut<AssessmentBrowseController>(() => AssessmentBrowseController());
  }
}

class ReportsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportController>(() => ReportController());
  }
}