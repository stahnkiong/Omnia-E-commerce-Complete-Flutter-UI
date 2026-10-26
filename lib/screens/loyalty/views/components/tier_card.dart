import 'package:flutter/material.dart';
import 'package:pasar_now/models/loyalty_model.dart';

class TierCard extends StatelessWidget {
  final CustomerLoyaltyModel? loyalty;
  final String customerName;
  final VoidCallback? onPointsTap;

  const TierCard({
    super.key,
    required this.loyalty,
    required this.customerName,
    this.onPointsTap,
  });

  // Metallic Gradients based on Tier
  LinearGradient _getTierGradient(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return const LinearGradient(
          colors: [Color(0xFF1E222D), Color(0xFF4B5366), Color(0xFF2C3240)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'gold':
        return const LinearGradient(
          colors: [Color(0xFF996515), Color(0xFFD4AF37), Color(0xFFE8C85A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'silver':
        return const LinearGradient(
          colors: [Color(0xFF5A6372), Color(0xFF8E9AAF), Color(0xFFB8C0D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'bronze':
      default:
        return const LinearGradient(
          colors: [Color(0xFF7A4526), Color(0xFFA5683F), Color(0xFFC68A5E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  String _getTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'platinum':
        return '💎';
      case 'gold':
        return '🥇';
      case 'silver':
        return '🥈';
      case 'bronze':
      default:
        return '🥉';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = loyalty?.tier ?? 'bronze';
    final tierName = loyalty?.tierName ?? 'Bronze';
    final points = loyalty?.pointsBalance ?? 0;
    final monthlySpendFormatted = loyalty?.monthlySpendFormatted ?? '\$0.00';
    final nextTier = loyalty?.nextTier;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: _getTierGradient(tier),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Tier Icon + Name & Points Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _getTierIcon(tier),
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$tierName Member",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          customerName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onPointsTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, color: Colors.amberAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "$points pts",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Middle: Monthly Spend Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "THIS MONTH'S SPEND",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      monthlySpendFormatted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (loyalty?.cycleEnd != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "CYCLE ENDS",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${loyalty!.cycleEnd!.day}/${loyalty!.cycleEnd!.month}/${loyalty!.cycleEnd!.year}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom: Next Tier Progress Bar
            if (nextTier != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (nextTier.progressPercentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Spend ${nextTier.spendNeededFormatted} more to reach ${nextTier.name}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    "${nextTier.progressPercentage}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.amberAccent, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "Top Tier VIP Member · Maximum Perks Active",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
