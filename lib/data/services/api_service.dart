import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/exceptions/app_exception.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://flight.wigian.in/flight_api.php',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Retry on network/timeout errors before propagating.
    _dio.interceptors.add(_RetryInterceptor(_dio));

    // Request/response logging — debug builds only.
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint('[Dio] $obj'),
      ));
    }
  }

  Future<Response> post(String path, {Map<String, dynamic>? body}) async {
    try {
      return await _dio.post(path, data: body ?? {});
    } on DioException catch (e) {
      throw _mapError(e);
    } catch (e) {
      debugPrint('[ApiService] Unexpected error: $e');
      throw NetworkException('An unexpected error occurred. Please try again.');
    }
  }

  AppException _mapError(DioException e) {
    debugPrint('[ApiService] ${e.type}: ${e.message}');
    switch (e.type) {
      case DioExceptionType.connectionError:
        return const OfflineException();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const RequestTimeoutException();
      default:
        if (e.response != null) {
          final code = e.response!.statusCode ?? 0;
          final data = e.response!.data;
          final msg = data is Map
              ? (data['error'] ?? data['message'] ?? 'Server error').toString()
              : 'Server error ($code)';
          return ServerException(msg, statusCode: code);
        }
        return const NetworkException();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────
// RETRY INTERCEPTOR
// Retries network/timeout errors up to 3 times with exponential backoff
// (1 s, 2 s, 4 s). Server errors (4xx/5xx) are NOT retried.
// ─────────────────────────────────────────────────────────────────────
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const int _maxRetries = 3;

  _RetryInterceptor(this._dio);

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final retryCount =
        (err.requestOptions.extra['_retryCount'] ?? 0) as int;

    if (retryCount >= _maxRetries) {
      handler.next(err);
      return;
    }

    err.requestOptions.extra['_retryCount'] = retryCount + 1;
    debugPrint(
        '[Retry] Attempt ${retryCount + 1}/$_maxRetries '
        'for ${err.requestOptions.path}');

    // Exponential backoff: 1s → 2s → 4s
    await Future.delayed(Duration(seconds: 1 << retryCount));

    try {
      final response = await _dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException e) =>
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.connectionError;
}

final apiServiceProvider = Provider<ApiService>((_) => ApiService());
