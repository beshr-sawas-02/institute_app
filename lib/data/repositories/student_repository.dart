// lib/data/repositories/student_repository.dart

import '../../utils/api_endpoints.dart';
import '../../utils/constants.dart';
import '../models/student_model.dart';
import '../models/notification_model.dart';
import '../providers/api_provider.dart';

class StudentRepository {
  final ApiProvider _api = ApiProvider.instance;

  // ==================== Get All ====================

  Future<PaginatedModel<StudentModel>> getAll({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? search,
  }) async {
    final response = await _api.get(
      ApiEndpoints.students,
      queryParams: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    if (!response.isSuccess) throw Exception(response.error);

    return PaginatedModel.fromJson(
      response.responseData as Map<String, dynamic>,
      StudentModel.fromJson,
    );
  }

  // ==================== Get One ====================

  Future<StudentModel> getById(int id) async {
    final response = await _api.get(ApiEndpoints.studentById(id));
    if (!response.isSuccess) throw Exception(response.error);
    return StudentModel.fromJson(response.responseData as Map<String, dynamic>);
  }

  // ==================== Get By Section ====================

  Future<List<StudentModel>> getBySection(int sectionId) async {
    final response = await _api.get(ApiEndpoints.studentsBySection(sectionId));
    if (!response.isSuccess) throw Exception(response.error);

    final data = response.responseData;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ==================== Get By Parent ====================

  Future<List<StudentModel>> getByParent(int parentId) async {
    final response = await _api.get(ApiEndpoints.studentsByParent(parentId));
    if (!response.isSuccess) throw Exception(response.error);

    final data = response.responseData;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((e) => StudentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ==================== Create ====================

  Future<StudentModel> create(CreateStudentDto dto) async {
    final response = await _api.post(
      ApiEndpoints.students,
      data: dto.toJson(),
    );
    if (!response.isSuccess) throw Exception(response.error);
    return StudentModel.fromJson(response.responseData as Map<String, dynamic>);
  }

  // ==================== Update ====================

  Future<StudentModel> update(int id, UpdateStudentDto dto) async {
    final response = await _api.patch(
      ApiEndpoints.studentById(id),
      data: dto.toJson(),
    );
    if (!response.isSuccess) throw Exception(response.error);
    return StudentModel.fromJson(response.responseData as Map<String, dynamic>);
  }

  // ==================== Delete ====================

  Future<void> delete(int id) async {
    final response = await _api.delete(ApiEndpoints.studentById(id));
    if (!response.isSuccess) throw Exception(response.error);
  }
}