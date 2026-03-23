import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';
import '../learning_progress_store.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.of(context).canPop() ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ) : null,
        title: const Text(AppStrings.myLearning),
      ),
      body: const _MyLearningBody(),
    );
  }
}

class _MyLearningBody extends StatelessWidget {
  const _MyLearningBody();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LearningProgressState>(
      valueListenable: LearningProgressStore.instance.progress,
      builder: (context, progress, _) {
        final percent = (progress.progressValue * 100).round();
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primary,
                    child: const Center(
                      child: Icon(
                        Icons.biotech_outlined,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LearningProgressState.courseTitle,
                      style: AppTextStyles.headingMD,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusMD),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Course Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '$percent%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress.progressValue,
                              backgroundColor: AppColors.progressBg,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.primary,
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${progress.completedLessonsCount} / ${LearningProgressState.totalLessons} Lessons Completed',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${progress.completedModulesCount} / ${LearningProgressState.totalModules} Modules Completed',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: progress.certificateUnlocked
                                  ? AppColors.successLight
                                  : AppColors.backgroundGrey,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMD,
                              ),
                            ),
                            child: Text(
                              progress.certificateUnlocked
                                  ? 'All modules and lessons are completed. Your certificate is now unlocked.'
                                  : 'Finish every module, complete all lessons, and pass each module quiz to unlock your certificate.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: progress.certificateUnlocked
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Course Modules', style: AppTextStyles.headingSM),
                    const SizedBox(height: 12),
                    ...LearningProgressState.modules.asMap().entries.map((entry) {
                      final index = entry.key;
                      final module = entry.value;
                      final isUnlocked = progress.isModuleUnlocked(index);
                      final isCompleted = progress.isModuleCompleted(index);
                      final done = progress.completedLessonsInModule(index);
                      final hasStarted =
                          done > 0 || progress.isModuleQuizPassed(index);
                      final subtitle = isUnlocked
                          ? '$done / ${module.lessons.length} Lessons | 1 Quiz | ${module.estimatedTime}'
                          : 'Complete previous module to unlock';
                      final actionLabel = isCompleted
                          ? 'Review Module'
                          : hasStarted
                              ? 'Continue Module'
                              : 'Start Module';
                      return _ModuleCard(
                        title: module.title,
                        subtitle: subtitle,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        actionLabel: actionLabel,
                        onTap: isUnlocked
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LessonScreen(moduleIndex: index),
                                  ),
                                )
                            : null,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.isUnlocked,
    required this.isCompleted,
    required this.actionLabel,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isUnlocked;
  final bool isCompleted;
  final String actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppColors.success
        : isUnlocked
            ? AppColors.primary
            : AppColors.textSecondary;
    final bg = isCompleted
        ? AppColors.success.withValues(alpha: 0.1)
        : isUnlocked
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.backgroundGrey;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isUnlocked
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (!isUnlocked)
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 13,
                            color: AppColors.textHint,
                          ),
                        if (!isUnlocked) const SizedBox(width: 4),
                        Expanded(
                          child: Text(subtitle, style: AppTextStyles.bodySM),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUnlocked ? color : AppColors.border,
                  ),
                ),
                child: Text(
                  isCompleted
                      ? 'Completed'
                      : isUnlocked
                          ? 'Unlocked'
                          : 'Locked',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (isUnlocked) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onTap,
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.moduleIndex,
  });

  final int moduleIndex;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final LearningProgressStore _progressStore = LearningProgressStore.instance;
  int _currentLesson = 0;

  LearningModuleDefinition get _module =>
      LearningProgressState.modules[widget.moduleIndex];

  @override
  void initState() {
    super.initState();
    _currentLesson = _firstIncompleteLessonIndex(_progressStore.progress.value);
  }

  int _firstIncompleteLessonIndex(LearningProgressState progress) {
    for (var index = 0; index < _module.lessons.length; index++) {
      if (!progress.isLessonCompleted(widget.moduleIndex, index)) {
        return index;
      }
    }
    return _module.lessons.length - 1;
  }

