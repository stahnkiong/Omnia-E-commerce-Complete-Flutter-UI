import 'package:flutter/material.dart';
import 'package:pasar_now/constants.dart';
import 'package:pasar_now/models/loyalty_model.dart';

class CouponTicketCard extends StatelessWidget {
  final CouponModel coupon;
  final VoidCallback onClaim;
  final bool isClaiming;

  const CouponTicketCard({
    super.key,
    required this.coupon,
    required this.onClaim,
    this.isClaiming = false,
  });

  @override
  Widget build(BuildContext context) {
    final isClaimed = coupon.claimStatus == 'already_claimed';
    final isRestricted = coupon.claimStatus == 'group_restricted';
    final isLoginRequired = coupon.claimStatus == 'login_required';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isClaimed ? Colors.grey.shade300 : primaryColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Box: Discount Value (Taobao/Meituan Style)
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isClaimed
                    ? Colors.grey.shade200
                    : primaryColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      coupon.formattedDiscount,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isClaimed ? Colors.grey.shade600 : primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.discountType == 'percentage' ? "Discount" : "Voucher",
                    style: TextStyle(
                      fontSize: 11,
                      color: isClaimed ? Colors.grey.shade500 : blackColor60,
                    ),
                  ),
                ],
              ),
            ),

            // Dashed Divider
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: DashedLinePainter(
                color: Colors.grey.shade300,
              ),
            ),

            // Middle Box: Code & Conditions
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            coupon.code,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        if (coupon.isGroupRestricted) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "VIP Only",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB78103),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      coupon.isGroupRestricted
                          ? "Exclusive for qualifying membership tier"
                          : "Applicable store-wide on checkout",
                      style: const TextStyle(
                        fontSize: 11,
                        color: blackColor60,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Right Box: Action Button ("Claim" / "Claimed" / "VIP Only")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Center(
                child: SizedBox(
                  width: 76,
                  height: 36,
                  child: isClaiming
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: coupon.canClaim ? onClaim : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isClaimed
                                ? Colors.grey.shade300
                                : isRestricted
                                    ? Colors.grey.shade200
                                    : primaryColor,
                            foregroundColor: isClaimed || isRestricted
                                ? Colors.grey.shade700
                                : Colors.white,
                            padding: EdgeInsets.zero,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            isClaimed
                                ? "Claimed"
                                : isRestricted
                                    ? "VIP Only"
                                    : isLoginRequired
                                        ? "Sign In"
                                        : "Claim",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
