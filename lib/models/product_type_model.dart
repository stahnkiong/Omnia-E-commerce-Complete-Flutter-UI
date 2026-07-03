import 'package:pasar_now/config.dart';

class ProductTypeModel {
  final String id;
  final String value;
  final String? image;
  final String? title;
  final String? subtitle;

  ProductTypeModel({
    required this.id,
    required this.value,
    this.image,
    this.title,
    this.subtitle,
  });

  static String? _replaceLocalhostUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http://localhost:9000')) {
      return url.replaceFirst(
          'http://localhost:9000', AppConfig.apiBaseUrl);
    }
    return url;
  }

  static String? _limitLength(String? text, int maxLength) {
    if (text == null) return null;
    if (text.length > maxLength) {
      return "${text.substring(0, maxLength - 3)}...";
    }
    return text;
  }

  factory ProductTypeModel.fromJson(Map<String, dynamic> json) {
    String? imageUrl = json['image'] ?? json['metadata']?['image'];
    imageUrl = _replaceLocalhostUrl(imageUrl);

    final String? rawTitle = json['title'] ?? json['metadata']?['title'];
    final String? rawSubtitle = json['subtitle'] ?? json['metadata']?['subtitle'];

    return ProductTypeModel(
      id: json['id'],
      value: json['value'],
      image: imageUrl,
      title: _limitLength(rawTitle, 25),
      subtitle: _limitLength(rawSubtitle, 50),
    );
  }
}
