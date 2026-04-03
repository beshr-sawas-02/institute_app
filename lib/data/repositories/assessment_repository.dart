// lib/data/repositories/assessment_repository.dart

import '../../utils/api_endpoints.dart';
import '../../utils/constants.dart';
import '../models/assessment_model.dart';
import '../models/notification_model.dart';
import '../providers/api_provider.dart';

class AssessmentRepository {
  final ApiProvider _api = ApiProvider.instance;

  Future<PaginatedModel<AssessmentModel>> getAll({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
  }) async {
    final response = await _api.get(
      ApiEndpoints.assessments,
      queryParams: {'page': page, 'limit': limit},
    );
    if (!response.isSuccess) throw Exception(response.error);
    return PaginatedModel.fromJson(
      response.responseData as Map<String, dynamic>,
      AssessmentModel.fromJson,
    );
  }

  Future<List<AssessmentModel>> getAllFiltered({
    int? sectionId,
    int? gradeSubjectId,
    int limit = 100,
  }) async {
    final response = await _api.get(
      ApiEndpoints.assessments,
      queryParams: {
        'page': 1,
        'limit': limit,
        if (sectionId != null) 'sectionId': sectionId,
        if (gradeSubjectId != null) 'gradeSubjectId': gradeSubjectId,
      },
    );
    if (!response.isSuccess) throw Exception(response.error);
    final result = PaginatedModel.fromJson(
      response.responseData as Map<String, dynamic>,
      AssessmentModel.fromJson,
    );
    return result.data;
  }

  Future<List<AssessmentModel>> getByStudent(int studentId) async {
    final response =
    await _api.get(ApiEndpoints.assessmentsByStudent(studentId));
    if (!response.isSuccess) throw Exception(response.error);
    final data = response.responseData;
    final list = data is List ? data : (data['data'] as List? ?? []);
    return list
        .map((e) => AssessmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AssessmentModel> getById(int id) async {
    final response = await _api.get(ApiEndpoints.assessmentById(id));
    if (!response.isSuccess) throw Exception(response.error);
    return AssessmentModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<AssessmentModel> create(CreateAssessmentDto dto) async {
    final response =
    await _api.post(ApiEndpoints.assessments, data: dto.toJson());
    if (!response.isSuccess) throw Exception(response.error);
    return AssessmentModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<AssessmentModel> update(int id, UpdateAssessmentDto dto) async {
    final response = await _api.patch(
      ApiEndpoints.assessmentById(id),
      data: dto.toJson(),
    );
    if (!response.isSuccess) throw Exception(response.error);
    return AssessmentModel.fromJson(
        response.responseData as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    final response = await _api.delete(ApiEndpoints.assessmentById(id));
    if (!response.isSuccess) throw Exception(response.error);
  }
}