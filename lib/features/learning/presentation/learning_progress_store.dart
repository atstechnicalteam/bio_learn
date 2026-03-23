import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningLessonDefinition {
  const LearningLessonDefinition({
    required this.title,
    required this.duration,
  });

  final String title;
  final String duration;
}

class LearningModuleDefinition {
  const LearningModuleDefinition({
    required this.title,
    required this.description,
    required this.estimatedTime,
    required this.lessons,
  });

  final String title;
  final String description;
  final String estimatedTime;
  final List<LearningLessonDefinition> lessons;
}

class LearningProgressState {
  LearningProgressState({
    required Set<String> completedLessonKeys,
    required Set<int> passedModuleQuizIndexes,
    required this.completionDate,
  })  : completedLessonKeys = Set.unmodifiable(completedLessonKeys),
        passedModuleQuizIndexes = Set.unmodifiable(passedModuleQuizIndexes);

  factory LearningProgressState.initial() {
    return LearningProgressState(
      completedLessonKeys: <String>{},
      passedModuleQuizIndexes: <int>{},
      completionDate: null,
    );
  }

  static const String courseTitle = 'Medical Coding Internship';
  static const String issuerName = 'Bioxplora';
  static const String recipientName = 'Vimalraj K';
  static const List<LearningModuleDefinition> modules = [
    LearningModuleDefinition(
      title: 'Module 1 - Introduction to Medical Coding',
      description:
          'Build the foundation of medical coding with terminology, healthcare workflow, and the role of a medical coder.',
      estimatedTime: '30 Minutes',
      lessons: [
        LearningLessonDefinition(
          title: '1. What is Medical Coding?',
          duration: '8:30',
        ),
        LearningLessonDefinition(
          title: '2. History of Medical Coding',
          duration: '10:25',
        ),
        LearningLessonDefinition(
          title: '3. Healthcare Ecosystem',
          duration: '12:15',
        ),
        LearningLessonDefinition(
          title: '4. Role of a Medical Coder',
          duration: '9:20',
        ),
        LearningLessonDefinition(
          title: '5. Basic Terminology',
          duration: '15:00',
        ),
      ],
    ),
    LearningModuleDefinition(
      title: 'Module 2 - ICD-10 Basics',
      description:
          'Understand ICD-10 code structure, chapters, and how to navigate the coding system accurately.',
      estimatedTime: '36 Minutes',
      lessons: [
        LearningLessonDefinition(
          title: '1. ICD-10 Structure Overview',
          duration: '9:45',
        ),
        LearningLessonDefinition(
          title: '2. Chapters and Categories',
          duration: '8:50',
        ),
        LearningLessonDefinition(
          title: '3. Main Terms and Subterms',
          duration: '10:10',
        ),
        LearningLessonDefinition(
          title: '4. Using the Alphabetic Index',
          duration: '7:40',
        ),
        LearningLessonDefinition(
          title: '5. Tabular List Navigation',
          duration: '9:15',
        ),
      ],
    ),
    LearningModuleDefinition(
      title: 'Module 3 - Clinical Documentation',
      description:
          'Learn how clinical documentation supports code selection, compliance, and quality review.',
      estimatedTime: '32 Minutes',
      lessons: [
        LearningLessonDefinition(
          title: '1. SOAP Notes and Clinical Context',
          duration: '8:20',
        ),
        LearningLessonDefinition(
          title: '2. Diagnosis Abstraction',
          duration: '7:55',
        ),
        LearningLessonDefinition(
          title: '3. Procedure Documentation Review',
          duration: '9:30',
        ),
        LearningLessonDefinition(
          title: '4. Documentation Quality Checks',
          duration: '8:10',
        ),
      ],
    ),
    LearningModuleDefinition(
      title: 'Module 4 - Medical Billing',
      description:
          'Connect coding output to claims, reimbursement workflow, and billing compliance requirements.',
      estimatedTime: '34 Minutes',
      lessons: [
        LearningLessonDefinition(
          title: '1. Revenue Cycle Basics',
          duration: '8:40',
        ),
        LearningLessonDefinition(
          title: '2. Claim Form Essentials',
          duration: '9:00',
        ),
        LearningLessonDefinition(
          title: '3. Denials and Rejections',
          duration: '7:35',
        ),
        LearningLessonDefinition(
          title: '4. Audit and Compliance Readiness',
          duration: '8:25',
        ),
      ],
    ),
    LearningModuleDefinition(
      title: 'Module 5 - Practical Coding Exercises',
      description:
          'Apply course concepts in real coding scenarios and complete the final practice review.',
      estimatedTime: '35 Minutes',
      lessons: [
        LearningLessonDefinition(
          title: '1. Outpatient Case Practice',
          duration: '9:10',
        ),
        LearningLessonDefinition(
          title: '2. Inpatient Case Practice',
          duration: '8:35',
        ),
        LearningLessonDefinition(
          title: '3. Modifier Application Workshop',
          duration: '7:55',
        ),
        LearningLessonDefinition(
          title: '4. Final Course Review',
          duration: '9:20',
        ),
      ],
    ),
  ];

