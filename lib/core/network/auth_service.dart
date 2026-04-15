import 'api_client.dart';
import 'api_endpoints.dart';
import 'connectivity_checker.dart';
import '../../shared/models/shared_models.dart';
import '../../shared/models/api_models.dart';

/// Handles all authentication-related API calls.
///
/// Singleton – access via AuthService().
class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  final _api = ApiClient();

  // ─── Register ─────────────────────────────────────────────────────────────

  /// Register a new student account.
  /// On success the user must verify via OTP before logging in.
  Future<ApiResponse<UserData>> register({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final res = await _api.post(
        ApiEndpoints.register,
        body: {
          'full_name': fullName,
          'email': email,
          'mobile': mobile,
          'password': password,
          'confirm_password': confirmPassword,
        },
        requiresAuth: false,
      );
      return ApiResponse<UserData>.fromJson(
        res,
        (data) => UserData.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<UserData>(success: false, message: e.toString());
    }
  }

  // ─── OTP ──────────────────────────────────────────────────────────────────

  /// Verify the 4-digit OTP sent to the user's email after registration.
  Future<ApiResponse<void>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final res = await _api.post(
        ApiEndpoints.verifyOtp,
        body: {'email': email, 'otp': otp},
        requiresAuth: false,
      );
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  /// Request a new OTP to be sent to the user's email.
  Future<ApiResponse<void>> resendOTP({required String email}) async {
    try {
      final res = await _api.post(
        ApiEndpoints.resendOtp(email),
        requiresAuth: false,
      );
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Login / Logout ───────────────────────────────────────────────────────

  /// Login with mobile + password.
  /// Saves JWT token to secure storage on success.
  Future<ApiResponse<UserData>> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final res = await _api.post(
        ApiEndpoints.login,
        body: {'mobile': mobile, 'password': password},
        requiresAuth: false,
      );
      final result = ApiResponse<UserData>.fromJson(
        res,
        (data) => UserData.fromJson(data as Map<String, dynamic>),
      );
      if (result.success && result.data?.token != null) {
        await _api.saveToken(result.data!.token!);
      }
      return result;
    } catch (e) {
      return ApiResponse<UserData>(success: false, message: e.toString());
    }
  }

  /// Logout the current user and clear the stored token.
  Future<ApiResponse<void>> logout() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(ApiEndpoints.logout, requiresAuth: true);
      await _api.clearToken(); // always clear locally
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      await _api.clearToken(); // clear even on error
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Password ─────────────────────────────────────────────────────────────

  /// Request a password-reset OTP via mobile number.
  Future<ApiResponse<void>> forgotPassword({required String mobile}) async {
    try {
      final res = await _api.post(
        ApiEndpoints.forgotPassword,
        body: {'mobile': mobile},
        requiresAuth: false,
      );
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  /// Reset password using the OTP received on mobile.
  Future<ApiResponse<void>> resetPassword({
    required String mobile,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final res = await _api.post(
        ApiEndpoints.resetPassword,
        body: {'mobile': mobile, 'otp': otp, 'new_password': newPassword},
        requiresAuth: false,
      );
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Firebase ─────────────────────────────────────────────────────────────

  /// Verify a Firebase phone-auth ID token and get BioXplora JWT.
  /// Flutter: final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  Future<ApiResponse<UserData>> firebaseVerify({required String idToken}) async {
    try {
      final res = await _api.post(
        ApiEndpoints.firebaseVerify,
        body: {'id_token': idToken},
        requiresAuth: false,
      );
      final result = ApiResponse<UserData>.fromJson(
        res,
        (data) => UserData.fromJson(data as Map<String, dynamic>),
      );
      if (result.success && result.data?.token != null) {
        await _api.saveToken(result.data!.token!);
      }
      return result;
    } catch (e) {
      return ApiResponse<UserData>(success: false, message: e.toString());
    }
  }
}
