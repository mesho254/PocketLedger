import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUser = 'auth_user';
  static const String _keyThemeMode = 'app_theme_mode';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRefreshToken(String? refreshToken) async {
    if (refreshToken == null || refreshToken.isEmpty) return;
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _storage.write(key: _keyUser, value: jsonEncode(userMap));
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      final str = await _storage.read(key: _keyUser);
      if (str != null && str.isNotEmpty) {
        return jsonDecode(str) as Map<String, dynamic>;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> clearAuth() async {
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyUser);
    } catch (_) {}
  }

  Future<void> saveThemeMode(String mode) async {
    try {
      await _storage.write(key: _keyThemeMode, value: mode);
    } catch (_) {}
  }

  Future<String?> getThemeMode() async {
    try {
      return await _storage.read(key: _keyThemeMode);
    } catch (_) {
      return null;
    }
  }
}
