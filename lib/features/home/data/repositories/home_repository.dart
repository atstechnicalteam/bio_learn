import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/home_models.dart';

abstract class HomeRepository {
  Future<List<InternshipModel>> getInternships();
  Future<List<InternshipModel>> getCourses();
  Future<List<CareerPathModel>> getCareerPaths();
  Future<ContinueLearningModel?> getContinueLearning();
  Future<InternshipModel> getInternshipDetail(String id);
  Future<CareerPathModel> getCareerPathDetail(String id);
  Future<List<InternshipModel>> search(String query, String type);
}

class HomeRepositoryImpl implements HomeRepository {
  final ApiClient _apiClient;

  HomeRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<InternshipModel>> getInternships() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.internships);
      final data = response['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => InternshipModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _demoInternships();
    }
  }

  @override
  Future<List<InternshipModel>> getCourses() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.courses);
      final data = response['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => InternshipModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _demoCourses();
    }
  }

  @override
  Future<List<CareerPathModel>> getCareerPaths() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.careerPaths);
      final data = response['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => CareerPathModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _demoCareerPaths();
    }
  }

  @override
  Future<ContinueLearningModel?> getContinueLearning() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.continueLearning);
      if (response['data'] == null) return null;
      return ContinueLearningModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } catch (_) {
      return _demoContinueLearning();
    }
  }

  @override
  Future<InternshipModel> getInternshipDetail(String id) async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.internshipDetail(id));
      return InternshipModel.fromJson(
          response['data'] as Map<String, dynamic>);
    } catch (_) {
      return _findInternship(id, _demoInternships() + _demoCourses());
    }
  }

  @override
  Future<CareerPathModel> getCareerPathDetail(String id) async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.careerPathDetail(id));
      return CareerPathModel.fromJson(response['data'] as Map<String, dynamic>);
    } catch (_) {
      return _findCareerPath(id, _demoCareerPaths());
    }
  }

  @override
  Future<List<InternshipModel>> search(String query, String type) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.search,
        queryParams: {'q': query, 'type': type},
      );
      final data = response['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => InternshipModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final source = type == 'courses' ? _demoCourses() : _demoInternships();
      final normalizedQuery = query.toLowerCase();
      return source.where((item) {
        final title = item.title.toLowerCase();
        final description = item.description.toLowerCase();
        return title.contains(normalizedQuery) ||
            description.contains(normalizedQuery);
      }).toList();
    }
  }
}

List<InternshipModel> _demoInternships() {
  return [
    InternshipModel(
      id: 'internship-medical-coding',
      title: 'Medical Coding',
      description: 'Learn ICD-10 coding and healthcare documentation',
      imageUrl: '',
      duration: '8 Weeks',
      rating: 4.8,
      studentsEnrolled: 1200,
      level: 'Beginner',
      priceOptions: [
        PriceOption(id: 'price-int-2w', duration: '2 Weeks', price: 999),
        PriceOption(id: 'price-int-4w', duration: '4 Weeks', price: 1999),
        PriceOption(
          id: 'price-int-8w',
          duration: '8 Weeks',
          price: 2999,
          originalPrice: 3999,
          isMostPopular: true,
        ),
      ],
    ),
    InternshipModel(
      id: 'internship-bioinformatics',
      title: 'Bioinformatics',
      description: 'Analyze biological data and genome sequences',
      imageUrl: '',
      duration: '6 Weeks',
      rating: 4.9,
      studentsEnrolled: 640,
      level: 'Beginner',
      priceOptions: [
        PriceOption(id: 'price-bio-2w', duration: '2 Weeks', price: 1099),
        PriceOption(id: 'price-bio-4w', duration: '4 Weeks', price: 2099),
        PriceOption(
          id: 'price-bio-6w',
          duration: '6 Weeks',
          price: 3499,
          originalPrice: 4499,
          isMostPopular: true,
        ),
      ],
    ),
  ];
}

