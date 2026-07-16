import 'package:flutter/material.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pasar_now/models/address_model.dart';

class AddNewAddressScreen extends StatefulWidget {
  final Address? address;
  const AddNewAddressScreen({super.key, this.address});

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedCity;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _provinceController =
      TextEditingController(text: "Sarawak");

  @override
  void initState() {
    super.initState();
    _provinceController.text = "Sarawak"; // Locked into Sarawak
    if (widget.address != null) {
      _phoneController.text = widget.address!.phone ?? '';
      _companyController.text =
          widget.address!.company ?? widget.address!.addressName;
      _address1Controller.text = widget.address!.address1 ?? '';
      _address2Controller.text = widget.address!.address2 ?? '';
      
      final cityLower = (widget.address!.city ?? '').trim().toLowerCase();
      if (cityLower == 'kuching') {
        _selectedCity = 'Kuching';
      } else if (cityLower == 'samarahan') {
        _selectedCity = 'Samarahan';
      } else {
        _selectedCity = null;
      }
      _cityController.text = _selectedCity ?? '';
      _postalCodeController.text = widget.address!.postalCode ?? '';
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
            const SnackBar(content: Text("Failed to save address")),
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
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: "Name (e.g. Home, Office)",
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedCity,
                      decoration: const InputDecoration(
                        labelText: "City",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Kuching", child: Text("Kuching")),
                        DropdownMenuItem(value: "Samarahan", child: Text("Samarahan")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                          _cityController.text = value ?? '';
                        });
                      },
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
                        final regExp = RegExp(r'^(93|94)\d{3}$');
                        if (!regExp.hasMatch(value)) {
                          return 'Must be 93xxx - 94xxx';
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
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "State / Province",
                  border: OutlineInputBorder(),
                  filled: true,
                ),
              ),
              const SizedBox(height: defaultPadding),
              InkWell(
                onTap: () async {
                  final Uri url = Uri.parse("https://wa.me/60182519988");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Could not launch WhatsApp")),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue[800],
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                            children: const [
                              TextSpan(
                                  text: "For bulk order and client outside of Kuching and Samarahan, please "),
                              TextSpan(
                                text: "contact office",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
