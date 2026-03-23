import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/portal_store.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../learning/presentation/screens/my_learning_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.program});

  final ProgramSelection program;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'upi';
  bool _isProcessing = false;

  double get _discountValue {
    final originalPrice = widget.program.originalPrice;
    if (originalPrice == null || originalPrice <= widget.program.price) {
      return 0;
    }
    return originalPrice - widget.program.price;
  }

  String _currency(double value) => '\u20B9${value.toInt()}';

  Future<void> _completePayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await PortalStore.instance.completePayment(widget.program);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.program.title} enrolled successfully.',
        ),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyLearningScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final originalPrice = widget.program.originalPrice;

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
          final pageWidth = constraints.maxWidth >= 560 ? 460.0 : double.infinity;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: pageWidth),
                child: Column(
                  children: [
                    _CheckoutCard(
                      title: 'Order Summary',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SummaryRow(
                            label:
                                '${widget.program.title} (${widget.program.durationLabel})',
                            value: _currency(widget.program.price),
                          ),
                          if (_discountValue > 0) ...[
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Discount',
                              value: '-${_currency(_discountValue)}',
                              isDiscount: true,
                            ),
                          ],
                          if (originalPrice != null) ...[
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: 'Original Price',
                              value: _currency(originalPrice),
                            ),
                          ],
                          const SizedBox(height: 10),
                          const Divider(),
                          const SizedBox(height: 10),
                          _SummaryRow(
                            label: 'Total',
                            value: _currency(widget.program.price),
                            isTotal: true,
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
                            subtitle: 'Pay using any UPI app',
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
                            onChanged: (value) => setState(
                              () => _selectedPaymentMethod = value,
                            ),
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
              : 'Pay ${_currency(widget.program.price)}',
          onPressed: _isProcessing ? null : _completePayment,
        ),
      ),
    );
  }
}

class _CheckoutCard extends StatelessWidget {
  const _CheckoutCard({required this.title, required this.child});

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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isDiscount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final color = isDiscount
        ? AppColors.success
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AppTextStyles.bodySM),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: (value) => onChanged(value!),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
