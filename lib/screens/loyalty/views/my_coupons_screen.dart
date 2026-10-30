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

  void _copyCode(String code, {bool navigateToShop = false}) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                navigateToShop
                    ? "Code '$code' copied! Apply it at checkout."
                    : "Promo code '$code' copied to clipboard!",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    if (navigateToShop) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "My Coupons",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, couponCenterScreenRoute);
            },
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text(
              "Get More",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: blackColor60,
          indicatorColor: primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          tabs: const [
            Tab(text: "Available"),
            Tab(text: "Used"),
            Tab(text: "Expired"),
          ],
        ),
      ),
      body: Consumer<LoyaltyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingMyCoupons && provider.myCoupons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final coupons = provider.myCoupons;

          return Column(
            children: [
              // Helpful Info Banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18, color: primaryColor),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "Tap 'Copy' or 'Use Now' to apply discount codes at checkout.",
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Coupon List or Empty State
              Expanded(
                child: coupons.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          _fetchCouponsForCurrentTab();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: coupons.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final item = coupons[index];
                            return _buildWalletTicketCard(item);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String tabTitle = "available";
    if (_tabController.index == 1) tabTitle = "used";
    if (_tabController.index == 2) tabTitle = "expired";

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 46,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No $tabTitle vouchers",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Claim member vouchers from the Coupon Center and apply them at checkout to save on your orders!",
              textAlign: TextAlign.center,
              style: TextStyle(color: blackColor60, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, couponCenterScreenRoute);
              },
              icon: const Icon(Icons.local_offer_outlined, size: 18),
              label: const Text("Explore Coupon Center"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTicketCard(UserCouponModel item) {
    final isAvailable = item.status == 'available';
    final isUsed = item.status == 'used';

    const double punchRadius = 9.0;
    const double punchPosition = 110.0;

    return PhysicalShape(
      clipper: TicketClipper(
        punchRadius: punchRadius,
        punchPosition: punchPosition,
      ),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isAvailable
                ? primaryColor.withValues(alpha: 0.25)
                : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Stub: Discount Amount
              Container(
                width: punchPosition,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                decoration: BoxDecoration(
                  gradient: isAvailable
                      ? LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.12),
                            primaryColor.withValues(alpha: 0.04),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey.shade200,
                            Colors.grey.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.formattedDiscount,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isAvailable ? primaryColor : Colors.grey.shade600,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? primaryColor.withValues(alpha: 0.15)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item.discountType == 'percentage' ? "DISCOUNT" : "VOUCHER",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isAvailable ? primaryColor : Colors.grey.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dashed Perforation Line
              CustomPaint(
                size: const Size(1, double.infinity),
                painter: DashedLinePainter(
                  color: isAvailable
                      ? primaryColor.withValues(alpha: 0.3)
                      : Colors.grey.shade300,
                ),
              ),

              // Right Body: Code, Details, Dates & Actions
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Code Pill + Copy Chip + Status Badge
                      Row(
                        children: [
                          // Promo Code Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? primaryColor.withValues(alpha: 0.08)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isAvailable
                                    ? primaryColor.withValues(alpha: 0.25)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  size: 13,
                                  color: isAvailable ? primaryColor : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  item.promotionCode,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable ? primaryColor : Colors.grey.shade700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Quick Copy Icon
                          InkWell(
                            onTap: () => _copyCode(item.promotionCode),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.copy_rounded,
                                size: 16,
                                color: isAvailable ? primaryColor : Colors.grey.shade500,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Status Pill
                          _buildStatusBadge(item),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Middle: Helper Note
                      Text(
                        isAvailable
                            ? "Applicable on your next order at checkout."
                            : isUsed
                                ? "This voucher has been redeemed."
                                : "This voucher has expired.",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),

                      // Bottom Row: Date & Action Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Date Stamp
                          Row(
                            children: [
                              Icon(
                                isUsed
                                    ? Icons.check_circle_outline
                                    : isAvailable
                                        ? Icons.event_available
                                        : Icons.event_busy,
                                size: 13,
                                color: isUsed
                                    ? Colors.green.shade600
                                    : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isUsed && item.formattedUsedDate.isNotEmpty
                                    ? "Used: ${item.formattedUsedDate}"
                                    : item.formattedClaimDate.isNotEmpty
                                        ? "Claimed: ${item.formattedClaimDate}"
                                        : "Valid in wallet",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isUsed
                                      ? Colors.green.shade700
                                      : Colors.grey.shade600,
                                  fontWeight: isUsed ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),

                          // Action Button (Only for Available)
                          if (isAvailable)
                            SizedBox(
                              height: 30,
                              child: ElevatedButton(
                                onPressed: () => _copyCode(
                                  item.promotionCode,
                                  navigateToShop: true,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Use Now",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(Icons.arrow_forward_rounded, size: 12),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(UserCouponModel item) {
    if (item.status == 'available') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              "Active",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      );
    } else if (item.status == 'used') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "Used",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Expired",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      );
    }
  }
}

/// Ticket Clipper that cuts out semicircular notches at the perforation line
class TicketClipper extends CustomClipper<Path> {
  final double punchRadius;
  final double punchPosition;

  TicketClipper({
    required this.punchRadius,
    required this.punchPosition,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    const cornerRadius = 12.0;

    // Top-left corner
    path.moveTo(0, cornerRadius);
    path.arcToPoint(
      const Offset(cornerRadius, 0),
      radius: const Radius.circular(cornerRadius),
    );

    // Top edge to punch notch
    path.lineTo(punchPosition - punchRadius, 0);
    path.arcToPoint(
      Offset(punchPosition + punchRadius, 0),
      radius: Radius.circular(punchRadius),
      clockwise: false,
    );

    // Continue to top-right corner
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );

    // Right edge
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: const Radius.circular(cornerRadius),
    );

    // Bottom edge to punch notch
    path.lineTo(punchPosition + punchRadius, size.height);
    path.arcToPoint(
      Offset(punchPosition - punchRadius, size.height),
      radius: Radius.circular(punchRadius),
      clockwise: false,
    );

    // Continue to bottom-left corner
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: const Radius.circular(cornerRadius),
    );

    // Left edge back to top
    path.lineTo(0, cornerRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 12;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startY < size.height - 12) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
