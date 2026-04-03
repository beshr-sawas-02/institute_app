// lib/controllers/attendance_controller.dart

import 'package:get/get.dart';
import '../data/models/attendance_model.dart';
import '../data/models/section_model.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/student_repository.dart';
import '../utils/helpers.dart';

class AttendanceController extends GetxController {
  final AttendanceRepository _repo = AttendanceRepository();
  final StudentRepository _studentRepo = StudentRepository();

  // ==================== State ====================
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  final attendanceSheet = Rxn<AttendanceSheet>();
  final exceptions = <int, SmartBulkException>{}.obs;
  final lastBulkResult = Rxn<SmartBulkResult>();
  final studentStats = Rxn<AttendanceStats>();
  final studentHistory = <AttendanceModel>[].obs;
  final selectedDate = DateTime.now().obs;
  final selectedSection = Rxn<SectionModel>();

  // ==================== Load Sheet ====================
  Future<void> loadSheet(int sectionId, String date) async {
    isLoading.value = true;
    errorMessage.value = '';
    exceptions.clear();
    try {
      final sheet = await _repo.getSectionSheet(sectionId, date);
      attendanceSheet.value = sheet;
      for (final entry in sheet.students) {
        if (entry.attendance != null) {
          final att = entry.attendance!;
          if (att.status != 'present') {
            exceptions[entry.studentId] = SmartBulkException(
              studentId: entry.studentId,
              status: att.status,
              lateMinutes: att.lateMinutes,
              notes: att.notes,
            );
          }
        }
      }
    } catch (e) {
      errorMessage.value =
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Toggle Exception ====================
  void setStudentStatus(int studentId, String status,
      {int lateMinutes = 0, String? notes}) {
    if (status == 'present') {
      exceptions.remove(studentId);
    } else {
      exceptions[studentId] = SmartBulkException(
        studentId: studentId,
        status: status,
        lateMinutes: lateMinutes,
        notes: notes,
      );
    }
  }

  String getStudentStatus(int studentId) {
    return exceptions[studentId]?.status ?? 'present';
  }

  int getStudentLateMinutes(int studentId) {
    return exceptions[studentId]?.lateMinutes ?? 0;
  }

  void updateLateMinutes(int studentId, int minutes) {
    final ex = exceptions[studentId];
    if (ex != null) {
      exceptions[studentId] = SmartBulkException(
        studentId: ex.studentId,
        status: ex.status,
        lateMinutes: minutes,
        notes: ex.notes,
      );
    }
  }

  // ==================== Submit Smart Bulk ====================
  Future<void> submitSmartBulk() async {
    final sheet = attendanceSheet.value;
    if (sheet == null) return;

    isSubmitting.value = true;
    try {
      final dto = SmartBulkAttendanceDto(
        sectionId: sheet.sectionId,
        date: Helpers.toApiDate(selectedDate.value),
        exceptions: exceptions.values.toList(),
      );

      final result = await _repo.smartBulk(dto);
      lastBulkResult.value = result;

      await loadSheet(
          sheet.sectionId, Helpers.toApiDate(selectedDate.value));

      Helpers.showSuccess(
          'attendance_success'.tr
              .replaceAll('@present', '${result.summary.present}')
              .replaceAll('@absent', '${result.summary.absent}')
              .replaceAll('@late', '${result.summary.late}'));
    } catch (e) {
      Helpers.showError(
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== Single Attendance ====================
  Future<void> createSingle(CreateAttendanceDto dto) async {
    isSubmitting.value = true;
    try {
      await _repo.create(dto);
      Helpers.showSuccess('attendance_submit'.tr);
    } catch (e) {
      final err = e.toString();
      if (err.contains('409') || err.contains('مسبقاً') || err.contains('conflict')) {
        try {
          final existing = await _repo.getByStudent(
            dto.studentId,
            dateFrom: dto.date,
            dateTo: dto.date,
          );
          if (existing.isNotEmpty) {
            await _repo.update(
              existing.first.id,
              UpdateAttendanceDto(
                status: dto.status,
                lateMinutes: dto.lateMinutes,
                notes: dto.notes,
              ),
            );
            Helpers.showSuccess('attendance_updated'.tr);
          }
        } catch (updateErr) {
          Helpers.showError(
              Helpers.parseApiError(updateErr.toString().replaceAll('Exception: ', '')));
        }
      } else {
        Helpers.showError(
            Helpers.parseApiError(err.toString().replaceAll('Exception: ', '')));
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== Update ====================
  Future<void> updateAttendance(int id, UpdateAttendanceDto dto) async {
    isSubmitting.value = true;
    try {
      final updated = await _repo.update(id, dto);
      final sheet = attendanceSheet.value;
      if (sheet != null) {
        final idx = sheet.students.indexWhere(
                (s) => s.attendance?.id == id);
        if (idx != -1) {
          final entry = sheet.students[idx];
          final newEntry = AttendanceSheetEntry(
            order: entry.order,
            studentId: entry.studentId,
            name: entry.name,
            attendance: updated,
          );
          sheet.students[idx] = newEntry;
          attendanceSheet.refresh();
        }
      }
      Helpers.showSuccess('attendance_updated'.tr);
    } catch (e) {
      Helpers.showError(
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== Delete ====================
  Future<void> deleteAttendance(int id) async {
    final confirmed = await Helpers.showConfirmDialog(
      title: 'attendance_delete_title'.tr,
      message: 'attendance_delete_msg'.tr,
      confirmText: 'delete'.tr,
      isDanger: true,
    );
    if (confirmed != true) return;

    isSubmitting.value = true;
    try {
      await _repo.delete(id);
      Helpers.showSuccess('attendance_deleted'.tr);
      if (attendanceSheet.value != null) {
        await loadSheet(
          attendanceSheet.value!.sectionId,
          Helpers.toApiDate(selectedDate.value),
        );
      }
    } catch (e) {
      Helpers.showError(
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isSubmitting.value = false;
    }
  }

  // ==================== Student History & Stats ====================
  Future<void> loadStudentHistory(int studentId,
      {String? dateFrom, String? dateTo}) async {
    isLoading.value = true;
    try {
      final history = await _repo.getByStudent(studentId,
          dateFrom: dateFrom, dateTo: dateTo);
      studentHistory.assignAll(history);
    } catch (e) {
      Helpers.showError(
          Helpers.parseApiError(e.toString().replaceAll('Exception: ', '')));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStudentStats(int studentId,
      {String? dateFrom, String? dateTo}) async {
    try {
      final stats = await _repo.getStats(studentId,
          dateFrom: dateFrom, dateTo: dateTo);
      studentStats.value = stats;
    } catch (_) {}
  }

  // ==================== Date Picker ====================
  void setDate(DateTime date) {
    selectedDate.value = date;
    if (selectedSection.value != null) {
      loadSheet(
          selectedSection.value!.id, Helpers.toApiDate(date));
    }
  }

  void setSection(SectionModel section) {
    selectedSection.value = section;
    loadSheet(section.id, Helpers.toApiDate(selectedDate.value));
  }

  // ==================== Summary ====================
  Map<String, int> get currentSummary {
    final sheet = attendanceSheet.value;
    if (sheet == null) return {};

    int present = 0, absent = 0, late = 0, excused = 0;
    for (final entry in sheet.students) {
      final status = getStudentStatus(entry.studentId);
      switch (status) {
        case 'present': present++; break;
        case 'absent': absent++; break;
        case 'late': late++; break;
        case 'excused': excused++; break;
      }
    }
    return {
      'present': present,
      'absent': absent,
      'late': late,
      'excused': excused,
    };
  }

  void markAll(String status) {
    final sheet = attendanceSheet.value;
    if (sheet == null) return;
    exceptions.clear();
    if (status != 'present') {
      for (final entry in sheet.students) {
        exceptions[entry.studentId] = SmartBulkException(
          studentId: entry.studentId,
          status: status,
        );
      }
    }
  }

  @override
  void onClose() {
    exceptions.clear();
    super.onClose();
  }
}