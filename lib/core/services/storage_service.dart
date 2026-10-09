import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static const String _userIdKey = 'user_id';
  static const String _userPhoneKey = 'user_phone';

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      debugPrint('[StorageService] Error saving token: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('[StorageService] Error reading token: $e');
      return null;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      debugPrint('[StorageService] Error saving userId: $e');
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      debugPrint('[StorageService] Error reading userId: $e');
      return null;
    }
  }

  Future<void> saveUserPhone(String phone) async {
    try {
      await _storage.write(key: _userPhoneKey, value: phone);
    } catch (e) {
      debugPrint('[StorageService] Error saving userPhone: $e');
    }
  }

  Future<String?> getUserPhone() async {
    try {
      return await _storage.read(key: _userPhoneKey);
    } catch (e) {
      debugPrint('[StorageService] Error reading userPhone: $e');
      return null;
    }
  }

  Future<void> clearAuth() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userPhoneKey);
    } catch (e) {
      debugPrint('[StorageService] Error clearing auth: $e');
    }
  }

  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('[StorageService] Error deleting all: $e');
    }
  }
}

