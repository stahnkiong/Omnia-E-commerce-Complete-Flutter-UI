class NextTierInfo {
  final String name;
  final int minMonthlySpend;
  final String minMonthlySpendFormatted;
  final int spendNeeded;
  final String spendNeededFormatted;
  final int progressPercentage;

  NextTierInfo({
    required this.name,
    required this.minMonthlySpend,
    required this.minMonthlySpendFormatted,
    required this.spendNeeded,
    required this.spendNeededFormatted,
    required this.progressPercentage,
  });

  factory NextTierInfo.fromJson(Map<String, dynamic> json) {
    return NextTierInfo(
      name: json['name'] ?? '',
      minMonthlySpend: (json['min_monthly_spend'] as num?)?.toInt() ?? 0,
      minMonthlySpendFormatted: json['min_monthly_spend_formatted'] ?? 'RM 0.00',
      spendNeeded: (json['spend_needed'] as num?)?.toInt() ?? 0,
      spendNeededFormatted: json['spend_needed_formatted'] ?? 'RM 0.00',
      progressPercentage: (json['progress_percentage'] as num?)?.toInt() ?? 0,
    );
  }
}

class CustomerLoyaltyModel {
  final String id;
  final String customerId;
  final String tier;
  final String tierName;
  final String? currentCustomerGroupId;
  final int pointsBalance;
  final int lifetimePoints;
  final int monthlySpend;
  final String monthlySpendFormatted;
  final DateTime? cycleStart;
  final DateTime? cycleEnd;
  final NextTierInfo? nextTier;
  final int availableCouponsCount;

  CustomerLoyaltyModel({
    required this.id,
    required this.customerId,
    required this.tier,
    required this.tierName,
    this.currentCustomerGroupId,
    required this.pointsBalance,
    required this.lifetimePoints,
    required this.monthlySpend,
    required this.monthlySpendFormatted,
    this.cycleStart,
    this.cycleEnd,
    this.nextTier,
    required this.availableCouponsCount,
  });

  factory CustomerLoyaltyModel.fromJson(Map<String, dynamic> json) {
    return CustomerLoyaltyModel(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      tier: (json['tier'] ?? 'bronze').toString().toLowerCase(),
      tierName: json['tier_name'] ?? 'Bronze',
      currentCustomerGroupId: json['current_customer_group_id'],
      pointsBalance: (json['points_balance'] as num?)?.toInt() ?? 0,
      lifetimePoints: (json['lifetime_points'] as num?)?.toInt() ?? 0,
      monthlySpend: (json['monthly_spend'] as num?)?.toInt() ?? 0,
      monthlySpendFormatted: json['monthly_spend_formatted'] ?? '\$0.00',
      cycleStart: json['cycle_start'] != null ? DateTime.tryParse(json['cycle_start']) : null,
      cycleEnd: json['cycle_end'] != null ? DateTime.tryParse(json['cycle_end']) : null,
      nextTier: json['next_tier'] != null ? NextTierInfo.fromJson(json['next_tier']) : null,
      availableCouponsCount: (json['available_coupons_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class PointsTransactionModel {
  final String id;
  final int amount;
  final String type;
  final String? referenceId;
  final String? description;
  final DateTime? createdAt;

  PointsTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    this.referenceId,
    this.description,
    this.createdAt,
  });

  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionModel(
      id: json['id'] ?? '',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      type: json['type'] ?? 'order_earn',
      referenceId: json['reference_id'],
      description: json['description'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}

class CouponModel {
  final String id;
  final String code;
  final String? type;
  final String discountType; // "percentage" or "fixed"
  final num value;
  final String? currencyCode;
  final int? maxQuantity;
  final List<String> targetGroupIds;
  final bool isGroupRestricted;
  final String claimStatus; // "claimable" | "already_claimed" | "group_restricted" | "login_required"
  final bool canClaim;

  CouponModel({
    required this.id,
    required this.code,
    this.type,
    required this.discountType,
    required this.value,
    this.currencyCode,
    this.maxQuantity,
    required this.targetGroupIds,
    required this.isGroupRestricted,
    required this.claimStatus,
    required this.canClaim,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      type: json['type'],
      discountType: json['discount_type'] ?? 'percentage',
      value: json['value'] ?? 0,
      currencyCode: json['currency_code'],
      maxQuantity: (json['max_quantity'] as num?)?.toInt(),
      targetGroupIds: (json['target_group_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isGroupRestricted: json['is_group_restricted'] ?? false,
      claimStatus: json['claim_status'] ?? 'claimable',
      canClaim: json['can_claim'] ?? false,
    );
  }

  String get formattedDiscount {
    if (discountType == 'percentage') {
      return "${value.toInt()}% OFF";
    }
    final cur = (currencyCode == null || currencyCode!.toUpperCase() == 'MYR') ? 'RM ' : '$currencyCode ';
    return "$cur${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)} OFF";
  }
}

class UserCouponModel {
  final String id;
  final String customerId;
  final String promotionId;
  final String promotionCode;
  final String status; // "available" | "used" | "expired"
  final DateTime? claimedAt;
  final DateTime? expiresAt;
  final DateTime? usedAt;
  final String? orderId;
  final Map<String, dynamic>? metadata;
  final String discountType;
  final num discountValue;
  final String? currencyCode;

  UserCouponModel({
    required this.id,
    required this.customerId,
    required this.promotionId,
    required this.promotionCode,
    required this.status,
    this.claimedAt,
    this.expiresAt,
    this.usedAt,
    this.orderId,
    this.metadata,
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.currencyCode,
  });

  factory UserCouponModel.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>?;
    final dType = json['discount_type'] ?? meta?['discount_type'] ?? 'percentage';
    final dVal = (json['discount_value'] as num?) ?? (meta?['discount_value'] as num?) ?? 0;
    final cCode = json['currency_code'] ?? meta?['currency_code'];

    return UserCouponModel(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      promotionId: json['promotion_id'] ?? '',
      promotionCode: json['promotion_code'] ?? '',
      status: json['status'] ?? 'available',
      claimedAt: json['claimed_at'] != null ? DateTime.tryParse(json['claimed_at']) : null,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
      usedAt: json['used_at'] != null ? DateTime.tryParse(json['used_at']) : null,
      orderId: json['order_id'],
      metadata: meta,
      discountType: dType,
      discountValue: dVal,
      currencyCode: cCode,
    );
  }

  String get formattedDiscount {
    if (discountType == 'percentage') {
      if (discountValue > 0) {
        return "${discountValue.toInt()}% OFF";
      }
      return "DISCOUNT";
    }
    if (discountValue > 0) {
      final cur = (currencyCode == null || currencyCode!.toUpperCase() == 'MYR') ? 'RM ' : '$currencyCode ';
      return "$cur${discountValue.toStringAsFixed(discountValue % 1 == 0 ? 0 : 2)} OFF";
    }
    return "VOUCHER";
  }

  String get formattedClaimDate {
    if (claimedAt == null) return '';
    return "${claimedAt!.day} ${_monthName(claimedAt!.month)} ${claimedAt!.year}";
  }

  String get formattedUsedDate {
    if (usedAt == null) return '';
    return "${usedAt!.day} ${_monthName(usedAt!.month)} ${usedAt!.year}";
  }

  String get formattedExpiryDate {
    if (expiresAt == null) return '';
    return "${expiresAt!.day} ${_monthName(expiresAt!.month)} ${expiresAt!.year}";
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
