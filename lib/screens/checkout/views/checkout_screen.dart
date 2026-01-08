import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/services/api_service.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/models/cart_model.dart';

enum PaymentMethod { stripe, cod }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cod;
  Address? _selectedAddress;
  List<Address> _addresses = [];
  bool _isLoadingAddresses = true;
  CartModel? _cart;
  bool _isLoadingCart = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchAddresses(),
      _fetchCart(),
    ]);
  }

  Future<void> _fetchAddresses() async {
    try {
      final addressesData = await ApiService().getAddresses();
      setState(() {
        _addresses =
            addressesData.map((json) => Address.fromJson(json)).toList();
        if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses.first;
        }
        _isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _fetchCart() async {
    try {
      final cart = await CartService().fetchCart();
      setState(() {
        _cart = cart;
        _isLoadingCart = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCart = false;
      });
    }
  }

  double get _totalAmount {
    if (_cart == null) return 0.0;
    // If COD is selected, we assume the backend price (which is marked up 10%)
    // should be discounted to the "lower rate".
    // "markup all the price by 10% ... unless they pick this option [COD]"
    // This implies COD price = Base Price. Stripe Price = Base Price + 10%.
    // If the cart total from backend is the "Stripe Price" (Marked up):
    // COD Total = Cart Total / 1.10
    // If the cart total from backend is the "Base Price":
    // Stripe Total = Cart Total * 1.10

    // Assuming backend sends the "Stripe Price" (Marked up by 10%):
    if (_selectedPaymentMethod == PaymentMethod.cod) {
      return _cart!.total / 1.10;
    }
    return _cart!.total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: _isLoadingAddresses || _isLoadingCart
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Section
                  Text(
                    "Delivery Address",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  if (_addresses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_off_outlined),
                          const SizedBox(width: defaultPadding),
                          const Expanded(
                            child: Text("No address found. Please add one."),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to add address screen (to be implemented)
                            },
                            child: const Text("Add"),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<Address>(
                      value: _selectedAddress,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: defaultPadding,
                            vertical: defaultPadding),
                      ),
                      isExpanded: true,
                      items: _addresses.map((address) {
                        return DropdownMenuItem(
                          value: address,
                          child: Text(
                            "${address.addressName} - ${address.address1}, ${address.city}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAddress = value;
                        });
                      },
                    ),
                  const SizedBox(height: defaultPadding * 2),

                  // Order Summary Section
                  Text(
                    "Order Summary",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Subtotal"),
                            Text(
                                "RM ${_cart?.subtotal.toStringAsFixed(2) ?? '0.00'}"),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        if (_selectedPaymentMethod == PaymentMethod.cod)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("COD Discount",
                                  style: TextStyle(color: successColor)),
                              Text(
                                  "- RM ${(_cart!.total - _totalAmount).toStringAsFixed(2)}",
                                  style: const TextStyle(color: successColor)),
                            ],
                          ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "RM ${_totalAmount.toStringAsFixed(2)}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 2),

                  // Payment Method Section
                  Text(
                    "Payment Method",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Column(
                    children: [
                      RadioListTile<PaymentMethod>(
                        value: PaymentMethod.stripe,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        title: const Text("Credit/Debit Card (Stripe)"),
                        subtitle: const Text("Pay securely online"),
                        secondary: const Icon(Icons.credit_card),
                      ),
                      RadioListTile<PaymentMethod>(
                        value: PaymentMethod.cod,
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                        title: const Text("Cash on Delivery"),
                        subtitle: const Text("Pay when you receive"),
                        secondary: const Icon(Icons.money),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: ElevatedButton(
            onPressed: (_cart == null || _addresses.isEmpty)
                ? null
                : () {
                    // Handle Payment
                    if (_selectedPaymentMethod == PaymentMethod.stripe) {
                      // Initialize Stripe Payment
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Stripe integration coming soon")),
                      );
                    } else {
                      // Place COD Order
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Order placed successfully!")),
                      );
                    }
                  },
            child: Text("Pay RM ${_totalAmount.toStringAsFixed(2)}"),
          ),
        ),
      ),
    );
  }
}
