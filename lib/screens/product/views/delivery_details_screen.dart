import 'package:flutter/material.dart';
import 'package:pasar_now/constants.dart';

class DeliveryDetailScreen extends StatelessWidget {
  const DeliveryDetailScreen({super.key});

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
                    "Delivery Details",
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
                  children: [
                    _buildDeliveryOptionCard(
                      context,
                      title: "Standard Delivery",
                      icon: Icons.local_shipping_outlined,
                      timing: "Delivered within 24 to 72 hours.",
                      extraLabel: "Best For",
                      extraValue:
                          "Regular restocking and non-urgent inventory items.",
                      color: primaryColor,
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildDeliveryOptionCard(
                      context,
                      title: "Express Delivery (Same-Day)",
                      icon: Icons.bolt_outlined,
                      timing:
                          "Delivered today if ordered before the 12:00 PM cutoff.",
                      extraLabel: "Note",
                      extraValue:
                          "Orders placed after 12:00 PM will automatically dispatch the next morning.",
                      color: warningColor,
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildDeliveryOptionCard(
                      context,
                      title: "HQ Self-Pickup",
                      icon: Icons.storefront_outlined,
                      timing:
                          "Ready for collection same-day at our central headquarters.",
                      extraLabel: "Note",
                      extraValue:
                          "Please wait for the \"Ready for Pickup\" app notification before arriving.",
                      color: successColor,
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

  Widget _buildDeliveryOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String timing,
    required String extraLabel,
    required String extraValue,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(defaultBorderRadious / 2),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          const Divider(),
          const SizedBox(height: defaultPadding / 2),
          Text(
            "Timing",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            timing,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            extraLabel,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            extraValue,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}
