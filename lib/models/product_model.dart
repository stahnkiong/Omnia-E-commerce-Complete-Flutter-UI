import 'package:pasar_now/constants.dart';
import 'package:pasar_now/config.dart';

class ProductModel {
  final String id;
  final String variant;
  final String image, brandName, title;
  final List<String> images;
  final String description;
  final String categories;
  final String? categoryId;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final String? subtitle;
  final String? weight;
  final List<ProductOptionModel> options;
  final List<ProductVariantModel> variants;

  ProductModel({
    this.id = "demo_id",
    this.variant = "var_id",
    required this.image,
    this.images = const [],
    this.description = "",
    required this.brandName,
    required this.title,
    this.categories = "",
    this.categoryId,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.subtitle,
    this.weight,
    this.options = const [],
    this.variants = const [],
  });

  // Helper method to replace localhost URLs with network IP
  static String _replaceLocalhostUrl(String url) {
    if (url.startsWith('http://localhost:9000')) {
      return url.replaceFirst(
          'http://localhost:9000', AppConfig.apiBaseUrl);
    }
    return url;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double price = 0.0;
    String variantId = "";
    List<ProductVariantModel> parsedVariants = [];
    if (json['variants'] != null && (json['variants'] as List).isNotEmpty) {
      final variantsJson = json['variants'] as List;
      double minPrice = double.infinity;

      for (var v in variantsJson) {
        final parsedVar = ProductVariantModel.fromJson(v);
        parsedVariants.add(parsedVar);
        
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

    // Process options
    List<ProductOptionModel> parsedOptions = [];
    if (json['options'] != null) {
      final opts = json['options'] as List;
      parsedOptions = opts.map((o) => ProductOptionModel.fromJson(o)).toList();
    }

    // Process thumbnail URL
    String thumbnailUrl = json['thumbnail'] ?? productDemoImg1;
    thumbnailUrl = _replaceLocalhostUrl(thumbnailUrl);

    // Process images URLs
    List<String> imagesList;
    if (json['images'] != null) {
      imagesList = (json['images'] as List)
          .map((e) => _replaceLocalhostUrl(e['url'] as String))
          .toList();
    } else {
      imagesList = [productDemoImg1, productDemoImg2, productDemoImg3];
    }

    String? categoryId;
    if (json['categories'] != null && (json['categories'] as List).isNotEmpty) {
      categoryId = json['categories'][0]['id'];
    }

    return ProductModel(
      id: json['id'] ?? '',
      variant: variantId,
      image: thumbnailUrl,
      images: imagesList,
      description: json['description'] ?? '',
      subtitle: json['subtitle'] ?? '',
      brandName: (json['collection'] != null)
          ? (json['collection']['title'] ?? '')
          : '',
      categories: (json['collection'] != null)
          ? (json['collection']['title'] ?? '')
          : '',
      categoryId: categoryId,
      title: json['title'] ?? '',
      price: price,
      weight: json['weight'] ?? '',
      options: parsedOptions,
      variants: parsedVariants,
    );
  }
}

class ProductOptionModel {
  final String id;
  final String title;
  final List<ProductOptionValueModel> values;

  ProductOptionModel({
    required this.id,
    required this.title,
    required this.values,
  });

  factory ProductOptionModel.fromJson(Map<String, dynamic> json) {
    var vals = json['values'] as List? ?? [];
    return ProductOptionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      values: vals.map((v) => ProductOptionValueModel.fromJson(v)).toList(),
    );
  }
}

class ProductOptionValueModel {
  final String id;
  final String value;
  final String optionId;

  ProductOptionValueModel({
    required this.id,
    required this.value,
    required this.optionId,
  });

  factory ProductOptionValueModel.fromJson(Map<String, dynamic> json) {
    return ProductOptionValueModel(
      id: json['id'] ?? '',
      value: json['value'] ?? '',
      optionId: json['option_id'] ?? '',
    );
  }
}

class VariantOptionAssociationModel {
  final String id;
  final String value;
  final String optionId;

  VariantOptionAssociationModel({
    required this.id,
    required this.value,
    required this.optionId,
  });

  factory VariantOptionAssociationModel.fromJson(Map<String, dynamic> json) {
    return VariantOptionAssociationModel(
      id: json['id'] ?? '',
      value: json['value'] ?? '',
      optionId: json['option_id'] ?? '',
    );
  }
}

class ProductVariantModel {
  final String id;
  final String title;
  final double? price;
  final double? priceAfterDiscount;
  final List<VariantOptionAssociationModel> options;
  final bool manageInventory;

  ProductVariantModel({
    required this.id,
    required this.title,
    required this.price,
    this.priceAfterDiscount,
    required this.options,
    this.manageInventory = false,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    double? calculatedPrice;
    double? originalPrice;
    
    if (json['calculated_price'] != null) {
      calculatedPrice = (json['calculated_price']['calculated_amount'] as num?)?.toDouble();
      originalPrice = (json['calculated_price']['original_amount'] as num?)?.toDouble();
    }
    
    var opts = json['options'] as List? ?? [];
    
    return ProductVariantModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: calculatedPrice,
      priceAfterDiscount: originalPrice != null && calculatedPrice != null && originalPrice > calculatedPrice ? originalPrice : null,
      options: opts.map((o) => VariantOptionAssociationModel.fromJson(o)).toList(),
      manageInventory: json['manage_inventory'] ?? false,
    );
  }
}

List<ProductModel> demoPopularProducts = [
  ProductModel(
    id: "demo_popular_1",
    image: productDemoImg1,
    title: "Mountain Warehouse for Women",
    brandName: "Lipsy london",
    categories: "",
    price: 540,
    priceAfetDiscount: 420,
    dicountpercent: 20,
  ),
  ProductModel(
    id: "demo_popular_2",
    image: productDemoImg4,
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    categories: "",
    price: 800,
  ),
  ProductModel(
    id: "demo_popular_3",
    image: productDemoImg5,
    title: "FS - Nike Air Max 270 Really React",
    brandName: "Lipsy london",
    categories: "",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    id: "demo_popular_4",
    image: productDemoImg6,
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    categories: "",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  )
];
