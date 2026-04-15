/// User/Auth Models
class UserData {
  final String? id;
  final String? fullName;
  final String? email;
  final String? mobile;
  final String? collegeName;
  final String? department;
  final String? yearOfStudy;
  final String? programType;
  final String? token;
  final String? profileImage;

  UserData({
    this.id,
    this.fullName,
    this.email,
    this.mobile,
    this.collegeName,
    this.department,
    this.yearOfStudy,
    this.programType,
    this.token,
    this.profileImage,
  });

  /// Factory constructor to parse JSON
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString(),
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
      collegeName: json['college_name'] as String?,
      department: json['department'] as String?,
      yearOfStudy: json['year_of_study'] as String?,
      programType: json['program_type'] as String?,
      token: json['token'] as String?,
      profileImage: json['profile_image'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'email': email,
    'mobile': mobile,
    'college_name': collegeName,
    'department': department,
    'year_of_study': yearOfStudy,
    'program_type': programType,
    'token': token,
    'profile_image': profileImage,
  };
}

/// Course/Internship Models
class CourseModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String type; // 'course' or 'internship'
  final String level;
  final String duration;
  final double rating;
  final int studentsEnrolled;
  final List<PriceOption> priceOptions;
  final bool isEnrolled;
  final String? instructor;
  final String? whatYouWillLearn;
  final List<Module>? modules;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.level,
    required this.duration,
    required this.rating,
    required this.studentsEnrolled,
    required this.priceOptions,
    this.isEnrolled = false,
    this.instructor,
    this.whatYouWillLearn,
    this.modules,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      type: json['type'] as String? ?? 'course',
      level: json['level'] as String? ?? 'Beginner',
      duration: json['duration'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      studentsEnrolled: json['students_enrolled'] as int? ?? 0,
      priceOptions:
          (json['price_options'] as List?)
              ?.map((p) => PriceOption.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      isEnrolled: json['is_enrolled'] as bool? ?? false,
      instructor: json['instructor'] as String?,
      whatYouWillLearn: json['what_you_will_learn'] as String?,
      modules: (json['modules'] as List?)
          ?.map((m) => Module.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PriceOption {
  final String id;
  final String duration;
  final double price;
  final double? originalPrice;
  final bool isMostPopular;

  PriceOption({
    required this.id,
    required this.duration,
    required this.price,
    this.originalPrice,
    this.isMostPopular = false,
  });

  factory PriceOption.fromJson(Map<String, dynamic> json) {
    return PriceOption(
      id: json['id']?.toString() ?? '',
      duration: json['duration'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      isMostPopular: json['is_most_popular'] as bool? ?? false,
    );
  }
}

/// Module and Lesson Models
class Module {
  final String id;
  final String title;
  final List<Lesson>? lessons;
  final Quiz? quiz;
  final int? lessonsCount;
  final int? completedLessons;

  Module({
    required this.id,
    required this.title,
    this.lessons,
    this.quiz,
    this.lessonsCount,
    this.completedLessons,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      lessons: (json['lessons'] as List?)
          ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
          .toList(),
      quiz: json['quiz'] != null
          ? Quiz.fromJson(json['quiz'] as Map<String, dynamic>)
          : null,
      lessonsCount: json['lessons_count'] as int?,
      completedLessons: json['completed_lessons'] as int?,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String videoUrl;
  final int durationSeconds;
  final bool isCompleted;
  final String? description;
  final String? watchProgress; // seconds watched

  Lesson({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.durationSeconds,
    this.isCompleted = false,
    this.description,
    this.watchProgress,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      description: json['description'] as String?,
      watchProgress: json['watch_progress']?.toString(),
    );
  }
}

/// Quiz Models
class Quiz {
  final String id;
  final String title;
  final int totalQuestions;
  final int timeLimitMinutes;
  final int passingPercentage;
  final List<Question>? questions;

  Quiz({
    required this.id,
    required this.title,
    required this.totalQuestions,
    required this.timeLimitMinutes,
    required this.passingPercentage,
    this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      totalQuestions: json['total_questions'] as int? ?? 0,
      timeLimitMinutes: json['time_limit_minutes'] as int? ?? 0,
      passingPercentage: json['passing_percentage'] as int? ?? 70,
      questions: (json['questions'] as List?)
          ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Question {
  final String id;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String? explanation;

  Question({
    required this.id,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id']?.toString() ?? '',
      question: json['question'] as String? ?? '',
      optionA: json['option_a'] as String? ?? '',
      optionB: json['option_b'] as String? ?? '',
      optionC: json['option_c'] as String? ?? '',
      optionD: json['option_d'] as String? ?? '',
      explanation: json['explanation'] as String?,
    );
  }
}

class QuizResult {
  final String attemptId;
  final int score;
  final int total;
  final double percentage;
  final bool isPassed;
  final int passingScore;

  QuizResult({
    required this.attemptId,
    required this.score,
    required this.total,
    required this.percentage,
    required this.isPassed,
    required this.passingScore,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      attemptId: json['attempt_id']?.toString() ?? '',
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      isPassed: json['is_passed'] as bool? ?? false,
      passingScore: json['passing_score'] as int? ?? 70,
    );
  }
}

/// Enrollment Models
class EnrollmentModel {
  final String enrollmentId;
  final String courseId;
  final String courseName;
  final double progress;
  final int totalLessons;
  final int doneLessons;
  final List<Module>? modules;
  final String? enrolledDate;

  EnrollmentModel({
    required this.enrollmentId,
    required this.courseId,
    required this.courseName,
    required this.progress,
    required this.totalLessons,
    required this.doneLessons,
    this.modules,
    this.enrolledDate,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      enrollmentId:
          json['enrollment_id']?.toString() ?? json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      totalLessons: json['total_lessons'] as int? ?? 0,
      doneLessons: json['done_lessons'] as int? ?? 0,
      modules: (json['modules'] as List?)
          ?.map((m) => Module.fromJson(m as Map<String, dynamic>))
          .toList(),
      enrolledDate: json['enrolled_date'] as String?,
    );
  }
}


/// Career Path Model
class CareerPathModel {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final bool isHighDemand;
  final String salaryRange;
  final List<String> whatYouWillDo;
  final List<String> skills;
  final List<LearningPathStep> learningPath;
  final List<String> careerOpportunities;

  CareerPathModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.isHighDemand,
    required this.salaryRange,
    required this.whatYouWillDo,
    required this.skills,
    required this.learningPath,
    required this.careerOpportunities,
  });

  factory CareerPathModel.fromJson(Map<String, dynamic> json) {
    return CareerPathModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      isHighDemand: json['is_high_demand'] as bool? ?? false,
      salaryRange: json['salary_range'] as String? ?? '',
      whatYouWillDo: (json['what_you_will_do'] as List?)?.cast<String>() ?? [],
      skills: (json['skills'] as List?)?.cast<String>() ?? [],
      learningPath:
          (json['learning_path'] as List?)
              ?.map((e) => LearningPathStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      careerOpportunities:
          (json['career_opportunities'] as List?)?.cast<String>() ?? [],
    );
  }
}

class LearningPathStep {
  final int step;
  final String title;
  final String subtitle;

  LearningPathStep({
    required this.step,
    required this.title,
    required this.subtitle,
  });

  factory LearningPathStep.fromJson(Map<String, dynamic> json) {
    return LearningPathStep(
      step: json['step'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
    );
  }
}

/// Additional Models for Course Service

class CourseDetailModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String type;
  final String level;
  final String duration;
  final double rating;
  final int studentsEnrolled;
  final List<PriceOption> priceOptions;
  final bool isEnrolled;
  final String? instructor;
  final List<String> whatYouWillLearn;
  final List<String> includes;
  final List<Module> modules;

  CourseDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.level,
    required this.duration,
    required this.rating,
    required this.studentsEnrolled,
    required this.priceOptions,
    required this.isEnrolled,
    this.instructor,
    required this.whatYouWillLearn,
    required this.includes,
    required this.modules,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      type: json['type'] as String? ?? 'course',
      level: json['level'] as String? ?? 'Beginner',
      duration: json['duration'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      studentsEnrolled: json['students_enrolled'] as int? ?? 0,
      priceOptions:
          (json['price_options'] as List?)
              ?.map((p) => PriceOption.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      isEnrolled: json['is_enrolled'] as bool? ?? false,
      instructor: json['instructor'] as String?,
      whatYouWillLearn:
          (json['what_you_will_learn'] as List?)?.cast<String>() ?? [],
      includes: (json['includes'] as List?)?.cast<String>() ?? [],
      modules:
          (json['modules'] as List?)
              ?.map((m) => Module.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CareerPathDetailModel {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final bool isHighDemand;
  final String salaryRange;
  final List<String> whatYouWillDo;
  final List<String> skills;
  final List<LearningPathStep> learningPath;
  final List<String> careerOpportunities;

  CareerPathDetailModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.isHighDemand,
    required this.salaryRange,
    required this.whatYouWillDo,
    required this.skills,
    required this.learningPath,
    required this.careerOpportunities,
  });

  factory CareerPathDetailModel.fromJson(Map<String, dynamic> json) {
    return CareerPathDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      isHighDemand: json['is_high_demand'] as bool? ?? false,
      salaryRange: json['salary_range'] as String? ?? '',
      whatYouWillDo: (json['what_you_will_do'] as List?)?.cast<String>() ?? [],
      skills: (json['skills'] as List?)?.cast<String>() ?? [],
      learningPath:
          (json['learning_path'] as List?)
              ?.map((e) => LearningPathStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      careerOpportunities:
          (json['career_opportunities'] as List?)?.cast<String>() ?? [],
    );
  }
}

class EnrollmentProgressModel {
  final EnrollmentModel enrollment;
  final List<Module> modules;
  final double progress;
  final int totalLessons;
  final int doneLessons;

  EnrollmentProgressModel({
    required this.enrollment,
    required this.modules,
    required this.progress,
    required this.totalLessons,
    required this.doneLessons,
  });

  factory EnrollmentProgressModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentProgressModel(
      enrollment: EnrollmentModel.fromJson(
        json['enrollment'] as Map<String, dynamic>,
      ),
      modules:
          (json['modules'] as List?)
              ?.map((m) => Module.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      totalLessons: json['total_lessons'] as int? ?? 0,
      doneLessons: json['done_lessons'] as int? ?? 0,
    );
  }
}

class ModuleDetailModel {
  final String id;
  final String title;
  final List<Lesson> lessons;
  final Quiz quiz;

  ModuleDetailModel({
    required this.id,
    required this.title,
    required this.lessons,
    required this.quiz,
  });

  factory ModuleDetailModel.fromJson(Map<String, dynamic> json) {
    return ModuleDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      lessons:
          (json['lessons'] as List?)
              ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      quiz: Quiz.fromJson(json['quiz'] as Map<String, dynamic>),
    );
  }
}

class LessonDetailModel {
  final String id;
  final String title;
  final String videoUrl;
  final String description;
  final List<Lesson> allLessons;

  LessonDetailModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.description,
    required this.allLessons,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    return LessonDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      allLessons:
          (json['all_lessons'] as List?)
              ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuizModel {
  final String id;
  final String title;
  final int totalQuestions;
  final int timeLimitMinutes;
  final int passingPercentage;
  final List<Question> questions;

  QuizModel({
    required this.id,
    required this.title,
    required this.totalQuestions,
    required this.timeLimitMinutes,
    required this.passingPercentage,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      totalQuestions: json['total_questions'] as int? ?? 0,
      timeLimitMinutes: json['time_limit_minutes'] as int? ?? 0,
      passingPercentage: json['passing_percentage'] as int? ?? 70,
      questions:
          (json['questions'] as List?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuizResultModel {
  final String attemptId;
  final int score;
  final int total;
  final double percentage;
  final bool isPassed;
  final int passingScore;
  final Map<String, dynamic>? certificate;

  QuizResultModel({
    required this.attemptId,
    required this.score,
    required this.total,
    required this.percentage,
    required this.isPassed,
    required this.passingScore,
    this.certificate,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      attemptId: json['attempt_id']?.toString() ?? '',
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      isPassed: json['is_passed'] as bool? ?? false,
      passingScore: json['passing_score'] as int? ?? 70,
      certificate: json['certificate'] as Map<String, dynamic>?,
    );
  }
}

class QuizReviewModel {
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctOption;
  final String selectedOption;
  final bool isCorrect;
  final String? explanation;

  QuizReviewModel({
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctOption,
    required this.selectedOption,
    required this.isCorrect,
    this.explanation,
  });

  factory QuizReviewModel.fromJson(Map<String, dynamic> json) {
    return QuizReviewModel(
      question: json['question'] as String? ?? '',
      optionA: json['option_a'] as String? ?? '',
      optionB: json['option_b'] as String? ?? '',
      optionC: json['option_c'] as String? ?? '',
      optionD: json['option_d'] as String? ?? '',
      correctOption: json['correct_option'] as String? ?? '',
      selectedOption: json['selected_option'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      explanation: json['explanation'] as String?,
    );
  }
}

class CartItemModel {
  final String id;
  final String courseId;
  final String courseName;
  final String courseImage;
  final double price;
  final String duration;

  CartItemModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseImage,
    required this.price,
    required this.duration,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      courseName: json['course_name'] as String? ?? '',
      courseImage: json['course_image'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] as String? ?? '',
    );
  }
}

class CheckoutModel {
  final String orderId;
  final double amount;
  final String currency;

  CheckoutModel({
    required this.orderId,
    required this.amount,
    required this.currency,
  });

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    return CheckoutModel(
      orderId: json['order_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
