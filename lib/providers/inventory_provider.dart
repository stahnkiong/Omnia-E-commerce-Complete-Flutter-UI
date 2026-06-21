import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../services/inventory_service.dart';

class InventoryItem {
  final String? id; // Database stock item ID
  final String productId;
  final int quantity; // Full Count
  final double loose; // Loose/Open Count (fraction like 0.25 or number of packs like 3)
  final String looseType; // 'decimal' or 'packs'
  final int maxLoosePacks; // e.g. 12 or 24, used if looseType is 'packs'

  InventoryItem({
    this.id,
    required this.productId,
    this.quantity = 0,
    this.loose = 0.0,
    this.looseType = 'decimal',
    this.maxLoosePacks = 12,
  });

  InventoryItem copyWith({
    String? id,
    String? productId,
    int? quantity,
    double? loose,
    String? looseType,
    int? maxLoosePacks,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      loose: loose ?? this.loose,
      looseType: looseType ?? this.looseType,
      maxLoosePacks: maxLoosePacks ?? this.maxLoosePacks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'loose': loose,
      'looseType': looseType,
      'maxLoosePacks': maxLoosePacks,
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String?,
      productId: json['productId'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      loose: (json['loose'] as num? ?? 0.0).toDouble(),
      looseType: json['looseType'] as String? ?? 'decimal',
      maxLoosePacks: json['maxLoosePacks'] as int? ?? 12,
    );
  }

  factory InventoryItem.fromBackendJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String?,
      productId: json['product_id'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      loose: (json['loose'] as num? ?? 0.0).toDouble(),
      looseType: json['loose_type'] as String? ?? 'decimal',
      maxLoosePacks: json['max_loose_packs'] as int? ?? 12,
    );
  }
}

class InventoryProvider with ChangeNotifier {
  final String _prefKey = 'stock_inventory_items';
  final InventoryService _inventoryService = InventoryService();
  
  List<InventoryItem> _items = [];
  List<ProductModel> _fetchedProducts = [];
  bool _isLoading = false;

  List<InventoryItem> get items => _items;
  List<ProductModel> get fetchedProducts => _fetchedProducts;
  bool get isLoading => _isLoading;

  InventoryProvider() {
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? itemsJson = prefs.getString(_prefKey);
      if (itemsJson != null) {
        final List<dynamic> decoded = json.decode(itemsJson);
        _items = decoded.map((item) => InventoryItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint("Error loading local inventory cache: $e");
    }
    notifyListeners();
    // Try to sync with backend on provider start
    fetchInventory();
  }

  Future<void> _saveInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString(_prefKey, encoded);
    } catch (e) {
      debugPrint("Error saving local inventory cache: $e");
    }
  }

  Future<void> fetchInventory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _inventoryService.fetchStockAndProducts();
      _items = response.stockItems;
      _fetchedProducts = response.products;
      await _saveInventory();
    } catch (e) {
      debugPrint("Error fetching inventory from backend: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  InventoryItem getItemForProduct(String productId) {
    return _items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => InventoryItem(productId: productId),
    );
  }

  Future<void> updateItem(InventoryItem updatedItem) async {
    final index = _items.indexWhere((item) => item.productId == updatedItem.productId);
    InventoryItem? oldItem;
    if (index != -1) {
      oldItem = _items[index];
      _items[index] = updatedItem;
    } else {
      _items.add(updatedItem);
    }
    notifyListeners();

    try {
      final savedItem = await _inventoryService.upsertStockItem(
        productId: updatedItem.productId,
        quantity: updatedItem.quantity,
        loose: updatedItem.loose,
        looseType: updatedItem.looseType,
        maxLoosePacks: updatedItem.maxLoosePacks,
      );
      final newIndex = _items.indexWhere((item) => item.productId == savedItem.productId);
      if (newIndex != -1) {
        _items[newIndex] = savedItem;
      }
      await _saveInventory();
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving stock item to backend: $e");
      // Rollback on error
      if (oldItem != null && index != -1) {
        _items[index] = oldItem;
      } else {
        _items.removeWhere((item) => item.productId == updatedItem.productId);
      }
      notifyListeners();
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final item = getItemForProduct(productId);
    await updateItem(item.copyWith(quantity: quantity));
  }

  Future<void> updateLoose(String productId, double loose) async {
    final item = getItemForProduct(productId);
    await updateItem(item.copyWith(loose: loose));
  }

  Future<void> updateLooseType(String productId, String looseType) async {
    final item = getItemForProduct(productId);
    await updateItem(item.copyWith(looseType: looseType));
  }

  Future<void> updateMaxLoosePacks(String productId, int maxLoosePacks) async {
    final item = getItemForProduct(productId);
    await updateItem(item.copyWith(maxLoosePacks: maxLoosePacks));
  }

  Future<void> deleteItem(String productId) async {
    final item = getItemForProduct(productId);
    final stockItemId = item.id;
    if (stockItemId == null || stockItemId.isEmpty) {
      _items.removeWhere((i) => i.productId == productId);
      notifyListeners();
      await _saveInventory();
      return;
    }

    final index = _items.indexWhere((i) => i.productId == productId);
    final oldItem = item;
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();

    try {
      await _inventoryService.deleteStockItem(stockItemId);
      await _saveInventory();
    } catch (e) {
      debugPrint("Error deleting stock item from backend: $e");
      if (index != -1) {
        _items.insert(index, oldItem);
      }
      notifyListeners();
    }
  }
}
