import 'package:flutter/material.dart';
import 'package:pasar_now/components/Banner/S/banner_g.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/route/screen_export.dart';
import 'package:pasar_now/models/product_type_model.dart';
import 'package:pasar_now/services/product_service.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchProductTypes();
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
          ],
        ),
      ),
    );
  }
}
