import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider with ChangeNotifier {
  final String _prefKey = 'wishlist_ids';
  List<String> _wishlistedIds = [];

  List<String> get wishlistedIds => _wishlistedIds;

  WishlistProvider() {
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    _wishlistedIds = prefs.getStringList(_prefKey) ?? [];
    notifyListeners();
  }

  Future<void> toggleWishlist(String productId) async {
    final prefs = await SharedPreferences.getInstance();

    if (_wishlistedIds.contains(productId)) {
      _wishlistedIds.remove(productId);
    } else {
      _wishlistedIds.add(productId);
    }

    await prefs.setStringList(_prefKey, _wishlistedIds);
    notifyListeners();
  }

  bool isWishlisted(String productId) {
    return _wishlistedIds.contains(productId);
  }
}
