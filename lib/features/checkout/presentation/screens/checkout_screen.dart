import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(AppStrings.checkout),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          children: [
            // TODO: Add order summary, payment method selection from API
            SizedBox(height: 24),
            _OrderSummary(),
            SizedBox(height: 16),
            _PaymentMethods(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        child: AppPrimaryButton(
          text: 'Pay ₹3,499',
          onPressed: () {},
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', style: AppTextStyles.headingSM),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Medical Coding Internship (4 Weeks)', value: '₹4,999'),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Discount', value: '-₹1,500', isDiscount: true),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Total', value: '₹3,499', isTotal: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label,
              style: TextStyle(
                fontSize: isTotal ? 15 : 13,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
                color: AppColors.textPrimary,
              )),
        ),
        Text(value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isDiscount
                  ? AppColors.success
                  : isTotal
                      ? AppColors.primary
                      : AppColors.textPrimary,
            )),
      ],
    );
  }
}

class _PaymentMethods extends StatefulWidget {
  const _PaymentMethods();

  @override
  State<_PaymentMethods> createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<_PaymentMethods> {
  String _selected = 'upi';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: AppTextStyles.headingSM),
          const SizedBox(height: 12),
          _PaymentOption(
            title: 'UPI',
            subtitle: 'Pay using any UPI app',
            icon: Icons.account_balance_wallet_outlined,
            value: 'upi',
            groupValue: _selected,
            onChanged: (v) => setState(() => _selected = v!),
          ),
          _PaymentOption(
            title: 'Credit / Debit Card',
            subtitle: 'Visa, Mastercard, Rupay',
            icon: Icons.credit_card_outlined,
            value: 'card',
            groupValue: _selected,
            onChanged: (v) => setState(() => _selected = v!),
          ),
          _PaymentOption(
            title: 'Net Banking',
            subtitle: 'All major banks supported',
            icon: Icons.account_balance_outlined,
            value: 'netbanking',
            groupValue: _selected,
            onChanged: (v) => setState(() => _selected = v!),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
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
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: AppTextStyles.bodySM),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
