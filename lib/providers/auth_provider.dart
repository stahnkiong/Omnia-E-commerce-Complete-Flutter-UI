import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _customer;

  bool get isLoading => _isLoading;
  String? get token => _token;
  Map<String, dynamic>? get customer => _customer;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final responseData = await _authService.login(email, password);
      _token = responseData['token'] as String?;

      // Save token to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token ?? '');

      await fetchCustomer();

      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final responseData = await _authService.register(email, password);
      _token = responseData['token'] as String?;

      // Save token to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token ?? '');

      // Create customer in store backend
      if (_token != null) {
        await _authService.createCustomer(email);
      }

      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    _isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      if (_token != null) {
        await fetchCustomer();
      }
    } catch (e) {
      // Handle potential errors like PlatformException during getInstance
      _token = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _customer = null;
    notifyListeners();
  }

  // Helper method to check if the user is authenticated
  bool get isAuthenticated => _token != null;

  Future<void> fetchCustomer() async {
    try {
      _customer = await _authService.getCustomer();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
