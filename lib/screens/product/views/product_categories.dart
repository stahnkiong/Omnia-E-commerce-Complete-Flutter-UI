import 'package:flutter/material.dart';
import 'package:pasar_now/components/product/product_card.dart';
import 'package:pasar_now/models/product_model.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:pasar_now/services/product_service.dart';
import 'package:pasar_now/route/screen_export.dart';

import 'package:pasar_now/constants.dart';

class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen(
      {super.key,
      this.collectionId,
      this.categoryId,
      this.isProductAvailable = true});

  final String? collectionId;
  final String? categoryId;
  final bool isProductAvailable;

  @override
  State<ProductCategoriesScreen> createState() =>
      _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();

  List<ProductModel> _products = [];
  int _offset = 0;
  final int _limit = 20;
  bool _isFirstLoad = true;
  bool _isMoreLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isMoreLoading &&
        _hasMore &&
        !_isFirstLoad &&
        widget.categoryId != null) {
      _loadProducts();
    }
  }

  Future<void> _loadProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _products.clear();
        _offset = 0;
        _hasMore = true;
        _isFirstLoad = true;
        _error = null;
      });
    } else if (_isMoreLoading) {
      return;
    } else if (_offset > 0) {
      setState(() {
        _isMoreLoading = true;
      });
    }

    try {
      if (widget.categoryId != null) {
        final result = await _productService.fetchProductsByCategory(
            widget.categoryId!, _offset, _limit);
        final List<ProductModel> newProducts = result['products'];
        final int totalCount = result['count'];

        if (!mounted) return;
        setState(() {
          _products.addAll(newProducts);
          _offset += newProducts.length;
          _isFirstLoad = false;
          _isMoreLoading = false;
          if (_offset >= totalCount || newProducts.isEmpty) {
            _hasMore = false;
          }
        });
      } else if (widget.collectionId != null) {
        final result =
            await _productService.fetchProductsByCollection(widget.collectionId!);
        if (!mounted) return;
        setState(() {
          _products = result;
          _isFirstLoad = false;
          _isMoreLoading = false;
          _hasMore = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isFirstLoad = false;
          _isMoreLoading = false;
          _hasMore = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFirstLoad = false;
        _isMoreLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.collectionId == null && widget.categoryId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Categories"),
        ),
        body: const Center(child: Text("No Categories provided")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isFirstLoad) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Error: $_error",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: defaultPadding),
              ElevatedButton(
                onPressed: () => _loadProducts(isRefresh: true),
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: defaultPadding),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              mainAxisSpacing: defaultPadding,
              crossAxisSpacing: defaultPadding,
              childAspectRatio: 0.66,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ProductCard(
                  productId: _products[index].id,
                  image: _products[index].image,
                  brandName: _products[index].brandName,
                  title: _products[index].title,
                  price: _products[index].price,
                  priceAfetDiscount: _products[index].priceAfetDiscount,
                  dicountpercent: _products[index].dicountpercent,
                  press: () {
                    Navigator.pushNamed(
                      context,
                      productDetailsScreenRoute,
                      arguments: {
                        'productId': _products[index].id,
                        'isProductAvailable': widget.isProductAvailable,
                      },
                    );
                  },
                );
              },
              childCount: _products.length,
            ),
          ),
        ),
        if (_isMoreLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        const SliverPadding(
          padding: EdgeInsets.all(defaultPadding),
          sliver: SliverToBoxAdapter(
            child: SizedBox(height: defaultPadding),
          ),
        ),
      ],
    );
  }
}
