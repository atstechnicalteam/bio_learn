class InternshipDetailModel {
  final String id;
  final String title;
  final String imageUrl;
  final double rating;
  final int studentsEnrolled;
  final String duration;
  final String level;
  final List<PricingOption> priceOptions;
  final String about;
  final List<String> whatYouWillLearn;
  final List<String> includes;
  final List<CourseModule> modules;

  InternshipDetailModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.studentsEnrolled,
    required this.duration,
    required this.level,
    required this.priceOptions,
    required this.about,
    required this.whatYouWillLearn,
    required this.includes,
    required this.modules,
  });
}

class PricingOption {
  final String id;
  final String duration;
  final double price;
  final double? originalPrice;
  final bool isMostPopular;

  PricingOption({
    required this.id,
    required this.duration,
    required this.price,
    this.originalPrice,
    this.isMostPopular = false,
  });
}

class CourseModule {
  final String id;
  final String title;
  final int lessonsCount;
  final int quizzesCount;
  final List<String> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.lessonsCount,
    required this.quizzesCount,
    required this.lessons,
  });
}
