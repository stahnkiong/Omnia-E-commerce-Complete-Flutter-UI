import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/buy_full_ui_kit.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/product_service.dart';
import 'package:shop/models/product_model.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen(
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
                      child: const ProductBuyNowScreen(),
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
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                          colorFilter: ColorFilter.mode(
                              Theme.of(context).textTheme.bodyLarge!.color!,
                              BlendMode.srcIn)),
                    ),
                  ],
                ),
                ProductImages(
                  images: product.images.isNotEmpty
                      ? product.images
                      : [product.image],
                ),
                ProductInfo(
                  brand: product.brandName,
                  title: product.title,
                  isAvailable: isProductAvailable,
                  description: product.description.isNotEmpty
                      ? product.description
                      : "A cool gray cap in soft corduroy. Watch me.' By buying cotton products from Lindex, you’re supporting more responsibly...",
                  rating: 4.4,
                  numOfReviews: 126,
                ),
                ProductListTile(
                  svgSrc: "assets/icons/Product.svg",
                  title: "Product Details",
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: const BuyFullKit(
                          images: ["assets/screens/Product detail.png"]),
                    );
                  },
                ),
                ProductListTile(
                  svgSrc: "assets/icons/Delivery.svg",
                  title: "Shipping Information",
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: const BuyFullKit(
                        images: ["assets/screens/Shipping information.png"],
                      ),
                    );
                  },
                ),
                ProductListTile(
                  svgSrc: "assets/icons/Return.svg",
                  title: "Returns",
                  isShowBottomBorder: true,
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.92,
                      child: const ProductReturnsScreen(),
                    );
                  },
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: ReviewCard(
                      rating: 4.3,
                      numOfReviews: 128,
                      numOfFiveStar: 80,
                      numOfFourStar: 30,
                      numOfThreeStar: 5,
                      numOfTwoStar: 4,
                      numOfOneStar: 1,
                    ),
                  ),
                ),
                ProductListTile(
                  svgSrc: "assets/icons/Chat.svg",
                  title: "Reviews",
                  isShowBottomBorder: true,
                  press: () {
                    Navigator.pushNamed(context, productReviewsScreenRoute);
                  },
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      "You may also like",
                      style: Theme.of(context).textTheme.titleSmall!,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(
                            left: defaultPadding,
                            right: index == 4 ? defaultPadding : 0),
                        child: ProductCard(
                          image: productDemoImg2,
                          title: "Sleeveless Tiered Dobby Swing Dress",
                          brandName: "LIPSY LONDON",
                          price: 24.65,
                          priceAfetDiscount: index.isEven ? 20.99 : null,
                          dicountpercent: index.isEven ? 25 : null,
                          press: () {},
                        ),
                      ),
                    ),
                  ),
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
