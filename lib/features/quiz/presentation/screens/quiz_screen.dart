import 'package:bio_xplora_portal/core/network/student_service.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../learning/presentation/learning_progress_store.dart';
import '../../../profile/presentation/screens/certificates_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.moduleIndex,
    this.isLastModule = false,
    // When provided, questions are fetched from API using this module ID
    this.moduleId,
    this.enrollmentId,
  });

  final int moduleIndex;
  final bool isLastModule;
  final int? moduleId;
  final int? enrollmentId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _studentService = StudentService();

  // State
  bool _loading = false;
  String? _error;
  QuizModel? _apiQuiz;      // loaded from API
  int _currentQuestion = 0;
  int? _selectedAnswer;
  final Map<int, int> _answers = {};

  // Fallback static questions (used when moduleId is null)
  final List<Map<String, dynamic>> _staticQuestions = const [
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

  // Derived
  List<Map<String, dynamic>> get _questions {
    if (_apiQuiz != null) {
      return _apiQuiz!.questions.map((q) => {
        'question': q.question,
        'options': [q.optionA, q.optionB, q.optionC, q.optionD],
        'correct': -1, // server does not return correct option during quiz
        'question_id': q.id,
      }).toList();
    }
    return _staticQuestions;
  }

  LearningModuleDefinition get _module =>
      LearningProgressState.modules[widget.moduleIndex];

  bool get _isLast => _currentQuestion == _questions.length - 1;
  bool get _useApi => widget.moduleId != null;

  @override
  void initState() {
    super.initState();
    if (_useApi) _fetchQuiz();
  }

  Future<void> _fetchQuiz() async {
    setState(() { _loading = true; _error = null; });
    final res = await _studentService.getQuiz(widget.moduleId!);
    if (!mounted) return;
    if (res.success) {
      setState(() { _apiQuiz = res.data; _loading = false; });
    } else {
      setState(() { _error = res.message ?? 'Failed to load quiz questions'; _loading = false; });
    }
  }

  Future<void> _submit() async {
    _answers[_currentQuestion] = _selectedAnswer!;
    if (!_isLast) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = _answers[_currentQuestion];
      });
      return;
    }

    // Submit to API if we have quiz + enrollment IDs
    if (_useApi && _apiQuiz != null && widget.enrollmentId != null) {
      final answers = _answers.entries.map((e) {
        final q = _apiQuiz!.questions[e.key];
        final optionLetter = ['a', 'b', 'c', 'd'][e.value];
        return {'question_id': int.tryParse(q.id) ?? 0, 'selected_option': optionLetter};
      }).toList();

      setState(() => _loading = true);
      final res = await _studentService.submitQuiz((int.tryParse(_apiQuiz!.id) ?? 0),
          widget.enrollmentId!, answers.cast<Map<String, dynamic>>());
      if (!mounted) return;
      setState(() => _loading = false);

      if (res.success && res.data != null) {
        final result = res.data!;
        if (result.isPassed) {
          await LearningProgressStore.instance.markModuleQuizPassed(widget.moduleIndex);
        }
        if (!mounted) return;
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            correct: result.score,
            total: result.total,
            answers: _answers,
            questions: _questions,
            moduleIndex: widget.moduleIndex,
            isLastModule: widget.isLastModule,
            attemptId: int.tryParse(result.attemptId) ?? 0,
            studentService: _studentService,
          ),
        ));
        return;
      }
    }

    // Fallback: score locally from static questions
    var correct = 0;
    _answers.forEach((index, answer) {
      if (_questions[index]['correct'] == answer) correct++;
    });
    final passed = (correct / _questions.length) >= 0.7;
    if (passed) await LearningProgressStore.instance.markModuleQuizPassed(widget.moduleIndex);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => QuizResultScreen(
        correct: correct,
        total: _questions.length,
        answers: _answers,
        questions: _questions,
        moduleIndex: widget.moduleIndex,
        isLastModule: widget.isLastModule,
        studentService: _studentService,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _fetchQuiz, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentQuestion];
    final options = question['options'] as List;
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
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
                  Text(_module.title.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('Module ${widget.moduleIndex + 1} Quiz', style: AppTextStyles.headingMD),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('${_questions.length} Questions', style: AppTextStyles.bodySM),
                    const Text(' | ', style: TextStyle(color: AppColors.textSecondary)),
                    Text(_apiQuiz != null ? '${_apiQuiz!.timeLimitMinutes} mins' : '5 mins',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const Text(' | ', style: TextStyle(color: AppColors.textSecondary)),
                    Text('Passing ${_apiQuiz?.passingPercentage ?? 70}%',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                  const SizedBox(height: 16),
                  Text('Question ${_currentQuestion + 1} of ${_questions.length}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.progressBg,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(question['question'] as String,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4)),
                  const SizedBox(height: 20),
                  ...options.asMap().entries.map((e) => _AnswerOption(
                    text: e.value as String,
                    isSelected: _selectedAnswer == e.key,
                    onTap: () => setState(() => _selectedAnswer = e.key),
                  )),
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

// ── Answer option widget ──────────────────────────────────────────────────────

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({required this.text, required this.isSelected, required this.onTap});
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
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 2),
              ),
              child: isSelected ? const Icon(Icons.circle, color: Colors.white, size: 10) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quiz result screen ────────────────────────────────────────────────────────

class QuizResultScreen extends StatefulWidget {
  const QuizResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.answers,
    required this.questions,
    required this.moduleIndex,
    this.isLastModule = false,
    this.attemptId,
    required this.studentService,
  });

  final int correct;
  final int total;
  final Map<int, int> answers;
  final List<Map<String, dynamic>> questions;
  final int moduleIndex;
  final bool isLastModule;
  final int? attemptId;
  final StudentService studentService;

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  List<QuizReviewModel>? _reviewData;

  Future<void> _loadReview() async {
    if (widget.attemptId == null) {
      _showLocalReview();
      return;
    }
    final res = await widget.studentService.reviewQuizAnswers(widget.attemptId!); 
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() => _reviewData = res.data);
      _showApiReview();
    } else {
      _showLocalReview();
    }
  }

  void _showLocalReview() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReviewAnswersScreen(answers: widget.answers, questions: widget.questions),
    ));
  }

  void _showApiReview() {
    if (_reviewData == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ApiReviewAnswersScreen(reviewData: _reviewData!),
    ));
  }

  double get _percentage => widget.correct / widget.total;
  bool get _passed => _percentage >= 0.7;

  @override
  Widget build(BuildContext context) {
    final module = LearningProgressState.modules[widget.moduleIndex];
    final message = _passed
        ? widget.isLastModule
            ? 'You completed the final module. Your certificate is now unlocked.'
            : 'You passed! The next module is now available in My Learning.'
        : 'Please review the lessons and try again to complete this module.';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.of(context).pop()),
        title: const Text(AppStrings.quizResult),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(module.title.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.radiusMD), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: _passed ? AppColors.success : AppColors.error, borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_passed ? Icons.check_circle_outline : Icons.cancel_outlined, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(_passed ? 'Passed' : 'Retry',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text('Your Score: ${widget.correct} / ${widget.total}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.backgroundGrey, borderRadius: BorderRadius.circular(AppSizes.radiusMD)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quiz performance', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('${(_percentage * 100).toInt()}%',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _passed ? AppColors.successLight : AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Text(message, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _passed ? AppColors.success : AppColors.error)),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _StatBox(label: 'Correct\nanswers', value: '${widget.correct}')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatBox(label: 'Needs\nreview', value: '${widget.total - widget.correct}')),
                  ]),
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
              text: _passed && widget.isLastModule ? 'View Certificate' : 'Back to Lesson',
              onPressed: () {
                if (_passed && widget.isLastModule) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CertificatesScreen()));
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 10),
            AppOutlinedButton(
              text: AppStrings.reviewAnswers,
              onPressed: _loadReview,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppSizes.radiusMD), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }
}

