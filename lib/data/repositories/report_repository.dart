// lib/data/repositories/report_repository.dart

import '../models/notification_model.dart';
import '../models/report_model.dart';
import '../providers/api_provider.dart';
import '../../utils/api_endpoints.dart';

class ReportRepository {
  final ApiProvider _api = ApiProvider.instance;

  Future<PaginatedModel<ReportModel>> getAll({int page = 1, int limit = 20}) async {
    final response = await _api.get(
      ApiEndpoints.reports,
      queryParams: {'page': page, 'limit': limit},
    );
    if (!response.isSuccess) throw Exception(response.error);
    return PaginatedModel.fromJson(
      response.responseData as Map<String, dynamic>,
      ReportModel.fromJson,
    );
  }

  Future<ReportModel> getById(int id) async {
    final response = await _api.get(ApiEndpoints.reportById(id));
    if (!response.isSuccess) throw Exception(response.error);
    return ReportModel.fromJson(response.responseData as Map<String, dynamic>);
  }

  Future<ReportModel> create(CreateReportDto dto) async {
    final response = await _api.post(ApiEndpoints.reports, data: dto.toJson());
    if (!response.isSuccess) throw Exception(response.error);
    return ReportModel.fromJson(response.responseData as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final response = await _api.delete(ApiEndpoints.reportById(id));
    if (!response.isSuccess) throw Exception(response.error);
  }

  // ==================== Monthly Reports ====================

  /// تقرير شهري لطالب واحد
  Future<Map<String, dynamic>> getMonthlyStudentReport(
      int studentId, int month, int year) async {
    final response = await _api.get(
      ApiEndpoints.monthlyReportStudent(studentId),
      queryParams: {'month': month, 'year': year},
    );
    if (!response.isSuccess) throw Exception(response.error);
    return response.responseData as Map<String, dynamic>;
  }

  /// تقرير شهري لشعبة كاملة
  Future<Map<String, dynamic>> getMonthlySectionReport(
      int sectionId, int month, int year) async {
    final response = await _api.get(
      ApiEndpoints.monthlyReportSection(sectionId),
      queryParams: {'month': month, 'year': year},
    );
    if (!response.isSuccess) throw Exception(response.error);
    return response.responseData as Map<String, dynamic>;
  }

  /// تقرير شعبة + إرسال إشعارات للأهل
  Future<Map<String, dynamic>> generateAndNotifySection(
      int sectionId, int month, int year) async {
    final response = await _api.post(
      ApiEndpoints.monthlyReportSectionNotify(sectionId),
      queryParams: {'month': month, 'year': year},
    );
    if (!response.isSuccess) throw Exception(response.error);
    return response.responseData as Map<String, dynamic>;
  }

  /// تقارير كل الشعب + إشعارات
  Future<Map<String, dynamic>> generateAndNotifyAll(int month, int year) async {
    final response = await _api.post(
      ApiEndpoints.monthlyReportAllNotify,
      queryParams: {'month': month, 'year': year},
    );
    if (!response.isSuccess) throw Exception(response.error);
    return response.responseData as Map<String, dynamic>;
  }
}