  final Set<String> completedLessonKeys;
  final Set<int> passedModuleQuizIndexes;
  final DateTime? completionDate;

  static int get totalModules => modules.length;

  static int get totalLessons =>
      modules.fold<int>(0, (sum, module) => sum + module.lessons.length);

  int get completedLessonsCount => completedLessonKeys.length;

  int get completedModulesCount =>
      List<int>.generate(totalModules, (index) => index)
          .where(isModuleCompleted)
          .length;

  bool get allLessonsCompleted => completedLessonsCount >= totalLessons;

  bool get allModulesCompleted => completedModulesCount >= totalModules;

  bool get certificateUnlocked => allModulesCompleted;

  double get progressValue {
    final totalUnits = totalLessons + totalModules;
    final completedUnits =
        completedLessonsCount + passedModuleQuizIndexes.length;
    if (totalUnits == 0) {
      return 0;
    }
    return completedUnits / totalUnits;
  }

  bool isLessonCompleted(int moduleIndex, int lessonIndex) {
    return completedLessonKeys.contains(_lessonKey(moduleIndex, lessonIndex));
  }

  int completedLessonsInModule(int moduleIndex) {
    if (!_isValidModuleIndex(moduleIndex)) {
      return 0;
    }

    return List<int>.generate(modules[moduleIndex].lessons.length, (i) => i)
        .where((lessonIndex) => isLessonCompleted(moduleIndex, lessonIndex))
        .length;
  }

  bool allLessonsCompletedInModule(int moduleIndex) {
    if (!_isValidModuleIndex(moduleIndex)) {
      return false;
    }

    return completedLessonsInModule(moduleIndex) >=
        modules[moduleIndex].lessons.length;
  }

  bool isModuleQuizPassed(int moduleIndex) {
    return passedModuleQuizIndexes.contains(moduleIndex);
  }

  bool isModuleCompleted(int moduleIndex) {
    return allLessonsCompletedInModule(moduleIndex) &&
        isModuleQuizPassed(moduleIndex);
  }

  bool isModuleUnlocked(int moduleIndex) {
    if (!_isValidModuleIndex(moduleIndex)) {
      return false;
    }

    if (moduleIndex == 0) {
      return true;
    }

    return isModuleCompleted(moduleIndex - 1);
  }

  LearningProgressState copyWith({
    Set<String>? completedLessonKeys,
    Set<int>? passedModuleQuizIndexes,
    DateTime? completionDate,
    bool updateCompletionDate = false,
  }) {
    return LearningProgressState(
      completedLessonKeys: completedLessonKeys ?? this.completedLessonKeys,
      passedModuleQuizIndexes:
          passedModuleQuizIndexes ?? this.passedModuleQuizIndexes,
      completionDate: updateCompletionDate ? completionDate : this.completionDate,
    );
  }

  static String _lessonKey(int moduleIndex, int lessonIndex) =>
      '$moduleIndex:$lessonIndex';

  static bool _isValidModuleIndex(int moduleIndex) =>
      moduleIndex >= 0 && moduleIndex < modules.length;
}

class LearningProgressStore {
  LearningProgressStore._();

  static final LearningProgressStore instance = LearningProgressStore._();

