import 'package:bio_xplora_portal/shared/models/shared_models.dart';
import 'package:bio_xplora_portal/shared/models/api_models.dart';
import 'package:bio_xplora_portal/core/network/api_client.dart';
import 'package:bio_xplora_portal/core/network/api_endpoints.dart';
import 'package:bio_xplora_portal/core/network/connectivity_checker.dart';

class CourseService {
  CourseService._();
  static final CourseService _instance = CourseService._();
  factory CourseService() => _instance;

  final _api = ApiClient();

  // ─── Listings ─────────────────────────────────────────────────────────────

  Future<ApiResponse<List<CourseModel>>> getInternships() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.internships);
      return _toCourseList(res);
    } catch (e) {
      return ApiResponse<List<CourseModel>>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<List<CourseModel>>> getCourses() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.courses);
      return _toCourseList(res);
    } catch (e) {
      return ApiResponse<List<CourseModel>>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<CourseDetailModel>> getInternshipDetail(int id) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.internshipDetail(id));
      return ApiResponse<CourseDetailModel>.fromJson(
        res,
        (data) => CourseDetailModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<CourseDetailModel>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<CourseDetailModel>> getCourseDetail(int id) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.courseDetail(id));
      return ApiResponse<CourseDetailModel>.fromJson(
        res,
        (data) => CourseDetailModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<CourseDetailModel>(success: false, message: e.toString());
    }
  }

  /// [type] must be "course" or "internship".
  Future<ApiResponse<List<CourseModel>>> search(String query, {String type = 'course'}) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.search, queryParams: {'q': query, 'type': type});
      return _toCourseList(res);
    } catch (e) {
      return ApiResponse<List<CourseModel>>(success: false, message: e.toString());
    }
  }

  // ─── Career Paths ─────────────────────────────────────────────────────────

  Future<ApiResponse<List<CareerPathModel>>> getCareerPaths() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.careerPaths);
      final list = (res['data'] as List?)
              ?.map((e) => CareerPathModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return ApiResponse<List<CareerPathModel>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<CareerPathModel>>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<CareerPathDetailModel>> getCareerPathDetail(int id) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.careerPathDetail(id));
      return ApiResponse<CareerPathDetailModel>.fromJson(
        res,
        (data) => CareerPathDetailModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<CareerPathDetailModel>(success: false, message: e.toString());
    }
  }

  // ─── Cart ─────────────────────────────────────────────────────────────────

  Future<ApiResponse<List<CartItemModel>>> getCart() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.cart);
      final list = (res['data'] as List?)
              ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return ApiResponse<List<CartItemModel>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<CartItemModel>>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<void>> addToCart(int courseId, int priceOptionId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(
        ApiEndpoints.cart,
        body: {'course_id': courseId, 'price_option_id': priceOptionId},
      );
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<void>> removeFromCart(int cartItemId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.delete(ApiEndpoints.removeFromCart(cartItemId));
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Wishlist ─────────────────────────────────────────────────────────────

  Future<ApiResponse<List<CourseModel>>> getWishlist() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.wishlist);
      return _toCourseList(res);
    } catch (e) {
      return ApiResponse<List<CourseModel>>(success: false, message: e.toString());
    }
  }

  /// POST /wishlist/{id}
  Future<ApiResponse<void>> addToWishlist(int courseId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(ApiEndpoints.addToWishlist(courseId));
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  /// DELETE /wishlist/{id}
  Future<ApiResponse<void>> removeFromWishlist(int courseId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.delete(ApiEndpoints.removeFromWishlist(courseId));
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Checkout & Payment ───────────────────────────────────────────────────

  /// Initiate checkout – returns Razorpay order_id + amount.
  Future<ApiResponse<CheckoutModel>> initiateCheckout(int courseId, int priceOptionId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(
        ApiEndpoints.checkout,
        body: {'course_id': courseId, 'price_option_id': priceOptionId},
      );
      return ApiResponse<CheckoutModel>.fromJson(
        res,
        (data) => CheckoutModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<CheckoutModel>(success: false, message: e.toString());
    }
  }

  /// Verify Razorpay payment signature after SDK success callback.
  Future<ApiResponse<void>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(
        ApiEndpoints.paymentVerify,
        body: {
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
      );
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Notifications ────────────────────────────────────────────────────────

  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.notifications);
      final list = (res['data'] as List?)
              ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return ApiResponse<List<NotificationModel>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<NotificationModel>>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<void>> markNotificationAsRead(int notificationId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(ApiEndpoints.markNotificationRead(notificationId));
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<void>> markAllNotificationsAsRead() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(ApiEndpoints.markAllNotificationsRead);
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  ApiResponse<List<CourseModel>> _toCourseList(Map<String, dynamic> res) {
    final list = (res['data'] as List?)
            ?.map((e) => CourseModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return ApiResponse<List<CourseModel>>(
      success: res['success'] as bool? ?? false,
      message: res['message'] as String?,
      data: list,
    );
  }
}
