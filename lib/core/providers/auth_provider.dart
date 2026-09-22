import 'package:flutter/material.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../network/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final ApiService _apiService;
  bool _isLoading = false;
  String? _currentPhone;
  String? _pendingFullName; // stored during signup to save after OTP

  AuthProvider(this._authRepository, this._apiService);

  bool get isLoading => _isLoading;
  String? get currentPhone => _currentPhone;

  Future<bool> login(String phone, {String? fullName}) async {
    _isLoading = true;
    notifyListeners();
    _currentPhone = phone;
    _pendingFullName = fullName;
    final success = await _authRepository.login(phone);
    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<bool> verifyOtp(String otp) async {
    if (_currentPhone == null) return false;
    _isLoading = true;
    notifyListeners();
    final success = await _authRepository.verifyOtp(_currentPhone!, otp);

    // If signup flow and we have a name to save, update the profile
    if (success && _pendingFullName != null && _pendingFullName!.isNotEmpty) {
      try {
        final token = await _authRepository.getStoredToken();
        if (token != null) {
          final parts = _pendingFullName!.split(' ');
          final firstName = parts.isNotEmpty ? parts.first : _pendingFullName!;
          final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
          await _apiService.updateProfile({'firstName': firstName, 'lastName': lastName}, token);
        }
      } catch (e) {
        debugPrint('Profile name save error: $e');
      }
      _pendingFullName = null;
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }
}
