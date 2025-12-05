import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _popularProducts = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get popularProducts => _popularProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPopularProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _popularProducts = await _productService.fetchPopularProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
