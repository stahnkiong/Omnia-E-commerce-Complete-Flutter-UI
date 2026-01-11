class ShippingOption {
  final String id;
  final String name;
  final int amount;
  final CalculatedPrice? calculatedPrice;
  final String? priceType;

  ShippingOption({
    required this.id,
    required this.name,
    required this.amount,
    this.calculatedPrice,
    this.priceType,
  });

  factory ShippingOption.fromJson(Map<String, dynamic> json) {
    int amount = 0;
    if (json['amount'] != null) {
      amount = json['amount'];
    } else if (json['prices'] != null && (json['prices'] as List).isNotEmpty) {
      amount = json['prices'][0]['amount'] ?? 0;
    }

    return ShippingOption(
      id: json['id'],
      name: json['name'],
      amount: amount,
      calculatedPrice: json['calculated_price'] != null
          ? CalculatedPrice.fromJson(json['calculated_price'])
          : null,
      priceType: json['price_type'],
    );
  }

  double get price => (calculatedPrice?.calculatedAmount ?? amount) / 100.0;
}

class CalculatedPrice {
  final int calculatedAmount;

  CalculatedPrice({required this.calculatedAmount});

  factory CalculatedPrice.fromJson(Map<String, dynamic> json) {
    return CalculatedPrice(
      calculatedAmount: json['calculated_amount'],
    );
  }
}
