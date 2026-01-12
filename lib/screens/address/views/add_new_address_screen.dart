import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/api_service.dart';

import 'package:shop/models/address_model.dart';

class AddNewAddressScreen extends StatefulWidget {
  final Address? address;
  const AddNewAddressScreen({super.key, this.address});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _addressNameController = TextEditingController();
  final TextEditingController _provinceController =
      TextEditingController(text: "Sarawak");

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _phoneController.text = widget.address!.phone ?? '';
      _companyController.text = widget.address!.company ?? '';
      _address1Controller.text = widget.address!.address1 ?? '';
      _address2Controller.text = widget.address!.address2 ?? '';
      _cityController.text = widget.address!.city ?? '';
      _postalCodeController.text = widget.address!.postalCode ?? '';
      // Assuming address_name isn't in the model yet or mapped differently,
      // but if it was, we'd map it here. For now leaving blank or mapping if available.
      // _addressNameController.text = widget.address!.metadata?['address_name'] ?? '';
      _provinceController.text = widget.address!.province ?? 'Sarawak';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _companyController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _addressNameController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final data = {
        "phone": _phoneController.text,
        "company": _companyController.text,
        "address_1": _address1Controller.text,
        "address_2": _address2Controller.text,
        "city": _cityController.text,
        "country_code": "my", // Hardcoded as requested
        "province": _provinceController.text,
        "postal_code": _postalCodeController.text,
        "metadata": {
          if (widget.address == null)
            "address_name": _addressNameController.text,
        }
      };

      bool success;
      if (widget.address != null) {
        success = await ApiService().updateAddress(widget.address!.id, data);
      } else {
        success = await ApiService().addAddress(data);
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to add address")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.address != null ? "Edit Address" : "Add New Address"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.address == null)
                TextFormField(
                  controller: _addressNameController,
                  decoration: const InputDecoration(
                    labelText: "Address Name (e.g. Home, Office)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address name';
                    }
                    return null;
                  },
                ),
              if (widget.address == null)
                const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: "Company (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _address1Controller,
                decoration: const InputDecoration(
                  labelText: "Address Line 1",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _address2Controller,
                decoration: const InputDecoration(
                  labelText: "Address Line 2 (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: "City",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: TextFormField(
                      controller: _postalCodeController,
                      decoration: const InputDecoration(
                        labelText: "Postal Code",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _provinceController,
                decoration: const InputDecoration(
                  labelText: "State / Province",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter state';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding * 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Save Address"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
