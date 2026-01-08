class Address {
  final String id;
  final String addressName;
  final String? company;
  final String? firstName;
  final String? lastName;
  final String? address1;
  final String? address2;
  final String? city;
  final String? countryCode;
  final String? province;
  final String? postalCode;
  final String? phone;

  Address({
    required this.id,
    required this.addressName,
    this.company,
    this.firstName,
    this.lastName,
    this.address1,
    this.address2,
    this.city,
    this.countryCode,
    this.province,
    this.postalCode,
    this.phone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '',
      addressName: json['address_name'] ?? '',
      company: json['company'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      address1: json['address_1'],
      address2: json['address_2'],
      city: json['city'],
      countryCode: json['country_code'],
      province: json['province'],
      postalCode: json['postal_code'],
      phone: json['phone'],
    );
  }
}
