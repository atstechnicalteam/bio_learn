import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/student_service.dart';
import '../../../../shared/models/api_models.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';
import '../learning_progress_store.dart';

class MyLearningScreen extends StatefulWidget {
  const MyLearningScreen({super.key});

  @override
  State<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends State<MyLearningScreen> {
  final _studentService = StudentService();
  List<EnrollmentModel> _enrollments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final res = await _studentService.getMyLearning();
    if (!mounted) return;
    if (res.success) {
      setState(() { _enrollments = res.data ?? []; _loading = false; });
    } else {
      setState(() { _error = res.message ?? 'Failed to load your courses'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.of(context).pop())
            : null,
        title: const Text(AppStrings.myLearning),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _enrollments.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 64, color: AppColors.textHint),
                          SizedBox(height: 16),
                          Text('No enrolled courses yet',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          SizedBox(height: 8),
                          Text('Enroll in an internship or course\nto start learning.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.paddingMD),
                        itemCount: _enrollments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) => _EnrollmentCard(
                          enrollment: _enrollments[i],
                          studentService: _studentService,
                        ),
                      ),
                    ),
    );
  }
}

// ── Enrollment card ─────────────────────────────────────────────────────────

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.enrollment, required this.studentService});
  final EnrollmentModel enrollment;
  final StudentService studentService;

  @override
  Widget build(BuildContext context) {
    final pct = (enrollment.progress * 100).round();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusMD)),
            ),
            child: const Center(
              child: Icon(Icons.biotech_outlined, color: AppColors.primary, size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(enrollment.courseName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                // Progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progress', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text('$pct%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: enrollment.progress,
                    backgroundColor: AppColors.progressBg,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${enrollment.doneLessons} / ${enrollment.totalLessons} Lessons',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                // Module list (if available from enrollment)
                if (enrollment.modules != null && enrollment.modules!.isNotEmpty)
                  ..._buildModuleList(context, enrollment),
                const SizedBox(height: 4),
                // Open learning button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _EnrollmentDetailScreen(
                          enrollment: enrollment,
                          studentService: studentService,
                        ),
                      ),
                    ),
                    child: Text(pct == 100 ? 'Review Course' : pct == 0 ? 'Start Learning' : 'Continue Learning'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildModuleList(BuildContext context, EnrollmentModel enrollment) {
    return enrollment.modules!.take(3).map((m) {
      final done = m.completedLessons ?? 0;
      final total = m.lessonsCount ?? 0;
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(
              done == total && total > 0 ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: done == total && total > 0 ? AppColors.success : AppColors.textHint,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(m.title,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Text('$done/$total', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      );
    }).toList();
  }
}

// ── Enrollment detail screen (modules + lessons from API) ────────────────────

class _EnrollmentDetailScreen extends StatefulWidget {
  const _EnrollmentDetailScreen({required this.enrollment, required this.studentService});
  final EnrollmentModel enrollment;
  final StudentService studentService;

  @override
  State<_EnrollmentDetailScreen> createState() => _EnrollmentDetailScreenState();
}

class _EnrollmentDetailScreenState extends State<_EnrollmentDetailScreen> {
  EnrollmentProgressModel? _progress;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() { _loading = true; _error = null; });
    final res = await widget.studentService.getEnrollmentProgress(
      int.tryParse(widget.enrollment.enrollmentId) ?? 0,
    );
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _progress = res.data; _loading = false; });
    } else {
      setState(() { _error = res.message ?? 'Failed to load progress'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollment = widget.enrollment;
    final pct = (_progress?.progress ?? enrollment.progress) * 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(enrollment.courseName, overflow: TextOverflow.ellipsis)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress summary
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Course Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                Text('${pct.round()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress?.progress ?? enrollment.progress,
                                backgroundColor: AppColors.progressBg,
                                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_progress?.doneLessons ?? enrollment.doneLessons} / ${_progress?.totalLessons ?? enrollment.totalLessons} Lessons Completed',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Modules', style: AppTextStyles.headingSM),
                      const SizedBox(height: 12),
                      ...(_progress?.modules ?? enrollment.modules ?? []).asMap().entries.map((entry) {
                        final idx = entry.key;
                        final m = entry.value;
                        final done = m.completedLessons ?? 0;
                        final total = m.lessonsCount ?? 0;
                        final completed = total > 0 && done >= total;
                        return _ApiModuleCard(
                          moduleIndex: idx,
                          module: m,
                          done: done,
                          total: total,
                          completed: completed,
                          enrollmentId: int.tryParse(enrollment.enrollmentId) ?? 0,
                          courseId: int.tryParse(enrollment.courseId) ?? 0,
                          studentService: widget.studentService,
                          onRefresh: _loadProgress,
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}

// ── Module card using real API lessons ───────────────────────────────────────

class _ApiModuleCard extends StatefulWidget {
  const _ApiModuleCard({
    required this.moduleIndex,
    required this.module,
    required this.done,
    required this.total,
    required this.completed,
    required this.enrollmentId,
    required this.courseId,
    required this.studentService,
    required this.onRefresh,
  });
  final int moduleIndex;
  final Module module;
  final int done;
  final int total;
  final bool completed;
  final int enrollmentId;
  final int courseId;
  final StudentService studentService;
  final VoidCallback onRefresh;

  @override
  State<_ApiModuleCard> createState() => _ApiModuleCardState();
}

class _ApiModuleCardState extends State<_ApiModuleCard> {
  bool _expanded = false;
  ModuleDetailModel? _detail;
  bool _loadingDetail = false;

  Future<void> _loadDetail() async {
    if (_detail != null) { setState(() => _expanded = !_expanded); return; }
    setState(() => _loadingDetail = true);
    final res = await widget.studentService.getModuleDetail(
      widget.courseId, int.tryParse(widget.module.id) ?? 0,
    );
    if (!mounted) return;
    setState(() {
      _detail = res.data;
      _expanded = true;
      _loadingDetail = false;
    });
  }

  Future<void> _markLessonDone(int lessonId) async {
    await widget.studentService.markLessonComplete(lessonId, widget.enrollmentId);
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: widget.completed ? AppColors.success : AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: widget.completed ? AppColors.success : AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                widget.completed ? Icons.check_rounded : Icons.book_outlined,
                color: widget.completed ? Colors.white : AppColors.primary,
                size: 18,
              ),
            ),
            title: Text(widget.module.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text('${widget.done} / ${widget.total} Lessons', style: AppTextStyles.bodySM),
            trailing: _loadingDetail
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textSecondary),
            onTap: _loadDetail,
          ),
          if (_expanded && _detail != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  ..._detail!.lessons.map((lesson) {
                    return _LessonTile(
                      lesson: lesson,
                      enrollmentId: widget.enrollmentId,
                      onMarkDone: () => _markLessonDone(int.tryParse(lesson.id) ?? 0),
                    );
                  }),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.backgroundGrey,
                      child: const Icon(Icons.quiz_outlined, size: 18, color: AppColors.primary),
                    ),
                    title: Text(_detail!.quiz.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('${_detail!.quiz.totalQuestions} Questions | Pass ${_detail!.quiz.passingPercentage}%',
                        style: AppTextStyles.bodySM),
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(moduleIndex: widget.moduleIndex),
                        ),
                      ),
                      child: const Text('Take Quiz', style: TextStyle(fontSize: 12)),
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

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.enrollmentId, required this.onMarkDone});
  final Lesson lesson;
  final int enrollmentId;
  final VoidCallback onMarkDone;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: Icon(
        lesson.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
        color: lesson.isCompleted ? AppColors.success : AppColors.textHint,
        size: 20,
      ),
      title: Text(lesson.title, style: const TextStyle(fontSize: 13)),
      subtitle: Text('${lesson.durationSeconds ~/ 60} min', style: AppTextStyles.bodySM),
      trailing: lesson.isCompleted
          ? null
          : TextButton(
              onPressed: onMarkDone,
              child: const Text('Mark Done', style: TextStyle(fontSize: 11)),
            ),
    );
  }
}
