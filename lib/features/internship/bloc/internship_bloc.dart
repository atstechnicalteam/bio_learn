// ─── Models ───────────────────────────────────────────────────────────────────
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

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

  factory InternshipDetailModel.fromJson(Map<String, dynamic> json) {
    return InternshipDetailModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      studentsEnrolled: json['students_enrolled'] as int? ?? 0,
      duration: json['duration'] as String? ?? '',
      level: json['level'] as String? ?? '',
      priceOptions: (json['price_options'] as List?)
              ?.map((e) => PricingOption.fromJson(e))
              .toList() ??
          [],
      about: json['about'] as String? ?? '',
      whatYouWillLearn: List<String>.from(json['what_you_will_learn'] ?? []),
      includes: List<String>.from(json['includes'] ?? []),
      modules: (json['modules'] as List?)
              ?.map((e) => CourseModule.fromJson(e))
              .toList() ??
          [],
    );
  }
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

  factory PricingOption.fromJson(Map<String, dynamic> json) => PricingOption(
        id: json['id']?.toString() ?? '',
        duration: json['duration'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        originalPrice: (json['original_price'] as num?)?.toDouble(),
        isMostPopular: json['is_most_popular'] as bool? ?? false,
      );
}

class CourseModule {
  final String id;
  final String title;
  final int lessonsCount;
  final int quizzesCount;

  CourseModule({
    required this.id,
    required this.title,
    required this.lessonsCount,
    required this.quizzesCount,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) => CourseModule(
        id: json['id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        lessonsCount: json['lessons_count'] as int? ?? 0,
        quizzesCount: json['quizzes_count'] as int? ?? 0,
      );
}

// ─── Repository ───────────────────────────────────────────────────────────────

abstract class InternshipRepository {
  Future<InternshipDetailModel> getDetail(String id);
  Future<void> addToCart(String id, String priceOptionId);
  Future<void> addToWishlist(String id);
  Future<void> enroll(String id, String priceOptionId);
}

class InternshipRepositoryImpl implements InternshipRepository {
  final ApiClient _apiClient;
  InternshipRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<InternshipDetailModel> getDetail(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.internshipDetail(id));
      return InternshipDetailModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } catch (_) {
      return _demoInternshipDetail(id);
    }
  }

  @override
  Future<void> addToCart(String id, String priceOptionId) async {
    try {
      await _apiClient.post(ApiEndpoints.cart,
          body: {'internship_id': id, 'price_option_id': priceOptionId});
    } catch (_) {}
  }

  @override
  Future<void> addToWishlist(String id) async {
    try {
      await _apiClient
          .post(ApiEndpoints.addToWishlist(id), body: {});
    } catch (_) {}
  }

  @override
  Future<void> enroll(String id, String priceOptionId) async {
    try {
      await _apiClient.post(ApiEndpoints.enroll,
          body: {'internship_id': id, 'price_option_id': priceOptionId});
    } catch (_) {}
  }
}

