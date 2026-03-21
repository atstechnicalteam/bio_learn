import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../data/models/internship_models.dart';
import '../../data/repositories/internship_repository.dart';
import '../../bloc/internship_bloc.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';

class InternshipDetailScreen extends StatefulWidget {
  final String internshipId;
  const InternshipDetailScreen({super.key, required this.internshipId});

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InternshipBloc(repository: InternshipRepositoryImpl())
        ..add(InternshipDetailRequested(id: widget.internshipId)),
      child: BlocBuilder<InternshipBloc, InternshipState>(
        builder: (context, state) {
          if (state is InternshipLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          if (state is InternshipDetailLoaded) {
            return _DetailContent(internship: state.internship);
          }
          if (state is InternshipError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(state.message)),
            );
          }
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  final InternshipDetailModel internship;
  const _DetailContent({required this.internship});

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  int _selectedPriceIndex = 2; // Default: 4 Weeks (Most Popular)
  final Set<int> _expandedModules = {};

  @override
  Widget build(BuildContext context) {
    final selectedPrice =
        widget.internship.priceOptions.isNotEmpty
            ? widget.internship.priceOptions[_selectedPriceIndex]
            : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textWhite),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.internship.imageUrl.isNotEmpty
                      ? Image.network(widget.internship.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.primary))
                      : Container(color: AppColors.primary),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      widget.internship.title,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Rating
                  Text(widget.internship.title, style: AppTextStyles.headingMD),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${widget.internship.rating} Rating',
                          style: AppTextStyles.bodyMD),
                      const SizedBox(width: 8),
                      Text('| ${widget.internship.studentsEnrolled} Students Enrolled',
                          style: AppTextStyles.bodyMD),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text('Up to ${widget.internship.duration}',
                          style: AppTextStyles.bodySM),
                      const SizedBox(width: 12),
                      const Icon(Icons.bar_chart_rounded,
                          color: AppColors.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text(widget.internship.level, style: AppTextStyles.bodySM),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingMD),
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingMD),

                  // Duration selector
                  Text('Select Internship Duration', style: AppTextStyles.headingSM),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        widget.internship.priceOptions.length,
                        (i) => _DurationCard(
                          option: widget.internship.priceOptions[i],
                          isSelected: _selectedPriceIndex == i,
                          onTap: () => setState(() => _selectedPriceIndex = i),
                        ),
                      ),
                    ),
                  ),
                  if (selectedPrice != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Price',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '₹${selectedPrice.price.toInt()}',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                              ),
                              if (selectedPrice.originalPrice != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '₹${selectedPrice.originalPrice!.toInt()}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textHint,
                                      decoration: TextDecoration.lineThrough),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${(((selectedPrice.originalPrice! - selectedPrice.price) / selectedPrice.originalPrice!) * 100).toInt()}% OFF',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.error),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.verified_outlined,
                                  color: AppColors.success, size: 14),
                              SizedBox(width: 4),
                              Text('Includes Internship Certificate',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.paddingMD),
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingMD),

                  // About
                  Text('About This Program', style: AppTextStyles.headingSM),
                  const SizedBox(height: 8),
                  Text(widget.internship.about, style: AppTextStyles.bodyMD),
                  const SizedBox(height: AppSizes.paddingMD),

                  // What you'll learn
                  Text('What You Will Learn', style: AppTextStyles.headingSM),
                  const SizedBox(height: 8),
                  ...widget.internship.whatYouWillLearn.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    color: AppColors.textSecondary, fontSize: 14)),
                            Expanded(
                              child: Text(item, style: AppTextStyles.bodyMD),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: AppSizes.paddingMD),

                  // Internship includes
                  Text('Internship Includes', style: AppTextStyles.headingSM),
                  const SizedBox(height: 8),
                  ...widget.internship.includes.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  size: 14, color: AppColors.textWhite),
                            ),
                            const SizedBox(width: 10),
                            Text(item, style: AppTextStyles.bodyMD),
                          ],
                        ),
                      )),
                  const SizedBox(height: AppSizes.paddingMD),

                  // Course Modules
                  Text('Course Modules', style: AppTextStyles.headingSM),
                  const SizedBox(height: 8),
                  ...List.generate(
                    widget.internship.modules.length,
                    (i) => _ModuleAccordion(
                      module: widget.internship.modules[i],
                      isExpanded: _expandedModules.contains(i),
                      onToggle: () => setState(() {
                        if (_expandedModules.contains(i)) {
                          _expandedModules.remove(i);
                        } else {
                          _expandedModules.add(i);
                        }
                      }),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppPrimaryButton(
              text: AppStrings.enrollNow,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppOutlinedButton(
                    text: AppStrings.addToCart,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppOutlinedButton(
                    text: AppStrings.addToWishlist,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  final dynamic option;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBackground : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (option.isMostPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Most Popular',
                    style: TextStyle(
                        fontSize: 9, color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ),
            Text(option.duration,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary)),
            Text('₹${option.price.toInt()}',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _ModuleAccordion extends StatelessWidget {
  final dynamic module;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _ModuleAccordion({
    required this.module,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: ListTile(
        onTap: onToggle,
        contentPadding: EdgeInsets.zero,
        title: Text(module.title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
        subtitle: Text('${module.lessonsCount} Lessons • ${module.quizzesCount} Quiz',
            style: AppTextStyles.bodySM),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
