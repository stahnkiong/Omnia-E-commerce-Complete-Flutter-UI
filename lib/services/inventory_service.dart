import '../models/product_model.dart';
import '../providers/inventory_provider.dart';
import 'api_service.dart';

class InventoryService {
  final ApiService _api = ApiService();

  Future<InventoryResponse> fetchStockAndProducts() async {
    try {
      final response = await _api.client.get('/store/customers/me/stock');
      
      final List<dynamic> stockItemsJson = response.data['stock_items'] ?? [];
      final List<dynamic> productsJson = response.data['products'] ?? [];

      final List<InventoryItem> stockItems = stockItemsJson
          .map((json) => InventoryItem.fromBackendJson(json))
          .toList();

      final List<ProductModel> products = productsJson
          .map((json) => ProductModel.fromJson(json))
          .toList();

      return InventoryResponse(
        stockItems: stockItems,
        products: products,
      );
    } catch (e) {
      throw Exception('Failed to fetch inventory stock: $e');
    }
  }

  Future<InventoryItem> upsertStockItem({
    required String productId,
    required int quantity,
    required double loose,
    required String looseType,
    required int maxLoosePacks,
  }) async {
    try {
      final response = await _api.client.post(
        '/store/customers/me/stock',
        data: {
          'product_id': productId,
          'quantity': quantity,
          'loose': loose,
          'loose_type': looseType,
          'max_loose_packs': maxLoosePacks,
        },
      );

      final stockItemJson = response.data['stock_item'];
      return InventoryItem.fromBackendJson(stockItemJson);
    } catch (e) {
      throw Exception('Failed to update inventory stock: $e');
    }
  }

  Future<bool> deleteStockItem(String stockItemId) async {
    try {
      await _api.client.delete(
        '/store/customers/me/stock',
        queryParameters: {'stock_item_id': stockItemId},
      );
      return true;
    } catch (e) {
      throw Exception('Failed to delete inventory stock item: $e');
    }
  }
}

class InventoryResponse {
  final List<InventoryItem> stockItems;
  final List<ProductModel> products;

  InventoryResponse({
    required this.stockItems,
    required this.products,
  });
}
