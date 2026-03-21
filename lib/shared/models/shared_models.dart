// Base API response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({required this.success, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJson,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: fromJson != null && json['data'] != null
          ? fromJson(json['data'])
          : null,
    );
  }
}

// User model
class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final String? profileImage;
  final String? collegeName;
  final String? department;
  final String? yearOfStudy;
  final String? programType;
  final String token;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    this.profileImage,
    this.collegeName,
    this.department,
    this.yearOfStudy,
    this.programType,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
      collegeName: json['college_name'] as String?,
      department: json['department'] as String?,
      yearOfStudy: json['year_of_study'] as String?,
      programType: json['program_type'] as String?,
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'mobile': mobile,
      'profile_image': profileImage,
      'college_name': collegeName,
      'department': department,
      'year_of_study': yearOfStudy,
      'program_type': programType,
      'token': token,
    };
  }
}

// Learning stats model
class LearningStats {
  final int coursesEnrolled;
  final int completed;
  final int inProgress;
  final int certificatesEarned;
  final double overallProgress;

  LearningStats({
    required this.coursesEnrolled,
    required this.completed,
    required this.inProgress,
    required this.certificatesEarned,
    required this.overallProgress,
  });

  factory LearningStats.fromJson(Map<String, dynamic> json) {
    return LearningStats(
      coursesEnrolled: json['courses_enrolled'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      inProgress: json['in_progress'] as int? ?? 0,
      certificatesEarned: json['certificates_earned'] as int? ?? 0,
      overallProgress: (json['overall_progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
