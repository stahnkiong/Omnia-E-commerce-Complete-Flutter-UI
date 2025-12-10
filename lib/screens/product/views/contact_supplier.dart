import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupplier extends StatelessWidget {
  const ContactSupplier({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 40,
                    child: BackButton(),
                  ),
                  Text(
                    "Contact Supplier",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: defaultPadding * 1.5),
                        child: Image.asset(
                          Theme.of(context).brightness == Brightness.light
                              ? "assets/Illustration/PayWithCash_lightTheme.png"
                              : "assets/Illustration/PayWithCash_darkTheme.png",
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                      ),
                    ),
                    Text(
                      "Check Bulk Order Availability and Get Better Pricing",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),
                    const SizedBox(height: defaultPadding),
                    const Text(
                      "WhatsApp Supplier to get in touch with the supplier of this product.",
                    ),
                    const SizedBox(height: defaultPadding * 1.5),
                    ElevatedButton(
                      onPressed: () async {
                        //external link to supplier whatsapp
                        final Uri whatsappUri =
                            Uri.parse('https://wa.me/60129388996');
                        if (!await launchUrl(whatsappUri)) {
                          if (context.mounted) {
                            // Handle error, e.g., show a SnackBar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Could not launch WhatsApp')),
                            );
                          }
                        }
                      },
                      child: const Text("WhatsApp Supplier"),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
