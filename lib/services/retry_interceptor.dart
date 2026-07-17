import 'dart:io';
import 'package:dio/dio.dart';

/// An interceptor that automatically retries failed requests if they encounter
/// transient network errors, such as SocketExceptions or "Bad file descriptor" errors.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryInterval = const Duration(milliseconds: 500),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Check if the error is transient and we should retry the request
    if (_shouldRetry(err)) {
      int retryCount = requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        retryCount++;
        requestOptions.extra['retryCount'] = retryCount;

        // Wait before retrying (exponential backoff or simple delay)
        await Future.delayed(retryInterval * retryCount);

        try {
          // Re-send the request with the same configurations
          final response = await dio.request(
            requestOptions.path,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
            cancelToken: requestOptions.cancelToken,
            options: Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
              extra: requestOptions.extra,
              responseType: requestOptions.responseType,
              contentType: requestOptions.contentType,
              validateStatus: requestOptions.validateStatus,
              receiveTimeout: requestOptions.receiveTimeout,
              sendTimeout: requestOptions.sendTimeout,
            ),
            onSendProgress: requestOptions.onSendProgress,
            onReceiveProgress: requestOptions.onReceiveProgress,
          );
          return handler.resolve(response);
        } on DioException catch (retryErr) {
          // If the retry fails, pass the new error forward
          return handler.next(retryErr);
        } catch (e) {
          // Pass the original error forward for other unexpected exceptions
          return handler.next(err);
        }
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    final requestOptions = err.requestOptions;
    final error = err.error;

    // Identify common socket/connection errors and specifically "Bad file descriptor"
    final isTransientSocketError = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (error is SocketException && error.message.toLowerCase().contains('bad file descriptor')) ||
        (error is HttpException && error.message.toLowerCase().contains('bad file descriptor')) ||
        err.message?.toLowerCase().contains('bad file descriptor') == true;

    // Only retry GET requests for all transient errors, to remain safe and idempotent.
    // For modifying requests (POST, PUT, DELETE), only retry if we are absolutely certain
    // it was a connection initialization/socket error (never reached the server).
    if (requestOptions.method == 'GET') {
      return isTransientSocketError;
    }

    return err.type == DioExceptionType.connectionError ||
        (error is SocketException && error.message.toLowerCase().contains('bad file descriptor')) ||
        (error is HttpException && error.message.toLowerCase().contains('bad file descriptor')) ||
        err.message?.toLowerCase().contains('bad file descriptor') == true;
  }
}
