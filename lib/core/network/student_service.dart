import 'api_client.dart';
import 'api_endpoints.dart';
import 'connectivity_checker.dart';
import '../../shared/models/shared_models.dart';
import '../../shared/models/api_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// StudentService – profile, learning, certificates, stats, downloads
// ═══════════════════════════════════════════════════════════════════════════

class StudentService {
  StudentService._();
  static final StudentService _instance = StudentService._();
  factory StudentService() => _instance;

  final _api = ApiClient();

  // ─── Profile ──────────────────────────────────────────────────────────────

  /// Fetch the current student's profile.
  Future<ApiResponse<UserData>> getProfile() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.studentProfile);
      return ApiResponse<UserData>.fromJson(
        res,
        (data) => UserData.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<UserData>(success: false, message: e.toString());
    }
  }

  /// Save student academic info (called once after OTP verification / first login).
  Future<ApiResponse<void>> saveStudentInfo({
    required String collegeName,
    required String department,
    required String yearOfStudy,
    required String programType,
  }) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(
        ApiEndpoints.studentInfo,
        body: {
          'college_name': collegeName,
          'department': department,
          'year_of_study': yearOfStudy,
          'program_type': programType,
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

  /// Update name / college / email etc.
  Future<ApiResponse<void>> updateProfile(Map<String, dynamic> fields) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(ApiEndpoints.updateProfile, body: fields);
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  /// Upload a profile image (multipart/form-data).
  /// [imagePath] is the local file path on the device.
  Future<ApiResponse<void>> uploadProfileImage(String imagePath) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.multipart(
        ApiEndpoints.profileImage,
        fileFieldName: 'image',
        filePath: imagePath,
      );
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Learning ─────────────────────────────────────────────────────────────

  /// All enrolled courses with progress info.
  Future<ApiResponse<List<EnrollmentModel>>> getMyLearning() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.myLearning);
      final list = (res['data'] as List?)
              ?.map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return ApiResponse<List<EnrollmentModel>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<EnrollmentModel>>(success: false, message: e.toString());
    }
  }

  /// The last accessed course (used for "Continue Learning" on home screen).
  Future<ApiResponse<EnrollmentModel>> getContinueLearning() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.continueLearning);
      return ApiResponse<EnrollmentModel>.fromJson(
        res,
        (data) => EnrollmentModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<EnrollmentModel>(success: false, message: e.toString());
    }
  }

  // ─── Certificates ─────────────────────────────────────────────────────────

  /// List all earned certificates.
  Future<ApiResponse<List<Map<String, dynamic>>>> getCertificates() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.certificates);
      final list = (res['data'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      return ApiResponse<List<Map<String, dynamic>>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(success: false, message: e.toString());
    }
  }

  /// Detail of a single certificate by [id].
  Future<ApiResponse<Map<String, dynamic>>> getCertificateDetail(String id) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.certificateDetail(id));
      return ApiResponse<Map<String, dynamic>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: res['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(success: false, message: e.toString());
    }
  }

  // ─── History / Stats ──────────────────────────────────────────────────────

  /// List of all past payments.
  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentHistory() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.paymentHistory);
      final list = (res['data'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      return ApiResponse<List<Map<String, dynamic>>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(success: false, message: e.toString());
    }
  }

  /// Aggregated learning stats (enrolled, completed, in-progress, certificates).
  Future<ApiResponse<Map<String, dynamic>>> getStats() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.studentStats);
      return ApiResponse<Map<String, dynamic>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: res['data'] as Map<String, dynamic>?,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(success: false, message: e.toString());
    }
  }

  /// Completed video lessons available for offline access.
  Future<ApiResponse<List<Map<String, dynamic>>>> getDownloads() async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.downloads);
      final list = (res['data'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      return ApiResponse<List<Map<String, dynamic>>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<Map<String, dynamic>>>(success: false, message: e.toString());
    }
  }

  // ─── Enrollment & Progress ────────────────────────────────────────────────

  /// Enroll after payment. Returns the new enrollment ID.
  Future<ApiResponse<String>> enrollInCourse({
    required int courseId,
    required int priceOptionId,
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(
        ApiEndpoints.enrollments,
        body: {
          'course_id': courseId,
          'price_option_id': priceOptionId,
          'payment_method': paymentMethod,
          'transaction_id': transactionId,
        },
      );
      final enrollmentId = (res['data'] as Map?)?['enrollment_id']?.toString() ?? '';
      return ApiResponse<String>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: enrollmentId,
      );
    } catch (e) {
      return ApiResponse<String>(success: false, message: e.toString());
    }
  }

  /// Progress summary for an enrollment (modules, lesson counts, overall %).
  Future<ApiResponse<EnrollmentProgressModel>> getEnrollmentProgress(int enrollmentId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.enrollmentProgress(enrollmentId));
      return ApiResponse<EnrollmentProgressModel>.fromJson(
        res,
        (data) => EnrollmentProgressModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<EnrollmentProgressModel>(success: false, message: e.toString());
    }
  }

  // ─── Modules & Lessons ────────────────────────────────────────────────────

  Future<ApiResponse<ModuleDetailModel>> getModuleDetail(int courseId, int moduleId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.moduleDetail(courseId, moduleId));
      return ApiResponse<ModuleDetailModel>.fromJson(
        res,
        (data) => ModuleDetailModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<ModuleDetailModel>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<LessonDetailModel>> getLessonDetail(int moduleId, int lessonId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.lessonDetail(moduleId, lessonId));
      return ApiResponse<LessonDetailModel>.fromJson(
        res,
        (data) => LessonDetailModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<LessonDetailModel>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<void>> markLessonComplete(int lessonId, int enrollmentId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(
        ApiEndpoints.lessonComplete(lessonId),
        body: {'enrollment_id': enrollmentId},
      );
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<void>> updateLessonProgress(
    int lessonId,
    int enrollmentId,
    int watchTimeSeconds,
  ) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(
        ApiEndpoints.lessonProgress(lessonId),
        body: {'enrollment_id': enrollmentId, 'watch_time_seconds': watchTimeSeconds},
      );
      return ApiResponse<void>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
      );
    } catch (e) {
      return ApiResponse<void>(success: false, message: e.toString());
    }
  }

  // ─── Quiz ─────────────────────────────────────────────────────────────────

  /// Fetch quiz questions for a module (correct_option is NOT included).
  Future<ApiResponse<QuizModel>> getQuiz(int moduleId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.moduleQuiz(moduleId));
      return ApiResponse<QuizModel>.fromJson(
        res,
        (data) => QuizModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<QuizModel>(success: false, message: e.toString());
    }
  }

  /// Submit quiz answers. Returns score + pass/fail + attempt_id.
  /// Save attempt_id to later call getQuizResult / reviewAnswers.
  Future<ApiResponse<QuizResultModel>> submitQuiz(
    int quizId,
    int enrollmentId,
    List<Map<String, dynamic>> answers,
  ) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.post(
        ApiEndpoints.submitQuiz(quizId),
        body: {'enrollment_id': enrollmentId, 'answers': answers},
      );
      return ApiResponse<QuizResultModel>.fromJson(
        res,
        (data) => QuizResultModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<QuizResultModel>(success: false, message: e.toString());
    }
  }

  /// Score details + certificate (if all modules passed).
  Future<ApiResponse<QuizResultModel>> getQuizResult(int attemptId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.quizResult(attemptId));
      return ApiResponse<QuizResultModel>.fromJson(
        res,
        (data) => QuizResultModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse<QuizResultModel>(success: false, message: e.toString());
    }
  }

  /// Correct answers + explanations for review screen.
  Future<ApiResponse<List<QuizReviewModel>>> reviewQuizAnswers(int attemptId) async {
    try {
      await ConnectivityChecker.checkConnection();
      final res = await _api.get(ApiEndpoints.reviewAnswers(attemptId));
      final list = (res['data'] as List?)
              ?.map((e) => QuizReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      return ApiResponse<List<QuizReviewModel>>(
        success: res['success'] as bool? ?? false,
        message: res['message'] as String?,
        data: list,
      );
    } catch (e) {
      return ApiResponse<List<QuizReviewModel>>(success: false, message: e.toString());
    }
  }
}
