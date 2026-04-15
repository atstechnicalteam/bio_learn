/// API Integration Guide
///
/// This file serves as documentation for how to use the new API services
/// created for the BioXplora app.
library;

// ═══════════════════════════════════════════════════════════════════════════
// 1. AUTHENTICATION SERVICE
// ═══════════════════════════════════════════════════════════════════════════

/*
import 'package:bio_xplora_portal/core/network/auth_service.dart';

final authService = AuthService();

// Register new user
final registerResult = await authService.register(
  fullName: 'John Doe',
  email: 'john@example.com',
  mobile: '9876543210',
  password: 'password123',
  confirmPassword: 'password123',
);

if (registerResult.success) {
  // Registration successful - proceed to OTP verification
  print('OTP sent to email');
} else {
  // Show error
  print(registerResult.getErrorMessage());
}

// Verify OTP
final otpResult = await authService.verifyOTP(
  email: 'john@example.com',
  otp: '1234',
);

if (otpResult.success) {
  print('Email verified');
} else {
  print(otpResult.getErrorMessage());
}

// Login
final loginResult = await authService.login(
  mobile: '9876543210',
  password: 'password123',
);

if (loginResult.success) {
  final user = loginResult.data;
  print('Logged in: ${user?.fullName}');
  // Token is automatically saved
} else {
  print(loginResult.getErrorMessage());
}

// Forgot password
final forgotResult = await authService.forgotPassword(mobile: '9876543210');

// Reset password
final resetResult = await authService.resetPassword(
  mobile: '9876543210',
  otp: '1234',
  newPassword: 'newpassword123',
);

// Logout
final logoutResult = await authService.logout();
*/

// ═══════════════════════════════════════════════════════════════════════════
// 2. COURSE SERVICE
// ═══════════════════════════════════════════════════════════════════════════

