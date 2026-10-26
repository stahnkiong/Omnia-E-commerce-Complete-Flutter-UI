import 'package:flutter/material.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/providers/auth_provider.dart';
import 'package:pasar_now/providers/loyalty_provider.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:provider/provider.dart';
import 'components/tier_card.dart';
import 'components/coupon_ticket_card.dart';

class MemberCenterScreen extends StatefulWidget {
  const MemberCenterScreen({super.key});

  @override
  State<MemberCenterScreen> createState() => _MemberCenterScreenState();
}

class _MemberCenterScreenState extends State<MemberCenterScreen> {
  String? _claimingPromoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
      loyaltyProvider.fetchLoyalty();
      loyaltyProvider.fetchAvailableCoupons();
    });
  }

  void _showPointsHistory(BuildContext context) {
    final loyaltyProvider = Provider.of<LoyaltyProvider>(context, listen: false);
    loyaltyProvider.fetchPointsHistory();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Consumer<LoyaltyProvider>(
              builder: (_, provider, __) {
                return Padding(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Points History (积分明细)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${provider.loyalty?.pointsBalance ?? 0} pts",
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      Expanded(
                        child: provider.isLoadingPoints
                            ? const Center(child: CircularProgressIndicator())
                            : provider.pointsHistory.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No points transactions yet.\nMake a purchase to earn 1 pt per \$1 spent!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: blackColor60),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: scrollController,
                                    itemCount: provider.pointsHistory.length,
                                    separatorBuilder: (_, __) => const Divider(),
                                    itemBuilder: (_, index) {
                                      final item = provider.pointsHistory[index];
                                      final isPositive = item.amount >= 0;
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundColor: isPositive
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                          child: Icon(
                                            isPositive ? Icons.add_circle : Icons.remove_circle,
                                            color: isPositive ? Colors.green : Colors.red,
                                          ),
                                        ),
                                        title: Text(
                                          item.description ?? (isPositive ? "Earned Points" : "Points Deduction"),
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        subtitle: item.createdAt != null
                                            ? Text(
                                                "${item.createdAt!.day}/${item.createdAt!.month}/${item.createdAt!.year}",
                                                style: const TextStyle(fontSize: 12, color: blackColor40),
                                              )
                                            : null,
                                        trailing: Text(
                                          "${isPositive ? '+' : ''}${item.amount} pts",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _handleClaim(String promoId) async {
    setState(() => _claimingPromoId = promoId);
    final provider = Provider.of<LoyaltyProvider>(context, listen: false);
    final result = await provider.claimCoupon(promoId);
    if (!mounted) return;
    setState(() => _claimingPromoId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Action completed'),
        backgroundColor: result['success'] == true ? primaryColor : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final customer = auth.customer;
    final customerName = customer != null
        ? "${customer['first_name'] ?? ''} ${customer['last_name'] ?? ''}".trim()
        : "Omnia Member";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Member Center (会员中心)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final lp = Provider.of<LoyaltyProvider>(context, listen: false);
              lp.fetchLoyalty();
              lp.fetchAvailableCoupons();
            },
          ),
        ],
      ),
      body: Consumer<LoyaltyProvider>(
        builder: (context, loyaltyProvider, child) {
          if (loyaltyProvider.isLoadingLoyalty && loyaltyProvider.loyalty == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final loyalty = loyaltyProvider.loyalty;
          final availableCoupons = loyaltyProvider.availableCoupons;

          return RefreshIndicator(
            onRefresh: () async {
              await loyaltyProvider.fetchLoyalty();
              await loyaltyProvider.fetchAvailableCoupons();
            },
            child: ListView(
              padding: const EdgeInsets.all(defaultPadding),
              children: [
                // 1. VIP Metallic Card
                TierCard(
                  loyalty: loyalty,
                  customerName: customerName.isEmpty ? "Valued Customer" : customerName,
                  onPointsTap: () => _showPointsHistory(context),
                ),

                const SizedBox(height: 20),

                // 2. Quick Action Icons Grid (Taobao / Meituan Style)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction(
                        icon: Icons.confirmation_number_outlined,
                        color: Colors.deepOrange,
                        label: "领券中心",
                        badge: "${availableCoupons.where((c) => c.canClaim).length}",
                        onTap: () {
                          Navigator.pushNamed(context, couponCenterScreenRoute);
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.wallet,
                        color: primaryColor,
                        label: "我的券包",
                        badge: "${loyalty?.availableCouponsCount ?? 0}",
                        onTap: () {
                          Navigator.pushNamed(context, myCouponsScreenRoute);
                        },
                      ),
                      _buildQuickAction(
                        icon: Icons.stars,
                        color: Colors.amber.shade700,
                        label: "积分明细",
                        onTap: () => _showPointsHistory(context),
                      ),
                      _buildQuickAction(
                        icon: Icons.verified_user_outlined,
                        color: Colors.teal,
                        label: "会员权益",
                        onTap: () => _scrollToPerks(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Coupon Center Preview (领券中心)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Member Vouchers (会员特权券)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, couponCenterScreenRoute);
                      },
                      child: const Text("View All >"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (availableCoupons.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "No vouchers currently available. Check back soon!",
                        style: TextStyle(color: blackColor60),
                      ),
                    ),
                  )
                else
                  ...availableCoupons.take(3).map((coupon) {
                    return CouponTicketCard(
                      coupon: coupon,
                      isClaiming: _claimingPromoId == coupon.id,
                      onClaim: () => _handleClaim(coupon.id),
                    );
                  }),

                const SizedBox(height: 24),

                // 4. Tier Perks Comparison Table
                const Text(
                  "Tier Privileges & Discounts",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPerksSection(),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required Color color,
    required String label,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 24),
              ),
              if (badge != null && badge != "0")
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: blackColor80,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerksSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPerkRow("🥉 Bronze", "\$0/mo", "Base pricing, 1 pt per \$1 spent"),
          const Divider(height: 1),
          _buildPerkRow("🥈 Silver", "\$200/mo", "2% off select products, Silver vouchers"),
          const Divider(height: 1),
          _buildPerkRow("🥇 Gold", "\$800/mo", "5% off select products, Gold VIP vouchers"),
          const Divider(height: 1),
          _buildPerkRow("💎 Platinum", "\$2,000/mo", "10% off select products, Top priority"),
        ],
      ),
    );
  }

  Widget _buildPerkRow(String tier, String threshold, String benefit) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  threshold,
                  style: const TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              benefit,
              style: const TextStyle(color: blackColor60, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToPerks() {
    // Smooth visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Scroll down to view tier privileges"),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
