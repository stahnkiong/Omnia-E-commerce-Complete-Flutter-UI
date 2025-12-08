import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/location_permission_store_availability_screen.dart';
import 'package:shop/screens/product/views/size_guide_screen.dart';
import 'package:shop/services/product_service.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
import 'components/selected_colors.dart';
import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  final String productId;

  const ProductBuyNowScreen({super.key, required this.productId});

  @override
  ProductBuyNowScreenState createState() => ProductBuyNowScreenState();
}

class ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  late Future<ProductModel?> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = ProductService().fetchProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel?>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Product not found')),
          );
        }

        final product = snapshot.data!;

        return Scaffold(
          bottomNavigationBar: CartButton(
            price: product.price,
            title: "Add to cart",
            subTitle: "Total price",
            press: () {
              customModalBottomSheet(
                context,
                isDismissible: false,
                child: const AddedToCartMessageScreen(),
              );
            },
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding / 2, vertical: defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const BackButton(),
                    Expanded(
                      child: Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: AspectRatio(
                          aspectRatio: 1.05,
                          child: NetworkImageWithLoader(product.image),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(defaultPadding),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: UnitPrice(
                                price: product.price,
                                priceAfterDiscount: product.priceAfetDiscount,
                              ),
                            ),
                            ProductQuantity(
                              numOfItem: 1,
                              onIncrement: () {},
                              onDecrement: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider()),
                    SliverToBoxAdapter(
                      child: SelectedColors(
                        colors: const [
                          Color(0xFFEA6262),
                          Color(0xFFB1CC63),
                          Color(0xFFFFBF5F),
                          Color(0xFF9FE1DD),
                          Color(0xFFC482DB),
                        ],
                        selectedColorIndex: 2,
                        press: (value) {},
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SelectedSize(
                        sizes: const ["S", "M", "L", "XL", "XXL"],
                        selectedIndex: 1,
                        press: (value) {},
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      sliver: ProductListTile(
                        title: "Size guide",
                        svgSrc: "assets/icons/Sizeguid.svg",
                        isShowBottomBorder: true,
                        press: () {
                          customModalBottomSheet(
                            context,
                            height: MediaQuery.of(context).size.height * 0.9,
                            child: const SizeGuideScreen(),
                          );
                        },
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: defaultPadding / 2),
                            Text(
                              "Store pickup availability",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: defaultPadding / 2),
                            const Text(
                                "Select a size to check store availability and In-Store pickup options.")
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      sliver: ProductListTile(
                        title: "Check stores",
                        svgSrc: "assets/icons/Stores.svg",
                        isShowBottomBorder: true,
                        press: () {
                          customModalBottomSheet(
                            context,
                            height: MediaQuery.of(context).size.height * 0.92,
                            child:
                                const LocationPermissonStoreAvailabilityScreen(),
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: defaultPadding))
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
