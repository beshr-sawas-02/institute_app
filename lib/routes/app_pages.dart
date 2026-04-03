// lib/routes/app_pages.dart

import 'package:get/get.dart';
import '../bindings/app_bindings.dart';
import '../middlewares/auth_middleware.dart';
import '../views/attendance/student_attendance_history_view.dart';
import '../views/attendance/single_attendance_view.dart';
import '../views/auth/register_reception_view.dart';
import '../views/splash/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/main/main_view.dart';
import '../views/attendance/attendance_view.dart';
import '../views/attendance/attendance_sheet_view.dart';
import '../views/grades/grades_view.dart';
import '../views/grades/assessment_detail_view.dart';
import '../views/grades/assessment_form_view.dart';
import '../views/grades/subject_assessments_view.dart';
import '../views/profile/profile_view.dart';
import '../views/profile/change_password_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    // ==================== Splash ====================
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ==================== Auth ====================
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.registerReception,
      page: () => const RegisterReceptionView(),
      middlewares: [GuestGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    // ==================== Main Shell ====================
    GetPage(
      name: AppRoutes.main,
      page: () => const MainView(),
      binding: MainBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ==================== Attendance ====================
    GetPage(
      name: AppRoutes.attendance,
      page: () => const AttendanceView(),
      binding: AttendanceBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.attendanceSheet,
      page: () => const AttendanceSheetView(),
      binding: AttendanceBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.attendanceStudentHistory,
      page: () => const StudentAttendanceHistoryView(),
      binding: AttendanceBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.singleAttendance,
      page: () => const SingleAttendanceView(),
      binding: AttendanceBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),

    // ==================== Assessments ====================
    GetPage(
      name: AppRoutes.assessments,
      page: () => const GradesView(),
      binding: AssessmentsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.assessmentDetail,
      page: () => const AssessmentDetailView(),
      binding: AssessmentsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.assessmentCreate,
      page: () => const AssessmentFormView(isEdit: false),
      binding: AssessmentsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.assessmentEdit,
      page: () => const AssessmentFormView(isEdit: true),
      binding: AssessmentsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.studentAssessments,
      page: () => const StudentAssessmentsView(),
      binding: AssessmentsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.subjectAssessments,
      page: () => const SubjectAssessmentsView(),
      binding: AssessmentsBinding(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),

    // ==================== Profile ====================
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      middlewares: [AuthGuard()],
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 280),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordView(),
      middlewares: [AuthGuard()],
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}