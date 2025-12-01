import 'package:dio/dio.dart';
import '../config.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: AppConfig.timeoutDuration),
    receiveTimeout: const Duration(seconds: AppConfig.timeoutDuration),
    headers: {
      "x-publishable-api-key": AppConfig.publishableKey,
      "Content-Type": "application/json",
    },
  ));

  Dio get client => _dio;
}