/*
import 'package:bio_xplora_portal/core/network/course_service.dart';

final courseService = CourseService();

// Get all internships
final internshipResult = await courseService.getInternships();
if (internshipResult.success) {
  final internships = internshipResult.data ?? [];
  print('Found ${internships.length} internships');
  for (final internship in internships) {
    print('${internship.title} - ₹${internship.priceOptions.first.price}');
  }
}

// Get all courses
final courseResult = await courseService.getCourses();
if (courseResult.success) {
  final courses = courseResult.data ?? [];
  print('Found ${courses.length} courses');
}

// Get internship detail
final detailResult = await courseService.getInternshipDetail('1');
if (detailResult.success) {
  final internship = detailResult.data;
  print('${internship?.title}');
  print('Rating: ${internship?.rating}');
  print('Enrolled: ${internship?.studentsEnrolled}');
}

// Search courses
final searchResult = await courseService.search(
  query: 'medical coding',
  type: 'course',
);

// Get career paths
final careerResult = await courseService.getCareerPaths();
if (careerResult.success) {
  final paths = careerResult.data ?? [];
  for (final path in paths) {
    print('${path.title} - ₹${path.salaryRange}');
  }
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// 3. LEARNING SERVICE
// ═══════════════════════════════════════════════════════════════════════════

/*
import 'package:bio_xplora_portal/core/network/course_service.dart';

final learningService = LearningService();

// Get my enrolled courses (my learning)
final myLearningResult = await learningService.getMyLearning();
if (myLearningResult.success) {
  final enrollments = myLearningResult.data ?? [];
  for (final enrollment in enrollments) {
    print('${enrollment.courseName}: ${(enrollment.progress * 100).toStringAsFixed(0)}%');
  }
}

// Get enrollment progress
final progressResult = await learningService.getEnrollmentProgress('enrollment_id_5');
if (progressResult.success) {
  final enrollment = progressResult.data;
  print('Progress: ${enrollment?.progress}');
  print('Completed ${enrollment?.doneLessons} of ${enrollment?.totalLessons} lessons');
}

// Get module detail
final moduleResult = await learningService.getModuleDetail('course_1', 'module_1');
if (moduleResult.success) {
  final module = moduleResult.data;
  print('Module: ${module?.title}');
  for (final lesson in module?.lessons ?? []) {
    print('  - ${lesson.title} (${lesson.durationSeconds}s)');
  }
}

// Get lesson detail
final lessonResult = await learningService.getLessonDetail('module_1', 'lesson_1');

// Mark lesson complete
final completeResult = await learningService.markLessonComplete(
  lessonId: 'lesson_1',
  enrollmentId: 'enrollment_5',
);

// Update lesson watch progress
final progressUpdateResult = await learningService.updateLessonProgress(
  lessonId: 'lesson_1',
  enrollmentId: 'enrollment_5',
  watchTimeSeconds: 245,
);

// Get quiz
final quizResult = await learningService.getQuiz('module_1');
if (quizResult.success) {
  final quiz = quizResult.data;
  print('Quiz: ${quiz?.title}');
  print('Questions: ${quiz?.totalQuestions}');
  print('Time Limit: ${quiz?.timeLimitMinutes} minutes');
  print('Passing: ${quiz?.passingPercentage}%');
  
  for (final question in quiz?.questions ?? []) {
    print('Q: ${question.question}');
    print('  A) ${question.optionA}');
    print('  B) ${question.optionB}');
    print('  C) ${question.optionC}');
    print('  D) ${question.optionD}');
  }
}

// Submit quiz
final submitResult = await learningService.submitQuiz(
  quizId: 'quiz_1',
  enrollmentId: 'enrollment_5',
  answers: [
    {'question_id': '1', 'selected_option': 'a'},
    {'question_id': '2', 'selected_option': 'c'},
  ],
);
if (submitResult.success) {
  final result = submitResult.data;
  print('Score: ${result?.score}/${result?.total}');
  print('Percentage: ${result?.percentage}%');
  print('Passed: ${result?.isPassed}');
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// 4. STUDENT SERVICE
// ═══════════════════════════════════════════════════════════════════════════

/*
import 'package:bio_xplora_portal/core/network/student_service.dart';

final studentService = StudentService();

// Get profile
final profileResult = await studentService.getProfile();
if (profileResult.success) {
  final user = profileResult.data;
  print('Name: ${user?.fullName}');
  print('College: ${user?.collegeName}');
  print('Department: ${user?.department}');
}

// Save student info (after OTP verification)
final saveResult = await studentService.saveStudentInfo(
  collegeName: 'Karpagam College',
  department: 'B.Sc Biotechnology',
  yearOfStudy: '2nd Year',
  programType: 'internship',
);

// Update profile
final updateResult = await studentService.updateProfile(
  fullName: 'Updated Name',
  collegeName: 'New College',
);

// Get certificates
final certificateResult = await studentService.getCertificates();
if (certificateResult.success) {
  final certificates = certificateResult.data ?? [];
  print('Certificates: ${certificates.length}');
}

// Get payment history
final historyResult = await studentService.getPaymentHistory();
if (historyResult.success) {
  final history = historyResult.data ?? [];
  for (final payment in history) {
    print('${payment['course_name']}: ₹${payment['amount']}');
  }
}

// Get continue learning (last accessed)
final continueResult = await studentService.getContinueLearning();
if (continueResult.success) {
  final lastCourse = continueResult.data;
  print('Continue: ${lastCourse?.courseName}');
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// 5. ENROLLMENT SERVICE
// ═══════════════════════════════════════════════════════════════════════════

/*
import 'package:bio_xplora_portal/core/network/student_service.dart';

final enrollmentService = EnrollmentService();

// Get cart
final cartResult = await enrollmentService.getCart();
if (cartResult.success) {
  final items = cartResult.data ?? [];
  print('Cart items: ${items.length}');
}

// Add to cart
final addCartResult = await enrollmentService.addToCart(
  courseId: '1',
  priceOptionId: '3',
);

// Remove from cart
final removeCartResult = await enrollmentService.removeFromCart('cart_item_1');

// Get wishlist
final wishlistResult = await enrollmentService.getWishlist();
if (wishlistResult.success) {
  final items = wishlistResult.data ?? [];
  print('Wishlist items: ${items.length}');
}

// Add to wishlist
final addWishResult = await enrollmentService.addToWishlist('course_1');

// Remove from wishlist
final removeWishResult = await enrollmentService.removeFromWishlist('course_1');

// Checkout
final checkoutResult = await enrollmentService.checkout(
  courseId: '1',
  priceOptionId: '3',
);
if (checkoutResult.success) {
  final checkoutData = checkoutResult.data;
  final orderId = checkoutData?['order_id'];
  final amount = checkoutData?['amount'];
  print('Order: $orderId for ₹$amount');
  // Pass orderId to Razorpay
}

// Verify payment (after Razorpay success)
final verifyResult = await enrollmentService.verifyPayment(
  razorpayOrderId: 'order_xyz123',
  razorpayPaymentId: 'pay_abc456',
  razorpaySignature: 'signature_def789',
);

// Enroll (after payment verification)
final enrollResult = await enrollmentService.enroll(
  courseId: '1',
  priceOptionId: '3',
  paymentMethod: 'razorpay',
  transactionId: 'pay_abc456',
);
if (enrollResult.success) {
  final enrollmentId = enrollResult.data;
  print('Enrolled! ID: $enrollmentId');
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// 6. ERROR HANDLING
// ═══════════════════════════════════════════════════════════════════════════

/*
// All API methods return ApiResponse<T> which has:
// - success: bool
// - message: String?
// - data: T?
// - errors: Map<String, dynamic>?
// - getErrorMessage(): String

// Always check for internet connection before making API calls
import 'package:bio_xplora_portal/core/network/connectivity_checker.dart';

try {
  await ConnectivityChecker.checkConnection();
  final result = await authService.login(...);
  if (result.success) {
    // Handle success
  } else {
    // Show error message
    final errorMsg = result.getErrorMessage();
    showErrorDialog(context, title: 'Error', message: errorMsg);
  }
} catch (e) {
  // Connection error
  showErrorDialog(context, title: 'Connection Error', message: e.toString());
}
*/

