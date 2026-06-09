import 'package:dio/dio.dart';
import 'biometric_auth_service.dart';

/// Custom exception thrown when biometric authentication fails or is canceled
/// by the user during the request interception phase.
class BiometricAuthException implements Exception {
  final String message;
  final RequestOptions requestOptions;

  BiometricAuthException({
    this.message = 'Biometric authentication failed or was canceled.',
    required this.requestOptions,
  });

  @override
  String toString() => 'BiometricAuthException: $message';
}

/// A custom non-blocking Dio interceptor that gates and injects Medusa JWT tokens
/// by synchronously reading the runtime memory cache in [BiometricAuthService].
///
/// This interceptor performs no native hardware I/O operations, keeping requests
/// lightning fast and preventing multiple concurrent prompt popups.
class MedusaAuthInterceptor extends Interceptor {
  final BiometricAuthService _biometricAuthService;

  MedusaAuthInterceptor({BiometricAuthService? biometricAuthService})
      : _biometricAuthService = biometricAuthService ?? BiometricAuthService();

  /// Helper to determine if an endpoint route requires customer authentication.
  bool _requiresAuth(String path) {
    // Endpoints for getting/updating customer profile, address, or orders require auth.
    return path.contains('/store/customers/me') || path.contains('/store/orders');
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // 1. If the request doesn't require authentication, proceed immediately (e.g. login, catalog).
    if (!_requiresAuth(options.path)) {
      return handler.next(options);
    }

    // 2. Check if the request already contains an Authorization header manually.
    if (options.headers.containsKey('Authorization') &&
        options.headers['Authorization'] != null &&
        options.headers['Authorization'].toString().isNotEmpty) {
      return handler.next(options);
    }

    // 3. Read instantly from runtime memory, NOT hardware secure enclave.
    final String? token = _biometricAuthService.unlockedToken;

    if (token != null && token.isNotEmpty) {
      // 4. Append the cached token as the Bearer auth header.
      options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    }

    // 5. If memory is empty, the app session is locked. Crash/cancel request safely.
    final biometricException = BiometricAuthException(
      message: 'Application session is locked. Biometric pre-flight required.',
      requestOptions: options,
    );
    final dioException = DioException(
      requestOptions: options,
      error: biometricException,
      type: DioExceptionType.cancel,
      message: 'Application session is locked. Biometric pre-flight required.',
    );
    return handler.reject(dioException);
  }
}
