import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningProgressState {
  LearningProgressState({
    required Set<int> completedLessonIndexes,
    required this.finalQuizPassed,
    required this.completionDate,
  }) : completedLessonIndexes = Set.unmodifiable(completedLessonIndexes);

  factory LearningProgressState.initial() {
    return LearningProgressState(
      completedLessonIndexes: <int>{},
      finalQuizPassed: false,
      completionDate: null,
    );
  }

  static const int totalLessons = 5;
  static const String courseTitle = 'Medical Coding Internship';
  static const String issuerName = 'Bioxplora';
  static const String recipientName = 'Vimalraj K';

  final Set<int> completedLessonIndexes;
  final bool finalQuizPassed;
  final DateTime? completionDate;

  int get completedLessonsCount => completedLessonIndexes.length;

  bool get allLessonsCompleted => completedLessonsCount >= totalLessons;

  bool get certificateUnlocked => allLessonsCompleted && finalQuizPassed;

  double get progressValue {
    const totalUnits = totalLessons + 1;
    final completedUnits = completedLessonsCount + (finalQuizPassed ? 1 : 0);
    return completedUnits / totalUnits;
  }

  LearningProgressState copyWith({
    Set<int>? completedLessonIndexes,
    bool? finalQuizPassed,
    DateTime? completionDate,
    bool updateCompletionDate = false,
  }) {
    return LearningProgressState(
      completedLessonIndexes:
          completedLessonIndexes ?? this.completedLessonIndexes,
      finalQuizPassed: finalQuizPassed ?? this.finalQuizPassed,
      completionDate: updateCompletionDate ? completionDate : this.completionDate,
    );
  }
}

class LearningProgressStore {
  LearningProgressStore._();

  static final LearningProgressStore instance = LearningProgressStore._();

  static const String _completedLessonsKey =
      'learning_progress.completed_lessons';
  static const String _finalQuizPassedKey =
      'learning_progress.final_quiz_passed';
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
    final completedLessonIndexes = (_preferences!
                .getStringList(_completedLessonsKey) ??
            const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    final completionDateValue = _preferences!.getString(_completionDateKey);

    progress.value = LearningProgressState(
      completedLessonIndexes: completedLessonIndexes,
      finalQuizPassed: _preferences!.getBool(_finalQuizPassedKey) ?? false,
      completionDate: completionDateValue == null
          ? null
          : DateTime.tryParse(completionDateValue),
    );

    _initialized = true;
  }

  Future<void> markLessonCompleted(int lessonIndex) async {
    if (lessonIndex < 0 || lessonIndex >= LearningProgressState.totalLessons) {
      return;
    }

    await ensureInitialized();
    final updatedLessonIndexes = <int>{
      ...progress.value.completedLessonIndexes,
      lessonIndex,
    };

    await _saveState(
      progress.value.copyWith(completedLessonIndexes: updatedLessonIndexes),
    );
  }

  Future<void> markFinalQuizPassed() async {
    await ensureInitialized();
    if (progress.value.finalQuizPassed) {
      return;
    }

    await _saveState(progress.value.copyWith(finalQuizPassed: true));
  }

  Future<void> _saveState(LearningProgressState state) async {
    final syncedState = _syncCompletionDate(state);
    progress.value = syncedState;

    await _preferences!.setStringList(
      _completedLessonsKey,
      syncedState.completedLessonIndexes
          .map((lessonIndex) => lessonIndex.toString())
          .toList(),
    );
    await _preferences!.setBool(
      _finalQuizPassedKey,
      syncedState.finalQuizPassed,
    );

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
}
