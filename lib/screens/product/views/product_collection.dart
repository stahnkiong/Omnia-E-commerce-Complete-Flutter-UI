import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/product_service.dart';
import 'package:shop/route/screen_export.dart';

import 'package:shop/constants.dart';

class ProductCollectionScreen extends StatefulWidget {
  const ProductCollectionScreen(
      {super.key, required this.collectionId, this.isProductAvailable = true});

  final String collectionId;
  final bool isProductAvailable;

  @override
  State<ProductCollectionScreen> createState() =>
      _ProductCollectionScreenState();
}

class _ProductCollectionScreenState extends State<ProductCollectionScreen> {
  final ProductService _productService = ProductService();
  late Future<List<ProductModel>> _productsFuture;
  String? _collectionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _collectionId = widget.collectionId;
    _productsFuture = _productService.fetchProductsByCollection(_collectionId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collection"),
      ),
      body: _collectionId == null
          ? const Center(child: Text("No collection ID provided"))
          : FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No products found"));
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
