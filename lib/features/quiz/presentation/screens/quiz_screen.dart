import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../learning/presentation/learning_progress_store.dart';
import '../../../profile/presentation/screens/certificates_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.moduleIndex,
    this.isLastModule = false,
  });

  final int moduleIndex;
  final bool isLastModule;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  final Map<int, int> _answers = {};

  LearningModuleDefinition get _module =>
      LearningProgressState.modules[widget.moduleIndex];

  final List<Map<String, dynamic>> _questions = const [
    {
      'question': 'What does ICD-10 stand for?',
      'options': [
        'A. International Classification of Diseases',
        'B. Internal Coding Data',
        'C. Integrated Clinical Data',
        'D. International Code Directory',
      ],
      'correct': 0,
    },
    {
      'question': 'Which organization publishes the ICD-10 codes?',
      'options': [
        'A. American Medical Association',
        'B. Centers for Disease Control',
        'C. World Health Organization',
        'D. National Health Institute',
      ],
      'correct': 2,
    },
    {
      'question': 'What is the primary role of a medical coder?',
      'options': [
        'A. Convert medical records into codes',
        'B. Treat patients',
        'C. Perform surgeries',
        'D. Manage hospital staff',
      ],
      'correct': 0,
    },
  ];

  bool get _isLast => _currentQuestion == _questions.length - 1;

  Future<void> _submit() async {
    _answers[_currentQuestion] = _selectedAnswer!;
    if (!_isLast) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = _answers[_currentQuestion];
      });
      return;
    }

    var correct = 0;
    _answers.forEach((index, answer) {
      if (_questions[index]['correct'] == answer) {
        correct++;
      }
    });

    final passed = (correct / _questions.length) >= 0.7;
    if (passed) {
      await LearningProgressStore.instance.markModuleQuizPassed(
        widget.moduleIndex,
      );
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          correct: correct,
          total: _questions.length,
          answers: _answers,
          questions: _questions,
          moduleIndex: widget.moduleIndex,
          isLastModule: widget.isLastModule,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Quiz'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _module.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Module ${widget.moduleIndex + 1} Quiz',
                    style: AppTextStyles.headingMD,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${_questions.length} Questions',
                          style: AppTextStyles.bodySM),
                      const Text(' | ',
                          style: TextStyle(color: AppColors.textSecondary)),
                      const Text('5 mins',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      const Text(' | ',
                          style: TextStyle(color: AppColors.textSecondary)),
                      const Text('Passing 70%',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Question ${_currentQuestion + 1} of ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.progressBg,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    question['question'] as String,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...(question['options'] as List<String>).asMap().entries.map(
                        (entry) => _AnswerOption(
                          text: entry.value,
                          isSelected: _selectedAnswer == entry.key,
                          onTap: () =>
                              setState(() => _selectedAnswer = entry.key),
                        ),
                      ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Row(
              children: [
                if (_currentQuestion > 0) ...[
                  Expanded(
                    child: AppOutlinedButton(
                      text: '< Prev',
                      onPressed: () => setState(() {
                        _currentQuestion--;
                        _selectedAnswer = _answers[_currentQuestion];
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: AppPrimaryButton(
                    text: _isLast ? 'View Score' : 'Next Question',
                    onPressed: _selectedAnswer == null ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBackground : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.circle, color: Colors.white, size: 10)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.answers,
    required this.questions,
    required this.moduleIndex,
    this.isLastModule = false,
  });

  final int correct;
  final int total;
  final Map<int, int> answers;
  final List<Map<String, dynamic>> questions;
  final int moduleIndex;
  final bool isLastModule;

  double get _percentage => correct / total;
  bool get _passed => _percentage >= 0.7;

  @override
  Widget build(BuildContext context) {
    final module = LearningProgressState.modules[moduleIndex];
    final message = _passed
        ? isLastModule
            ? 'You completed the final module. Your certificate is now unlocked.'
            : 'You passed this module quiz. The next module is now available in My Learning.'
        : 'Please review the lessons and try again to complete this module.';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(AppStrings.quizResult),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _passed ? AppColors.success : AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _passed
                              ? Icons.check_circle_outline
                              : Icons.cancel_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _passed ? 'Passed' : 'Retry',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Score: $correct / $total',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quiz performance',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(_percentage * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _passed
                          ? AppColors.successLight
                          : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _passed ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(label: 'Correct\nanswers', value: '$correct'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatBox(
                          label: 'Needs\nreview',
                          value: '${total - correct}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppPrimaryButton(
              text: _passed && isLastModule
                  ? 'View Certificate'
                  : 'Back to Lesson',
              onPressed: () {
                if (_passed && isLastModule) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CertificatesScreen(),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 10),
            AppOutlinedButton(
              text: AppStrings.reviewAnswers,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReviewAnswersScreen(
                    answers: answers,
                    questions: questions,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewAnswersScreen extends StatelessWidget {
  const ReviewAnswersScreen({
    super.key,
    required this.answers,
    required this.questions,
  });

  final Map<int, int> answers;
  final List<Map<String, dynamic>> questions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.reviewAnswers),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        itemCount: questions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final question = questions[index];
          final selected = answers[index];
          final correct = question['correct'] as int;
          final options = question['options'] as List<String>;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  question['question'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.asMap().entries.map((entry) {
                  final optionIndex = entry.key;
                  final isCorrect = optionIndex == correct;
                  final isSelected = optionIndex == selected;
                  final color = isCorrect
                      ? AppColors.success
                      : isSelected
                          ? AppColors.error
                          : AppColors.textSecondary;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? AppColors.successLight
                          : isSelected
                              ? AppColors.errorLight
                              : AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCorrect || isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: color,
                            ),
                          ),
                        ),
                        if (isCorrect)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                            size: 18,
                          ),
                        if (!isCorrect && isSelected)
                          const Icon(
                            Icons.cancel_rounded,
                            color: AppColors.error,
                            size: 18,
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
