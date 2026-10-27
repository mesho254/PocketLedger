import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

class ApiClient {
  late final Dio dio;
  final SecureStorageService storageService;
  void Function()? onUnauthorized;

  ApiClient({
    required this.storageService,
    this.onUnauthorized,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await storageService.clearAuth();
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );
  }

  ApiException _handleDioError(DioException e) {
    if (e.response != null && e.response?.data is Map) {
      final data = e.response!.data as Map;
      final msg = data['message'] ?? 'An error occurred';
      return ApiException(
        message: msg.toString(),
        statusCode: e.response?.statusCode,
        details: data['details'],
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(message: 'Connection timed out. Please check your internet connection.');
    }

    if (e.type == DioExceptionType.connectionError) {
      return ApiException(message: 'Unable to connect to server. Please ensure backend is running.');
    }

    return ApiException(message: e.message ?? 'Unexpected network error occurred.');
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
