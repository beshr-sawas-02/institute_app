// lib/routes/app_routes.dart

abstract class AppRoutes {
  AppRoutes._();

  // ==================== Auth ====================
  static const splash = '/';
  static const login = '/login';
  static const registerReception = '/register-reception';

  // ==================== Main Shell ====================
  static const main = '/main';

  // ==================== Attendance ====================
  static const attendance = '/attendance';
  static const attendanceSheet = '/attendance/sheet';
  static const attendanceStudentHistory = '/attendance/student-history';
  static const singleAttendance = '/attendance/single';

  // ==================== Assessments ====================
  static const assessments = '/assessments';
  static const assessmentDetail = '/assessments/detail';
  static const assessmentCreate = '/assessments/create';
  static const assessmentEdit = '/assessments/edit';
  static const studentAssessments = '/assessments/student';
  static const subjectAssessments = '/assessments/subject';
  // ==================== Reports ====================
  static const reports = '/reports';

  // ==================== Profile ====================
  static const profile = '/profile';
  static const changePassword = '/profile/change-password';
}