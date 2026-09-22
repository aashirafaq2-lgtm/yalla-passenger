import 'dart:convert';
import '../network/api_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository(this._apiService, this._storageService);

  Future<bool> login(String phone) async {
    try {
      final response = await _apiService.login(phone);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    try {
      final response = await _apiService.verifyOtp(phone, otp);
      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = response.data['user'];
        if (token != null) {
          await _storageService.saveToken(token);
        }
        if (user != null) {
          if (user['id'] != null) {
            await _storageService.saveUserId(user['id']);
          }
          if (user['phone'] != null) {
            await _storageService.saveUserPhone(user['phone']);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getStoredToken() async {
    return await _storageService.getToken();
  }
}
