import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.notifications)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        children: [
          // Today's reminder card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSizes.radiusLG),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Reminder",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Complete your daily practice and maintain your streak.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        ),
                        child: const Text(
                          'Start Practice',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Today'),
          _NotificationCard(
            date: '18.03.2026',
            time: '03:12 PM',
            icon: Icons.health_and_safety_outlined,
            iconBg: AppColors.accentLight,
            iconColor: AppColors.primary,
            title: 'Continue your Medical Coding Internship',
            subtitle: 'You are on Module 2 – ICD-10 Basics',
            actionText: 'Resume Learning',
            onAction: () {},
          ),
          _NotificationCard(
            date: '17.03.2026',
            time: '03:12 PM',
            icon: Icons.quiz_outlined,
            iconBg: const Color(0xFFFFF8E1),
            iconColor: Colors.orange,
            title: 'Module 1 Quiz Pending',
            subtitle: 'Complete the quiz to unlock next module',
            actionText: 'Take Quiz',
            onAction: () {},
          ),
          const SizedBox(height: 16),
          _SectionLabel(label: 'Yesterday'),
          _NotificationCard(
            date: '17.03.2026',
            time: '03:12 PM',
            icon: Icons.local_fire_department_outlined,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: Colors.deepOrange,
            title: '🔥 3 Day Streak Achieved',
            subtitle: 'Keep practicing daily',
            actionText: null,
            onAction: null,
          ),
          const SizedBox(height: 16),
          _SectionLabel(label: 'Older'),
          _NotificationCard(
            date: '01.03.2026',
            time: '03:12 PM',
            icon: Icons.star_outline_rounded,
            iconBg: AppColors.successLight,
            iconColor: AppColors.success,
            title: 'New Bioinformatics course available',
            subtitle: 'Explore now',
            actionText: null,
            onAction: null,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String date;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const _NotificationCard({
    required this.date,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
              Text(date,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
              Text(time,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          if (actionText != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAction,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Center(
                  child: Text(
                    actionText!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
