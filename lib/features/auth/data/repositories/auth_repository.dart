import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/models/shared_models.dart';
import '../models/auth_models.dart';

abstract class AuthRepository {
  Future<UserModel> login(LoginRequestModel request);
  Future<void> register(RegisterRequestModel request);
  Future<void> sendOtp(String mobile);
  Future<UserModel> verifyOtp(OtpRequestModel request);
  Future<void> resendOtp(String mobile);
  Future<void> saveStudentInfo(StudentInfoRequestModel request);
  Future<void> logout();
  Future<void> forgotPassword(String mobile);
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<UserModel> login(LoginRequestModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: request.toJson(),
      requiresAuth: false,
    );
    final user = UserModel.fromJson(response['data'] as Map<String, dynamic>);
    await _apiClient.saveToken(user.token);
    return user;
  }

  @override
  Future<void> register(RegisterRequestModel request) async {
    await _apiClient.post(
      ApiEndpoints.register,
      body: request.toJson(),
      requiresAuth: false,
    );
  }

  @override
  Future<void> sendOtp(String mobile) async {
    await _apiClient.post(
      ApiEndpoints.sendOtp,
      body: {'mobile': mobile},
      requiresAuth: false,
    );
  }

  @override
  Future<UserModel> verifyOtp(OtpRequestModel request) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      body: request.toJson(),
      requiresAuth: false,
    );
    final user = UserModel.fromJson(response['data'] as Map<String, dynamic>);
    await _apiClient.saveToken(user.token);
    return user;
  }

  @override
  Future<void> resendOtp(String mobile) async {
    await _apiClient.post(
      ApiEndpoints.resendOtp,
      body: {'mobile': mobile},
      requiresAuth: false,
    );
  }

  @override
  Future<void> saveStudentInfo(StudentInfoRequestModel request) async {
    await _apiClient.post(
      ApiEndpoints.studentInfo,
      body: request.toJson(),
    );
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout, body: {});
    } finally {
      await _apiClient.clearToken();
    }
  }

  @override
  Future<void> forgotPassword(String mobile) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      body: {'mobile': mobile},
      requiresAuth: false,
    );
  }
}
