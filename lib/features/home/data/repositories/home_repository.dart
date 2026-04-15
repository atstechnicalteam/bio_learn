import 'package:bio_xplora_portal/core/network/course_service.dart';

import '../../../../core/network/student_service.dart';
import '../../../../shared/models/api_models.dart';
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
  final CourseService _courseService;
  final StudentService _studentService;

  HomeRepositoryImpl({
    CourseService? courseService,
    StudentService? studentService,
  }) : _courseService = courseService ?? CourseService(),
       _studentService = studentService ?? StudentService();

  @override
  Future<List<InternshipModel>> getInternships() async {
    final response = await _courseService.getInternships();
    if (response.success && response.data != null) {
      return response.data!
          .map(
            (course) => InternshipModel(
              id: course.id,
              title: course.title,
              description: course.description,
              imageUrl: course.imageUrl,
              duration: course.duration,
              rating: course.rating,
              studentsEnrolled: course.studentsEnrolled,
              level: course.level,
              priceOptions: course.priceOptions,
            ),
          )
          .toList();
    }
    throw Exception(response.message ?? 'Failed to load internships');
  }

  @override
  Future<List<InternshipModel>> getCourses() async {
    final response = await _courseService.getCourses();
    if (response.success && response.data != null) {
      return response.data!
          .map(
            (course) => InternshipModel(
              id: course.id,
              title: course.title,
              description: course.description,
              imageUrl: course.imageUrl,
              duration: course.duration,
              rating: course.rating,
              studentsEnrolled: course.studentsEnrolled,
              level: course.level,
              priceOptions: course.priceOptions,
            ),
          )
          .toList();
    }
    throw Exception(response.message ?? 'Failed to load courses');
  }

  @override
  Future<List<CareerPathModel>> getCareerPaths() async {
    final response = await _courseService.getCareerPaths();
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message ?? 'Failed to load career paths');
  }

  @override
  Future<ContinueLearningModel?> getContinueLearning() async {
    final response = await _studentService.getContinueLearning();
    if (response.success && response.data != null) {
      final enrollment = response.data!;
      return ContinueLearningModel(
        enrollmentId: enrollment.enrollmentId,
        courseId: enrollment.courseId,
        courseTitle: enrollment.courseName,
        currentModule: enrollment.modules?.isNotEmpty == true
            ? enrollment.modules!.first.title
            : 'Module 1',
        progress: enrollment.progress,
      );
    }
    return null; // No continue learning data
  }

  @override
  Future<InternshipModel> getInternshipDetail(String id) async {
    final response = await _courseService.getInternshipDetail(int.tryParse(id) ?? 0);
    if (response.success && response.data != null) {
      final course = response.data!;
      return InternshipModel(
        id: course.id,
        title: course.title,
        description: course.description,
        imageUrl: course.imageUrl,
        duration: course.duration,
        rating: course.rating,
        studentsEnrolled: course.studentsEnrolled,
        level: course.level,
        priceOptions: course.priceOptions,
      );
    }
    throw Exception(response.message ?? 'Failed to load internship detail');
  }

  @override
  Future<CareerPathModel> getCareerPathDetail(String id) async {
    final response = await _courseService.getCareerPathDetail(int.tryParse(id) ?? 0);
    if (response.success && response.data != null) {
      final data = response.data!;
      return CareerPathModel(
        id: data.id,
        title: data.title,
        description: data.description,
        iconUrl: data.iconUrl,
        isHighDemand: data.isHighDemand,
        salaryRange: data.salaryRange,
        whatYouWillDo: data.whatYouWillDo,
        skills: data.skills,
        learningPath: data.learningPath,
        careerOpportunities: data.careerOpportunities,
      );
    }
    throw Exception(response.message ?? 'Failed to load career path detail');
  }

  @override
  Future<List<InternshipModel>> search(String query, String type) async {
    final response = await _courseService.search(query, type: type);
    if (response.success && response.data != null) {
      return response.data!
          .map(
            (course) => InternshipModel(
              id: course.id,
              title: course.title,
              description: course.description,
              imageUrl: course.imageUrl,
              duration: course.duration,
              rating: course.rating,
              studentsEnrolled: course.studentsEnrolled,
              level: course.level,
              priceOptions: course.priceOptions,
            ),
          )
          .toList();
    }
    throw Exception(response.message ?? 'Failed to search');
  }
}
