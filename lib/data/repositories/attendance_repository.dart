// lib/data/repositories/attendance_repository.dart

import '../../utils/api_endpoints.dart';
import '../models/attendance_model.dart';
import '../providers/api_provider.dart';

class AttendanceRepository {
  final ApiProvider _api = ApiProvider.instance;

  // ==================== Section Sheet ====================

  Future<AttendanceSheet> getSectionSheet(int sectionId, String date) async {
    final response = await _api.get(
      ApiEndpoints.attendanceSectionSheet(sectionId),
      queryParams: {'date': date},
    );
    if (!response.isSuccess) throw Exception(response.error);
    return AttendanceSheet.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  // ==================== Smart Bulk ====================

  Future<SmartBulkResult> smartBulk(SmartBulkAttendanceDto dto) async {
    final response = await _api.post(
      ApiEndpoints.attendanceSmartBulk,
      data: dto.toJson(),
    );
    if (!response.isSuccess) throw Exception(response.error);
    return SmartBulkResult.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  // ==================== Bulk Manual ====================

  Future<Map<String, dynamic>> bulkCreate(BulkAttendanceDto dto) async {
    final response = await _api.post(
      ApiEndpoints.attendanceBulk,
      data: dto.toJson(),
    );
    if (!response.isSuccess) throw Exception(response.error);
    return response.responseData as Map<String, dynamic>;
  }

  // ==================== Single Create ====================

  Future<AttendanceModel> create(CreateAttendanceDto dto) async {
    final response = await _api.post(
      ApiEndpoints.attendance,
      data: dto.toJson(),
    );
    if (!response.isSuccess) throw Exception(response.error);
    return AttendanceModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  // ==================== Get By Student ====================

  Future<List<AttendanceModel>> getByStudent(
      int studentId, {
        String? dateFrom,
        String? dateTo,
      }) async {
    final response = await _api.get(
      ApiEndpoints.attendanceByStudent(studentId),
      queryParams: {
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      },
    );
    if (!response.isSuccess) throw Exception(response.error);

    final data = response.responseData;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ==================== Get By Section + Date ====================

  Future<List<AttendanceModel>> getBySection(
      int sectionId, String date) async {
    final response = await _api.get(
      ApiEndpoints.attendanceBySection(sectionId),
      queryParams: {'date': date},
    );
    if (!response.isSuccess) throw Exception(response.error);

    final data = response.responseData;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ==================== Stats ====================

  Future<AttendanceStats> getStats(
      int studentId, {
        String? dateFrom,
        String? dateTo,
      }) async {
    final response = await _api.get(
      ApiEndpoints.attendanceStats(studentId),
      queryParams: {
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      },
    );
    if (!response.isSuccess) throw Exception(response.error);
    return AttendanceStats.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  // ==================== Update ====================

  Future<AttendanceModel> update(int id, UpdateAttendanceDto dto) async {
    final response = await _api.patch(
      ApiEndpoints.attendanceById(id),
      data: dto.toJson(),
    );
    if (!response.isSuccess) throw Exception(response.error);
    return AttendanceModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  // ==================== Delete ====================

  Future<void> delete(int id) async {
    final response = await _api.delete(ApiEndpoints.attendanceById(id));
    if (!response.isSuccess) throw Exception(response.error);
  }
}