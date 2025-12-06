import 'api_service.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<List<ProductModel>> fetchPopularProducts() async {
    try {
      final response = await _api.client.get(
        '/store/products',
        queryParameters: {
          'tag_id': 'ptag_01KBPS5PM2MYA6KT373DX3NYJE',
          'limit': 10,
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

  Future<List<ProductModel>> fetchMostPopular() async {
    try {
      final response = await _api.client.get(
        '/store/products',
        queryParameters: {
          'tag_id': 'ptag_01KBSANZY7K5B8YDB68RZQ177B',
          'limit': 10,
        },
      );

      if (response.data != null && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];

        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch most popular: $e');
    }
  }

  Future<ProductModel?> fetchProduct(String id) async {
    try {
      final response = await _api.client.get('/store/products/$id');
      if (response.data != null && response.data['product'] != null) {
        return ProductModel.fromJson(response.data['product']);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }
}
