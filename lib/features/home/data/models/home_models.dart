// ─── Models ───────────────────────────────────────────────────────────────────

import 'package:bio_xplora_portal/shared/models/api_models.dart';

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
      priceOptions:
          (json['price_options'] as List<dynamic>?)
              ?.map((e) => PriceOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
