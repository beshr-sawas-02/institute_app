// lib/data/providers/api_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Response;
import '../../utils/api_endpoints.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class ApiProvider {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static ApiProvider? _instance;
  static ApiProvider get instance => _instance ??= ApiProvider._();

  ApiProvider._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        sendTimeout: const Duration(milliseconds: AppConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<void> _handleUnauthorized() async {
    await _storage.deleteAll();
    if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login');
      Helpers.showError('error_session_expired'.tr);
    }
  }

  // ==================== Core Request Methods ====================

  Future<ApiResponse> get(
      String path, {
        Map<String, dynamic>? queryParams,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: options,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.failure(_parseDioError(e));
    } catch (e) {
      return ApiResponse.failure('unknown_error'.tr);
    }
  }

  Future<ApiResponse> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParams,
        Options? options,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.failure(_parseDioError(e));
    } catch (e) {
      return ApiResponse.failure('unknown_error'.tr);
    }
  }

  Future<ApiResponse> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParams,
        Options? options,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.failure(_parseDioError(e));
    } catch (e) {
      return ApiResponse.failure('unknown_error'.tr);
    }
  }

  Future<ApiResponse> delete(
      String path, {
        Map<String, dynamic>? queryParams,
        Options? options,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParams,
        options: options,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      return ApiResponse.failure(_parseDioError(e));
    } catch (e) {
      return ApiResponse.failure('unknown_error'.tr);
    }
  }

  // ==================== Token Management ====================

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.deleteAll();
  }

  // ==================== Error Parsing ====================

  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'error_timeout'.tr;
      case DioExceptionType.connectionError:
        return 'error_connection'.tr;
      case DioExceptionType.badResponse:
        return _parseServerError(e.response);
      case DioExceptionType.cancel:
        return 'error_request_cancelled'.tr;
      default:
        return 'unknown_error'.tr;
    }
  }

  String _parseServerError(Response? response) {
    if (response == null) return 'error_no_response'.tr;

    final data = response.data;
    if (data == null) {
      return _statusCodeMessage(response.statusCode);
    }

    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      if (message is List && message.isNotEmpty) return message.first.toString();

      final error = data['error'];
      if (error is String && error.isNotEmpty) return error;
    }

    return _statusCodeMessage(response.statusCode);
  }

  String _statusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400: return 'error_bad_request'.tr;
      case 401: return 'error_unauthorized'.tr;
      case 403: return 'error_forbidden'.tr;
      case 404: return 'error_not_found'.tr;
      case 409: return 'error_conflict'.tr;
      case 422: return 'error_unprocessable'.tr;
      case 500: return 'error_server'.tr;
      case 503: return 'error_unavailable'.tr;
      default: return 'error_unknown_code'.tr.replaceAll('@code', '${statusCode ?? "?"}');
    }
  }
}

// ==================== ApiResponse Wrapper ====================

class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final String? error;

  const ApiResponse._({
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory ApiResponse.success(dynamic data) =>
      ApiResponse._(isSuccess: true, data: data);

  factory ApiResponse.failure(String error) =>
      ApiResponse._(isSuccess: false, error: error);

  dynamic get responseData {
    if (data is Map && data['data'] != null) return data['data'];
    return data;
  }

  String get message {
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return '';
  }

  Map<String, dynamic>? get meta {
    if (responseData is Map && responseData['meta'] != null) {
      return Map<String, dynamic>.from(responseData['meta']);
    }
    return null;
  }

  List get listData {
    final d = responseData;
    if (d is Map && d['data'] != null && d['data'] is List) {
      return d['data'] as List;
    }
    if (d is List) return d;
    return [];
  }
}