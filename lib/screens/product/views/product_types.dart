import 'package:flutter/material.dart';
import 'package:pasar_now/components/product/product_card.dart';
import 'package:pasar_now/models/product_model.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:pasar_now/services/product_service.dart';
import 'package:pasar_now/route/screen_export.dart';

import 'package:pasar_now/constants.dart';

class ProductTypesScreen extends StatefulWidget {
  const ProductTypesScreen({
    super.key,
    required this.typeId,
    this.typeName,
    this.isProductAvailable = true,
  });

  final String typeId;
  final String? typeName;
  final bool isProductAvailable;

  @override
  State<ProductTypesScreen> createState() => _ProductTypesScreenState();
}

class _ProductTypesScreenState extends State<ProductTypesScreen> {
  final ProductService _productService = ProductService();
  late Future<List<ProductModel>> _productsFuture;
  String? _typeId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _typeId = widget.typeId;
    _productsFuture = _productService.fetchProductsByType(_typeId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.typeName ?? "Product Type"),
      ),
      body: _typeId == null
          ? const Center(child: Text("No product type ID provided"))
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
                              productId: products[index].id,
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
