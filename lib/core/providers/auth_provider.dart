import 'package:flutter/material.dart';
import '../../features/auth/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isLoading = false;
  String? _currentPhone;

  AuthProvider(this._authRepository);

  bool get isLoading => _isLoading;
  String? get currentPhone => _currentPhone;

  Future<bool> login(String phone) async {
    _isLoading = true;
    notifyListeners();
    _currentPhone = phone;
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
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
