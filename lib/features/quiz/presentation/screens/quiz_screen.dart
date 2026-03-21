import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../profile/presentation/screens/certificates_screen.dart';

// ─── Quiz Screen ──────────────────────────────────────────────────────────────

class QuizScreen extends StatefulWidget {
  final bool isLastModule;
  const QuizScreen({super.key, this.isLastModule = false});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  final Map<int, int> _answers = {};

  final List<Map<String, dynamic>> _questions = [
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
                  // Module label
                  const Text(
                    'MODULE 1 – MEDICAL CODING BASICS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Module 1 Quiz', style: AppTextStyles.headingMD),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${_questions.length} Questions',
                          style: AppTextStyles.bodySM),
                      const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                      const Text('5 mins', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                      const Text('Passing 70%', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Question ${_currentQuestion + 1} of ${_questions.length}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.progressBg,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    question['question'] as String,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary, height: 1.4),
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
                    onPressed: _selectedAnswer == null
                        ? null
                        : () {
                            _answers[_currentQuestion] = _selectedAnswer!;
                            if (_isLast) {
                              // calculate score
                              int correct = 0;
                              _answers.forEach((qi, ai) {
                                if (_questions[qi]['correct'] == ai) correct++;
                              });
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => QuizResultScreen(
                                    correct: correct,
                                    total: _questions.length,
                                    answers: _answers,
                                    questions: _questions,
                                    isLastModule: widget.isLastModule,
                                  ),
                                ),
                              );
                            } else {
                              setState(() {
                                _currentQuestion++;
                                _selectedAnswer = _answers[_currentQuestion];
                              });
                            }
                          },
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
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

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
              child: Text(text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: AppColors.textPrimary,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quiz Result Screen ───────────────────────────────────────────────────────

class QuizResultScreen extends StatelessWidget {
  final int correct;
  final int total;
  final Map<int, int> answers;
  final List<Map<String, dynamic>> questions;
  final bool isLastModule;

  const QuizResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.answers,
    required this.questions,
    this.isLastModule = false,
  });

  double get _percentage => correct / total;
  bool get _passed => _percentage >= 0.7;

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'MODULE 1 – MEDICAL CODING BASICS',
              style: TextStyle(
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
                  // Passed/Failed badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _passed ? AppColors.success : AppColors.error,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _passed ? Icons.check_circle_outline : Icons.cancel_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _passed ? 'Passed' : 'Retry',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Score: $correct / $total',
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
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
                        const Text('Quiz performance',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          '${(_percentage * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text('Passing score: 70%',
                              style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text('Completed in 4 mins',
                              style: TextStyle(fontSize: 12)),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_passed ? '🎉' : '⚠️', style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _passed
                                    ? 'Congratulations! Module Completed'
                                    : 'Keep Going!',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _passed
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _passed
                                    ? 'You passed the module quiz and unlocked the next lesson path in your course.'
                                    : 'Please review the lessons and try again to unlock the next part of your course.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _passed
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                            label: 'Correct\nanswers', value: '$correct'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatBox(
                            label: 'Needs\nreview',
                            value: '${total - correct}'),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: _StatBox(label: 'Next\nmodule', value: '30 min'),
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
              text: _passed
                  ? (isLastModule ? 'View Certificate' : 'Continue to Next Module')
                  : 'Back to Video',
              onPressed: () {
                if (_passed && isLastModule) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CertificatesScreen()),
                  );
                } else {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
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
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

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
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Review Answers Screen ────────────────────────────────────────────────────

class ReviewAnswersScreen extends StatelessWidget {
  final Map<int, int> answers;
  final List<Map<String, dynamic>> questions;

  const ReviewAnswersScreen({
    super.key,
    required this.answers,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(AppStrings.reviewAnswers),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Module 1 Quiz Review',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Score: ${answers.entries.where((e) => questions[e.key]['correct'] == e.value).length}/${questions.length}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...questions.asMap().entries.map((entry) {
              final qi = entry.key;
              final q = entry.value;
              final userAnswer = answers[qi];
              final correctAnswer = q['correct'] as int;
              final isCorrect = userAnswer == correctAnswer;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'QUESTION ${qi + 1}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCorrect ? AppColors.success : AppColors.error,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
                                color: isCorrect ? AppColors.success : AppColors.error,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isCorrect ? 'Correct' : 'Incorrect',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isCorrect ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(q['question'] as String,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    ...(q['options'] as List<String>).asMap().entries.map((opt) {
                      final isCorrectOption = opt.key == correctAnswer;
                      final isUserSelected = opt.key == userAnswer;
                      final isWrongUserSelection =
                          isUserSelected && !isCorrectOption;

                      Color bgColor = AppColors.background;
                      Color borderColor = AppColors.border;
                      Widget? leadingWidget;

                      if (isCorrectOption) {
                        bgColor = AppColors.successLight;
                        borderColor = AppColors.success;
                        leadingWidget = Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 14),
                        );
                      } else if (isWrongUserSelection) {
                        bgColor = AppColors.errorLight;
                        borderColor = AppColors.error;
                        leadingWidget = Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 14),
                        );
                      } else {
                        final letter = String.fromCharCode(65 + opt.key);
                        leadingWidget = Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGrey,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Text(letter,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary)),
                          ),
                        );
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(color: borderColor, width: isCorrectOption || isWrongUserSelection ? 1.5 : 1),
                        ),
                        child: Row(
                          children: [
                            leadingWidget,
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(opt.value,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary)),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (!isCorrect) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(8),
                          border: const Border(
                            left: BorderSide(color: AppColors.primary, width: 3),
                          ),
                        ),
                        child: const Text(
                          'Explanation: The World Health Organization (WHO) owns, develops, and publishes the International Classification of Diseases.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: AppPrimaryButton(
          text: 'Back to Results',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
