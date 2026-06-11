import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/biometric_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final BiometricAuthService _biometricAuth = BiometricAuthService();
  
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
      _token = (responseData['token'] ?? responseData['access_token']) as String?;

      // Save token securely and update runtime memory cache
      if (_token != null && _token!.isNotEmpty) {
        await _biometricAuth.saveSessionToken(_token!);
      }

      await fetchCustomer();
      return true;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initiates Google login.
  /// Returns a redirect URL string if the user needs to be redirected to Google for authentication,
  /// or null if the user was authenticated immediately.
  Future<String?> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final responseData = await _authService.loginWithGoogle();
      
      if (responseData.containsKey('location') && responseData['location'] != null) {
        return responseData['location'] as String;
      }

      _token = (responseData['token'] ?? responseData['access_token']) as String?;

      if (_token != null && _token!.isNotEmpty) {
        await _biometricAuth.saveSessionToken(_token!);
        await fetchCustomer();
      }
      return null;
    } catch (e) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called from the deep link callback screen with the `code` query param.
  /// Exchanges the code for a JWT, persists it, and loads the customer profile.
  Future<bool> handleGoogleCallback(String code) async {
    _isLoading = true;
    notifyListeners();
    try {
      _token = await _authService.exchangeCodeForToken(code);
      await _biometricAuth.saveSessionToken(_token!);
      await fetchCustomer();
      return true;
    } catch (e) {
      _token = null;
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
      _token = (responseData['token'] ?? responseData['access_token']) as String?;

      // Save token securely and update runtime memory cache
      if (_token != null && _token!.isNotEmpty) {
        await _biometricAuth.saveSessionToken(_token!);
      }

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

  /// Runs the pre-flight check exactly once at app startup or resume.
  /// 
  /// Triggers the native biometric scan prompt to decrypt/unlock the session
  /// and populate the memory cache in [BiometricAuthService].
  Future<void> initialize() async {
    _isLoading = true;
    try {
      // Check if biometrics are supported/configured first.
      final bool biometricAvailable = await _biometricAuth.isBiometricAvailable();
      
      if (biometricAvailable) {
        // Trigger native biometric lock prompt exactly once on app entry.
        final bool unlocked = await _biometricAuth.unlockSessionWithBiometrics();
        if (unlocked) {
          _token = _biometricAuth.unlockedToken;
        } else {
          _token = null;
        }
      } else {
        // Fallback: If biometrics are not setup/supported, bypass gating and read the token directly.
        _token = await _biometricAuth.getSessionTokenWithoutBiometrics();
      }

      if (_token != null) {
        await fetchCustomer();
      }
    } catch (e) {
      _token = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _biometricAuth.clearSession();
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
