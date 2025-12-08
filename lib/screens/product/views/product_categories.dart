import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/product_service.dart';
import 'package:shop/route/screen_export.dart';

import 'package:shop/constants.dart';

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
  late Future<List<ProductModel>> _productsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.categoryId != null) {
      _productsFuture =
          _productService.fetchProductsByCategory(widget.categoryId!);
    } else if (widget.collectionId != null) {
      _productsFuture =
          _productService.fetchProductsByCollection(widget.collectionId!);
    } else {
      _productsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories"),
      ),
      body: (widget.collectionId == null && widget.categoryId == null)
          ? const Center(child: Text("No Categories provided"))
          : FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Categories found"));
                }

                final products = snapshot.data!;
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding, vertical: defaultPadding),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200.0,
                          mainAxisSpacing: defaultPadding,
                          crossAxisSpacing: defaultPadding,
                          childAspectRatio: 0.66,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return ProductCard(
                              image: products[index].image,
                              brandName: products[index].brandName,
                              title: products[index].title,
                              price: products[index].price,
                              priceAfetDiscount:
                                  products[index].priceAfetDiscount,
                              dicountpercent: products[index].dicountpercent,
                              press: () {
                                Navigator.pushNamed(
                                  context,
                                  productDetailsScreenRoute,
                                  arguments: {
                                    'productId': products[index].id,
                                    'isProductAvailable':
                                        widget.isProductAvailable,
                                  },
                                );
                              },
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
