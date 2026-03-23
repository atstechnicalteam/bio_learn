import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/portal_store.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../bloc/internship_bloc.dart';
import '../../../checkout/presentation/screens/checkout_screen.dart';

class InternshipDetailScreen extends StatefulWidget {
  const InternshipDetailScreen({super.key, required this.internshipId});

  final String internshipId;

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
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          if (state is InternshipError) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(child: Text(state.message)),
            );
          }
          if (state is InternshipDetailLoaded) {
            return _DetailContent(internship: state.internship);
          }
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  const _DetailContent({required this.internship});

  final InternshipDetailModel internship;

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  final PortalStore _portalStore = PortalStore.instance;
  final Set<int> _expandedModules = <int>{};
  int _selectedPriceIndex = 0;

  @override
  void initState() {
    super.initState();
    final popularIndex = widget.internship.priceOptions.indexWhere(
      (option) => option.isMostPopular,
    );
    _selectedPriceIndex = popularIndex >= 0
        ? popularIndex
        : (widget.internship.priceOptions.isEmpty
            ? 0
            : widget.internship.priceOptions.length - 1);
  }

  String _currency(double value) => '\u20B9${value.toInt()}';

  ProgramSelection? get _selectedProgram {
    if (widget.internship.priceOptions.isEmpty) return null;
    final price = widget.internship.priceOptions[_selectedPriceIndex];
    return ProgramSelection(
      id: widget.internship.id,
      title: widget.internship.title,
      description: widget.internship.about,
      imageUrl: widget.internship.imageUrl,
      level: widget.internship.level,
      durationLabel: price.duration,
      priceOptionId: price.id,
      price: price.price,
      originalPrice: price.originalPrice,
    );
  }

  Future<void> _toggleWishlist() async {
    final program = _selectedProgram;
    if (program == null) return;
    final wasWishlisted = _portalStore.state.value.isWishlisted(program.id);
    await _portalStore.toggleWishlist(program);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasWishlisted ? 'Removed from wishlist.' : 'Added to wishlist.',
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    final program = _selectedProgram;
    if (program == null) return;
    await _portalStore.addToCart(program);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart.')),
    );
  }

  void _goToCheckout() {
    final program = _selectedProgram;
    if (program == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CheckoutScreen(program: program)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPrice = widget.internship.priceOptions.isEmpty
        ? null
        : widget.internship.priceOptions[_selectedPriceIndex];
    final selectedProgram = _selectedProgram;
    final isWishlisted = selectedProgram != null &&
        _portalStore.state.value.isWishlisted(selectedProgram.id);
    final isInCart = selectedProgram != null &&
        _portalStore.state.value.isInCart(
          selectedProgram.id,
          selectedProgram.priceOptionId,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textWhite,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.internship.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.internship.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppColors.primary),
                        )
                      : Container(color: AppColors.primary),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withValues(alpha: 0.82),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      widget.internship.title,
                      style: const TextStyle(
                        color: Colors.white,
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
                  Text(widget.internship.title, style: AppTextStyles.headingMD),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text('${widget.internship.rating} Rating'),
                        ],
                      ),
                      Text('| ${widget.internship.studentsEnrolled} Students Enrolled'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text('Up to ${widget.internship.duration}', style: AppTextStyles.bodySM),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(widget.internship.level, style: AppTextStyles.bodySM),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingMD),
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingMD),
                  Text('Select Internship Duration', style: AppTextStyles.headingSM),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final threeAcross = constraints.maxWidth >= 360;
                      final cardWidth = threeAcross
                          ? (constraints.maxWidth - 20) / 3
                          : 110.0;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          widget.internship.priceOptions.length,
                          (index) => SizedBox(
                            width: cardWidth,
                            child: _DurationCard(
                              option: widget.internship.priceOptions[index],
                              isSelected: _selectedPriceIndex == index,
                              onTap: () => setState(() => _selectedPriceIndex = index),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (selectedPrice != null) ...[
                    const SizedBox(height: 12),
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
                            'Total Price',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _currency(selectedPrice.price),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (selectedPrice.originalPrice != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  _currency(selectedPrice.originalPrice!),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textHint,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.verified_outlined, color: AppColors.success, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Includes Internship Certificate',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.paddingMD),
                  const Divider(),
                  const SizedBox(height: AppSizes.paddingMD),
                  Text('About This Program', style: AppTextStyles.headingSM),
                  const SizedBox(height: 8),
                  Text(widget.internship.about, style: AppTextStyles.bodyMD),
                  const SizedBox(height: AppSizes.paddingMD),
                  Text('What You Will Learn', style: AppTextStyles.headingSM),
                  const SizedBox(height: 8),
                  ...widget.internship.whatYouWillLearn.map(
                    (item) => _InfoBullet(text: item),
                  ),
                  const SizedBox(height: AppSizes.paddingMD),
                  Text('Internship Includes', style: AppTextStyles.headingSM),
                  const SizedBox(height: 8),
                  ...widget.internship.includes.map(
                    (item) => _InfoBullet(text: item, useCheckIcon: true),
                  ),
                  const SizedBox(height: AppSizes.paddingMD),
                  Text('Course Modules', style: AppTextStyles.headingSM),
                  const SizedBox(height: 8),
                  ...List.generate(
                    widget.internship.modules.length,
                    (index) => _ModuleAccordion(
                      module: widget.internship.modules[index],
                      isExpanded: _expandedModules.contains(index),
                      onToggle: () => setState(() {
                        if (_expandedModules.contains(index)) {
                          _expandedModules.remove(index);
                        } else {
                          _expandedModules.add(index);
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stackSecondaryButtons = constraints.maxWidth < 360;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppPrimaryButton(text: AppStrings.enrollNow, onPressed: _goToCheckout),
                const SizedBox(height: 10),
                if (stackSecondaryButtons) ...[
                  AppOutlinedButton(
                    text: isInCart ? 'Added to Cart' : AppStrings.addToCart,
                    onPressed: _addToCart,
                  ),
                  const SizedBox(height: 10),
                  AppOutlinedButton(
                    text: isWishlisted ? 'Wishlisted' : AppStrings.addToWishlist,
                    onPressed: _toggleWishlist,
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: AppOutlinedButton(
                          text: isInCart ? 'Added to Cart' : AppStrings.addToCart,
                          onPressed: _addToCart,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppOutlinedButton(
                          text: isWishlisted ? 'Wishlisted' : AppStrings.addToWishlist,
                          onPressed: _toggleWishlist,
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  const _DurationCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final PricingOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBackground : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (option.isMostPopular)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Most Popular',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            Text(
              option.duration,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\u20B9${option.price.toInt()}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBullet extends StatelessWidget {
  const _InfoBullet({
    required this.text,
    this.useCheckIcon = false,
  });

  final String text;
  final bool useCheckIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (useCheckIcon)
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
            )
          else
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.circle, size: 7, color: AppColors.primary),
            ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodyMD)),
        ],
      ),
    );
  }
}

class _ModuleAccordion extends StatelessWidget {
  const _ModuleAccordion({
    required this.module,
    required this.isExpanded,
    required this.onToggle,
  });

  final CourseModule module;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final lessons = module.lessons.isNotEmpty
        ? module.lessons
        : List<String>.generate(
            module.lessonsCount,
            (index) => 'Lesson ${index + 1}',
          );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onToggle,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            title: Text(
              module.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${module.lessonsCount} Lessons | ${module.quizzesCount} Quiz',
              style: AppTextStyles.bodySM,
            ),
            trailing: Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 6),
                  ...lessons.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${entry.key + 1}. ${entry.value}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundGrey,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.quiz_outlined, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Module quiz unlocks after completing these lessons.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
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
    );
  }
}
