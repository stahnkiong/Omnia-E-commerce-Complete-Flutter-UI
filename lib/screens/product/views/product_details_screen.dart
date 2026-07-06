import 'package:flutter/material.dart';
// import 'package:pasar_now/components/buy_full_ui_kit.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:pasar_now/components/cart_button.dart';
import 'package:pasar_now/components/custom_modal_bottom_sheet.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/route/screen_export.dart';
import 'package:pasar_now/screens/home/views/components/flash_sale.dart';
import 'package:pasar_now/screens/product/views/components/unavailable_card.dart';
import 'package:pasar_now/screens/product/views/product_returns_screen.dart';
import 'dart:math';
import 'package:pasar_now/services/api_service.dart';
import 'package:pasar_now/services/product_service.dart';
import 'package:pasar_now/models/product_model.dart';
// import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import 'components/product_option_selector.dart';

import 'package:pasar_now/components/product/product_card.dart';
// import 'package:pasar_now/components/review_card.dart';
import 'product_buy_now_screen.dart';
import 'delivery_details_screen.dart';
import 'payment_options_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen(
      {super.key, required this.productId, this.isProductAvailable = true});

  final String productId;
  final bool isProductAvailable;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Future<ProductModel?> _productFuture;
  late Future<List<ProductModel>> _relatedProductsFuture;
  final Map<String, String> _selectedOptions = {};
  ProductVariantModel? _selectedVariant;

  @override
  void initState() {
    super.initState();
    _productFuture =
        ProductService().fetchProduct(widget.productId).then((product) {
      if (product != null) {
        _initializeSelectedOptions(product);
      }
      return product;
    });
    _relatedProductsFuture = _productFuture.then((product) {
      if (product != null) {
        return _fetchRelatedProducts(product.categoryId);
      }
      return <ProductModel>[];
    });
  }

  Future<List<ProductModel>> _fetchRelatedProducts(String? categoryId) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': 50,
        'fields': '*variants.calculated_price',
      };
      if (categoryId != null) {
        queryParams['category_id'] = categoryId;
      }
      final response = await ApiService().client.get(
        '/store/products',
        queryParameters: queryParams,
      );
      if (response.data != null && response.data['products'] != null) {
        final List<dynamic> productsJson = response.data['products'];
        final List<ProductModel> products = productsJson
            .map((json) => ProductModel.fromJson(json))
            .where((p) => p.id != widget.productId)
            .toList();
        products.shuffle(Random());
        return products.take(18).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching related products: $e");
      return [];
    }
  }

  void _initializeSelectedOptions(ProductModel product) {
    if (_selectedOptions.isNotEmpty) return;

    // Find the default variant
    ProductVariantModel? defaultVar;
    for (var v in product.variants) {
      if (v.id == product.variant) {
        defaultVar = v;
        break;
      }
    }

    if (defaultVar == null && product.variants.isNotEmpty) {
      defaultVar = product.variants.first;
    }

    if (defaultVar != null) {
      for (var opt in defaultVar.options) {
        _selectedOptions[opt.optionId] = opt.value;
      }
    } else {
      for (var opt in product.options) {
        if (opt.values.isNotEmpty) {
          _selectedOptions[opt.id] = opt.values.first.value;
        }
      }
    }
    _updateSelectedVariant(product);
  }

  void _updateSelectedVariant(ProductModel product) {
    ProductVariantModel? matchedVariant;
    for (var variant in product.variants) {
      bool allMatch = true;
      for (var optAssociation in variant.options) {
        if (_selectedOptions[optAssociation.optionId] != optAssociation.value) {
          allMatch = false;
          break;
        }
      }
      if (allMatch && variant.options.length == product.options.length) {
        matchedVariant = variant;
        break;
      }
    }
    _selectedVariant = matchedVariant;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel?>(
      future: _productFuture,
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

        // Safety initialization in case builder runs before or during async initialization completion
        _initializeSelectedOptions(product);

        return Scaffold(
          bottomNavigationBar: widget.isProductAvailable
              ? CartButton(
                  price: _selectedVariant?.price ?? product.price,
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: ProductBuyNowScreen(
                        productId: product.id,
                        selectedVariantId: _selectedVariant?.id,
                      ),
                    );
                  },
                )
              : const UnavailableCard(),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  floating: true,
                  title: Text(product.categories),
                ),
                ProductImages(
                  images: product.images.isNotEmpty
                      ? product.images
                      : [product.image],
                ),
                ProductInfo(
                  productId: product.id,
                  brand: product.brandName,
                  title: product.title,
                  isAvailable: widget.isProductAvailable,
                  description:
                      product.description.isNotEmpty ? product.description : "",
                ),
                if (product.options.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      children: product.options.map((opt) {
                        return ProductOptionSelector(
                          title: opt.title,
                          values: opt.values.map((v) => v.value).toList(),
                          selectedValue: _selectedOptions[opt.id] ?? '',
                          onSelected: (val) {
                            setState(() {
                              _selectedOptions[opt.id] = val;
                              _updateSelectedVariant(product);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ProductListTile(
                  svgSrc: "assets/icons/Product.svg",
                  title: "Delivery Details",
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const DeliveryDetailScreen(),
                    );
                  },
                ),
                ProductListTile(
                  svgSrc: "assets/icons/Cash.svg",
                  title: "Payment & Bulk Options",
                  press: () {
                    customModalBottomSheet(
                      context,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const PaymentOptionsScreen(),
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
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const ProductReturnsScreen(),
                    );
                  },
                ),
                // const SliverToBoxAdapter(
                //   child: Padding(
                //     padding: EdgeInsets.all(defaultPadding),
                //     child: ReviewCard(
                //       rating: 5.0,
                //       numOfReviews: 1,
                //       numOfFiveStar: 1,
                //       numOfFourStar: 0,
                //       numOfThreeStar: 0,
                //       numOfTwoStar: 0,
                //       numOfOneStar: 0,
                //     ),
                //   ),
                // ),
                const SliverToBoxAdapter(child: FlashSale()),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      "You may also like",
                      style: Theme.of(context).textTheme.titleSmall!,
                    ),
                  ),
                ),
                FutureBuilder<List<ProductModel>>(
                  future: _relatedProductsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(defaultPadding),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      );
                    }
                    final products = snapshot.data ?? [];
                    if (products.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: defaultPadding,
                          crossAxisSpacing: defaultPadding,
                          childAspectRatio: 0.54,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return ProductCard(
                              productId: product.id,
                              image: product.image,
                              brandName: product.brandName,
                              title: product.title,
                              price: product.price,
                              priceAfetDiscount: product.priceAfetDiscount,
                              dicountpercent: product.dicountpercent,
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                maximumSize: Size.infinite,
                                padding: const EdgeInsets.all(4),
                              ),
                              press: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  productDetailsScreenRoute,
                                  arguments: product.id,
                                );
                              },
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    );
                  },
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