// ── Local review (fallback with static questions) ─────────────────────────────

class ReviewAnswersScreen extends StatelessWidget {
  const ReviewAnswersScreen({super.key, required this.answers, required this.questions});
  final Map<int, int> answers;
  final List<Map<String, dynamic>> questions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.reviewAnswers)),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        itemCount: questions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final question = questions[index];
          final selected = answers[index];
          final correct = question['correct'] as int;
          final options = question['options'] as List<String>;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radiusMD), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Question ${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 6),
              Text(question['question'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ...options.asMap().entries.map((entry) {
                final i = entry.key;
                final isCorrect = i == correct;
                final isSelected = i == selected;
                final color = isCorrect ? AppColors.success : isSelected ? AppColors.error : AppColors.textSecondary;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppColors.successLight : isSelected ? AppColors.errorLight : AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(entry.value, style: TextStyle(fontSize: 13, fontWeight: isCorrect || isSelected ? FontWeight.w600 : FontWeight.w400, color: color))),
                    if (isCorrect) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    if (!isCorrect && isSelected) const Icon(Icons.cancel_rounded, color: AppColors.error, size: 18),
                  ]),
                );
              }),
            ]),
          );
        },
      ),
    );
  }
}

// ── API review (from server with correct answers + explanations) ──────────────

class ApiReviewAnswersScreen extends StatelessWidget {
  const ApiReviewAnswersScreen({super.key, required this.reviewData});
  final List<QuizReviewModel> reviewData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.reviewAnswers)),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        itemCount: reviewData.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final r = reviewData[index];
          final options = {'a': r.optionA, 'b': r.optionB, 'c': r.optionC, 'd': r.optionD};
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppSizes.radiusMD), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Question ${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 6),
              Text(r.question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              ...options.entries.map((entry) {
                final key = entry.key;
                final isCorrect = key == r.correctOption;
                final isSelected = key == r.selectedOption;
                final color = isCorrect ? AppColors.success : isSelected ? AppColors.error : AppColors.textSecondary;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppColors.successLight : isSelected ? AppColors.errorLight : AppColors.backgroundGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(entry.value, style: TextStyle(fontSize: 13, fontWeight: isCorrect || isSelected ? FontWeight.w600 : FontWeight.w400, color: color))),
                    if (isCorrect) const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                    if (!isCorrect && isSelected) const Icon(Icons.cancel_rounded, color: AppColors.error, size: 18),
                  ]),
                );
              }),
              if (r.explanation != null && r.explanation!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(8)),
                  child: Text('💡 ${r.explanation}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ),
              ],
            ]),
          );
        },
      ),
    );
  }
}
