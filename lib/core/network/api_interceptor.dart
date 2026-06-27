import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config/constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await _secureStorage.read(key: AppConstants.tokenKey);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - Token expired
    if (err.response?.statusCode == 401) {
      // Clear token and redirect to login
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);

      // You can emit an event here to navigate to login screen
      // using a global event bus or stream
    }

    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}

// Retry Interceptor for failed requests
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    // Only retry for specific errors
    if (_shouldRetry(err) && retryCount < maxRetries) {
      retryCount++;
      err.requestOptions.extra['retryCount'] = retryCount;

      // Wait before retrying (exponential backoff)
      await Future.delayed(Duration(seconds: retryCount * 2));

      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue to error handler
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
