import 'package:dio/dio.dart';
import 'package:pasar_now/models/loyalty_model.dart';
import 'api_service.dart';

class LoyaltyService {
  final ApiService _api = ApiService();

  /// Fetches the authenticated customer's loyalty profile, current tier, and next tier progression.
  Future<CustomerLoyaltyModel?> getMyLoyalty() async {
    try {
      final response = await _api.client.get('/store/loyalty/me');
      if (response.statusCode == 200 && response.data['loyalty'] != null) {
        return CustomerLoyaltyModel.fromJson(response.data['loyalty']);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Guest user or session not authenticated
        return null;
      }
      rethrow;
    } catch (e) {
      return null;
    }
  }

  /// Fetches points audit history (ledger transactions).
  Future<List<PointsTransactionModel>> getPointsHistory() async {
    try {
      final response = await _api.client.get('/store/loyalty/points/history');
      if (response.statusCode == 200 && response.data['transactions'] != null) {
        final List<dynamic> list = response.data['transactions'];
        return list.map((json) => PointsTransactionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Fetches available coupons for the Coupon Center (领券中心) with tier eligibility.
  Future<List<CouponModel>> getAvailableCoupons() async {
    try {
      final response = await _api.client.get('/store/loyalty/coupons');
      if (response.statusCode == 200 && response.data['coupons'] != null) {
        final List<dynamic> list = response.data['coupons'];
        return list.map((json) => CouponModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Claims a voucher into the user's wallet (领券 action).
  Future<Map<String, dynamic>> claimCoupon(String promotionId) async {
    try {
      final response = await _api.client.post('/store/loyalty/coupons/$promotionId/claim');
      return {
        'success': true,
        'message': response.data['message'] ?? 'Coupon claimed successfully!',
        'user_coupon': response.data['user_coupon'],
      };
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to claim coupon';
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Fetches claimed vouchers in user's wallet ("我的优惠券").
  Future<List<UserCouponModel>> getMyCoupons({String? status}) async {
    try {
      final queryParams = status != null ? {'status': status} : null;
      final response = await _api.client.get(
        '/store/loyalty/my-coupons',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200 && response.data['coupons'] != null) {
        final List<dynamic> list = response.data['coupons'];
        return list.map((json) => UserCouponModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
