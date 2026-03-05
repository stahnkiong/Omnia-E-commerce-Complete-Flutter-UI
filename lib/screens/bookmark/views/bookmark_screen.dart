import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pasar_now/components/product/product_card.dart';
import 'package:pasar_now/models/product_model.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:pasar_now/providers/wishlist_provider.dart';
import 'package:pasar_now/providers/product_provider.dart';

import '../../../constants.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<WishlistProvider, ProductProvider>(
        builder: (context, wishlistProvider, productProvider, child) {
          final wishlistedIds = wishlistProvider.wishlistedIds;

          final allProducts = [
            ...demoPopularProducts,
            ...productProvider.popularProducts,
            ...productProvider.bestSellers,
            ...productProvider.featuredProducts,
            ...productProvider.flashSaleProducts,
          ];

          final Map<String, ProductModel> uniqueMap = {};
          for (var p in allProducts) {
            uniqueMap[p.id] = p;
          }
          final uniqueProducts = uniqueMap.values.toList();
          final bookmarkedProducts = uniqueProducts
              .where((p) => wishlistedIds.contains(p.id))
              .toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding),
                sliver: bookmarkedProducts.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(defaultPadding * 2),
                            child: Text("No items in wishlist"),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200.0,
                          mainAxisSpacing: defaultPadding,
                          crossAxisSpacing: defaultPadding,
                          childAspectRatio: 0.66,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final product = bookmarkedProducts[index];
                            return ProductCard(
                              productId: product.id,
                              image: product.image,
                              brandName: product.brandName,
                              title: product.title,
                              price: product.price,
                              priceAfetDiscount: product.priceAfetDiscount,
                              dicountpercent: product.dicountpercent,
                              press: () {
                                Navigator.pushNamed(
                                  context,
                                  productDetailsScreenRoute,
                                  arguments: product.id,
                                );
                              },
                            );
                          },
                          childCount: bookmarkedProducts.length,
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
