import 'dart:convert';

import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/storage/secure_storage.dart';
import '../core/storage/local_storage.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;
  final SecureStorageHelper _secureStorage;
  final LocalStorageHelper _localStorage;

  // Cached user
  UserModel? _currentUser;

  AuthService({
    required ApiClient apiClient,
    required SecureStorageHelper secureStorage,
    required LocalStorageHelper localStorage,
  }) : _apiClient = apiClient,
       _secureStorage = secureStorage,
       _localStorage = localStorage;

  /// Get current user
  UserModel? get currentUser => _currentUser;

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _secureStorage.isLoggedIn();
  }

  /// Login with email and password
  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(
        response['data'] ?? response,
      );

      // Save token
      await _secureStorage.saveToken(loginResponse.token);
      if (loginResponse.refreshToken != null) {
        await _secureStorage.saveRefreshToken(loginResponse.refreshToken!);
      }

      // Save user data
      await _secureStorage.saveUserData(loginResponse.user.toJson());

      // Cache user
      _currentUser = UserModel.fromJson(loginResponse.user.toJson());

      return ApiResponse.success(
        data: loginResponse,
        message: response['message'] ?? 'Login successful',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message);
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  // /// Register new user
  // Future<ApiResponse<LoginResponse>> register({
  //   required String name,
  //   required String email,
  //   required String password,
  //   required String passwordConfirmation,
  //   String? phone,
  // }) async {
  //   try {
  //     final response = await _apiClient.post(
  //       ApiEndpoints.register,
  //       data: {
  //         'name': name,
  //         'email': email,
  //         'password': password,
  //         'password_confirmation': passwordConfirmation,
  //         'phone': phone,
  //       },
  //     );

  //     final loginResponse = LoginResponse.fromJson(
  //       response['data'] ?? response,
  //     );

  //     // Save token
  //     await _secureStorage.saveToken(loginResponse.token);
  //     if (loginResponse.refreshToken != null) {
  //       await _secureStorage.saveRefreshToken(loginResponse.refreshToken!);
  //     }

  //     // Save user data
  //     await _secureStorage.saveUserData(loginResponse.user.toJson());

  //     // Cache user
  //     _currentUser = UserModel.fromJson(loginResponse.user.toJson());

  //     return ApiResponse.success(
  //       data: loginResponse,
  //       message: response['message'] ?? 'Registration successful',
  //     );
  //   } on ApiException catch (e) {
  //     return ApiResponse.error(message: e.message);
  //   } catch (e) {
  //     return ApiResponse.error(message: 'An unexpected error occurred');
  //   }
  // }

  /// Forgot password
  Future<ApiResponse<void>> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      return ApiResponse.success(
        message:
            response['message'] ?? 'Password reset link sent to your email',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message);
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  /// Reset password
  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      return ApiResponse.success(
        message: response['message'] ?? 'Password reset successful',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message);
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  /// Logout
  Future<ApiResponse<void>> logout() async {
    try {
      // Try to call logout API
      try {
        await _apiClient.post(ApiEndpoints.logout);
      } catch (_) {
        // Ignore API errors, still clear local data
      }

      // Clear local data
      await _clearAuthData();

      return ApiResponse.success(message: 'Logged out successfully');
    } catch (e) {
      // Still clear local data even if there's an error
      await _clearAuthData();
      return ApiResponse.success(message: 'Logged out successfully');
    }
  }

  /// Get current user profile
  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      // First try to get from cache/storage
      if (_currentUser != null) {
        return ApiResponse.success(data: _currentUser);
      }

      // Try to get from secure storage
      final userData = await _secureStorage.getUserData();
      if (userData != null) {
        _currentUser = UserModel.fromJson(userData);
        return ApiResponse.success(data: _currentUser);
      }

      // Fetch from API
      final response = await _apiClient.get(ApiEndpoints.me);
      final user = UserModel.fromJson(response['data'] ?? response);

      // Cache user
      _currentUser = user;
      await _secureStorage.saveUserData(user.toJson());

      return ApiResponse.success(data: user);
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message);
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  /// Update profile
  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? phone,
    String? avatar,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.updateProfile,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (avatar != null) 'avatar': avatar,
        },
      );

      final user = UserModel.fromJson(response['data'] ?? response);

      // Update cache
      _currentUser = user;
      await _secureStorage.saveUserData(user.toJson());

      return ApiResponse.success(
        data: user,
        message: response['message'] ?? 'Profile updated successfully',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message);
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  /// Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );

      return ApiResponse.success(
        message: response['message'] ?? 'Password changed successfully',
      );
    } on ApiException catch (e) {
      return ApiResponse.error(message: e.message);
    } catch (e) {
      return ApiResponse.error(message: 'An unexpected error occurred');
    }
  }

  /// Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final newToken = response['token'] ?? response['access_token'];
      final newRefreshToken = response['refresh_token'];

      if (newToken != null) {
        await _secureStorage.saveToken(newToken);
        if (newRefreshToken != null) {
          await _secureStorage.saveRefreshToken(newRefreshToken);
        }
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Clear auth data
  Future<void> _clearAuthData() async {
    _currentUser = null;
    await _secureStorage.deleteToken();
    await _secureStorage.deleteRefreshToken();
    await _secureStorage.deleteUserData();
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
