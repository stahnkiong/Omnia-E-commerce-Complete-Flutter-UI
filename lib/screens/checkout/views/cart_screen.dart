import 'package:flutter/material.dart';

import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/cart_model.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/screens/product/views/components/product_quantity.dart';

import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartModel? _cart;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initCart();
  }

  Future<void> _initCart() async {
    try {
      final cart = await CartService().fetchCart();
      if (mounted) {
        setState(() {
          _cart = cart;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshCart() async {
    try {
      final cart = await CartService().fetchCart();
      if (mounted) {
        setState(() {
          _cart = cart;
        });
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Cart"),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _cart == null || _cart!.items.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(defaultPadding),
                          itemCount: _cart!.items.length,
                          itemBuilder: (context, index) {
                            final item = _cart!.items[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: defaultPadding),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: NetworkImageWithLoader(
                                        item.thumbnail ?? "",
                                        radius: defaultBorderRadious,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: defaultPadding),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productTitle,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Text(
                                        //   item.variantTitle,
                                        //   style: Theme.of(context).textTheme.bodySmall,
                                        // ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            ProductQuantity(
                                              numOfItem: item.quantity,
                                              onIncrement: () async {
                                                await CartService()
                                                    .updateLineItem(item.id,
                                                        item.quantity + 1);
                                                _refreshCart();
                                              },
                                              onDecrement: () async {
                                                if (item.quantity > 1) {
                                                  await CartService()
                                                      .updateLineItem(item.id,
                                                          item.quantity - 1);
                                                  _refreshCart();
                                                } else {
                                                  // Prompt user to delete
                                                  if (context.mounted) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            "Remove Item"),
                                                        content: const Text(
                                                            "Are you sure you want to remove this item from your cart?"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                "Cancel"),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  context);
                                                              await CartService()
                                                                  .deleteLineItem(
                                                                      item.id);
                                                              _refreshCart();
                                                            },
                                                            child: const Text(
                                                                "Remove"),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                            Text(
                                              "RM ${item.unitPrice.toStringAsFixed(2)}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall!
                                                  .copyWith(
                                                      color: primaryColor),
                                            ),
                                          ],
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
                      Container(
                        padding: const EdgeInsets.all(defaultPadding),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, -4),
                              blurRadius: 20,
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Subtotal"),
                                Text(
                                  "RM ${_cart!.subtotal.toStringAsFixed(2)}",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: defaultPadding),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total"),
                                Text(
                                  "RM ${_cart!.total.toStringAsFixed(2)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: defaultPadding),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CheckoutScreen(),
                                    ),
                                  );
                                },
                                child: const Text("Checkout"),
                              ),
                            ),
                            const SizedBox(height: defaultPadding * 2),
                          ],
                        ),
                      ),
                    ],
                  ));
  }
}
