import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:pasar_now/components/cart_button.dart';
import 'package:pasar_now/components/custom_modal_bottom_sheet.dart';
// import 'package:pasar_now/components/network_image_with_loader.dart';
import 'package:pasar_now/models/product_model.dart';
import 'package:pasar_now/screens/product/views/added_to_cart_message_screen.dart';
import 'package:pasar_now/screens/product/views/components/product_list_tile.dart';
import 'package:pasar_now/screens/product/views/contact_supplier.dart';
import 'package:pasar_now/services/product_service.dart';
import 'package:pasar_now/services/cart_service.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
// import 'components/selected_colors.dart';
// import 'components/selected_size.dart';
import 'components/unit_price.dart';
import 'components/product_option_selector.dart';

class ProductBuyNowScreen extends StatefulWidget {
  final String productId;
  final String? selectedVariantId;

  const ProductBuyNowScreen(
      {super.key, required this.productId, this.selectedVariantId});

  @override
  ProductBuyNowScreenState createState() => ProductBuyNowScreenState();
}

class ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  late Future<ProductModel?> _productFuture;
  int _quantity = 1;
  bool _isAddingToCart = false;
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
  }

  void _initializeSelectedOptions(ProductModel product) {
    if (_selectedOptions.isNotEmpty) return;

    ProductVariantModel? initialVariant;
    if (widget.selectedVariantId != null) {
      for (var v in product.variants) {
        if (v.id == widget.selectedVariantId) {
          initialVariant = v;
          break;
        }
      }
    }

    if (initialVariant == null) {
      for (var v in product.variants) {
        if (v.id == product.variant) {
          initialVariant = v;
          break;
        }
      }
    }

    if (initialVariant == null && product.variants.isNotEmpty) {
      initialVariant = product.variants.first;
    }

    // if first variant is unavailable, loop thru all the variants once available. if all unavailable returns to first 1
    if (initialVariant != null && (initialVariant.manageInventory || initialVariant.price == null)) {
      ProductVariantModel? availableVar;
      for (var v in product.variants) {
        if (!v.manageInventory && v.price != null) {
          availableVar = v;
          break;
        }
      }
      if (availableVar != null) {
        initialVariant = availableVar;
      }
    }

    if (initialVariant != null) {
      for (var opt in initialVariant.options) {
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

        // Safety initialization in case builder runs before or during async initialization completion
        _initializeSelectedOptions(product);

        final isUnavailable = (_selectedVariant?.manageInventory == true) || (_selectedVariant?.price == null);

        return Scaffold(
          bottomNavigationBar: isUnavailable
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.red.withValues(alpha: 0.1),
                      child: const Center(
                        child: Text(
                          "Unavailable at the moment",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    CartButton(
                      price: (_selectedVariant?.price ?? product.price) * _quantity,
                      title: "Unavailable",
                      subTitle: "Total price",
                      isEnabled: false,
                      press: null,
                    ),
                  ],
                )
              : CartButton(
                  price: (_selectedVariant?.price ?? product.price) * _quantity,
                  title: "Add to cart",
                  subTitle: "Total price",
                  isLoading: _isAddingToCart,
                  press: () async {
                    setState(() {
                      _isAddingToCart = true;
                    });
                    try {
                      final targetVariantId = _selectedVariant?.id ?? product.variant;
                      await CartService().addToCart(targetVariantId, _quantity);
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
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isAddingToCart = false;
                        });
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
                  ],
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(defaultPadding),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: UnitPrice(
                                price: _selectedVariant?.price ?? product.price,
                                priceAfterDiscount:
                                    _selectedVariant?.priceAfterDiscount ??
                                        product.priceAfetDiscount,
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
                    // const SliverPadding(
                    // padding: EdgeInsets.symmetric(vertical: defaultPadding),
                    // sliver: ProductListTile(
                    //   title: "Shipping Info",
                    //   svgSrc: "assets/icons/Express.svg",
                    //   isShowBottomBorder: true,
                    //   press: () {
                    //     customModalBottomSheet(
                    //       context,
                    //       height: MediaQuery.of(context).size.height * 0.5,
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.start,
                    //         children: [
                    //           Container(
                    //             padding:
                    //                 const EdgeInsets.all(defaultPadding / 2),
                    //             margin: const EdgeInsets.all(defaultPadding),
                    //             child: const Column(
                    //               crossAxisAlignment:
                    //                   CrossAxisAlignment.start,
                    //               children: [
                    //                 SizedBox(height: defaultPadding),
                    //                 Text(
                    //                   "Shipping Information",
                    //                   style: TextStyle(
                    //                     fontSize: 20,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.black,
                    //                   ),
                    //                 ),
                    //                 SizedBox(height: defaultPadding),
                    //                 Text(
                    //                   "Processing Time: Orders typically ship within 1 business days following placement.",
                    //                 ),
                    //                 SizedBox(height: defaultPadding),
                    //                 Text(
                    //                   "Delivery Estimate: Standard shipping usually takes an additional 1-2 business days to arrive after dispatch.",
                    //                 ),
                    //                 SizedBox(height: defaultPadding),
                    //                 Text(
                    //                   "Please note: Times may vary during peak seasons or due to unforeseen carrier delays.",
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // ),
                    // ),
                    const SliverToBoxAdapter(
                        child: SizedBox(height: defaultPadding)),
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
