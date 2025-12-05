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
      print(response.data);

      if (response.data != null && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];

        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print(e);
      throw Exception('Failed to fetch popular products: $e');
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
      print(e);
      throw Exception('Failed to fetch product: $e');
    }
  }
}
