import 'package:flutter/material.dart';
import 'package:pasar_now/models/loyalty_model.dart';
import 'package:pasar_now/services/loyalty_service.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyService _loyaltyService = LoyaltyService();

  CustomerLoyaltyModel? _loyalty;
  List<CouponModel> _availableCoupons = [];
  List<UserCouponModel> _myCoupons = [];
  List<PointsTransactionModel> _pointsHistory = [];

  bool _isLoadingLoyalty = false;
  bool _isLoadingCoupons = false;
  bool _isLoadingMyCoupons = false;
  bool _isLoadingPoints = false;
  String? _errorMessage;

  CustomerLoyaltyModel? get loyalty => _loyalty;
  List<CouponModel> get availableCoupons => _availableCoupons;
  List<UserCouponModel> get myCoupons => _myCoupons;
  List<PointsTransactionModel> get pointsHistory => _pointsHistory;

  bool get isLoadingLoyalty => _isLoadingLoyalty;
  bool get isLoadingCoupons => _isLoadingCoupons;
  bool get isLoadingMyCoupons => _isLoadingMyCoupons;
  bool get isLoadingPoints => _isLoadingPoints;
  String? get errorMessage => _errorMessage;

  /// Fetch member loyalty profile, tier status, and next tier progress.
  Future<void> fetchLoyalty({bool silent = false}) async {
    if (!silent) {
      _isLoadingLoyalty = true;
      notifyListeners();
    }

    try {
      _loyalty = await _loyaltyService.getMyLoyalty();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingLoyalty = false;
      notifyListeners();
    }
  }

  /// Fetch available coupons in Coupon Center ("领券中心").
  Future<void> fetchAvailableCoupons({bool silent = false}) async {
    if (!silent) {
      _isLoadingCoupons = true;
      notifyListeners();
    }

    try {
      _availableCoupons = await _loyaltyService.getAvailableCoupons();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingCoupons = false;
      notifyListeners();
    }
  }

  /// Claim a voucher into user wallet (领券 action).
  Future<Map<String, dynamic>> claimCoupon(String promotionId) async {
    final result = await _loyaltyService.claimCoupon(promotionId);
    if (result['success'] == true) {
      // Optimistically update the coupon status in the available list
      final index = _availableCoupons.indexWhere((c) => c.id == promotionId);
      if (index != -1) {
        final current = _availableCoupons[index];
        _availableCoupons[index] = CouponModel(
          id: current.id,
          code: current.code,
          type: current.type,
          discountType: current.discountType,
          value: current.value,
          currencyCode: current.currencyCode,
          maxQuantity: current.maxQuantity,
          targetGroupIds: current.targetGroupIds,
          isGroupRestricted: current.isGroupRestricted,
          claimStatus: 'already_claimed',
          canClaim: false,
        );
      }
      // Refresh my coupons and profile in background
      fetchMyCoupons();
      fetchLoyalty(silent: true);
      notifyListeners();
    }
    return result;
  }

  /// Fetch customer claimed vouchers ("我的优惠券").
  Future<void> fetchMyCoupons({String? status, bool silent = false}) async {
    if (!silent) {
      _isLoadingMyCoupons = true;
      notifyListeners();
    }

    try {
      _myCoupons = await _loyaltyService.getMyCoupons(status: status);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMyCoupons = false;
      notifyListeners();
    }
  }

  /// Fetch points transaction ledger.
  Future<void> fetchPointsHistory({bool silent = false}) async {
    if (!silent) {
      _isLoadingPoints = true;
      notifyListeners();
    }

    try {
      _pointsHistory = await _loyaltyService.getPointsHistory();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingPoints = false;
      notifyListeners();
    }
  }

  /// Clear state on logout
  void reset() {
    _loyalty = null;
    _availableCoupons = [];
    _myCoupons = [];
    _pointsHistory = [];
    _errorMessage = null;
    notifyListeners();
  }
}
