import 'package:flutter/material.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/providers/loyalty_provider.dart';
import 'package:pasar_now/route/route_constants.dart';
import 'package:provider/provider.dart';
import 'components/coupon_ticket_card.dart';

class CouponCenterScreen extends StatefulWidget {
  const CouponCenterScreen({super.key});

  @override
  State<CouponCenterScreen> createState() => _CouponCenterScreenState();
}

class _CouponCenterScreenState extends State<CouponCenterScreen> {
  String _selectedFilter = 'all'; // 'all', 'claimable', 'exclusive'
  String? _claimingPromoId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoyaltyProvider>(context, listen: false).fetchAvailableCoupons();
    });
  }

  Future<void> _handleClaim(String promoId) async {
    setState(() => _claimingPromoId = promoId);
    final provider = Provider.of<LoyaltyProvider>(context, listen: false);
    final result = await provider.claimCoupon(promoId);
    if (mounted) {
      setState(() => _claimingPromoId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Action completed'),
          backgroundColor: result['success'] == true ? primaryColor : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          action: result['success'] == true
              ? SnackBarAction(
                  label: "VIEW",
                  textColor: Colors.amberAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, myCouponsScreenRoute);
                  },
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Coupon Center",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallet),
            tooltip: "My Vouchers",
            onPressed: () {
              Navigator.pushNamed(context, myCouponsScreenRoute);
            },
          ),
        ],
      ),
      body: Consumer<LoyaltyProvider>(
        builder: (context, provider, child) {
          final allCoupons = provider.availableCoupons;
          final filteredCoupons = allCoupons.filter((c) {
            if (_selectedFilter == 'claimable') {
              return c.canClaim;
            } else if (_selectedFilter == 'exclusive') {
              return c.isGroupRestricted;
            }
            return true;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchAvailableCoupons();
            },
            child: ListView(
              padding: const EdgeInsets.all(defaultPadding),
              children: [
                // Top Banner (Taobao / Meituan Header Style)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B61FF), Color(0xFFFF6584)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Coupon Center · Exclusive Deals",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Claim vouchers now & apply discounts automatically at checkout",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.confirmation_num,
                        color: Colors.white,
                        size: 46,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All Coupons (${allCoupons.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('claimable', 'Available to Claim'),
                      const SizedBox(width: 8),
                      _buildFilterChip('exclusive', 'VIP Exclusives'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // List of Coupons
                if (provider.isLoadingCoupons && allCoupons.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredCoupons.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          "No coupons in this category",
                          style: TextStyle(color: blackColor60, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredCoupons.map((coupon) {
                    return CouponTicketCard(
                      coupon: coupon,
                      isClaiming: _claimingPromoId == coupon.id,
                      onClaim: () => _handleClaim(coupon.id),
                    );
                  }),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = key);
      },
      selectedColor: primaryColor,
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : blackColor80,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> filter(bool Function(T) test) sync* {
    for (final element in this) {
      if (test(element)) {
        yield element;
      }
    }
  }
}
