// lib/utils/api_endpoints.dart

class ApiEndpoints {
  ApiEndpoints._();

  // --- Base ---
  static const String baseUrl = 'https://institute-managemnt.vercel.app';
//  static const String baseUrl = 'http://172.20.10.2:3000';

  // ==================== Auth ====================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerReception = '/auth/register-reception';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // ==================== Users ====================
  static const String users = '/users';
  static String userById(int id) => '/users/$id';

  // ==================== Students ====================
  static const String students = '/students';
  static String studentById(int id) => '/students/$id';
  static String studentsBySection(int sectionId) => '/students/section/$sectionId';
  static String studentsByParent(int parentId) => '/students/parent/$parentId';

  // ==================== Parents ====================
  static const String parents = '/parents';
  static String parentById(int id) => '/parents/$id';

  // ==================== Teachers ====================
  static const String teachers = '/teachers';
  static String teacherById(int id) => '/teachers/$id';

  // ==================== Grades ====================
  static const String grades = '/grades';
  static String gradeById(int id) => '/grades/$id';

  // ==================== Sections ====================
  static const String sections = '/sections';
  static String sectionById(int id) => '/sections/$id';
  static String sectionsByGrade(int gradeId) => '/sections/grade/$gradeId';

  // ==================== Subjects ====================
  static const String subjects = '/subjects';
  static String subjectById(int id) => '/subjects/$id';

  // ==================== Grade Subjects ====================
  static const String gradeSubjects = '/grade-subjects';
  static String gradeSubjectById(int id) => '/grade-subjects/$id';
  static String gradeSubjectsByGrade(int gradeId) => '/grade-subjects/grade/$gradeId';
  static String gradeSubjectsByTeacher(int teacherId) => '/grade-subjects/teacher/$teacherId';

  // ==================== Schedules ====================
  static const String schedules = '/schedules';
  static String scheduleById(int id) => '/schedules/$id';
  static String schedulesBySection(int sectionId) => '/schedules/section/$sectionId';
  static String schedulesByTeacher(int teacherId) => '/schedules/teacher/$teacherId';

  // ==================== Attendance ====================
  static const String attendance = '/attendance';
  static const String attendanceBulk = '/attendance/bulk';
  static const String attendanceSmartBulk = '/attendance/smart-bulk';
  static String attendanceById(int id) => '/attendance/$id';
  static String attendanceSectionSheet(int sectionId) => '/attendance/section/$sectionId/sheet';
  static String attendanceBySection(int sectionId) => '/attendance/section/$sectionId';
  static String attendanceByStudent(int studentId) => '/attendance/student/$studentId';
  static String attendanceStats(int studentId) => '/attendance/stats/$studentId';

  // ==================== Assessments ====================
  static const String assessments = '/assessments';
  static String assessmentById(int id) => '/assessments/$id';
  static String assessmentsByStudent(int studentId) => '/assessments/student/$studentId';

  // ==================== Payments ====================
  static const String payments = '/payments';
  static const String paymentsStats = '/payments/stats';
  static String paymentById(int id) => '/payments/$id';
  static String paymentsByStudent(int studentId) => '/payments/student/$studentId';

  // ==================== Expenses ====================
  static const String expenses = '/expenses';
  static const String expensesStats = '/expenses/stats';
  static String expenseById(int id) => '/expenses/$id';

  // ==================== Notifications ====================
  static const String notifications = '/notifications';
  static const String notificationsBulk = '/notifications/bulk';
  static const String notificationsMy = '/notifications/my';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationById(int id) => '/notifications/$id';
  static String notificationMarkRead(int id) => '/notifications/$id/read';

  // ==================== Reports ====================
  static const String reports = '/reports';
  static String reportById(int id) => '/reports/$id';

  // ==================== Monthly Reports ====================
  static String monthlyReportStudent(int studentId) => '/reports/monthly/student/$studentId';
  static String monthlyReportSection(int sectionId) => '/reports/monthly/section/$sectionId';
  static String monthlyReportSectionNotify(int sectionId) => '/reports/monthly/section/$sectionId/notify';
  static const String monthlyReportAllNotify = '/reports/monthly/all/notify';

  // ==================== Dashboard ====================
  static const String dashboard = '/dashboard';
  static const String dashboardFinancial = '/dashboard/financial';
  static const String dashboardAttendance = '/dashboard/attendance';
}