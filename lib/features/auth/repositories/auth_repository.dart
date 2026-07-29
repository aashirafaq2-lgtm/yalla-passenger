import 'dart:convert';
import '../../../core/network/api_service.dart';
import '../../../core/services/storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository(this._apiService, this._storageService);

  Future<bool> login(String phone) async {
    // LOGIN BYPASSED for development
    return true; 

    /* Original Logic
    try {
      final response = await _apiService.login(phone);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
    */
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    // OTP SYSTEM BYPASSED for development
    return true; 
    
    /* Original Logic 
    try {
      final response = await _apiService.verifyOtp(phone, otp);
      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await _storageService.saveToken(token);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
    */
  }
}