  Future<void> _markComplete(int lessonIndex) async {
    final progress = _progressStore.progress.value;
    if (progress.isLessonCompleted(widget.moduleIndex, lessonIndex)) {
      return;
    }

    await _progressStore.markLessonCompleted(
      moduleIndex: widget.moduleIndex,
      lessonIndex: lessonIndex,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentLesson = _firstIncompleteLessonIndex(_progressStore.progress.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLastModule =
        widget.moduleIndex == LearningProgressState.totalModules - 1;

    return ValueListenableBuilder<LearningProgressState>(
      valueListenable: _progressStore.progress,
      builder: (context, progress, _) {
        final quizPassed = progress.isModuleQuizPassed(widget.moduleIndex);
        final allLessonsDone =
            progress.allLessonsCompletedInModule(widget.moduleIndex);
        final completedCount =
            progress.completedLessonsInModule(widget.moduleIndex);
        final lesson = _module.lessons[_currentLesson];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(LearningProgressState.courseTitle),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _markComplete(_currentLesson),
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    color: Colors.black87,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 12,
                          child: Text(
                            lesson.duration,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 10,
                          right: 12,
                          child: Row(
                            children: [
                              Text(
                                'HD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 28,
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: const LinearProgressIndicator(
                                value: 0.4,
                                backgroundColor: Colors.white30,
                                valueColor: AlwaysStoppedAnimation(
                                  AppColors.accent,
                                ),
                                minHeight: 3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Module ${widget.moduleIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(lesson.title, style: AppTextStyles.headingMD),
                      const SizedBox(height: 6),
                      Text(
                        _module.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lessons in Module ${widget.moduleIndex + 1}',
                            style: AppTextStyles.headingSM,
                          ),
                          Text(
                            '$completedCount / ${_module.lessons.length} Completed',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._module.lessons.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isCompleted =
                            progress.isLessonCompleted(widget.moduleIndex, index);
                        final isCurrent = index == _currentLesson;

                        return GestureDetector(
                          onTap: () => setState(() => _currentLesson = index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppColors.cardBackground
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusMD,
                              ),
                              border: Border.all(
                                color: isCurrent
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isCurrent ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? AppColors.success
                                        : isCurrent
                                            ? AppColors.primary
                                            : AppColors.backgroundGrey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check_rounded
                                        : isCurrent
                                            ? Icons.play_arrow_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                    color: isCompleted || isCurrent
                                        ? Colors.white
                                        : AppColors.textHint,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: isCurrent
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Video | ${item.duration}${isCurrent ? ' | Playing' : ''}',
                                        style: AppTextStyles.bodySM,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.download_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: progress.certificateUnlocked
                              ? AppColors.successLight
                              : quizPassed
                                  ? AppColors.cardBackground
                                  : AppColors.backgroundGrey,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMD),
                        ),
                        child: Text(
                          progress.certificateUnlocked
                              ? 'All modules and lessons are completed. Your certificate is ready in the certificate screen.'
                              : quizPassed
                                  ? 'This module is completed. Continue with the next module to keep progressing toward your certificate.'
                                  : allLessonsDone
                                      ? 'All lessons are complete. Pass the module quiz to finish this module.'
                                      : 'Finish every lesson in this module to unlock the quiz and certificate progress.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: progress.certificateUnlocked
                                ? AppColors.success
                                : quizPassed
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: allLessonsDone
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                      moduleIndex: widget.moduleIndex,
                                      isLastModule: isLastModule,
                                    ),
                                  ),
                                )
                            : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: allLessonsDone
                                ? quizPassed
                                    ? AppColors.successLight
                                    : AppColors.cardBackground
                                : AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMD),
                            border: Border.all(
                              color: allLessonsDone
                                  ? quizPassed
                                      ? AppColors.success
                                      : AppColors.primary
                                  : AppColors.border,
                              width: allLessonsDone ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: quizPassed
                                      ? AppColors.success
                                      : allLessonsDone
                                          ? AppColors.primary
                                          : AppColors.backgroundGrey,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  quizPassed
                                      ? Icons.check_rounded
                                      : allLessonsDone
                                          ? Icons.play_arrow_rounded
                                          : Icons.lock_outline_rounded,
                                  color: allLessonsDone
                                      ? Colors.white
                                      : AppColors.textHint,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Module ${widget.moduleIndex + 1} Final Quiz',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: allLessonsDone
                                            ? quizPassed
                                                ? AppColors.success
                                                : AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      quizPassed
                                          ? 'Quiz passed | Module completed'
                                          : '10 Questions | Needs all lessons',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
