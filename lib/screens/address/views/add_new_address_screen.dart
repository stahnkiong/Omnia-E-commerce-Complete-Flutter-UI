import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/api_service.dart';

class AddNewAddressScreen extends StatefulWidget {
  const AddNewAddressScreen({super.key});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
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
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
        "first_name": _firstNameController.text,
        "last_name": _lastNameController.text,
        "phone": _phoneController.text,
        "company": _companyController.text,
        "address_1": _address1Controller.text,
        "address_2": _address2Controller.text,
        "city": _cityController.text,
        "country_code": "my", // Hardcoded as requested
        "province": _provinceController.text,
        "postal_code": _postalCodeController.text,
        "address_name": _addressNameController.text,
        "metadata": {}
      };

      final success = await ApiService().addAddress(data);

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
        title: const Text("Add New Address"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: "First Name",
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
                      controller: _lastNameController,
                      decoration: const InputDecoration(
                        labelText: "Last Name",
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
                ],
              ),
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
