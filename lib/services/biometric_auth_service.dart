import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// A secure service handling client-side biometric locking and key storage
/// for a MedusaJS storefront session token.
class BiometricAuthService {
  // Constant configuration key for storing the Medusa session token securely.
  static const String _sessionTokenKey = 'medusa_session_token';

  // Secure storage instance using constant platform-specific configuration options.
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      // ignore: deprecated_member_use
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Instance of LocalAuthentication for verifying biometrics.
  final LocalAuthentication _auth = LocalAuthentication();

  // The runtime token cache - keeps your API screaming fast by avoiding redundant prompts.
  String? _unlockedAccessToken;

  /// Exposes the runtime memory token if the session is currently unlocked.
  String? get unlockedToken => _unlockedAccessToken;

  /// Checks if biometric authentication is available on the device.
  /// Checks both the hardware capability and support status.
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on LocalAuthException catch (e, stackTrace) {
      _logLocalAuthException(e, 'isBiometricAvailable');
      developer.log(
        'LocalAuthException in isBiometricAvailable: ${e.code} - ${e.description}',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error in isBiometricAvailable',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Triggers biometric prompt to unlock the session and load the token into memory.
  /// Call this during app startup or when resuming from the background.
  Future<bool> unlockSessionWithBiometrics() async {
    try {
      // 1. Check if token actually exists in secure storage.
      final hasToken = await _secureStorage.containsKey(key: _sessionTokenKey);
      if (!hasToken) return false;

      // 2. Trigger biometric authentication.
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Unlock your store profile',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (authenticated) {
        // 3. Decrypt into runtime memory.
        _unlockedAccessToken = await _secureStorage.read(key: _sessionTokenKey);
        return true;
      }
    } on LocalAuthException catch (e, stackTrace) {
      _logLocalAuthException(e, 'unlockSessionWithBiometrics');
      developer.log(
        'LocalAuthException in unlockSessionWithBiometrics: ${e.code} - ${e.description}',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error in unlockSessionWithBiometrics',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return false;
  }

  /// Writes the Medusa JWT token string to secure storage and updates memory cache.
  Future<void> saveSessionToken(String token) async {
    try {
      await _secureStorage.write(key: _sessionTokenKey, value: token);
      _unlockedAccessToken = token; // Decrypt into runtime memory
    } on PlatformException catch (e, stackTrace) {
      developer.log(
        'PlatformException in saveSessionToken: ${e.code} - ${e.message}',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error in saveSessionToken',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Attempts to authenticate with biometrics and retrieve the stored session token.
  /// 
  /// Returns the token string if successful, or null if the token is not present,
  /// authentication fails, is canceled by the user, or throws a PlatformException.
  /// Uses memory cache to avoid prompting the user multiple times during active session.
  Future<String?> getSessionTokenWithBiometrics() async {
    // 1. If we already have the token cached in runtime memory, return it immediately.
    if (_unlockedAccessToken != null && _unlockedAccessToken!.isNotEmpty) {
      return _unlockedAccessToken;
    }

    try {
      // 2. Check if token exists in secure storage.
      final String? token = await _secureStorage.read(key: _sessionTokenKey);
      if (token == null || token.isEmpty) {
        return null;
      }

      // 3. Trigger native local_auth prompt using modern 3.0.x direct parameters.
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Scan your face or fingerprint to unlock your session',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      // 4. If authentication succeeds, update memory cache and return the token string.
      if (authenticated) {
        _unlockedAccessToken = token;
        return token;
      }
      
      developer.log(
        'Biometric authentication failed or was canceled by the user.',
        name: 'BiometricAuthService',
      );
      return null;
    } on LocalAuthException catch (e, stackTrace) {
      _logLocalAuthException(e, 'getSessionTokenWithBiometrics');
      developer.log(
        'LocalAuthException in getSessionTokenWithBiometrics: ${e.code} - ${e.description}',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error in getSessionTokenWithBiometrics',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Retrieves the stored session token directly from secure storage without biometrics,
  /// and caches it in memory. Used as a fallback for devices without biometric hardware.
  Future<String?> getSessionTokenWithoutBiometrics() async {
    try {
      final String? token = await _secureStorage.read(key: _sessionTokenKey);
      if (token != null && token.isNotEmpty) {
        _unlockedAccessToken = token;
      }
      return token;
    } on PlatformException catch (e, stackTrace) {
      developer.log(
        'PlatformException in getSessionTokenWithoutBiometrics: ${e.code} - ${e.message}',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error in getSessionTokenWithoutBiometrics',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Removes the token key from secure storage and clears runtime memory cache.
  Future<void> clearSession() async {
    try {
      _unlockedAccessToken = null; // Clear runtime memory cache
      await _secureStorage.delete(key: _sessionTokenKey);
    } on PlatformException catch (e, stackTrace) {
      developer.log(
        'PlatformException in clearSession: ${e.code} - ${e.message}',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error in clearSession',
        name: 'BiometricAuthService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Inspects and logs common biometric exception error codes from LocalAuthException.
  void _logLocalAuthException(LocalAuthException e, String methodName) {
    final String errorPrefix = 'LocalAuthException in $methodName:';
    switch (e.code) {
      case LocalAuthExceptionCode.noBiometricHardware:
        developer.log(
          '$errorPrefix Biometric hardware is not available on this device.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case LocalAuthExceptionCode.noBiometricsEnrolled:
        developer.log(
          '$errorPrefix No biometrics are enrolled on this device.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case LocalAuthExceptionCode.noCredentialsSet:
        developer.log(
          '$errorPrefix Device credentials (PIN/pattern/passcode) are not set on the device.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
        developer.log(
          '$errorPrefix Biometric hardware is temporarily unavailable.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case LocalAuthExceptionCode.userCanceled:
        developer.log(
          '$errorPrefix Authentication was canceled by the user.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case LocalAuthExceptionCode.authInProgress:
        developer.log(
          '$errorPrefix An authentication attempt is already in progress.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case LocalAuthExceptionCode.uiUnavailable:
        developer.log(
          '$errorPrefix The authentication UI could not be displayed.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case LocalAuthExceptionCode.timeout:
        developer.log(
          '$errorPrefix The authentication attempt timed out.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case LocalAuthExceptionCode.systemCanceled:
        developer.log(
          '$errorPrefix The authentication process was canceled by the system.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      default:
        developer.log(
          '$errorPrefix Unknown local auth exception code: ${e.code}',
          name: 'BiometricAuthService',
          error: e,
        );
    }
  }
}
