import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/route/screen_export.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';
import 'package:pasar_now/providers/auth_provider.dart';
import 'package:pasar_now/providers/loyalty_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoyaltyProvider>(context, listen: false).fetchLoyalty(silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              final customer = auth.customer;
              return ProfileCard(
                name: customer != null
                    ? "${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}"
                            .trim()
                            .isEmpty
                        ? "User"
                        : "${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}"
                    : "Guest",
                email: customer?['email'] ?? "No Email",
                imageSrc: "assets/Illustration/profile_icon.png",
              );
            },
          ),

          // VIP Membership Quick Banner
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding / 2,
            ),
            child: Consumer<LoyaltyProvider>(
              builder: (context, loyaltyProvider, child) {
                final loyalty = loyaltyProvider.loyalty;
                final tierName = loyalty?.tierName ?? "Bronze";
                final points = loyalty?.pointsBalance ?? 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, memberCenterScreenRoute);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C3240), Color(0xFF4B5366)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.workspace_premium, color: Colors.amberAccent, size: 28),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$tierName Member",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  "Points: $points pts · View Perks",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                "Enter",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chevron_right, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Membership & Rewards Section
          const SizedBox(height: defaultPadding / 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "Membership & Rewards (会员特权)",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: "Member Center (会员中心)",
            svgSrc: "assets/icons/diamond.svg",
            press: () {
              Navigator.pushNamed(context, memberCenterScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Coupon Center (领券中心)",
            svgSrc: "assets/icons/Coupon.svg",
            press: () {
              Navigator.pushNamed(context, couponCenterScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "My Coupons (我的优惠券)",
            svgSrc: "assets/icons/Discount.svg",
            press: () {
              Navigator.pushNamed(context, myCouponsScreenRoute);
            },
          ),

          const SizedBox(height: defaultPadding / 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              "Account",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: "Current Orders",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              Navigator.pushNamed(context, currentOrdersScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Past Orders",
            svgSrc: "assets/icons/Order.svg",
            press: () {
              Navigator.pushNamed(context, ordersScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Addresses",
            svgSrc: "assets/icons/Address.svg",
            press: () {
              Navigator.pushNamed(context, addressesScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Invoices",
            svgSrc: "assets/icons/card.svg",
            press: () {
              Navigator.pushNamed(context, invoicesScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: "Biometric Login",
            svgSrc: "assets/icons/Fingerprint.svg",
            press: () {
              Navigator.pushNamed(context, enableBiometricLoginScreenRoute);
            },
          ),

          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding, vertical: defaultPadding / 2),
            child: Text(
              "Help & Support",
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          ProfileMenuListTile(
            text: "Get Help",
            svgSrc: "assets/icons/Help.svg",
            press: () async {
              final Uri url =
                  Uri.parse("https://www.omniafoodsupply.com.my/contact/");
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
          ProfileMenuListTile(
            text: "Delete Account",
            svgSrc: "assets/icons/Delete.svg",
            press: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text("Delete Account"),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Account deletion is permanent and cannot be undone. You can review our policy or request deletion below.",
                          ),
                          const SizedBox(height: defaultPadding),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.description_outlined, color: primaryColor),
                            title: const Text(
                              "Data Retention & Deletion Policy",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            subtitle: const Text(
                              "View policy in your browser",
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.open_in_new, size: 18),
                            onTap: () async {
                              final Uri url = Uri.parse("https://www.omniafoodsupply.com.my/data-retention-deletion/");
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.mail_outline, color: errorColor),
                            title: const Text(
                              "Request Account Deletion",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: errorColor),
                            ),
                            subtitle: const Text(
                              "Send deletion request email",
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right, size: 18),
                            onTap: () async {
                              Navigator.pop(dialogContext);
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              final customerEmail = authProvider.customer?['email'] ?? '';
                              const String email = 'feedback@omniafoodsupply.com.my';
                              final String subject = Uri.encodeComponent('Requesting Data Deletion');
                              final String body = Uri.encodeComponent(
                                'Dear Omnia Support Team,\n\n'
                                'I am writing to request the permanent deletion of my account and all associated personal data from your systems.\n\n'
                                'Account Details:\n'
                                '- Email Address: $customerEmail\n\n'
                                'Please process this request and confirm once the deletion is complete.\n\n'
                                'Thank you.',
                              );
                              final Uri url = Uri.parse('mailto:$email?subject=$subject&body=$body');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Could not launch mail application."),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Cancel"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ProfileMenuListTile(
            text: "FAQ",
            svgSrc: "assets/icons/FAQ.svg",
            press: () async {
              final Uri url = Uri.parse(
                  "https://www.omniafoodsupply.com.my/delivery-return-policy/");
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
            isShowDivider: false,
          ),
          const SizedBox(height: defaultPadding),

          // Log Out
          ListTile(
            onTap: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (context.mounted) {
                context.read<LoyaltyProvider>().reset();
              }

              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                onbordingScreenRoute,
                (route) => false,
              );
              Navigator.pushNamed(context, logInScreenRoute);
            },
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              "assets/icons/Logout.svg",
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: const Text(
              "Log Out",
              style: TextStyle(color: errorColor, fontSize: 14, height: 1),
            ),
          )
        ],
      ),
    );
  }
}
