import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
// import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/contact_supplier.dart';
import 'package:shop/services/product_service.dart';
import 'package:shop/services/cart_service.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
// import 'components/selected_colors.dart';
// import 'components/selected_size.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  final String productId;

  const ProductBuyNowScreen({super.key, required this.productId});

  @override
  ProductBuyNowScreenState createState() => ProductBuyNowScreenState();
}

class ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  late Future<ProductModel?> _productFuture;
  int _quantity = 1;

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
            price: product.price * _quantity,
            title: "Add to cart",
            subTitle: "Total price",
            press: () async {
              try {
                await CartService().addToCart(product.variant, _quantity);
                if (context.mounted) {
                  customModalBottomSheet(
                    context,
                    isDismissible: false,
                    child: const AddedToCartMessageScreen(),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to add to cart: $e")),
                  );
                }
              }
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
                    // IconButton(
                    //   onPressed: () {},
                    //   icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                    //       colorFilter: const ColorFilter.mode(
                    //           Color.fromARGB(255, 188, 18, 5),
                    //           BlendMode.srcIn)),
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // SliverToBoxAdapter(
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: defaultPadding),
                    //     child: AspectRatio(
                    //       aspectRatio: 1.05,
                    //       child: NetworkImageWithLoader(product.image),
                    //     ),
                    //   ),
                    // ),
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
                              numOfItem: _quantity,
                              onIncrement: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              onDecrement: () {
                                if (_quantity > 1) {
                                  setState(() {
                                    _quantity--;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const SliverToBoxAdapter(child: Divider()),
                    // SliverToBoxAdapter(
                    //   child: SelectedColors(
                    //     colors: const [
                    //       Color(0xFFEA6262),
                    //       Color(0xFFB1CC63),
                    //       Color(0xFFFFBF5F),
                    //       Color(0xFF9FE1DD),
                    //       Color(0xFFC482DB),
                    //     ],
                    //     selectedColorIndex: 2,
                    //     press: (value) {},
                    //   ),
                    // ),
                    // SliverToBoxAdapter(
                    //   child: SelectedSize(
                    //     sizes: const ["S", "M", "L", "XL", "XXL"],
                    //     selectedIndex: 1,
                    //     press: (value) {},
                    //   ),
                    // ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      sliver: ProductListTile(
                        title: "Shipping Info",
                        svgSrc: "assets/icons/Express.svg",
                        isShowBottomBorder: true,
                        press: () {
                          customModalBottomSheet(
                            context,
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.all(defaultPadding / 2),
                                  margin: const EdgeInsets.all(defaultPadding),
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: defaultPadding),
                                      Text(
                                        "Shipping Information",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: defaultPadding),
                                      Text(
                                        "Processing Time: Orders typically ship within 1 business days following placement.",
                                      ),
                                      SizedBox(height: defaultPadding),
                                      Text(
                                        "Delivery Estimate: Standard shipping usually takes an additional 1-2 business days to arrive after dispatch.",
                                      ),
                                      SizedBox(height: defaultPadding),
                                      Text(
                                        "Please note: Times may vary during peak seasons or due to unforeseen carrier delays.",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                              "Bulk Order",
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: defaultPadding / 2),
                            const Text(
                                "Check with supplier for bulk order availability and better pricing.")
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(vertical: defaultPadding),
                      sliver: ProductListTile(
                        title: "Contact Supplier",
                        svgSrc: "assets/icons/Stores.svg",
                        isShowBottomBorder: true,
                        press: () {
                          customModalBottomSheet(
                            context,
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: const ContactSupplier(),
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
