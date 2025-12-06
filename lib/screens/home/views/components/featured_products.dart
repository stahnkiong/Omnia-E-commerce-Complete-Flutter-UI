import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/components/skleton/product/products_skelton.dart';

import 'package:shop/constants.dart';

class FeaturedProducts extends StatefulWidget {
  const FeaturedProducts({super.key});

  @override
  State<FeaturedProducts> createState() => _FeaturedProductsState();
}

class _FeaturedProductsState extends State<FeaturedProducts> {
  @override
  void initState() {
    super.initState();
    // Fetch products when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchFeaturedProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: defaultPadding / 2),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Text(
                "Featured products",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            if (productProvider.isLoading)
              const SizedBox(
                height: 220,
                child: ProductsSkelton(),
              )
            else if (productProvider.error != null)
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Text('Error: ${productProvider.error}'),
              )
            else
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productProvider.featuredProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.featuredProducts[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: defaultPadding,
                        right:
                            index == productProvider.featuredProducts.length - 1
                                ? defaultPadding
                                : 0,
                      ),
                      child: ProductCard(
                        image: product.image,
                        brandName: product.brandName,
                        title: product.title,
                        price: product.price,
                        priceAfetDiscount: product.priceAfetDiscount,
                        dicountpercent: product.dicountpercent,
                        press: () {
                          Navigator.pushNamed(
                              context, productDetailsScreenRoute,
                              arguments: product.id);
                        },
                      ),
                    );
                  },
                ),
              )
          ],
        );
      },
    );
  }
}