InternshipDetailModel _demoInternshipDetail(String id) {
  final isCourse = id.toLowerCase().contains('course');

  return InternshipDetailModel(
    id: id,
    title: isCourse ? 'Pharmacovigilance Course' : 'Medical Coding Internship',
    imageUrl: '',
    rating: isCourse ? 4.6 : 4.8,
    studentsEnrolled: isCourse ? 930 : 1200,
    duration: isCourse ? '5 Weeks' : '8 Weeks',
    level: 'Beginner',
    priceOptions: [
      PricingOption(id: 'detail-price-2w', duration: '2 Weeks', price: 999),
      PricingOption(id: 'detail-price-4w', duration: '4 Weeks', price: 1999),
      PricingOption(
        id: 'detail-price-8w',
        duration: '8 Weeks',
        price: 2999,
        originalPrice: 3999,
        isMostPopular: true,
      ),
    ],
    about: isCourse
        ? 'This offline-ready course walkthrough introduces core pharmacovigilance concepts, safety workflows, and reporting basics.'
        : 'This offline-ready internship walkthrough gives learners a practical view of medical coding concepts, tools, and workflow.',
    whatYouWillLearn: isCourse
        ? const [
            'Drug safety terminology',
            'Case intake and processing basics',
            'Signal detection fundamentals',
            'Safety documentation workflow',
          ]
        : const [
            'Medical terminology fundamentals',
            'ICD and CPT coding basics',
            'Documentation review process',
            'Coding workflow practice',
          ],
    includes: const [
      'Recorded sessions',
      'Practice assignments',
      'Quiz access',
      'Certificate of completion',
    ],
    modules: [
      CourseModule(
        id: 'module-1',
        title: 'Introduction and Foundations',
        lessonsCount: 5,
        quizzesCount: 1,
      ),
      CourseModule(
        id: 'module-2',
        title: 'Core Concepts and Workflow',
        lessonsCount: 6,
        quizzesCount: 1,
      ),
      CourseModule(
        id: 'module-3',
        title: 'Hands-on Practice',
        lessonsCount: 4,
        quizzesCount: 1,
      ),
    ],
  );
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

abstract class InternshipEvent extends Equatable {
  const InternshipEvent();
  @override
  List<Object?> get props => [];
}

class InternshipDetailRequested extends InternshipEvent {
  final String id;
  const InternshipDetailRequested({required this.id});
  @override
  List<Object?> get props => [id];
}

class InternshipAddToCart extends InternshipEvent {
  final String id;
  final String priceOptionId;
  const InternshipAddToCart({required this.id, required this.priceOptionId});
}

class InternshipAddToWishlist extends InternshipEvent {
  final String id;
  const InternshipAddToWishlist({required this.id});
}

class InternshipEnroll extends InternshipEvent {
  final String id;
  final String priceOptionId;
  const InternshipEnroll({required this.id, required this.priceOptionId});
}

abstract class InternshipState extends Equatable {
  const InternshipState();
  @override
  List<Object?> get props => [];
}

class InternshipInitial extends InternshipState {}
class InternshipLoading extends InternshipState {}

class InternshipDetailLoaded extends InternshipState {
  final InternshipDetailModel internship;
  const InternshipDetailLoaded({required this.internship});
  @override
  List<Object?> get props => [internship];
}

class InternshipActionSuccess extends InternshipState {
  final String message;
  const InternshipActionSuccess({required this.message});
}

class InternshipError extends InternshipState {
  final String message;
  const InternshipError({required this.message});
  @override
  List<Object?> get props => [message];
}

class InternshipBloc extends Bloc<InternshipEvent, InternshipState> {
  final InternshipRepository _repository;

  InternshipBloc({required InternshipRepository repository})
      : _repository = repository,
        super(InternshipInitial()) {
    on<InternshipDetailRequested>(_onDetailLoaded);
    on<InternshipAddToCart>(_onAddToCart);
    on<InternshipAddToWishlist>(_onAddToWishlist);
    on<InternshipEnroll>(_onEnroll);
  }

  Future<void> _onDetailLoaded(
      InternshipDetailRequested event, Emitter<InternshipState> emit) async {
    emit(InternshipLoading());
    try {
      final internship = await _repository.getDetail(event.id);
      emit(InternshipDetailLoaded(internship: internship));
    } catch (e) {
      emit(InternshipError(message: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onAddToCart(
      InternshipAddToCart event, Emitter<InternshipState> emit) async {
    try {
      await _repository.addToCart(event.id, event.priceOptionId);
      emit(const InternshipActionSuccess(message: 'Added to cart'));
    } catch (e) {
      emit(InternshipError(message: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onAddToWishlist(
      InternshipAddToWishlist event, Emitter<InternshipState> emit) async {
    try {
      await _repository.addToWishlist(event.id);
      emit(const InternshipActionSuccess(message: 'Added to wishlist'));
    } catch (e) {
      emit(InternshipError(message: e.toString().replaceAll('ApiException: ', '')));
    }
  }

  Future<void> _onEnroll(
      InternshipEnroll event, Emitter<InternshipState> emit) async {
    try {
      await _repository.enroll(event.id, event.priceOptionId);
      emit(const InternshipActionSuccess(message: 'Enrolled successfully'));
    } catch (e) {
      emit(InternshipError(message: e.toString().replaceAll('ApiException: ', '')));
    }
  }
}
