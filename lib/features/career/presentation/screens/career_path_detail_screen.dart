import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../home/data/models/home_models.dart';
import '../../../home/data/repositories/home_repository.dart';

class CareerPathDetailScreen extends StatefulWidget {
  final String careerId;
  const CareerPathDetailScreen({super.key, required this.careerId});

  @override
  State<CareerPathDetailScreen> createState() => _CareerPathDetailScreenState();
}

class _CareerPathDetailScreenState extends State<CareerPathDetailScreen> {
  bool _isLoading = true;
  CareerPathModel? _career;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final career =
          await HomeRepositoryImpl().getCareerPathDetail(widget.careerId);
      if (mounted) setState(() { _career = career; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_error != null || _career == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(_error ?? 'Error')));
    }
    final career = _career!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.careerPaths),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // High Demand Badge
            if (career.isHighDemand)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.highDemandBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded, color: AppColors.highDemandText, size: 14),
                    SizedBox(width: 4),
                    Text('High Demand',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.highDemandText)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(career.title, style: AppTextStyles.headingLG),
            const SizedBox(height: 8),
            Text(career.description, style: AppTextStyles.bodyMD),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // What You Will Do
            Text('What You Will Do', style: AppTextStyles.headingSM),
            const SizedBox(height: 12),
            ...career.whatYouWillDo.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 13, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item, style: AppTextStyles.bodyMD)),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Skills
            Text('Skills You Will Learn', style: AppTextStyles.headingSM),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: career.skills.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(s,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textPrimary)),
                  )).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Learning Path
            Text('Learning Path', style: AppTextStyles.headingSM),
            const SizedBox(height: 12),
            ...List.generate(career.learningPath.length, (i) {
              final step = career.learningPath[i];
              final isLast = i == career.learningPath.length - 1;
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${step.step}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 40,
                            color: AppColors.success.withOpacity(0.3),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(step.title,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            Text(step.subtitle, style: AppTextStyles.bodySM),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Career Opportunities
            Text('Career Opportunities', style: AppTextStyles.headingSM),
            const SizedBox(height: 12),
            ...career.careerOpportunities.map((opp) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline_rounded,
                          color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 10),
                      Text(opp, style: AppTextStyles.bodyMD),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Salary Insight
            Text('Salary Insight', style: AppTextStyles.headingSM),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                    ),
                    child: const Center(
                      child: Text('₹',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Average Salary in India',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text(career.salaryRange,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: AppPrimaryButton(
          text: 'Start This Path',
          onPressed: () {},
        ),
      ),
    );
  }
}
