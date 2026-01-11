import 'package:shop/config.dart';
import 'package:shop/models/address_model.dart';

class OrderModel {
  final String id;
  final int displayId;
  final String status;
  final String fulfillmentStatus;
  final String paymentStatus;
  final double total;
  final String currencyCode;
  final DateTime createdAt;
  final List<LineItemModel> items;
  final List<FulfillmentModel> fulfillments;
  final Address? shippingAddress;

  OrderModel({
    required this.id,
    required this.displayId,
    required this.status,
    required this.fulfillmentStatus,
    required this.paymentStatus,
    required this.total,
    required this.currencyCode,
    required this.items,
    required this.createdAt,
    this.fulfillments = const [],
    this.shippingAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      displayId: json['display_id'],
      status: json['status'],
      fulfillmentStatus: json['fulfillment_status'],
      paymentStatus: json['payment_status'],
      total: (json['total'] as num).toDouble() /
          100, // Medusa amounts are in cents
      currencyCode: json['currency_code'].toString().toUpperCase(),
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List)
          .map((item) => LineItemModel.fromJson(item))
          .toList(),
      fulfillments: json['fulfillments'] != null
          ? (json['fulfillments'] as List)
              .map((f) => FulfillmentModel.fromJson(f))
              .toList()
          : [],
      shippingAddress: json['shipping_address'] != null
          ? Address.fromJson(json['shipping_address'])
          : null,
    );
  }
}

class LineItemModel {
  final String id;
  final String title;
  final String thumbnail;
  final int quantity;
  final double unitPrice;

  LineItemModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.quantity,
    required this.unitPrice,
  });

  factory LineItemModel.fromJson(Map<String, dynamic> json) {
    String thumb = json['thumbnail'] ?? "";
    if (thumb.startsWith('http://localhost') && AppConfig.isDev) {
      thumb = thumb.replaceFirst("localhost", "10.0.2.2");
    }

    return LineItemModel(
      id: json['id'],
      title: json['title'],
      thumbnail: thumb,
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble() / 100,
    );
  }
}

class FulfillmentModel {
  final String id;
  final String providerId;

  FulfillmentModel({required this.id, required this.providerId});

  factory FulfillmentModel.fromJson(Map<String, dynamic> json) {
    return FulfillmentModel(
      id: json['id'],
      providerId: json['provider_id'],
    );
  }
}
