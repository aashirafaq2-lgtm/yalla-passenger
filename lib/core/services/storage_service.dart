import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static const String _userIdKey = 'user_id';
  static const String _userPhoneKey = 'user_phone';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> saveUserPhone(String phone) async {
    await _storage.write(key: _userPhoneKey, value: phone);
  }

  Future<String?> getUserPhone() async {
    return await _storage.read(key: _userPhoneKey);
  }

  Future<void> clearAuth() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userPhoneKey);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
