/// All BioXplora API endpoint constants
/// Base URL is configured in ApiClient
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ───────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static String sendOtp(String email) => '/auth/send-otp?email=$email';
  static String resendOtp(String email) => '/auth/resend-otp?email=$email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String logout = '/auth/logout';
  static const String firebaseVerify = '/auth/firebase-verify';

  // ─── Student ─────────────────────────────────────────────────────────────
  static const String studentInfo = '/student/info';
  static const String studentProfile = '/student/profile';
  static const String updateProfile = '/student/profile/update';
  static const String profileImage = '/student/profile/image';
  static const String myLearning = '/student/my-learning';
  static const String continueLearning = '/student/continue-learning';
  static const String certificates = '/student/certificates';
  static const String paymentHistory = '/student/payment-history';
  static const String studentStats = '/student/stats';
  static const String downloads = '/student/downloads';

  static String certificateDetail(dynamic id) => '/student/certificates/$id';

  // ─── Courses & Internships ───────────────────────────────────────────────
  static const String internships = '/internships';
  static const String courses = '/courses';
  static const String search = '/search';

  static String internshipDetail(dynamic id) => '/internships/$id';
  static String courseDetail(dynamic id) => '/courses/$id';

  // ─── Career Paths ────────────────────────────────────────────────────────
  static const String careerPaths = '/career-paths';
  static String careerPathDetail(dynamic id) => '/career-paths/$id';

  // ─── Enrollments ────────────────────────────────────────────────────────
  static const String enrollments = '/enrollments';
  static String enrollmentProgress(dynamic id) => '/enrollments/$id/progress';

  // ─── Modules & Lessons ──────────────────────────────────────────────────
  static String moduleDetail(dynamic courseId, dynamic moduleId) =>
      '/courses/$courseId/modules/$moduleId';
  static String lessonDetail(dynamic moduleId, dynamic lessonId) =>
      '/modules/$moduleId/lessons/$lessonId';
  static String lessonComplete(dynamic lessonId) => '/lessons/$lessonId/complete';
  static String lessonProgress(dynamic lessonId) => '/lessons/$lessonId/progress';

  // ─── Quiz ────────────────────────────────────────────────────────────────
  static String moduleQuiz(dynamic moduleId) => '/modules/$moduleId/quiz';
  static String submitQuiz(dynamic quizId) => '/quiz/$quizId/submit';
  static String quizResult(dynamic attemptId) => '/quiz/attempt/$attemptId/result';
  static String reviewAnswers(dynamic attemptId) => '/quiz/attempt/$attemptId/review';

  // ─── Cart ────────────────────────────────────────────────────────────────
  static const String cart = '/cart';
  static String removeFromCart(dynamic cartItemId) => '/cart/$cartItemId';

  // ─── Wishlist ─────────────────────────────────────────────────────────────
  static const String wishlist = '/wishlist';
  static String addToWishlist(dynamic courseId) => '/wishlist/$courseId';
  static String removeFromWishlist(dynamic courseId) => '/wishlist/$courseId';

  // ─── Checkout & Payment ──────────────────────────────────────────────────
  static const String checkout = '/checkout';
  static const String paymentVerify = '/payment/verify';

  // ─── Notifications ──────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static String markNotificationRead(dynamic id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
}
