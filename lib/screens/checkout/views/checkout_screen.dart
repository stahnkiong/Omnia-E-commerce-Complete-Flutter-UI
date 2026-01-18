import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/api_service.dart';
import 'package:shop/services/cart_service.dart';
import 'package:shop/models/cart_model.dart';

import 'package:shop/models/payment_provider_model.dart';
import 'package:shop/models/shipping_option_model.dart';
import 'package:shop/models/payment_collection_model.dart';
import 'package:shop/screens/address/views/add_new_address_screen.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Address;
import 'package:provider/provider.dart';
import 'package:shop/providers/auth_provider.dart';

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

    // Remove COD promotion if exists to reset state
    if (_cart != null) {
      await ApiService().removePromotion(_cart!.id, ['COD_OFFER_8996']);
      // Refresh cart to reflect changes
      await _fetchCart();
    }

    // Update email if available
    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.customer != null && _cart != null) {
        final email = authProvider.customer!['email'];
        if (email != null) {
          await ApiService().updateCart(_cart!.id, {'email': email});
        }
      }
    }

    await Future.wait([
      _fetchAddresses(),
      _fetchPaymentProviders(),
      if (_cart != null) _fetchShippingOptions(_cart!.id),
    ]);
  }

  Future<void> _fetchShippingOptions(String cartId) async {
    try {
      final options = await ApiService().getShippingOptions(cartId);
      // Sort by amount (smaller first)
      options.sort((a, b) => a.amount.compareTo(b.amount));

      setState(() {
        _shippingOptions = options;
        if (_shippingOptions.isNotEmpty) {
          _selectedShippingOption = _shippingOptions.first;
        }
        _isLoadingShippingOptions = false;
      });

      // Select first option by default if available
      if (_selectedShippingOption != null && _cart != null) {
        await ApiService()
            .addShippingMethod(_cart!.id, _selectedShippingOption!.id);
        await _fetchCart();
      }
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
        _selectedPaymentProvider = null; // Ensure unselected
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

      if (_selectedAddress != null) {
        await _updateCartAddress(_selectedAddress!);
      }
    } catch (e) {
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _updateCartAddress(Address address) async {
    if (_cart == null) return;

    setState(() {
      _isLoadingCart = true;
    });

    try {
      final addressData = {
        'shipping_address': {
          'first_name': address.firstName ?? 'user',
          'last_name': address.lastName ?? '',
          'address_1': address.address1 ?? '',
          'address_2': address.address2 ?? '',
          'city': address.city ?? '',
          'country_code': address.countryCode ?? 'my',
          'postal_code': address.postalCode ?? '',
          'province': address.province ?? '',
          'phone': address.phone ?? '',
          'company': address.company ?? '',
        }
      };

      await ApiService().updateCart(_cart!.id, addressData);

      // Refresh cart and shipping options
      await _fetchCart();
      await _fetchShippingOptions(_cart!.id);
    } catch (e) {
      debugPrint("Error updating cart address: $e");
      setState(() {
        _isLoadingCart = false;
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
    return _cart!.total;
  }

  bool _isProcessing = false;

  Future<void> _handlePaymentProviderChange(PaymentProvider? value) async {
    if (value == null || _cart == null) return;

    setState(() {
      _selectedPaymentProvider = value;
      _isLoadingCart = true;
    });

    try {
      Map<String, dynamic>? updatedCartData;
      if (value.id.toLowerCase() == codPaymentProviderId.toLowerCase()) {
        updatedCartData =
            await ApiService().addPromotion(_cart!.id, ['COD_OFFER_8996']);
      } else {
        updatedCartData =
            await ApiService().removePromotion(_cart!.id, ['COD_OFFER_8996']);
      }

      if (updatedCartData != null) {
        setState(() {
          _cart = CartModel.fromJson(updatedCartData!);
        });
      }
    } catch (e) {
      debugPrint("Error updating promotion: $e");
    } finally {
      setState(() {
        _isLoadingCart = false;
      });
    }
  }

  Future<void> _handlePayment() async {
    if (_cart == null || _selectedPaymentProvider == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final api = ApiService();

      // 0. Ensure shipping method is set (just in case)
      if (_selectedShippingOption != null) {
        await api.addShippingMethod(_cart!.id, _selectedShippingOption!.id);
        // Refresh cart to ensure totals are 100% accurate before payment
        final updatedCart = await CartService().fetchCart();
        if (updatedCart != null) {
          setState(() {
            _cart = updatedCart;
          });
        }
      }

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

      // 3. Handle Stripe Payment
      if (_selectedPaymentProvider!.id == 'pp_stripe_stripe') {
        // Find the Stripe payment session
        final stripeSession = paymentCollection.paymentSessions.firstWhere(
          (session) => session.providerId == 'pp_stripe_stripe',
          orElse: () => throw Exception("Stripe session not found"),
        );

        final clientSecret = stripeSession.data['client_secret'];
        if (clientSecret == null) {
          throw Exception("Client secret not found");
        }

        // Initialize Payment Sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'PasarNow',
          ),
        );

        // Present Payment Sheet
        await Stripe.instance.presentPaymentSheet();
      }

      // 4. Complete Cart
      final completionResult = await CartService().completeCart();

      if (completionResult != null && completionResult['type'] == 'order') {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order placed successfully!")),
          );
          // Navigate to order history
          Navigator.popAndPushNamed(context, ordersScreenRoute);
        }
      } else {
        throw Exception("Failed to complete order");
      }
    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Payment cancelled or failed: ${e.error.localizedMessage}")),
        );
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
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Address Section

                  // Order Summary Section
                  Text(
                    "Order Summary",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding / 4),
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
                            Text(
                              "Subtotal",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              "RM ${(_cart!.subtotal).toStringAsFixed(2)}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 4),
                        if (_cart!.shippingTotal > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Shipping",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                "RM ${(_cart!.shippingTotal).toStringAsFixed(2)}",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          )
                        else if (_selectedShippingOption != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Shipping",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                "RM ${(_selectedShippingOption!.amount).toStringAsFixed(2)}",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        const SizedBox(height: defaultPadding / 4),
                        if (_cart!.taxTotal > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tax",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                "RM ${(_cart!.taxTotal).toStringAsFixed(2)}",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        const SizedBox(height: defaultPadding / 4),
                        if (_cart!.discountTotal > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Discount",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                "- RM ${(_cart!.discountTotal).toStringAsFixed(2)}",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
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
                                  .titleSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "RM ${(_totalAmount).toStringAsFixed(2)}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  Text(
                    "Delivery Address",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding / 4),
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
                          Expanded(
                            child: Text(
                              "No address found. Please add one.",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
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
                            child: Text(
                              "Add",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<Address>(
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
                                      "${address.address1}, ${address.city}",
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAddress = value;
                                  });
                                  if (value != null) {
                                    _updateCartAddress(value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: defaultPadding),
                            IconButton(
                              onPressed: () async {
                                if (_selectedAddress != null) {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddNewAddressScreen(
                                          address: _selectedAddress),
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchAddresses();
                                  }
                                }
                              },
                              icon: const Icon(Icons.edit),
                              tooltip: "Edit Address",
                            ),
                          ],
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
                          label: Text(
                            "Add New Address",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: defaultPadding),

                  // Shipping Method Section
                  Text(
                    "Shipping Method",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  RadioGroup<ShippingOption>(
                    groupValue: _selectedShippingOption,
                    onChanged: (value) async {
                      setState(() {
                        _selectedShippingOption = value;
                        _isLoadingCart = true; // Show loading while updating
                      });
                      if (value != null && _cart != null) {
                        await ApiService()
                            .addShippingMethod(_cart!.id, value.id);
                        await _fetchCart(); // Refresh cart to get updated totals
                      }
                    },
                    child: Column(
                      children: _shippingOptions.map((option) {
                        return RadioListTile<ShippingOption>(
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          dense: true,
                          value: option,
                          title: Text(option.name,
                              style: Theme.of(context).textTheme.bodySmall),
                          subtitle: Text(
                              "RM ${(option.amount).toStringAsFixed(2)}",
                              style: Theme.of(context).textTheme.bodySmall),
                          secondary: const Icon(Icons.local_shipping),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),

                  // Payment Method Section
                  Text(
                    "Payment Method",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding / 4),
                  RadioGroup<PaymentProvider>(
                    groupValue: _selectedPaymentProvider,
                    onChanged: _handlePaymentProviderChange,
                    child: Column(
                      children: _paymentProviders.map((provider) {
                        bool isCod =
                            provider.id.toLowerCase() == codPaymentProviderId;
                        return RadioListTile<PaymentProvider>(
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          dense: true,
                          value: provider,
                          title: Text(
                            isCod
                                ? "Cash on Delivery"
                                : "Card / Online Payment",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          subtitle: Text(
                            isCod
                                ? "Pay less with cash on delivery"
                                : "Pay securely online",
                            style: isCod
                                ? const TextStyle(
                                    color: successColor,
                                    fontWeight: FontWeight.bold,
                                  )
                                : Theme.of(context).textTheme.bodySmall,
                          ),
                          secondary:
                              Icon(isCod ? Icons.money : Icons.credit_card),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: ElevatedButton(
            onPressed: (_cart == null ||
                    _addresses.isEmpty ||
                    _isProcessing ||
                    _selectedPaymentProvider == null ||
                    _selectedShippingOption == null)
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
