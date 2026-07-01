import 'package:flutter/material.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/components/product/product_card.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:pasar_now/models/product_model.dart';
import 'package:pasar_now/services/product_service.dart';
import 'components/search_form.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  int _offset = 0;
  final int _limit = 20;
  List<ProductModel> _products = [];
  bool _isFirstLoad = false;
  bool _isMoreLoading = false;
  bool _hasMore = true;
  String _query = "";

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _scrollController = ScrollController()..addListener(_onScroll);
    
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _query = widget.initialQuery!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startSearch();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isMoreLoading &&
        _hasMore &&
        !_isFirstLoad &&
        _query.isNotEmpty) {
      _fetchNextSearchPage();
    }
  }

  Future<void> _startSearch() async {
    setState(() {
      _products.clear();
      _offset = 0;
      _hasMore = true;
      _isFirstLoad = true;
    });

    try {
      final productService = ProductService();
      final result = await productService.searchProductsPaginated(_query, _offset, _limit);
      final List<ProductModel> newProducts = result['products'];
      final int totalCount = result['count'];

      setState(() {
        _products = newProducts;
        _offset += newProducts.length;
        _isFirstLoad = false;
        if (_offset >= totalCount || newProducts.isEmpty) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFirstLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching products: $e')),
      );
    }
  }

  Future<void> _fetchNextSearchPage() async {
    setState(() {
      _isMoreLoading = true;
    });

    try {
      final productService = ProductService();
      final result = await productService.searchProductsPaginated(_query, _offset, _limit);
      final List<ProductModel> newProducts = result['products'];
      final int totalCount = result['count'];

      setState(() {
        _products.addAll(newProducts);
        _offset += newProducts.length;
        _isMoreLoading = false;
        if (_offset >= totalCount || newProducts.isEmpty) {
          _hasMore = false;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isMoreLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more results: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SearchForm(
                controller: _searchController,
                autofocus: widget.initialQuery == null || widget.initialQuery!.isEmpty,
                onFieldSubmitted: (val) {
                  if (val != null) {
                    final cleanVal = val.trim();
                    if (cleanVal.isNotEmpty) {
                      _query = cleanVal;
                      _startSearch();
                    }
                  }
                },
                onChanged: (val) {
                  if (val == null || val.trim().isEmpty) {
                    setState(() {
                      _query = "";
                      _products.clear();
                      _offset = 0;
                      _hasMore = false;
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: defaultPadding),
            Text(
              "Type to search for products...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_isFirstLoad) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: defaultPadding),
            Text(
              "No products found.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: (_products.length / 2).ceil() + (_isMoreLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == (_products.length / 2).ceil()) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final int firstIndex = index * 2;
        final int secondIndex = firstIndex + 1;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding / 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: ProductCard(
                  productId: _products[firstIndex].id,
                  image: _products[firstIndex].image,
                  brandName: _products[firstIndex].brandName,
                  title: _products[firstIndex].title,
                  price: _products[firstIndex].price,
                  priceAfetDiscount: _products[firstIndex].priceAfetDiscount,
                  dicountpercent: _products[firstIndex].dicountpercent,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 240),
                    maximumSize: const Size(double.infinity, 240),
                    padding: const EdgeInsets.all(8),
                  ),
                  press: () {
                    Navigator.pushNamed(
                      context,
                      productDetailsScreenRoute,
                      arguments: {
                        'productId': _products[firstIndex].id,
                        'isProductAvailable': true,
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: secondIndex < _products.length
                    ? ProductCard(
                        productId: _products[secondIndex].id,
                        image: _products[secondIndex].image,
                        brandName: _products[secondIndex].brandName,
                        title: _products[secondIndex].title,
                        price: _products[secondIndex].price,
                        priceAfetDiscount: _products[secondIndex].priceAfetDiscount,
                        dicountpercent: _products[secondIndex].dicountpercent,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 240),
                          maximumSize: const Size(double.infinity, 240),
                          padding: const EdgeInsets.all(8),
                        ),
                        press: () {
                          Navigator.pushNamed(
                            context,
                            productDetailsScreenRoute,
                            arguments: {
                              'productId': _products[secondIndex].id,
                              'isProductAvailable': true,
                            },
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
