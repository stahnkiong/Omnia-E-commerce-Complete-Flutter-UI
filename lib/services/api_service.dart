import 'package:dio/dio.dart';
import '../config.dart';
import 'biometric_auth_service.dart';
import 'medusa_auth_interceptor.dart';
import 'retry_interceptor.dart';

import 'package:pasar_now/models/payment_provider_model.dart';
import 'package:pasar_now/models/shipping_option_model.dart';
import 'package:pasar_now/models/payment_collection_model.dart';
import 'package:pasar_now/models/order_model.dart';

class ApiService {
  final Dio client = Dio();

  ApiService() {
    client.options.baseUrl = AppConfig.apiBaseUrl;
    
    // Register the biometric authentication interceptor
    client.interceptors.add(MedusaAuthInterceptor());
    
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['x-publishable-api-key'] = AppConfig.publishableKey;
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 || e.error is BiometricAuthException) {
            // Clear secure session if token is invalid or session is locked
            await BiometricAuthService().clearSession();
          }
          return handler.next(e);
        },
      ),
    );

    // Register the retry interceptor to handle transient socket and connection errors
    client.interceptors.add(RetryInterceptor(dio: client));
  }


  Future<List<dynamic>> getAddresses() async {
    try {
      final response = await client.get('/store/customers/me/addresses');
      return response.data['addresses'] ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<PaymentProvider>> getPaymentProviders() async {
    try {
      final response = await client.get(
        '/store/payment-providers?region_id=reg_01KB5C4AEGCZPG55XAWFJBCFCH',
      );
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

  Future<bool> addShippingMethod(String cartId, String optionId) async {
    try {
      await client.post(
        '/store/carts/$cartId/shipping-methods',
        data: {'option_id': optionId},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addAddress(Map<String, dynamic> data) async {
    try {
      await client.post(
        '/store/customers/me/addresses',
        data: data,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAddress(
      String addressId, Map<String, dynamic> data) async {
    try {
      await client.post(
        '/store/customers/me/addresses/$addressId',
        data: data,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    try {
      await client.delete('/store/customers/me/addresses/$addressId');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<PaymentCollection?> createPaymentCollection(String cartId) async {
    try {
      final response = await client.post(
        '/store/payment-collections',
        data: {'cart_id': cartId},
      );
      return PaymentCollection.fromJson(response.data['payment_collection']);
    } catch (e) {
      return null;
    }
  }

  Future<PaymentCollection?> initiatePaymentSession(
      String paymentCollectionId, String providerId) async {
    try {
      final response = await client.post(
        '/store/payment-collections/$paymentCollectionId/payment-sessions',
        data: {'provider_id': providerId},
      );
      return PaymentCollection.fromJson(response.data['payment_collection']);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> completeCart(String cartId) async {
    try {
      final response = await client.post(
        '/store/carts/$cartId/complete',
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateCart(
      String cartId, Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        '/store/carts/$cartId',
        data: data,
      );
      return response.data['cart'];
    } catch (e) {
      return null;
    }
  }

  Future<List<OrderModel>> getOrders({String? status}) async {
    try {
      final String url =
          status != null ? '/store/orders?status=$status' : '/store/orders';
      final response = await client.get(
        url,
      );
      final List<dynamic> ordersData = response.data['orders'] ?? [];
      return ordersData.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<OrderModel?> getOrder(String id) async {
    try {
      final response = await client.get('/store/orders/$id');
      final orderData = response.data['order'];
      if (orderData != null) {
        return OrderModel.fromJson(orderData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> addPromotion(
      String cartId, List<String> promoCodes) async {
    try {
      final response = await client.post(
        '/store/carts/$cartId/promotions',
        data: {'promo_codes': promoCodes},
      );
      return response.data['cart'];
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> removePromotion(
      String cartId, List<String> promoCodes) async {
    try {
      final response = await client.delete(
        '/store/carts/$cartId/promotions',
        data: {'promo_codes': promoCodes},
      );
      return response.data['cart'];
    } catch (e) {
      return null;
    }
  }
}
