import 'package:shop/models/payment_collection_model.dart';

class CartModel {
  final String id;
  final double total;
  final double subtotal;
  final List<CartItemModel> items;
  final PaymentCollection? paymentCollection;

  CartModel({
    required this.id,
    required this.total,
    required this.subtotal,
    required this.items,
    this.paymentCollection,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'],
      total: (json['total'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      paymentCollection: json['payment_collection'] != null
          ? PaymentCollection.fromJson(json['payment_collection'])
          : null,
    );
  }
}

class CartItemModel {
  final String id;
  final String? thumbnail;
  final String productTitle;
  final String variantTitle;
  final int quantity;
  final double unitPrice;

  CartItemModel({
    required this.id,
    this.thumbnail,
    required this.productTitle,
    required this.variantTitle,
    required this.quantity,
    required this.unitPrice,
  });

  // Helper method to replace localhost URLs with network IP
  static String _replaceLocalhostUrl(String url) {
    if (url.startsWith('http://localhost:9000')) {
      return url.replaceFirst(
          'http://localhost:9000', 'http://192.168.50.50:9000');
    }
    return url;
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      thumbnail: _replaceLocalhostUrl(json['thumbnail']),
      productTitle: json['product_title'] ?? '',
      variantTitle: json['variant_title'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] as num).toDouble(),
    );
  }
}
