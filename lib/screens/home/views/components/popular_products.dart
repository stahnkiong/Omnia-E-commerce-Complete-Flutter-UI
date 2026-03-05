import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pasar_now/components/product/product_card.dart';
import 'package:pasar_now/providers/product_provider.dart';
import 'package:pasar_now/route/screen_export.dart';
import 'package:pasar_now/components/skleton/product/products_skelton.dart';

import 'package:pasar_now/constants.dart';

class PopularProducts extends StatefulWidget {
  const PopularProducts({super.key});

  @override
  State<PopularProducts> createState() => PopularProductsState();
}

class PopularProductsState extends State<PopularProducts> {
  @override
  void initState() {
    super.initState();
    // Fetch products when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchPopularProducts();
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
                "Popular products",
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
                  itemCount: productProvider.popularProducts.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.popularProducts[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: defaultPadding,
                        right:
                            index == productProvider.popularProducts.length - 1
                                ? defaultPadding
                                : 0,
                      ),
                      child: ProductCard(
                        productId: product.id,
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
