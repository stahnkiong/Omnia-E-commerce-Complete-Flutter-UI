import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ApiService {
  final Dio client = Dio();

  ApiService() {
    client.options.baseUrl = AppConfig.apiBaseUrl;
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['x-publishable-api-key'] = AppConfig.publishableKey;
          return handler.next(options);
        },
      ),
    );
  }
}
