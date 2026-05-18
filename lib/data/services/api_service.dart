import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://flight.wigian.in/flight_api.php',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logging interceptor (helps you see requests in console while debugging)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  /// Generic POST method — all endpoints use POST
  Future<Response> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.post(path, data: body ?? {});
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Convert DioException to a friendly error message
  ApiException _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException('Connection timed out. Please try again.');
    } else if (e.type == DioExceptionType.connectionError) {
      return ApiException('No internet connection.');
    } else if (e.response != null) {
      final code = e.response?.statusCode;
      final msg = e.response?.data is Map
          ? (e.response?.data['error'] ?? 'Server error')
          : 'Server error';
      return ApiException('$msg (code: $code)');
    }
    return ApiException('Something went wrong. Please try again.');
  }
}

/// Custom exception with a user-friendly message
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Riverpod provider — single shared instance of ApiService
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());