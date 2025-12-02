import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthProvider() {
    print('AuthProvider initialized');
  }
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(email, password);
      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
