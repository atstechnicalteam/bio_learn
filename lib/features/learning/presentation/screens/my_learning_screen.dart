import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../learning_progress_store.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';

class MyLearningScreen extends StatelessWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
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
        final completionPercent = (progress.progressValue * 100).round();

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
                  errorBuilder: (_, __, ___) => Container(
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
                                '$completionPercent%',
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
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${progress.completedLessonsCount} / ${LearningProgressState.totalLessons} Lessons Completed',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
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
                                  ? 'Certificate unlocked. You can now open your certificate screen and export the PDF.'
                                  : 'Complete all lessons and pass the final quiz to unlock your certificate.',
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
                    _ModuleCard(
                      title: 'Module 1 - Introduction to Medical Coding',
                      subtitle: '5 Lessons | 1 Final Quiz | 30 Minutes',
                      isUnlocked: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LessonScreen(),
                        ),
                      ),
                    ),
                    const _ModuleCard(
                      title: 'Module 2 - ICD-10 Basics',
                      subtitle: 'Complete previous module to unlock',
                      isUnlocked: false,
                    ),
                    const _ModuleCard(
                      title: 'Module 3 - Clinical Documentation',
                      subtitle: 'Complete previous module to unlock',
                      isUnlocked: false,
                    ),
                    const _ModuleCard(
                      title: 'Module 4 - Medical Billing',
                      subtitle: 'Complete previous module to unlock',
                      isUnlocked: false,
                    ),
                    const _ModuleCard(
                      title: 'Module 5 - Practical Coding Exercises',
                      subtitle: 'Complete previous module to unlock',
                      isUnlocked: false,
                    ),
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
  final String title;
  final String subtitle;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: isUnlocked
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUnlocked ? AppColors.success : AppColors.border,
                  ),
                ),
                child: Text(
                  isUnlocked ? 'Unlocked' : 'Locked',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        isUnlocked ? AppColors.success : AppColors.textSecondary,
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
                child: const Text('Start Lesson'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final LearningProgressStore _progressStore = LearningProgressStore.instance;

  int _currentLesson = 0;
  bool _allCompleted = false;

  final List<Map<String, dynamic>> _lessons = [
    {
      'title': '1. What is Medical Coding?',
      'duration': '8:30',
      'completed': false,
    },
    {
      'title': '2. History of Medical Coding',
      'duration': '10:25',
      'completed': false,
    },
    {
      'title': '3. Healthcare Ecosystem',
      'duration': '12:15',
      'completed': false,
    },
    {
      'title': '4. Role of a Medical Coder',
      'duration': '9:20',
      'completed': false,
    },
    {
      'title': '5. Basic Terminology',
      'duration': '15:00',
      'completed': false,
    },
  ];

  @override
  void initState() {
    super.initState();

    final progress = _progressStore.progress.value;
    for (var index = 0; index < _lessons.length; index++) {
      _lessons[index]['completed'] =
          progress.completedLessonIndexes.contains(index);
    }
    _allCompleted = progress.allLessonsCompleted;
  }

  int get _completedLessonCount =>
      _lessons.where((lesson) => lesson['completed'] == true).length;

  Future<void> _markComplete(int index) async {
    if (_lessons[index]['completed'] == true) {
      return;
    }

    setState(() {
      _lessons[index]['completed'] = true;
      _allCompleted = _lessons.every((lesson) => lesson['completed'] == true);
    });

    await _progressStore.markLessonCompleted(index);
  }

  @override
  Widget build(BuildContext context) {
    final finalQuizPassed = _progressStore.progress.value.finalQuizPassed;

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
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
                    const Positioned(
                      bottom: 10,
                      left: 12,
                      child: Text(
                        '04:12',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const Positioned(
                      bottom: 10,
                      right: 12,
                      child: Row(
                        children: [
                          Text(
                            '10:45',
                            style: TextStyle(color: Colors.white, fontSize: 12),
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
                    child: const Text(
                      'Module 1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _lessons[_currentLesson]['title'] as String,
                    style: AppTextStyles.headingMD,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Understand the medical classification systems from early mortality tracking to modern ICD-10 implementation.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lessons in Module 1', style: AppTextStyles.headingSM),
                      Text(
                        '$_completedLessonCount / ${_lessons.length} Completed',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._lessons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final lesson = entry.value;
                    final isCompleted = lesson['completed'] as bool;
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
                            color:
                                isCurrent ? AppColors.primary : AppColors.border,
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
                                        : Icons.lock_outline_rounded,
                                color: isCompleted || isCurrent
                                    ? Colors.white
                                    : AppColors.textHint,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson['title'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isCurrent
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Video | ${lesson['duration']}${isCurrent ? ' | Playing' : ''}',
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
                      color: finalQuizPassed
                          ? AppColors.successLight
                          : AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Text(
                      finalQuizPassed
                          ? 'Final quiz passed. Your certificate is ready in the certificate screen.'
                          : 'Finish every lesson to unlock the final quiz and certificate.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: finalQuizPassed
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _allCompleted
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const QuizScreen(isLastModule: true),
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
                        color: _allCompleted
                            ? AppColors.cardBackground
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                        border: Border.all(
                          color: _allCompleted
                              ? AppColors.primary
                              : AppColors.border,
                          width: _allCompleted ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _allCompleted
                                  ? AppColors.primary
                                  : AppColors.backgroundGrey,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _allCompleted
                                  ? Icons.play_arrow_rounded
                                  : Icons.lock_outline_rounded,
                              color: _allCompleted
                                  ? Colors.white
                                  : AppColors.textHint,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Module 1 Final Quiz',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _allCompleted
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const Text(
                                  '10 Questions | Needs all lessons',
                                  style: TextStyle(
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
  }
}