List<InternshipModel> _demoCourses() {
  return [
    InternshipModel(
      id: 'course-medical-coding',
      title: 'Medical Coding',
      description: 'Learn ICD-10 coding and healthcare documentation',
      imageUrl: '',
      duration: '5 Weeks',
      rating: 4.6,
      studentsEnrolled: 930,
      level: 'Beginner',
      priceOptions: [
        PriceOption(id: 'price-course-mc-1m', duration: '1 Month', price: 1499),
        PriceOption(id: 'price-course-mc-2m', duration: '2 Months', price: 2299),
        PriceOption(
          id: 'price-course-mc-3m',
          duration: '3 Months',
          price: 2999,
          originalPrice: 3599,
          isMostPopular: true,
        ),
      ],
    ),
    InternshipModel(
      id: 'course-bioinformatics',
      title: 'Bioinformatics',
      description: 'Analyze biological data and genome sequences',
      imageUrl: '',
      duration: '4 Weeks',
      rating: 4.5,
      studentsEnrolled: 520,
      level: 'Beginner',
      priceOptions: [
        PriceOption(id: 'price-course-bio-1m', duration: '1 Month', price: 1299),
        PriceOption(id: 'price-course-bio-2m', duration: '2 Months', price: 1999),
        PriceOption(
          id: 'price-course-bio-3m',
          duration: '3 Months',
          price: 2599,
          originalPrice: 3199,
          isMostPopular: true,
        ),
      ],
    ),
  ];
}

List<CareerPathModel> _demoCareerPaths() {
  return [
    CareerPathModel(
      id: 'career-medical-coder',
      title: 'Medical Coding Specialist',
      description: 'Work in hospitals and healthcare companies handling critical data.',
      iconUrl: '',
      isHighDemand: true,
      whatYouWillDo: [
        'Review patient charts and healthcare records.',
        'Assign ICD and CPT codes accurately.',
        'Support billing teams with clean claim documentation.',
      ],
      skills: ['ICD-10', 'CPT', 'Medical Terminology', 'Documentation Review'],
      learningPath: [
        LearningPathStep(step: 1, title: 'Basics', subtitle: 'Understand terms and anatomy'),
        LearningPathStep(step: 2, title: 'Coding Systems', subtitle: 'Learn ICD and CPT usage'),
        LearningPathStep(step: 3, title: 'Practice', subtitle: 'Work through real sample cases'),
      ],
      careerOpportunities: ['Medical Coder', 'Coding Analyst', 'Revenue Cycle Associate'],
      salaryRange: '3.0 LPA - 6.5 LPA',
    ),
    CareerPathModel(
      id: 'career-bioinformatics',
      title: 'Bioinformatics Analyst',
      description: 'Work with biological computation and genome analysis workflows.',
      iconUrl: '',
      isHighDemand: true,
      whatYouWillDo: [
        'Assist with trial documentation and monitoring.',
        'Track protocol adherence and site activity.',
        'Support ethics and compliance reporting.',
      ],
      skills: ['GCP', 'Documentation', 'Monitoring', 'Clinical Operations'],
      learningPath: [
        LearningPathStep(step: 1, title: 'Foundations', subtitle: 'Understand the trial lifecycle'),
        LearningPathStep(step: 2, title: 'Compliance', subtitle: 'Learn GCP and reporting standards'),
        LearningPathStep(step: 3, title: 'Execution', subtitle: 'Practice site coordination tasks'),
      ],
      careerOpportunities: ['CRA', 'Clinical Trial Assistant', 'Clinical Operations Coordinator'],
      salaryRange: '4.0 LPA - 8.0 LPA',
    ),
  ];
}

ContinueLearningModel _demoContinueLearning() {
  return ContinueLearningModel(
    enrollmentId: 'demo-enrollment-1',
    courseId: 'course-bioinformatics-masterclass',
    courseTitle: 'Bioinformatics Complete Masterclass',
    currentModule: 'Module 4: DNA Sequence Analysis',
    progress: 0.65,
  );
}

InternshipModel _findInternship(String id, List<InternshipModel> items) {
  return items.firstWhere(
    (item) => item.id == id,
    orElse: () => items.first,
  );
}

CareerPathModel _findCareerPath(String id, List<CareerPathModel> items) {
  return items.firstWhere(
    (item) => item.id == id,
    orElse: () => items.first,
  );
}
