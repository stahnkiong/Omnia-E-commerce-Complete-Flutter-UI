import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _api.client.post(
        '/auth/customer/emailpass',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Assuming the API returns user data on successful login
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
