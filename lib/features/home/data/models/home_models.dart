// ─── Models ───────────────────────────────────────────────────────────────────

class InternshipModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String duration;
  final double rating;
  final int studentsEnrolled;
  final String level;
  final List<PriceOption> priceOptions;

  InternshipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.duration,
    required this.rating,
    required this.studentsEnrolled,
    required this.level,
    required this.priceOptions,
  });

  factory InternshipModel.fromJson(Map<String, dynamic> json) {
    return InternshipModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      studentsEnrolled: json['students_enrolled'] as int? ?? 0,
      level: json['level'] as String? ?? '',
      priceOptions: (json['price_options'] as List<dynamic>?)
              ?.map((e) => PriceOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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

class CareerPathModel {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final bool isHighDemand;
  final List<String> whatYouWillDo;
  final List<String> skills;
  final List<LearningPathStep> learningPath;
  final List<String> careerOpportunities;
  final String salaryRange;

  CareerPathModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.isHighDemand,
    required this.whatYouWillDo,
    required this.skills,
    required this.learningPath,
    required this.careerOpportunities,
    required this.salaryRange,
  });

  factory CareerPathModel.fromJson(Map<String, dynamic> json) {
    return CareerPathModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      isHighDemand: json['is_high_demand'] as bool? ?? false,
      whatYouWillDo: List<String>.from(json['what_you_will_do'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      learningPath: (json['learning_path'] as List<dynamic>?)
              ?.map((e) => LearningPathStep.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      careerOpportunities: List<String>.from(json['career_opportunities'] ?? []),
      salaryRange: json['salary_range'] as String? ?? '',
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

class ContinueLearningModel {
  final String enrollmentId;
  final String courseId;
  final String courseTitle;
  final String currentModule;
  final double progress;

  ContinueLearningModel({
    required this.enrollmentId,
    required this.courseId,
    required this.courseTitle,
    required this.currentModule,
    required this.progress,
  });

  factory ContinueLearningModel.fromJson(Map<String, dynamic> json) {
    return ContinueLearningModel(
      enrollmentId: json['enrollment_id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      courseTitle: json['course_title'] as String? ?? '',
      currentModule: json['current_module'] as String? ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
