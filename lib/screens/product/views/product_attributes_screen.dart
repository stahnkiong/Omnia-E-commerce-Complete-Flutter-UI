import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/product/views/components/notify_me_card.dart';
import 'package:shop/services/product_service.dart';
import 'package:shop/models/product_model.dart';

import 'components/product_info.dart';
import 'product_buy_now_screen.dart';

class ProductAttributesScreen extends StatelessWidget {
  const ProductAttributesScreen(
      {super.key, required this.productId, this.isProductAvailable = true});

  final String productId;
  final bool isProductAvailable;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel?>(
      future: ProductService().fetchProduct(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: Text("Error: ${snapshot.error ?? 'Product not found'}")),
          );
        }

        final product = snapshot.data!;

        return Scaffold(
          bottomNavigationBar: isProductAvailable
              ? CartButton(
                  price: product.price,
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: ProductBuyNowScreen(productId: product.id),
                    );
                  },
                )
              : NotifyMeCard(
                  isNotify: false,
                  onChanged: (value) {},
                ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  floating: true,
                  title: Text(product.title),
                ),
                ProductInfo(
                  brand: product.brandName,
                  title: product.title,
                  isAvailable: isProductAvailable,
                  description:
                      product.description.isNotEmpty ? product.description : "",
                  rating: 0.0,
                  numOfReviews: 0,
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: defaultPadding),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
