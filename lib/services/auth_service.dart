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

  // Register with email and password
  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final response = await _api.client.post(
        '/auth/customer/emailpass/register',
        data: {
          'email': email,
          'password': password,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Create customer in store backend
  Future<void> createCustomer(String email) async {
    try {
      await _api.client.post(
        '/store/customers',
        data: {
          'email': email,
        },
      );
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  Future<Map<String, dynamic>> getCustomer() async {
    try {
      final response = await _api.client.get('/store/customers/me');
      return response.data['customer'];
    } catch (e) {
      throw Exception('Failed to get customer: $e');
    }
  }
}
