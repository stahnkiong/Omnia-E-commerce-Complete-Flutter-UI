import 'api_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<List<ProductModel>> fetchPopularProducts() async {
    try {
      final response = await _api.client.get(
        '/store/products',
        queryParameters: {
          'tag_id': 'ptag_01KBPS5PM2MYA6KT373DX3NYJE',
          'limit': 10,
          'fields': '*variants.calculated_price'
        },
      );

      if (response.data != null && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];

        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch popular products: $e');
    }
  }

  Future<List<ProductModel>> fetchBestSellers() async {
    try {
      final response = await _api.client.get(
        '/store/products',
        queryParameters: {
          'tag_id': 'ptag_01KBSAG9VG1E8RHZAGWHR2HN41',
          'limit': 10,
          'fields': '*variants.calculated_price'
        },
      );

      if (response.data != null && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];

        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch best sellers: $e');
    }
  }

  Future<List<ProductModel>> fetchFeaturedProducts() async {
    try {
      final response = await _api.client.get(
        '/store/products',
        queryParameters: {
          'tag_id': 'ptag_01KBSANZY7K5B8YDB68RZQ177B',
          'limit': 10,
          'fields': '*variants.calculated_price'
        },
      );

      if (response.data != null && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];

        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  Future<List<ProductModel>> fetchFlashSaleProducts() async {
    try {
      final response = await _api.client.get(
        '/store/products',
        queryParameters: {
          'tag_id': 'ptag_01KBSDR2WPW75KEJ2YHFVG8JJJ',
          'limit': 10,
          'fields': '*variants.calculated_price'
        },
      );

      if (response.data != null && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];

        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch flash sale products: $e');
    }
  }

  Future<ProductModel?> fetchProduct(String id) async {
    try {
      final response = await _api.client.get('/store/products/$id',
          queryParameters: {'fields': '*variants.calculated_price'});
      if (response.data != null && response.data['product'] != null) {
        return ProductModel.fromJson(response.data['product']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  Future<List<ProductModel>> fetchProductsByCollection(
      String collectionId) async {
    try {
      final response = await _api.client.get(
        '/store/products',
        queryParameters: {
          'collection_id': collectionId,
          'limit': 10,
          'fields': '*variants.calculated_price'
        },
      );

      if (response.data != null && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];
        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch products by collection: $e');
    }
  }

  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    try {
      final response = await _api.client.get(
        '/store/products',
        queryParameters: {
          'category_id': categoryId,
          'limit': 10,
          'fields': '*variants.calculated_price'
        },
      );

      if (response.data != null && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];
        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch products by collection: $e');
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _api.client.get('/store/product-categories');

      if (response.data != null &&
          response.data['product_categories'] != null) {
        final List<dynamic> categoriesJson =
            response.data['product_categories'];
        return categoriesJson
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
