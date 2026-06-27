// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'dart:async'; // Import this for delays
import 'mock_data.dart'; // Import your mock data
import 'api_exceptions.dart';

class ApiClient {
  final Dio _dio;

  // ✅ ENABLE MOCKING HERE
  final bool isMockEnabled = true;

  ApiClient(this._dio);

  // --- HELPER TO SIMULATE NETWORK DELAY ---
  Future<dynamic> _mockRequest(
    String path, {
    String method = 'GET',
    dynamic data,
  }) async {
    print("MOCK API [$method]: $path");
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // AUTH ROUTES
    if (path.contains('/login')) return MockData.loginSuccess;
    if (path.contains('/me') || path.contains('/profile'))
      return MockData.userProfile;
    if (path.contains('/logout'))
      return {"success": true, "message": "Logged out"};

    // BID ROUTES
    if (path.contains('/bids')) {
      if (method == 'GET') return MockData.bidList;

      // Mock Creating a Bid
      if (method == 'POST') {
        return {
          "success": true,
          "message": "Bid created successfully (Mock)",
          "data": {
            ...data,
            "id": DateTime.now().millisecondsSinceEpoch.toString(),
            "status": "pending",
            "created_at": DateTime.now().toIso8601String(),
            "is_synced": true,
          },
        };
      }
    }

    // Default Mock Response
    return {"success": true, "message": "Mock operation successful"};
  }

  // --- UPDATED GET METHOD ---
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (isMockEnabled) return _mockRequest(path, method: 'GET'); // 👈 Intercept

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // --- UPDATED POST METHOD ---
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (isMockEnabled)
      return _mockRequest(path, method: 'POST', data: data); // 👈 Intercept

    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ... Update PUT, DELETE similarly ...
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (isMockEnabled) return _mockRequest(path, method: 'PUT', data: data);
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (isMockEnabled) return _mockRequest(path, method: 'DELETE');
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ... keep _handleResponse and _handleDioError as they were ...
  dynamic _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      throw ApiException(
        message: response.data['message'] ?? 'Something went wrong',
        statusCode: response.statusCode,
      );
    }
  }

  ApiException _handleDioError(DioException error) {
    // ... keep existing error handling logic ...
    return ApiException(message: error.message ?? 'Unknown error');
  }
}
