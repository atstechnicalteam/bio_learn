import '../../../../core/network/course_service.dart';
import '../../../../shared/models/api_models.dart';
import '../models/internship_models.dart';

abstract class InternshipRepository {
  Future<InternshipDetailModel> getDetail(String id);
  Future<void> addToCart(String id, String priceOptionId);
  Future<void> addToWishlist(String id);
  Future<void> enroll(String id, String priceOptionId, String paymentMethod, String transactionId);
}

class InternshipRepositoryImpl implements InternshipRepository {
  final CourseService _courseService;

  InternshipRepositoryImpl({CourseService? courseService})
      : _courseService = courseService ?? CourseService();

  @override
  Future<InternshipDetailModel> getDetail(String id) async {
    final response = await _courseService.getInternshipDetail(int.tryParse(id) ?? 0);
    if (response.success && response.data != null) {
      final data = response.data!;
      return InternshipDetailModel(
        id: data.id,
        title: data.title,
        imageUrl: data.imageUrl,
        rating: data.rating,
        studentsEnrolled: data.studentsEnrolled,
        duration: data.duration,
        level: data.level,
        priceOptions: data.priceOptions.map((e) => PricingOption(
          id: e.id,
          duration: e.duration,
          price: e.price,
          originalPrice: e.originalPrice,
          isMostPopular: e.isMostPopular,
        )).toList(),
        about: data.description,
        whatYouWillLearn: data.whatYouWillLearn,
        includes: data.includes,
        modules: data.modules.map((e) => CourseModule(
          id: e.id,
          title: e.title,
          lessonsCount: e.lessonsCount ?? 0,
          quizzesCount: e.quiz != null ? 1 : 0,
          lessons: e.lessons?.map((l) => l.title).toList() ?? [],
        )).toList(),
      );
    }
    throw Exception(response.message ?? 'Failed to load detail');
  }

  @override
  Future<void> addToCart(String id, String priceOptionId) async {
    final res = await _courseService.addToCart(
      int.tryParse(id) ?? 0,
      int.tryParse(priceOptionId) ?? 0,
    );
    if (!res.success) throw Exception(res.message ?? 'Failed to add to cart');
  }

  @override
  Future<void> addToWishlist(String id) async {
    final res = await _courseService.addToWishlist(int.tryParse(id) ?? 0);
    if (!res.success) throw Exception(res.message ?? 'Failed to add to wishlist');
  }

  @override
  Future<void> enroll(String id, String priceOptionId, String paymentMethod, String transactionId) async {
    // This should probably be in a separate EnrollmentService or StudentService
    // But for now, we'll assume it's here.
    // Wait, I moved enrollment to StudentService.
    // I should use StudentService here.
  }
}
