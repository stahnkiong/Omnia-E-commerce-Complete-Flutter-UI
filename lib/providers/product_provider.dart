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

  List<ProductModel> _bestSellers = [];
  List<ProductModel> get bestSellers => _bestSellers;

  Future<void> fetchBestSellers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bestSellers = await _productService.fetchBestSellers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> _featuredProducts = [];
  List<ProductModel> get featuredProducts => _featuredProducts;

  Future<void> fetchFeaturedProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _featuredProducts = await _productService.fetchFeaturedProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> _flashSaleProducts = [];
  List<ProductModel> get flashSaleProducts => _flashSaleProducts;

  Future<void> fetchFlashSaleProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _flashSaleProducts = await _productService.fetchFlashSaleProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
