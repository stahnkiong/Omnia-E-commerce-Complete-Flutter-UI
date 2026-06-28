import 'package:pasar_now/config.dart';

class ProductTypeModel {
  final String id;
  final String value;
  final String? image;

  ProductTypeModel({
    required this.id,
    required this.value,
    this.image,
  });

  static String? _replaceLocalhostUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http://localhost:9000')) {
      return url.replaceFirst(
          'http://localhost:9000', AppConfig.apiBaseUrl);
    }
    return url;
  }

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image'] ?? json['metadata']?['image'];
    imageUrl = _replaceLocalhostUrl(imageUrl);
    return ProductTypeModel(
      id: json['id'],
      value: json['value'],
      image: imageUrl,
    );
  }
}
