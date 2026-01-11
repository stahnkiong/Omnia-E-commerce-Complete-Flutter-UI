import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/services/api_service.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/models/cart_model.dart';

import 'package:shop/models/payment_provider_model.dart';
import 'package:shop/models/shipping_option_model.dart';
import 'package:shop/models/payment_collection_model.dart';
import 'package:shop/screens/address/views/add_new_address_screen.dart';

const String codPaymentProviderId = 'pp_system_default';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentProvider? _selectedPaymentProvider;
  Address? _selectedAddress;
  List<Address> _addresses = [];
  bool _isLoadingAddresses = true;
  CartModel? _cart;
  bool _isLoadingCart = true;
  List<PaymentProvider> _paymentProviders = [];
  bool _isLoadingPaymentProviders = true;
  List<ShippingOption> _shippingOptions = [];
  ShippingOption? _selectedShippingOption;
  bool _isLoadingShippingOptions = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _fetchCart();
    await Future.wait([
      _fetchAddresses(),
      _fetchPaymentProviders(),
      if (_cart != null) _fetchShippingOptions(_cart!.id),
    ]);
  }

  Future<void> _fetchShippingOptions(String cartId) async {
    try {
      final options = await ApiService().getShippingOptions(cartId);
      setState(() {
        _shippingOptions = options;
        if (_shippingOptions.isNotEmpty) {
          _selectedShippingOption = _shippingOptions.first;
        }
        _isLoadingShippingOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingShippingOptions = false;
      });
    }
  }

  Future<void> _fetchPaymentProviders() async {
    try {
      final providersData = await ApiService().getPaymentProviders();
      setState(() {
        _paymentProviders = providersData;
        if (_paymentProviders.isNotEmpty) {
          _selectedPaymentProvider = _paymentProviders.first;
        }
        _isLoadingPaymentProviders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPaymentProviders = false;
      });
    }
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

    double cartTotal = _cart!.total;

    // Apply COD discount to the cart total (items)
    if (_selectedPaymentProvider?.id.toLowerCase() ==
        codPaymentProviderId.toLowerCase()) {
      cartTotal = cartTotal / 1.05;
    }

    // Add shipping cost
    if (_selectedShippingOption != null) {
      cartTotal += _selectedShippingOption!.amount;
    }

    return cartTotal;
  }

  bool _isProcessing = false;

  Future<void> _handlePayment() async {
    if (_cart == null || _selectedPaymentProvider == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final api = ApiService();
      PaymentCollection? paymentCollection = _cart!.paymentCollection;

      // 1. Create Payment Collection if not exists
      if (paymentCollection == null) {
        paymentCollection = await api.createPaymentCollection(_cart!.id);
        if (paymentCollection == null) {
          throw Exception("Failed to create payment collection");
        }
      }

      // 2. Initiate Payment Session
      paymentCollection = await api.initiatePaymentSession(
        paymentCollection.id,
        _selectedPaymentProvider!.id,
      );

      if (paymentCollection == null) {
        throw Exception("Failed to initiate payment session");
      }

      // 3. Complete Cart
      final completionResult = await api.completeCart(_cart!.id);

      if (completionResult != null && completionResult['type'] == 'order') {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order placed successfully!")),
          );
          // Clear cart locally (optional, but good practice)
          // Navigate to success screen or home
          Navigator.pop(context);
        }
      } else {
        throw Exception("Failed to complete order");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: _isLoadingAddresses ||
              _isLoadingCart ||
              _isLoadingPaymentProviders ||
              _isLoadingShippingOptions
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Section

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
                            Text("RM ${(_cart!.subtotal).toStringAsFixed(2)}"),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        if (_selectedShippingOption != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Shipping"),
                              Text(
                                  "RM ${(_selectedShippingOption!.amount).toStringAsFixed(2)}"),
                            ],
                          ),
                        const SizedBox(height: defaultPadding / 2),
                        if (_selectedPaymentProvider?.id.toLowerCase() ==
                            codPaymentProviderId.toLowerCase())
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Discount",
                                  style: TextStyle(color: successColor)),
                              Text(
                                  "- RM ${((_cart!.total - (_cart!.total / 1.05))).toStringAsFixed(2)}",
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
                              "RM ${(_totalAmount).toStringAsFixed(2)}",
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
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AddNewAddressScreen(),
                                ),
                              );
                              if (result == true) {
                                _fetchAddresses();
                              }
                            },
                            child: const Text("Add"),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        DropdownButtonFormField<Address>(
                          initialValue: _selectedAddress,
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
                        TextButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AddNewAddressScreen(),
                              ),
                            );
                            if (result == true) {
                              _fetchAddresses();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add New Address"),
                        ),
                      ],
                    ),
                  const SizedBox(height: defaultPadding * 2),

                  // Shipping Method Section
                  Text(
                    "Shipping Method",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Column(
                    children: _shippingOptions.map((option) {
                      return RadioListTile<ShippingOption>(
                        value: option,
                        groupValue: _selectedShippingOption,
                        onChanged: (value) {
                          setState(() {
                            _selectedShippingOption = value;
                          });
                        },
                        title: Text(option.name),
                        subtitle:
                            Text("RM ${(option.amount).toStringAsFixed(2)}"),
                        secondary: const Icon(Icons.local_shipping),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: defaultPadding * 2),

                  // Payment Method Section
                  Text(
                    "Payment Method",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Column(
                    children: _paymentProviders.map((provider) {
                      bool isCod =
                          provider.id.toLowerCase() == codPaymentProviderId;
                      return RadioListTile<PaymentProvider>(
                        value: provider,
                        groupValue: _selectedPaymentProvider,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentProvider = value!;
                          });
                        },
                        title: Text(isCod
                            ? "Cash on Delivery"
                            : "Card / Online Payment"),
                        subtitle: Text(
                          isCod
                              ? "Pay less with cash on delivery"
                              : "Pay securely online",
                          style: isCod
                              ? const TextStyle(
                                  color: successColor,
                                  fontWeight: FontWeight.bold,
                                )
                              : null,
                        ),
                        secondary:
                            Icon(isCod ? Icons.money : Icons.credit_card),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: ElevatedButton(
            onPressed: (_cart == null || _addresses.isEmpty || _isProcessing)
                ? null
                : _handlePayment,
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text("Pay RM ${(_totalAmount).toStringAsFixed(2)}"),
          ),
        ),
      ),
    );
  }
}
