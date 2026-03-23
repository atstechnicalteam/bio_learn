import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/portal_store.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../home/data/models/home_models.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../../learning/presentation/screens/my_learning_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    this.program,
    this.programs,
  }) : assert(
          program != null || (programs != null && programs.length > 0),
          'Provide a program or a non-empty program list.',
        );

  final ProgramSelection? program;
  final List<ProgramSelection>? programs;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'upi';
  bool _isProcessing = false;
  late final HomeRepository _homeRepository;
  late List<ProgramSelection> _checkoutItems;
  List<InternshipModel> _courseSuggestions = const <InternshipModel>[];
  bool _isLoadingSuggestions = true;

  @override
  void initState() {
    super.initState();
    _homeRepository = HomeRepositoryImpl();
    _checkoutItems = widget.programs != null && widget.programs!.isNotEmpty
        ? List<ProgramSelection>.from(widget.programs!)
        : widget.program != null
            ? <ProgramSelection>[widget.program!]
            : <ProgramSelection>[];
    _loadCourseSuggestions();
  }

  List<ProgramSelection> get _items {
    return List<ProgramSelection>.unmodifiable(_checkoutItems);
  }

  double get _subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.price);

  double get _selectedPlanSavings {
    return _items.fold<double>(0, (sum, item) {
      final originalPrice = item.originalPrice;
      if (originalPrice == null || originalPrice <= item.price) {
        return sum;
      }
      return sum + (originalPrice - item.price);
    });
  }

  int get _courseCount => _items.where((item) => item.isCourse).length;

  double get _multiCourseOffer => _courseCount >= 2 ? 500 : 0;

  bool get _isUpiOfferEligible => _subtotal >= 5000;

  double get _upiOffer {
    if (_selectedPaymentMethod != 'upi' || !_isUpiOfferEligible) {
      return 0;
    }
    return 500;
  }

  double get _payableAmount {
    final total = _subtotal - _multiCourseOffer - _upiOffer;
    return total < 0 ? 0 : total;
  }

  String _currency(double value) => '\u20B9${value.toInt()}';

  List<InternshipModel> get _availableOfferCourses {
    final currentIds = _items.map((item) => item.id).toSet();
    return _courseSuggestions
        .where((course) => !currentIds.contains(course.id))
        .toList();
  }

  Future<void> _loadCourseSuggestions() async {
    try {
      final courses = await _homeRepository.getCourses();
      if (!mounted) {
        return;
      }
      setState(() {
        _courseSuggestions = courses;
        _isLoadingSuggestions = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoadingSuggestions = false);
    }
  }

  ProgramSelection? _selectionForCourse(InternshipModel course) {
    if (course.priceOptions.isEmpty) {
      return null;
    }

    final preferredIndex = course.priceOptions.indexWhere(
      (option) => option.isMostPopular,
    );
    final selectedOption = preferredIndex >= 0
        ? course.priceOptions[preferredIndex]
        : course.priceOptions.last;

    return ProgramSelection(
      id: course.id,
      title: course.title,
      description: course.description,
      imageUrl: course.imageUrl,
      level: course.level,
      durationLabel: selectedOption.duration,
      priceOptionId: selectedOption.id,
      price: selectedOption.price,
      originalPrice: selectedOption.originalPrice,
    );
  }

  Future<void> _addOfferCourse(InternshipModel course) async {
    final selection = _selectionForCourse(course);
    if (selection == null || _items.any((item) => item.id == selection.id)) {
      return;
    }

    await PortalStore.instance.addToCart(selection);
    if (!mounted) {
      return;
    }

    setState(() {
      _checkoutItems = [..._checkoutItems, selection];
    });

    final remainingToUnlock = 2 - _courseCount;
    final courseLabel = remainingToUnlock == 1 ? 'course' : 'courses';
    final message = _multiCourseOffer > 0
        ? '${course.title} added. Rs.500 offer applied.'
        : remainingToUnlock > 0
            ? '${course.title} added. Add $remainingToUnlock more $courseLabel to unlock Rs.500 off.'
            : '${course.title} added to your order.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _completePayment() async {
    if (_isProcessing || _items.isEmpty) {
      return;
    }

    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await PortalStore.instance.completePayment(_items);

    if (!mounted) {
      return;
    }

    final itemCount = _items.length;
    final successMessage = itemCount == 1
        ? '${_items.first.title} enrolled successfully.'
        : '$itemCount programs enrolled successfully.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage)),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyLearningScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(AppStrings.checkout),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pageWidth =
              constraints.maxWidth >= 560 ? 470.0 : double.infinity;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: pageWidth),
                child: Column(
                  children: [
                    _CheckoutCard(
                      title: _items.length > 1
                          ? 'Cart Summary'
                          : 'Order Summary',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _OrderItemTile(
                                title: item.title,
                                subtitle:
                                    '${item.durationLabel} | ${item.level}',
                                price: _currency(item.price),
                              ),
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 10),
                          _SummaryRow(
                            label: 'Subtotal',
                            value: _currency(_subtotal),
                          ),
                          if (_selectedPlanSavings > 0) ...[
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Selected Plan Savings',
                              value: '-${_currency(_selectedPlanSavings)}',
                              isDiscount: true,
                              isInfoOnly: true,
                            ),
                          ],
                          if (_multiCourseOffer > 0) ...[
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: '2 Course Offer',
                              value: '-${_currency(_multiCourseOffer)}',
                              isDiscount: true,
                            ),
                          ],
                          if (_selectedPaymentMethod == 'upi' &&
                              _upiOffer > 0) ...[
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'UPI Offer',
                              value: '-${_currency(_upiOffer)}',
                              isDiscount: true,
                            ),
                          ],
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 10),
                          _SummaryRow(
                            label: 'Payable Total',
                            value: _currency(_payableAmount),
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CheckoutCard(
                      title: 'Offers',
                      child: Column(
                        children: [
                          _OfferTile(
                            title: 'Buy 2 Courses, Get Rs.500 Off',
                            subtitle: _courseCount >= 2
                                ? 'Offer applied to your cart.'
                                : 'Add 2 courses to the cart to unlock this offer.',
                            isApplied: _multiCourseOffer > 0,
                          ),
                          if (_multiCourseOffer == 0) ...[
                            const SizedBox(height: 12),
                            if (_isLoadingSuggestions)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              )
                            else if (_availableOfferCourses.isNotEmpty)
                              _OfferCourseGrid(
                                items: _availableOfferCourses.take(2).toList(),
                                currencyFormatter: _currency,
                                selectionBuilder: _selectionForCourse,
                                onAdd: _addOfferCourse,
                              ),
                          ],
                          const SizedBox(height: 10),
                          _OfferTile(
                            title: 'UPI Offer Rs.500 Off',
                            subtitle: _isUpiOfferEligible
                                ? 'Choose UPI to get Rs.500 off on orders of Rs.5000 or more.'
                                : 'Available on orders of Rs.5000 or more.',
                            isApplied: _upiOffer > 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _CheckoutCard(
                      title: 'Payment Method',
                      child: Column(
                        children: [
                          _PaymentOption(
                            title: 'UPI',
                            subtitle: _isUpiOfferEligible
                                ? 'Pay using any UPI app and save Rs.500'
                                : 'Pay using any UPI app',
                            icon: Icons.account_balance_wallet_outlined,
                            value: 'upi',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) =>
                                setState(() => _selectedPaymentMethod = value),
                          ),
                          _PaymentOption(
                            title: 'Credit / Debit Card',
                            subtitle: 'Visa, Mastercard, Rupay',
                            icon: Icons.credit_card_outlined,
                            value: 'card',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) =>
                                setState(() => _selectedPaymentMethod = value),
                          ),
                          _PaymentOption(
                            title: 'Net Banking',
                            subtitle: 'All major banks supported',
                            icon: Icons.account_balance_outlined,
                            value: 'netbanking',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) =>
                                setState(() => _selectedPaymentMethod = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: AppPrimaryButton(
          text: _isProcessing
              ? 'Processing...'
              : 'Pay ${_currency(_payableAmount)}',
          onPressed: _isProcessing || _items.isEmpty ? null : _completePayment,
        ),
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingSM),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          price,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isTotal = false,
    this.isInfoOnly = false,
  });

  final String label;
  final String value;
  final bool isDiscount;
  final bool isTotal;
  final bool isInfoOnly;

  @override
  Widget build(BuildContext context) {
    final color = isDiscount
        ? (isInfoOnly ? AppColors.textSecondary : AppColors.success)
        : isTotal
            ? AppColors.primary
            : AppColors.textPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isInfoOnly ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({
    required this.title,
    required this.subtitle,
    required this.isApplied,
  });

  final String title;
  final String subtitle;
  final bool isApplied;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isApplied ? AppColors.successLight : AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isApplied ? Icons.local_offer_rounded : Icons.sell_outlined,
            color: isApplied ? AppColors.success : AppColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isApplied ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardBackground : AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(subtitle, style: AppTextStyles.bodySM),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferCourseGrid extends StatelessWidget {
  const _OfferCourseGrid({
    required this.items,
    required this.currencyFormatter,
    required this.selectionBuilder,
    required this.onAdd,
  });

  final List<InternshipModel> items;
  final String Function(double value) currencyFormatter;
  final ProgramSelection? Function(InternshipModel course) selectionBuilder;
  final ValueChanged<InternshipModel> onAdd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 360 && items.length > 1;
        final cardWidth = useTwoColumns
            ? (constraints.maxWidth - 10) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((course) {
            final selection = selectionBuilder(course);
            return SizedBox(
              width: cardWidth,
              child: _OfferCourseCard(
                title: course.title,
                description: course.description,
                planLabel: selection == null
                    ? ''
                    : '${selection.durationLabel} | ${currencyFormatter(selection.price)}',
                onAdd: selection == null ? null : () => onAdd(course),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _OfferCourseCard extends StatelessWidget {
  const _OfferCourseCard({
    required this.title,
    required this.description,
    required this.planLabel,
    required this.onAdd,
  });

  final String title;
  final String description;
  final String planLabel;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'Recommended Course',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            planLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add Course',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
