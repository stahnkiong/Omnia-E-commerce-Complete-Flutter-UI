import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

import 'package:shop/models/payment_provider_model.dart';

import 'package:shop/models/shipping_option_model.dart';

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
  Future<List<dynamic>> getAddresses() async {
    try {
      final response = await client.get('/store/customers/me/addresses');
      return response.data['addresses'] ?? [];
    } catch (e) {
      // Handle error or return empty list
      return [];
    }
  }

  Future<List<PaymentProvider>> getPaymentProviders() async {
    try {
      final response = await client.get(
          '/store/payment-providers?region_id=reg_01KB5C4AEGCZPG55XAWFJBCFCH');
      final List<dynamic> providersData =
          response.data['payment_providers'] ?? [];
      return providersData
          .map((json) => PaymentProvider.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ShippingOption>> getShippingOptions(String cartId) async {
    try {
      final response =
          await client.get('/store/shipping-options?cart_id=$cartId');
      final List<dynamic> optionsData = response.data['shipping_options'] ?? [];
      return optionsData.map((json) => ShippingOption.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
