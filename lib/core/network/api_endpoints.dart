class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';

  // Student
  static const String studentInfo = '/student/info';
  static const String studentProfile = '/student/profile';
  static const String updateProfile = '/student/profile/update';

  // Home
  static const String internships = '/internships';
  static const String courses = '/courses';
  static const String careerPaths = '/career-paths';
  static const String continueLearning = '/student/continue-learning';

  // Internship / Course detail
  static String internshipDetail(String id) => '/internships/$id';
  static String courseDetail(String id) => '/courses/$id';
  static String careerPathDetail(String id) => '/career-paths/$id';

  // Enroll
  static const String enroll = '/enrollments';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static String addToWishlist(String id) => '/wishlist/$id';
  static String removeFromWishlist(String id) => '/wishlist/$id';

  // Checkout
  static const String checkout = '/checkout';
  static const String payment = '/payment';

  // Learning
  static const String myLearning = '/student/my-learning';
  static String courseProgress(String enrollmentId) => '/enrollments/$enrollmentId/progress';
  static String moduleDetail(String courseId, String moduleId) =>
      '/courses/$courseId/modules/$moduleId';
  static String lessonDetail(String moduleId, String lessonId) =>
      '/modules/$moduleId/lessons/$lessonId';
  static String markLessonComplete(String lessonId) => '/lessons/$lessonId/complete';

  // Quiz
  static String moduleQuiz(String moduleId) => '/modules/$moduleId/quiz';
  static String submitQuiz(String quizId) => '/quiz/$quizId/submit';
  static String quizResult(String quizId) => '/quiz/$quizId/result';
  static String reviewAnswers(String quizId) => '/quiz/$quizId/review';

  // Notifications
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // Profile
  static const String certificates = '/student/certificates';
  static String certificateDetail(String id) => '/student/certificates/$id';
  static const String paymentHistory = '/student/payment-history';
  static const String downloads = '/student/downloads';

  // Search
  static const String search = '/search';
}
