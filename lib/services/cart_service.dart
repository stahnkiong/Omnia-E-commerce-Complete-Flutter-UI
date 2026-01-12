import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/cart_model.dart';

class CartService {
  final ApiService _api = ApiService();
  static const String _cartIdKey = 'cart_id';

  Future<String> getOrCreateCartId() async {
    final prefs = await SharedPreferences.getInstance();
    String? cartId = prefs.getString(_cartIdKey);

    if (cartId == null) {
      cartId = await _createCart();
      if (cartId != null) {
        await prefs.setString(_cartIdKey, cartId);
      } else {
        throw Exception("Failed to create cart");
      }
    }
    return cartId;
  }

  Future<String?> _createCart() async {
    try {
      final response = await _api.client.post(
        '/store/carts',
        data: {"region_id": "reg_01KB5C4AEGCZPG55XAWFJBCFCH"},
      );

      if (response.data != null && response.data['cart'] != null) {
        return response.data['cart']['id'];
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error creating cart: $e');
      return null;
    }
  }

  Future<void> addToCart(String variantId, int quantity) async {
    try {
      final cartId = await getOrCreateCartId();
      await _api.client.post(
        '/store/carts/$cartId/line-items',
        data: {
          "variant_id": variantId,
          "quantity": quantity,
        },
      );
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<CartModel?> fetchCart() async {
    try {
      final cartId = await getOrCreateCartId();
      final response = await _api.client.get('/store/carts/$cartId');

      if (response.data != null && response.data['cart'] != null) {
        return CartModel.fromJson(response.data['cart']);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching cart: $e');
      return null;
    }
  }

  Future<void> updateLineItem(String lineId, int quantity) async {
    try {
      final cartId = await getOrCreateCartId();
      await _api.client.post(
        '/store/carts/$cartId/line-items/$lineId',
        data: {
          "quantity": quantity,
        },
      );
    } catch (e) {
      throw Exception('Failed to update line item: $e');
    }
  }

  Future<void> deleteLineItem(String lineId) async {
    try {
      final cartId = await getOrCreateCartId();
      await _api.client.delete(
        '/store/carts/$cartId/line-items/$lineId',
      );
    } catch (e) {
      throw Exception('Failed to delete line item: $e');
    }
  }

  Future<Map<String, dynamic>?> completeCart() async {
    try {
      final cartId = await getOrCreateCartId();
      final result = await _api.completeCart(cartId);
      if (result != null && result['type'] == 'order') {
        await clearCartId();
      }
      return result;
    } catch (e) {
      // ignore: avoid_print
      print('Error completing cart: $e');
      return null;
    }
  }

  Future<void> clearCartId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartIdKey);
  }
}
