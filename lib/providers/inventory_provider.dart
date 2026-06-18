import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventoryItem {
  final String productId;
  final int quantity; // Full Count
  final double loose; // Loose/Open Count (fraction like 0.25 or number of packs like 3)
  final String looseType; // 'decimal' or 'packs'
  final int maxLoosePacks; // e.g. 12 or 24, used if looseType is 'packs'

  InventoryItem({
    required this.productId,
    this.quantity = 0,
    this.loose = 0.0,
    this.looseType = 'decimal',
    this.maxLoosePacks = 12,
  });

  InventoryItem copyWith({
    String? productId,
    int? quantity,
    double? loose,
    String? looseType,
    int? maxLoosePacks,
  }) {
    return InventoryItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      loose: loose ?? this.loose,
      looseType: looseType ?? this.looseType,
      maxLoosePacks: maxLoosePacks ?? this.maxLoosePacks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'loose': loose,
      'looseType': looseType,
      'maxLoosePacks': maxLoosePacks,
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      productId: json['productId'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      loose: (json['loose'] as num? ?? 0.0).toDouble(),
      looseType: json['looseType'] as String? ?? 'decimal',
      maxLoosePacks: json['maxLoosePacks'] as int? ?? 12,
    );
  }
}

class InventoryProvider with ChangeNotifier {
  final String _prefKey = 'stock_inventory_items';
  List<InventoryItem> _items = [];

  List<InventoryItem> get items => _items;

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
      } else {
        // Prepopulate with user's examples
        _items = [
          InventoryItem(
            productId: "mock_beef_broth",
            quantity: 2,
            loose: 0.25,
            looseType: 'decimal',
            maxLoosePacks: 12,
          ),
          InventoryItem(
            productId: "mock_ayamfiesta_nuggets",
            quantity: 1,
            loose: 3.0,
            looseType: 'packs',
            maxLoosePacks: 12,
          ),
        ];
        await _saveInventory();
      }
    } catch (e) {
      debugPrint("Error loading inventory: $e");
    }
    notifyListeners();
  }

  Future<void> _saveInventory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_items.map((item) => item.toJson()).toList());
      await prefs.setString(_prefKey, encoded);
    } catch (e) {
      debugPrint("Error saving inventory: $e");
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
    if (index != -1) {
      _items[index] = updatedItem;
    } else {
      _items.add(updatedItem);
    }
    notifyListeners();
    await _saveInventory();
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
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
    await _saveInventory();
  }
}
