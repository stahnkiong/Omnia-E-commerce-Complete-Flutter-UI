class PaymentCollection {
  final String id;
  final double amount;
  final List<PaymentSession> paymentSessions;

  PaymentCollection({
    required this.id,
    required this.amount,
    required this.paymentSessions,
  });

  factory PaymentCollection.fromJson(Map<String, dynamic> json) {
    return PaymentCollection(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      paymentSessions: (json['payment_sessions'] as List?)
              ?.map((e) => PaymentSession.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PaymentSession {
  final String id;
  final String providerId;
  final String status;
  final Map<String, dynamic> data;

  PaymentSession({
    required this.id,
    required this.providerId,
    required this.status,
    required this.data,
  });

  factory PaymentSession.fromJson(Map<String, dynamic> json) {
    return PaymentSession(
      id: json['id'],
      providerId: json['provider_id'],
      status: json['status'],
      data: json['data'] ?? {},
    );
  }
}
