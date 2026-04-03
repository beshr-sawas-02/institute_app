// lib/data/repositories/payment_repository.dart

import '../../utils/api_endpoints.dart';
import '../../utils/constants.dart';
import '../models/dashboard_model.dart';
import '../models/grade_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/section_model.dart';
import '../models/subject_model.dart';
import '../models/teacher_model.dart';
import '../providers/api_provider.dart';

class PaymentRepository {
  final ApiProvider _api = ApiProvider.instance;

  Future<PaginatedModel<PaymentModel>> getAll({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? search,
  }) async {
    final response = await _api.get(
      ApiEndpoints.payments,
      queryParams: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    if (!response.isSuccess) throw Exception(response.error);
    return PaginatedModel.fromJson(
      response.responseData as Map<String, dynamic>,
      PaymentModel.fromJson,
    );
  }

  Future<List<PaymentModel>> getByStudent(int studentId) async {
    final response =
    await _api.get(ApiEndpoints.paymentsByStudent(studentId));
    if (!response.isSuccess) throw Exception(response.error);
    final data = response.responseData;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaymentModel> getById(int id) async {
    final response = await _api.get(ApiEndpoints.paymentById(id));
    if (!response.isSuccess) throw Exception(response.error);
    return PaymentModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<PaymentStats> getStats({String? academicYear}) async {
    final response = await _api.get(
      ApiEndpoints.paymentsStats,
      queryParams: {
        if (academicYear != null) 'academicYear': academicYear,
      },
    );
    if (!response.isSuccess) throw Exception(response.error);
    return PaymentStats.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<PaymentModel> create(CreatePaymentDto dto) async {
    final response =
    await _api.post(ApiEndpoints.payments, data: dto.toJson());
    if (!response.isSuccess) throw Exception(response.error);
    return PaymentModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<PaymentModel> update(int id, UpdatePaymentDto dto) async {
    final response = await _api.patch(
      ApiEndpoints.paymentById(id),
      data: dto.toJson(),
    );
    if (!response.isSuccess) throw Exception(response.error);
    return PaymentModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final response = await _api.delete(ApiEndpoints.paymentById(id));
    if (!response.isSuccess) throw Exception(response.error);
  }
}

// ==================== lib/data/repositories/section_repository.dart ====================


class SectionRepository {
  final ApiProvider _api = ApiProvider.instance;

  Future<PaginatedModel<SectionModel>> getAll({
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    final response = await _api.get(
      ApiEndpoints.sections,
      queryParams: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    if (!response.isSuccess) throw Exception(response.error);
    return PaginatedModel.fromJson(
      response.responseData as Map<String, dynamic>,
      SectionModel.fromJson,
    );
  }

  Future<List<SectionModel>> getByGrade(int gradeId) async {
    final response =
    await _api.get(ApiEndpoints.sectionsByGrade(gradeId));
    if (!response.isSuccess) throw Exception(response.error);
    final data = response.responseData;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((e) => SectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SectionModel> getById(int id) async {
    final response = await _api.get(ApiEndpoints.sectionById(id));
    if (!response.isSuccess) throw Exception(response.error);
    return SectionModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<SectionModel> create(CreateSectionDto dto) async {
    final response =
    await _api.post(ApiEndpoints.sections, data: dto.toJson());
    if (!response.isSuccess) throw Exception(response.error);
    return SectionModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final response = await _api.delete(ApiEndpoints.sectionById(id));
    if (!response.isSuccess) throw Exception(response.error);
  }
}

// ==================== lib/data/repositories/grade_repository.dart ====================


class GradeRepository {
  final ApiProvider _api = ApiProvider.instance;

  Future<PaginatedModel<GradeModel>> getAll({int page = 1, int limit = 100}) async {
    final response = await _api.get(
      ApiEndpoints.grades,
      queryParams: {'page': page, 'limit': limit},
    );
    if (!response.isSuccess) throw Exception(response.error);
    return PaginatedModel.fromJson(
      response.responseData as Map<String, dynamic>,
      GradeModel.fromJson,
    );
  }

  Future<GradeModel> getById(int id) async {
    final response = await _api.get(ApiEndpoints.gradeById(id));
    if (!response.isSuccess) throw Exception(response.error);
    return GradeModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<GradeModel> create(CreateGradeDto dto) async {
    final response =
    await _api.post(ApiEndpoints.grades, data: dto.toJson());
    if (!response.isSuccess) throw Exception(response.error);
    return GradeModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final response = await _api.delete(ApiEndpoints.gradeById(id));
    if (!response.isSuccess) throw Exception(response.error);
  }

  Future<List<GradeSubjectModel>> getGradeSubjects() async {
    final response = await _api.get(
      ApiEndpoints.gradeSubjects,
      queryParams: {'page': 1, 'limit': 100},
    );
    if (!response.isSuccess) throw Exception(response.error);
    // backend may return paginated or plain list
    final data = response.responseData;
    if (data is List) {
      return data.map((e) => GradeSubjectModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => GradeSubjectModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<GradeSubjectModel>> getGradeSubjectsForGrade(int gradeId) async {
    final response = await _api.get(
      ApiEndpoints.gradeSubjectsByGrade(gradeId),
      queryParams: {'page': 1, 'limit': 100},
    );
    if (!response.isSuccess) throw Exception(response.error);
    final data = response.responseData;
    if (data is List) {
      return data.map((e) => GradeSubjectModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => GradeSubjectModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

// ==================== lib/data/repositories/notification_repository.dart ====================

class NotificationRepository {
  final ApiProvider _api = ApiProvider.instance;

  Future<List<NotificationModel>> getMyNotifications() async {
    final response = await _api.get(ApiEndpoints.notificationsMy);
    if (!response.isSuccess) throw Exception(response.error);
    final data = response.responseData;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UnreadCountModel> getUnreadCount() async {
    final response = await _api.get(ApiEndpoints.notificationsUnreadCount);
    if (!response.isSuccess) throw Exception(response.error);
    return UnreadCountModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<NotificationModel> markAsRead(int id) async {
    final response =
    await _api.patch(ApiEndpoints.notificationMarkRead(id));
    if (!response.isSuccess) throw Exception(response.error);
    return NotificationModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<void> markAllAsRead() async {
    final response = await _api.patch(ApiEndpoints.notificationsReadAll);
    if (!response.isSuccess) throw Exception(response.error);
  }

  Future<void> delete(int id) async {
    final response = await _api.delete(ApiEndpoints.notificationById(id));
    if (!response.isSuccess) throw Exception(response.error);
  }

  Future<Map<String, dynamic>> sendBulk({
    required String role,
    required String title,
    required String message,
  }) async {
    final response = await _api.post(
      ApiEndpoints.notificationsBulk,
      data: {'role': role, 'title': title, 'message': message},
    );
    if (!response.isSuccess) throw Exception(response.error);
    return response.responseData as Map<String, dynamic>;
  }
}

// ==================== lib/data/repositories/dashboard_repository.dart ====================


class DashboardRepository {
  final ApiProvider _api = ApiProvider.instance;

  Future<DashboardStats> getStats() async {
    final response = await _api.get(ApiEndpoints.dashboard);
    if (!response.isSuccess) throw Exception(response.error);
    return DashboardStats.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<FinancialSummary> getFinancialSummary({int? month, int? year}) async {
    final response = await _api.get(
      ApiEndpoints.dashboardFinancial,
      queryParams: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    if (!response.isSuccess) throw Exception(response.error);
    return FinancialSummary.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getAttendanceSummary({
    String? dateFrom,
    String? dateTo,
  }) async {
    final response = await _api.get(
      ApiEndpoints.dashboardAttendance,
      queryParams: {
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      },
    );
    if (!response.isSuccess) throw Exception(response.error);
    return response.responseData as Map<String, dynamic>;
  }
}