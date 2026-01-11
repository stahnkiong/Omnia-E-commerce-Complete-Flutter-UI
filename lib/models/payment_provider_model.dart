class PaymentProvider {
  final String id;

  PaymentProvider({required this.id});

  factory PaymentProvider.fromJson(Map<String, dynamic> json) {
    return PaymentProvider(
      id: json['id'],
    );
  }
}