  static const String _legacyCompletedLessonsKey =
      'learning_progress.completed_lessons';
  static const String _legacyFinalQuizPassedKey =
      'learning_progress.final_quiz_passed';
  static const String _completedLessonKeysKey =
      'learning_progress.completed_lesson_keys';
  static const String _passedModuleQuizzesKey =
      'learning_progress.passed_module_quizzes';
  static const String _completionDateKey =
      'learning_progress.completion_date';

  final ValueNotifier<LearningProgressState> progress =
      ValueNotifier(LearningProgressState.initial());

  SharedPreferences? _preferences;
  bool _initialized = false;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    _preferences = await SharedPreferences.getInstance();

    final completedLessonKeys = (_preferences!
                .getStringList(_completedLessonKeysKey) ??
            const <String>[])
        .toSet();

    final legacyCompletedLessons =
        _preferences!.getStringList(_legacyCompletedLessonsKey) ??
            const <String>[];
    if (completedLessonKeys.isEmpty && legacyCompletedLessons.isNotEmpty) {
      completedLessonKeys.addAll(
        legacyCompletedLessons
            .map(int.tryParse)
            .whereType<int>()
            .map((lessonIndex) => '0:$lessonIndex'),
      );
    }

    final passedModuleQuizIndexes = (_preferences!
                .getStringList(_passedModuleQuizzesKey) ??
            const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();

    if (passedModuleQuizIndexes.isEmpty &&
        (_preferences!.getBool(_legacyFinalQuizPassedKey) ?? false)) {
      passedModuleQuizIndexes.add(0);
    }

    final completionDateValue = _preferences!.getString(_completionDateKey);

    progress.value = LearningProgressState(
      completedLessonKeys: completedLessonKeys,
      passedModuleQuizIndexes: passedModuleQuizIndexes,
      completionDate: completionDateValue == null
          ? null
          : DateTime.tryParse(completionDateValue),
    );

    _initialized = true;
  }

  Future<void> markLessonCompleted({
    required int moduleIndex,
    required int lessonIndex,
  }) async {
    await ensureInitialized();
    if (!_isValidLesson(moduleIndex, lessonIndex)) {
      return;
    }

    final updatedLessonKeys = <String>{
      ...progress.value.completedLessonKeys,
      '$moduleIndex:$lessonIndex',
    };

    await _saveState(
      progress.value.copyWith(completedLessonKeys: updatedLessonKeys),
    );
  }

  Future<void> markModuleQuizPassed(int moduleIndex) async {
    await ensureInitialized();
    if (!LearningProgressState._isValidModuleIndex(moduleIndex)) {
      return;
    }

    final updatedQuizIndexes = <int>{
      ...progress.value.passedModuleQuizIndexes,
      moduleIndex,
    };

    await _saveState(
      progress.value.copyWith(passedModuleQuizIndexes: updatedQuizIndexes),
    );
  }

  Future<void> _saveState(LearningProgressState state) async {
    final syncedState = _syncCompletionDate(state);
    progress.value = syncedState;

    await _preferences!.setStringList(
      _completedLessonKeysKey,
      syncedState.completedLessonKeys.toList(),
    );
    await _preferences!.setStringList(
      _passedModuleQuizzesKey,
      syncedState.passedModuleQuizIndexes
          .map((moduleIndex) => moduleIndex.toString())
          .toList(),
    );

    await _preferences!.remove(_legacyCompletedLessonsKey);
    await _preferences!.remove(_legacyFinalQuizPassedKey);

    if (syncedState.completionDate == null) {
      await _preferences!.remove(_completionDateKey);
    } else {
      await _preferences!.setString(
        _completionDateKey,
        syncedState.completionDate!.toIso8601String(),
      );
    }
  }

  LearningProgressState _syncCompletionDate(LearningProgressState state) {
    if (state.certificateUnlocked && state.completionDate == null) {
      return state.copyWith(
        completionDate: DateTime.now(),
        updateCompletionDate: true,
      );
    }

    if (!state.certificateUnlocked && state.completionDate != null) {
      return state.copyWith(
        completionDate: null,
        updateCompletionDate: true,
      );
    }

    return state;
  }

  bool _isValidLesson(int moduleIndex, int lessonIndex) {
    if (!LearningProgressState._isValidModuleIndex(moduleIndex)) {
      return false;
    }

    return lessonIndex >= 0 &&
        lessonIndex < LearningProgressState.modules[moduleIndex].lessons.length;
  }
}
