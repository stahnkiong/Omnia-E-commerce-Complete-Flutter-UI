import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/models/loyalty_model.dart';
import 'package:pasar_now/providers/loyalty_provider.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:provider/provider.dart';

class MyCouponsScreen extends StatefulWidget {
  const MyCouponsScreen({super.key});

  @override
  State<MyCouponsScreen> createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends State<MyCouponsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _fetchCouponsForCurrentTab();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCouponsForCurrentTab();
    });
  }

  void _fetchCouponsForCurrentTab() {
    final provider = Provider.of<LoyaltyProvider>(context, listen: false);
    String? status;
    switch (_tabController.index) {
      case 0:
        status = 'available';
        break;
      case 1:
        status = 'used';
        break;
      case 2:
        status = 'expired';
        break;
    }
    provider.fetchMyCoupons(status: status);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Promo code '$code' copied to clipboard!"),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Coupons (我的优惠券)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: blackColor60,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(text: "Available (可使用)"),
            Tab(text: "Used (已使用)"),
            Tab(text: "Expired (已过期)"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: "Claim More Vouchers",
            onPressed: () {
              Navigator.pushNamed(context, couponCenterScreenRoute);
            },
          ),
        ],
      ),
      body: Consumer<LoyaltyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingMyCoupons && provider.myCoupons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final coupons = provider.myCoupons;

          if (coupons.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      "No vouchers in this tab",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Claim member vouchers from the Coupon Center and apply them at checkout!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: blackColor60),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, couponCenterScreenRoute);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text("Go to Coupon Center (去领券)"),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _fetchCouponsForCurrentTab();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(defaultPadding),
              itemCount: coupons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = coupons[index];
                return _buildWalletCouponCard(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildWalletCouponCard(UserCouponModel item) {
    final isAvailable = item.status == 'available';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable ? primaryColor.withOpacity(0.3) : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Left Value Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isAvailable
                    ? primaryColor.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    item.formattedDiscount,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? primaryColor : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green.shade700 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Middle Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.promotionCode,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.copy, size: 16, color: primaryColor),
                        onPressed: () => _copyCode(item.promotionCode),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (item.claimedAt != null)
                    Text(
                      "Claimed: ${item.claimedAt!.day}/${item.claimedAt!.month}/${item.claimedAt!.year}",
                      style: const TextStyle(fontSize: 11, color: blackColor60),
                    ),
                  if (item.usedAt != null)
                    Text(
                      "Used: ${item.usedAt!.day}/${item.usedAt!.month}/${item.usedAt!.year}",
                      style: const TextStyle(fontSize: 11, color: Colors.green),
                    ),
                ],
              ),
            ),

            // Right Button
            if (isAvailable)
              ElevatedButton(
                onPressed: () {
                  _copyCode(item.promotionCode);
                  // Pop back or navigate to Home
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Use", style: TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
