import 'package:flutter/material.dart';

import '../../../constants.dart';

class ProductReturnsScreen extends StatelessWidget {
  const ProductReturnsScreen({super.key});

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
                    "Return",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: RichText(
                text: const TextSpan(
                  text:
                      "Free pre-paid returns and exchanges for orders shipped to the ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Sarawak",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ". Get refunded faster with easy online returns and FREE pre-paid return Omnia Fodds online! Return or exchange any unused or defective merchandise by mail or at one of our store locations.",
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: RichText(
                text: const TextSpan(
                  text:
                      "Damaged or expired items cannot be returned or exchanged. Please check your goods upon receiving them and report any issues to us immediately.",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
