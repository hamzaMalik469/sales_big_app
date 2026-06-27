import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../config/constants.dart';

class SecureStorageHelper {
  final FlutterSecureStorage _storage;

  SecureStorageHelper(this._storage);

  // Token Management
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
  }

  // Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  // User Data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(userData),
    );
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: AppConstants.userKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> deleteUserData() async {
    await _storage.delete(key: AppConstants.userKey);
  }

  // Generic Read/Write
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all secure storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
