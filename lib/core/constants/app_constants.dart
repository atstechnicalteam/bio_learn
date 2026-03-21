import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF0A0F5C); // Dark Navy Blue
  static const Color primaryLight = Color(0xFF1A2080);
  static const Color primaryDark = Color(0xFF06093A);

  // Accent / Secondary
  static const Color accent = Color(0xFF4DC8E8); // Cyan/Light Blue
  static const Color accentLight = Color(0xFFB3E8F5);
  static const Color authOutline = Color(0xFF2C8CFF);

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF5F6FA);
  static const Color cardBackground = Color(0xFFF0F4FF);

  // Text
  static const Color textPrimary = Color(0xFF0A0F5C);
  static const Color textSecondary = Color(0xFF8C95A8);
  static const Color textHint = Color(0xFFAAB3C3);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Border
  static const Color border = Color(0xFFE6EAF2);
  static const Color borderFocused = Color(0xFF0A0F5C);

  // Divider
  static const Color divider = Color(0xFFE9EDF4);

  // Bottom Nav
  static const Color bottomNavActive = Color(0xFF0A0F5C);
  static const Color bottomNavInactive = Color(0xFFADB5BD);

  // Splash / dark bg
  static const Color splashDark = Color(0xFF010B45);

  // Progress
  static const Color progressFg = Color(0xFF0A0F5C);
  static const Color progressBg = Color(0xFFE5E7EB);

  // Career path badge
  static const Color highDemandBg = Color(0xFFDCFCE7);
  static const Color highDemandText = Color(0xFF16A34A);
}

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Poppins';

  static const TextStyle headingXL = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headingLG = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle headingMD = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle headingSM = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLG = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMD = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySM = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelMD = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.3,
  );

  static const TextStyle authTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle authSubtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle formLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle formInput = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle formHint = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.3,
  );

  static const TextStyle helperText = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.3,
  );

  static const TextStyle authLink = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
  );

  static const TextStyle authButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    height: 1.2,
  );
}

class AppSizes {
  AppSizes._();

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;

  // Icon
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;

  // Button
  static const double buttonHeight = 48.0;
  static const double buttonRadius = 8.0;

  // Input
  static const double inputHeight = 48.0;
  static const double inputRadius = 8.0;

  // Bottom Nav
  static const double bottomNavHeight = 70.0;
}

class AppStrings {
  AppStrings._();

  static const String appName = 'BioXplora';
  static const String tagline = 'Exploring the bio era..';
  static const String login = 'Login';
  static const String createAccount = 'Create Account';
  static const String mobileNumber = 'Mobile Number';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot password?';
  static const String or = 'OR';
  static const String newToBioxplora = 'New to Bioxplora?';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String sendOtp = 'Send OTP';
  static const String verifyAccount = 'Verify Account';
  static const String verifyAndContinue = 'Verify & Continue';
  static const String resend = 'Resend';
  static const String studentInformation = 'Student Information';
  static const String continueText = 'Continue';
  static const String home = 'Home';
  static const String wishlist = 'Wish list';
  static const String myLearning = 'My Learning';
  static const String notifications = 'Notifications';
  static const String profile = 'Profile';
  static const String internships = 'Internships';
  static const String courses = 'Courses';
  static const String careerPaths = 'Career Paths';
  static const String continueLearning = 'Continue Learning';
  static const String viewDetails = 'View Details';
  static const String explorePath = 'Explore Path';
  static const String enrollNow = 'Enroll Now';
  static const String addToCart = 'Add to Cart';
  static const String addToWishlist = 'Add to Wishlist';
  static const String checkout = 'Checkout';
  static const String quizResult = 'Quiz Result';
  static const String reviewAnswers = 'Review Answers';
}

class AppAssets {
  AppAssets._();

  static const String bioLogo = 'assets/biologo.png';
}
