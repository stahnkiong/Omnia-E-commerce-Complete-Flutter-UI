import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants.dart';

class ProductReturnsScreen extends StatefulWidget {
  const ProductReturnsScreen({super.key});

  @override
  State<ProductReturnsScreen> createState() => _ProductReturnsScreenState();
}

class _ProductReturnsScreenState extends State<ProductReturnsScreen> {
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _handlePress;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    final Uri url =
        Uri.parse('https://www.omniafoodsupply.com.my/delivery-return-policy/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

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
                    "Returns & Exchange",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(defaultPadding),
                      decoration: BoxDecoration(
                        color: successColor.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                        border: Border.all(
                            color: successColor.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.verified_user_outlined,
                                color: successColor,
                                size: 24,
                              ),
                              const SizedBox(width: defaultPadding / 2),
                              Text(
                                "100% Quality Guarantee",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: successColor,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: defaultPadding / 2),
                          Text(
                            "We pride ourselves on quality. Our 100% Quality Guarantee means if any produce is not fresh or up to standard, we replace it instantly, no questions asked.",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 1.5),
                    Text(
                      "Conditions for Return & Exchange:",
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildConditionRow(
                      context,
                      title: "Perishable Goods",
                      description:
                          "Issues should be reported upon receiving the delivery for immediate replacement.",
                      icon: Icons.timer_outlined,
                      iconColor: warningColor,
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildConditionRow(
                      context,
                      title: "Non-Perishable Items",
                      description:
                          "Standard 7-day return policy applies for defective or incorrect items.",
                      icon: Icons.calendar_today_outlined,
                      iconColor: primaryColor,
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildConditionRow(
                      context,
                      title: "Original Packaging",
                      description:
                          "Items should be in their original packaging where possible to facilitate the exchange.",
                      icon: Icons.inventory_2_outlined,
                      iconColor: Colors.blueGrey,
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "For more details, please read our ",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color
                                        ?.withValues(alpha: 0.7),
                                  ),
                          children: [
                            TextSpan(
                              text: "Delivery & Return Policy",
                              recognizer: _tapGestureRecognizer,
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: "."),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionRow(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
