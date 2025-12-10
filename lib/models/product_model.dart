import 'package:shop/constants.dart';

class ProductModel {
  final String id;
  final String variant;
  final String image, brandName, title;
  final List<String> images;
  final String description;
  final String categories;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final String? subtitle;
  final String? weight;

  ProductModel({
    this.id = "demo_id",
    this.variant = "var_id",
    required this.image,
    this.images = const [],
    this.description = "",
    required this.brandName,
    required this.title,
    this.categories = "",
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.subtitle,
    this.weight,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double price = 0.0;
    String variantId = "";
    if (json['variants'] != null && (json['variants'] as List).isNotEmpty) {
      final variants = json['variants'] as List;
      double minPrice = double.infinity;

      for (var v in variants) {
        if (v['calculated_price'] != null &&
            v['calculated_price']['calculated_amount'] != null) {
          double currentPrice =
              (v['calculated_price']['calculated_amount'] as num).toDouble();
          if (currentPrice < minPrice) {
            minPrice = currentPrice;
            variantId = v['id'] ?? "";
          }
        }
      }
      if (minPrice != double.infinity) {
        price = minPrice;
      }
    }

    return ProductModel(
      id: json['id'] ?? '',
      variant: variantId,
      image: json['thumbnail'] ?? productDemoImg1,
      images: json['images'] != null
          ? (json['images'] as List).map((e) => e['url'] as String).toList()
          : [productDemoImg1, productDemoImg2, productDemoImg3],
      description: json['description'] ?? '',
      subtitle: json['subtitle'] ?? '',
      brandName: (json['collection'] != null)
          ? (json['collection']['title'] ?? '')
          : '',
      categories: (json['collection'] != null)
          ? (json['collection']['title'] ?? '')
          : '',
      title: json['title'] ?? '',
      price: price,
      weight: json['weight'] ?? '',
    );
  }
}

List<ProductModel> demoPopularProducts = [
  ProductModel(
    image: productDemoImg1,
    title: "Mountain Warehouse for Women",
    brandName: "Lipsy london",
    categories: "",
    price: 540,
    priceAfetDiscount: 420,
    dicountpercent: 20,
  ),
  ProductModel(
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    categories: "",
    price: 800,
  ),
  ProductModel(
    image: productDemoImg5,
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy london",
    categories: "",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    image: productDemoImg6,
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    categories: "",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  )
];
