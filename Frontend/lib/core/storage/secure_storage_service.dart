import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<void> saveUser(Map<String, dynamic> userMap) async {
    await _storage.write(key: _keyUser, value: jsonEncode(userMap));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final str = await _storage.read(key: _keyUser);
    if (str != null && str.isNotEmpty) {
      try {
        return jsonDecode(str) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }
}
