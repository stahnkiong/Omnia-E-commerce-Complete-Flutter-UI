import 'package:flutter/material.dart';
import 'package:pasar_now/components/Banner/S/banner_g.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/route/screen_export.dart';
import 'package:pasar_now/models/product_type_model.dart';
import 'package:pasar_now/services/product_service.dart';
import 'package:pasar_now/components/product/product_card.dart';
import 'package:pasar_now/models/product_model.dart';

import 'components/best_sellers.dart';
import 'components/flash_sale.dart';
import 'components/featured_products.dart';
import 'components/categories.dart';
import 'components/popular_products.dart';
import 'home_screen_images.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  List<ProductTypeModel>? _productTypes;

  // Pagination State for Infinite Scroll
  final ScrollController _scrollController = ScrollController();
  final List<ProductModel> _paginatedProducts = [];
  int _offset = 0;
  final int _limit = 20;
  bool _isMoreLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchProductTypes();
    _fetchNextProductsPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchNextProductsPage();
    }
  }

  Future<void> _fetchNextProductsPage() async {
    if (_isMoreLoading || !_hasMore) return;
    setState(() {
      _isMoreLoading = true;
    });

    try {
      final result = await _productService.fetchProductsPaginated(_offset, _limit);
      final List<ProductModel> newProducts = result['products'];
      final int totalCount = result['count'];

      if (mounted) {
        setState(() {
          _paginatedProducts.addAll(newProducts);
          _offset += _limit;
          _isMoreLoading = false;
          if (_paginatedProducts.length >= totalCount || newProducts.isEmpty) {
            _hasMore = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMoreLoading = false;
        });
      }
    }
  }

  Future<void> _fetchProductTypes() async {
    try {
      final types = await _productService.fetchProductTypes();
      if (mounted) {
        setState(() {
          _productTypes = types;
          if (types.isNotEmpty && types[0].image != null) {
            HomeScreenImages.banner1 = types[0].image!;
          }
          if (types.length > 1 && types[1].image != null) {
            HomeScreenImages.banner2 = types[1].image!;
          }
          if (types.length > 2 && types[2].image != null) {
            HomeScreenImages.banner3 = types[2].image!;
          }
          if (types.length > 3 && types[3].image != null) {
            HomeScreenImages.banner4 = types[3].image!;
          }
          if (types.length > 4 && types[4].image != null) {
            HomeScreenImages.banner5 = types[4].image!;
          }
        });
      }
    } catch (e) {
      // Failed to load product types, defaults will remain
    }
  }

  String _getBannerImage(int index, String defaultAsset) {
    if (_productTypes != null && _productTypes!.length > index) {
      return _productTypes![index].image ?? defaultAsset;
    }
    return defaultAsset;
  }

  void _onBannerTap(int index) {
    if (_productTypes != null && _productTypes!.length > index) {
      final type = _productTypes![index];
      Navigator.pushNamed(
        context,
        productTypesScreenRoute,
        arguments: {
          'typeId': type.id,
          'typeName': type.value,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  BannerG(
                    image: _getBannerImage(0, HomeScreenImages.banner1),
                    press: () => _onBannerTap(0),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text(
                  "Categories",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Categories()),
            const SliverToBoxAdapter(child: PopularProducts()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding),
                  BannerG(
                    image: _getBannerImage(1, HomeScreenImages.banner2),
                    press: () => _onBannerTap(1),
                  ),
                ],
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding * 0.5),
              sliver: SliverToBoxAdapter(child: FlashSale()),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding),
                  BannerG(
                    image: _getBannerImage(2, HomeScreenImages.banner3),
                    press: () => _onBannerTap(2),
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: BestSellers()),
            const SliverToBoxAdapter(child: FeaturedProducts()),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: defaultPadding * 1.5),
                  const SizedBox(height: defaultPadding / 4),
                  BannerG(
                    image: _getBannerImage(3, HomeScreenImages.banner4),
                    press: () => _onBannerTap(3),
                  ),
                  const SizedBox(height: defaultPadding / 4),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: BestSellers()),
            if (_productTypes == null || _productTypes!.length >= 5)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    BannerG(
                      image: _getBannerImage(4, HomeScreenImages.banner5),
                      press: () => _onBannerTap(4),
                    ),
                  ],
                ),
              ),
            if (_paginatedProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Text(
                    "More Products",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            if (_paginatedProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (_paginatedProducts.length / 2).ceil(),
                  itemBuilder: (context, index) {
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
                              productId: _paginatedProducts[firstIndex].id,
                              image: _paginatedProducts[firstIndex].image,
                              brandName: _paginatedProducts[firstIndex].brandName,
                              title: _paginatedProducts[firstIndex].title,
                              price: _paginatedProducts[firstIndex].price,
                              priceAfetDiscount:
                                  _paginatedProducts[firstIndex].priceAfetDiscount,
                              dicountpercent:
                                  _paginatedProducts[firstIndex].dicountpercent,
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
                                    'productId': _paginatedProducts[firstIndex].id,
                                    'isProductAvailable': true,
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: defaultPadding),
                          Expanded(
                            child: secondIndex < _paginatedProducts.length
                                ? ProductCard(
                                    productId: _paginatedProducts[secondIndex].id,
                                    image: _paginatedProducts[secondIndex].image,
                                    brandName: _paginatedProducts[secondIndex].brandName,
                                    title: _paginatedProducts[secondIndex].title,
                                    price: _paginatedProducts[secondIndex].price,
                                    priceAfetDiscount:
                                        _paginatedProducts[secondIndex]
                                            .priceAfetDiscount,
                                    dicountpercent:
                                        _paginatedProducts[secondIndex]
                                            .dicountpercent,
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
                                          'productId': _paginatedProducts[secondIndex].id,
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
          ],
        ),
      ),
    );
  }
}