// ═══════════════════════════════════════════════════════════════════════════
// 7. VALIDATION UTILITIES
// ═══════════════════════════════════════════════════════════════════════════

/*
import 'package:bio_xplora_portal/core/utils/form_validation.dart';

// Use in form validators
validator: FormValidation.validateEmail,
validator: FormValidation.validatePhone,
validator: FormValidation.validatePassword,
validator: FormValidation.validateOTP,
validator: FormValidation.validateFullName,
validator: FormValidation.validateCollege,

// Or manually
final error = FormValidation.validatePhone('9876543210');
if (error != null) {
  print('Error: $error');
}

// Check password strength
final strengthError = FormValidation.checkPasswordStrength('weak');
*/

// ═══════════════════════════════════════════════════════════════════════════
// 8. SWEET ALERT DIALOGS
// ═══════════════════════════════════════════════════════════════════════════

/*
import 'package:bio_xplora_portal/shared/widgets/shared_widgets.dart';

// Success dialog
await showSuccessDialog(
  context,
  title: 'Success',
  message: 'Registered successfully!',
  buttonText: 'OK',
  onPressed: () {
    // Custom callback
  },
);

// Error dialog
await showErrorDialog(
  context,
  title: 'Error',
  message: 'Something went wrong',
);

// Warning dialog with confirmation
await showWarningDialog(
  context,
  title: 'Are you sure?',
  message: 'Do you want to proceed?',
  confirmText: 'Yes',
  cancelText: 'No',
  onConfirm: () {
    // Handle confirmation
  },
  onCancel: () {
    // Handle cancellation
  },
);

// Info dialog
await showInfoDialog(
  context,
  title: 'Info',
  message: 'Important information',
);
*/

class ApiIntegrationGuide {}
