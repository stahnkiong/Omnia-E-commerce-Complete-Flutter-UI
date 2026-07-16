import 'package:flutter/material.dart';
import 'package:pasar_now/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentOptionsScreen extends StatelessWidget {
  const PaymentOptionsScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $urlString')),
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
                    "Payment & Bulk Options",
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
                    _buildPaymentOptionCard(
                      context,
                      title: "Normal Rates (Instant Payment)",
                      icon: Icons.credit_card_outlined,
                      description:
                          "Rate: Standard Rate\n\nOptions:\n💳 Credit / Debit Card (Visa & Mastercard)\n🏦 FPX Online Banking (Instant transfer via Maybank2u, CIMB Clicks, Public Bank, etc.)",
                      color: Colors.blue,
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildPaymentOptionCard(
                      context,
                      title: "Cash on Delivery (COD)",
                      icon: Icons.payments_outlined,
                      description:
                          "Pay on arrival via Cash or Instant Bank Transfer and enjoy up to a 5% discount on your total order.",
                      color: successColor,
                    ),
                    const SizedBox(height: defaultPadding),
                    _buildPaymentOptionCard(
                      context,
                      title: "B2B Credit Accounts",
                      icon: Icons.business_outlined,
                      description:
                          "Existing corporate clients enjoy your approved 14-day to 30-day credit terms automatically at checkout.\n\nTo apply for credit terms, please contact your account manager directly.",
                      color: primaryColor,
                      actionWidget: Padding(
                        padding: const EdgeInsets.only(top: defaultPadding),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _launchUrl(context, 'tel:+60182519988'),
                                icon: const Icon(Icons.phone),
                                label: const Text("Call"),
                              ),
                            ),
                            const SizedBox(width: defaultPadding),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _launchUrl(
                                    context, 'https://wa.me/60182519988'),
                                icon: const Icon(Icons.chat),
                                label: const Text("WhatsApp"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
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

  Widget _buildPaymentOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String description,
    required Color color,
    Widget? actionWidget,
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
            description,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  height: 1.5,
                ),
          ),
          if (actionWidget != null) actionWidget,
        ],
      ),
    );
  }
}
