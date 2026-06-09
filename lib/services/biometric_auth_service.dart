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

  /// Checks if biometric authentication is available on the device.
  /// Checks both the hardware capability and support status.
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException catch (e, stackTrace) {
      _logPlatformException(e, 'isBiometricAvailable');
      developer.log(
        'PlatformException in isBiometricAvailable: ${e.code} - ${e.message}',
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

  /// Writes the Medusa JWT token string to secure storage under a unique key constant.
  Future<void> saveSessionToken(String token) async {
    try {
      await _secureStorage.write(key: _sessionTokenKey, value: token);
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
  Future<String?> getSessionTokenWithBiometrics() async {
    try {
      // 1. Check if token exists in secure storage.
      final String? token = await _secureStorage.read(key: _sessionTokenKey);
      if (token == null || token.isEmpty) {
        return null;
      }

      // 2. Trigger native local_auth prompt using modern AuthenticationOptions.
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Scan your face or fingerprint to unlock your session',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      // 3. If authentication succeeds, return the token string.
      if (authenticated) {
        return token;
      }
      
      developer.log(
        'Biometric authentication failed or was canceled by the user.',
        name: 'BiometricAuthService',
      );
      return null;
    } on PlatformException catch (e, stackTrace) {
      _logPlatformException(e, 'getSessionTokenWithBiometrics');
      developer.log(
        'PlatformException in getSessionTokenWithBiometrics: ${e.code} - ${e.message}',
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

  /// Removes the token key from secure storage, typically during user logout.
  Future<void> clearSession() async {
    try {
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

  /// Inspects and logs common biometric platform exception error codes.
  void _logPlatformException(PlatformException e, String methodName) {
    final String errorPrefix = 'PlatformException in $methodName:';
    switch (e.code) {
      case 'passcodeNotSet':
      case 'PasscodeNotSet':
        developer.log(
          '$errorPrefix Device passcode or PIN is not configured by the user.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case 'lockedOut':
      case 'LockedOut':
        developer.log(
          '$errorPrefix Biometric authentication is temporarily locked due to too many failed attempts.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case 'permanentlyLockedOut':
      case 'PermanentlyLockedOut':
        developer.log(
          '$errorPrefix Biometrics are permanently locked out. Passcode verification is required to re-enable.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case 'notAvailable':
      case 'NotAvailable':
        developer.log(
          '$errorPrefix Biometric hardware capability is not available or supported on this device.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      case 'notEnrolled':
      case 'NotEnrolled':
        developer.log(
          '$errorPrefix User has not registered any fingerprint or facial data on the device.',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
      default:
        developer.log(
          '$errorPrefix Generic platform error: code=${e.code}, message=${e.message}',
          name: 'BiometricAuthService',
          error: e,
        );
        break;
    }
  }
}
