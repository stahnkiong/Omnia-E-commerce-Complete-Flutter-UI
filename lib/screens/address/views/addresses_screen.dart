import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/screens/address/views/add_new_address_screen.dart';
import 'package:shop/services/api_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final addressesData = await ApiService().getAddresses();
      setState(() {
        _addresses =
            addressesData.map((json) => Address.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final success = await ApiService().deleteAddress(addressId);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Address deleted successfully")),
        );
      }
      _fetchAddresses();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete address")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Addresses"),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddNewAddressScreen(),
                ),
              );
              if (result == true) {
                _fetchAddresses();
              }
            },
            icon: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/Address.svg",
                        height: 100,
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: defaultPadding),
                      const Text("No addresses found"),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAddresses,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: _addresses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: defaultPadding),
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      return AddressCard(
                        address: address,
                        onEdit: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddNewAddressScreen(address: address),
                            ),
                          );
                          if (result == true) {
                            _fetchAddresses();
                          }
                        },
                        onDelete: () => _deleteAddress(address.id),
                      );
                    },
                  ),
                ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (address.addressName.isNotEmpty) ...[
                const Icon(Icons.location_on_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  address.addressName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: SvgPicture.asset(
                  "assets/icons/Edit Square.svg",
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete Address"),
                      content: const Text(
                          "Are you sure you want to delete this address?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete();
                          },
                          child: const Text(
                            "Delete",
                            style: TextStyle(color: errorColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: SvgPicture.asset(
                  "assets/icons/Delete.svg",
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    errorColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: defaultPadding / 2),
          Text(
            "${address.firstName ?? ''} ${address.lastName ?? ''}".trim(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(address.phone ?? ''),
          const SizedBox(height: 8),
          Text(address.address1 ?? ''),
          if (address.address2 != null && address.address2!.isNotEmpty)
            Text(address.address2!),
          Text(
              "${address.city ?? ''}, ${address.postalCode ?? ''}, ${address.province ?? ''}"),
        ],
      ),
    );
  }
}
