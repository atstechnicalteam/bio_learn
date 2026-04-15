import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/student_service.dart';
import '../../../../shared/models/user_session_store.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'certificates_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _studentService = StudentService();

  // Stats loaded from API
  int _coursesEnrolled = 0;
  int _completed = 0;
  int _inProgress = 0;
  int _certificatesEarned = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final res = await _studentService.getStats();
    if (!mounted) return;
    if (res.success && res.data != null) {
      final d = res.data!;
      setState(() {
        _coursesEnrolled = (d['courses_enrolled'] as num?)?.toInt() ?? 0;
        _completed      = (d['completed'] as num?)?.toInt() ?? 0;
        _inProgress     = (d['in_progress'] as num?)?.toInt() ?? 0;
        _certificatesEarned = (d['certificates_earned'] as num?)?.toInt() ?? 0;
        _statsLoading   = false;
      });
    } else {
      setState(() => _statsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.profile, style: AppTextStyles.headingLG),
              const SizedBox(height: 16),

              // ── Profile card from UserSessionStore ──────────────────────
              ValueListenableBuilder<UserSessionState>(
                valueListenable: UserSessionStore.instance.state,
                builder: (context, session, _) {
                  final departmentText = session.department.trim().isNotEmpty
                      ? session.department.trim()
                      : 'Student';
                  final collegeText = session.collegeName.trim().isNotEmpty
                      ? session.collegeName.trim()
                      : 'Add your college details';
                  final emailText = session.email.trim().isNotEmpty
                      ? session.email.trim()
                      : session.mobile.trim().isNotEmpty
                          ? '+91 ${session.mobile.trim()}'
                          : 'No email added';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(session.displayName, style: AppTextStyles.headingSM),
                              const SizedBox(height: 2),
                              Text(emailText,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(departmentText,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                              Text(collegeText,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20),
                          onPressed: () {
                            // TODO: navigate to edit profile screen
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              Text('Your Learning', style: AppTextStyles.headingSM),
              const SizedBox(height: 12),

              // ── Stats from API ──────────────────────────────────────────
              _statsLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _StatCard(value: '$_coursesEnrolled', label: 'Courses Enrolled')),
                            const SizedBox(width: 10),
                            Expanded(child: _StatCard(value: '$_completed', label: 'Completed')),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _StatCard(value: '$_inProgress', label: 'In Progress')),
                            const SizedBox(width: 10),
                            Expanded(child: _StatCard(value: '$_certificatesEarned', label: 'Certificates Earned')),
                          ],
                        ),
                      ],
                    ),

              const SizedBox(height: 20),
              Text('Quick Actions', style: AppTextStyles.headingSM),
              const SizedBox(height: 12),
              _QuickActionTile(
                icon: Icons.workspace_premium_outlined,
                title: 'My Certificates',
                subtitle: 'View or download certificates',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CertificatesScreen()),
                ),
              ),
              _QuickActionTile(
                icon: Icons.history_outlined,
                title: 'Payment History',
                subtitle: 'View your past payments',
                onTap: () => _showPaymentHistory(context),
              ),
              _QuickActionTile(
                icon: Icons.download_outlined,
                title: 'Downloads',
                subtitle: 'Completed video lessons',
                onTap: () => _showDownloads(context),
              ),
              _QuickActionTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Contact support or FAQs',
                onTap: () {},
              ),

              const SizedBox(height: 20),
              Text('Settings', style: AppTextStyles.headingSM),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                    Switch(value: true, onChanged: (v) {}, activeThumbColor: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // ── Logout ──────────────────────────────────────────────────
              GestureDetector(
                onTap: () => _confirmLogout(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.error)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try { await AuthRepositoryImpl().logout(); } catch (_) {}
              await UserSessionStore.instance.clear();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showPaymentHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PaymentHistorySheet(service: _studentService),
    );
  }

  void _showDownloads(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DownloadsSheet(service: _studentService),
    );
  }
}

// ── Payment History Sheet ───────────────────────────────────────────────────

class _PaymentHistorySheet extends StatefulWidget {
  const _PaymentHistorySheet({required this.service});
  final StudentService service;

  @override
  State<_PaymentHistorySheet> createState() => _PaymentHistorySheetState();
}

class _PaymentHistorySheetState extends State<_PaymentHistorySheet> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await widget.service.getPaymentHistory();
    if (!mounted) return;
    setState(() { _items = res.data ?? []; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Payment History', style: AppTextStyles.headingSM),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('No payment history found.', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.separated(
                        controller: ctrl,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (_, i) {
                          final p = _items[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(p['course_name']?.toString() ?? 'Course', style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(p['created_at']?.toString() ?? '', style: AppTextStyles.bodySM),
                            trailing: Text(
                              '\u20B9${p['amount'] ?? 0}',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Downloads Sheet ─────────────────────────────────────────────────────────

class _DownloadsSheet extends StatefulWidget {
  const _DownloadsSheet({required this.service});
  final StudentService service;

  @override
  State<_DownloadsSheet> createState() => _DownloadsSheetState();
}

class _DownloadsSheetState extends State<_DownloadsSheet> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await widget.service.getDownloads();
    if (!mounted) return;
    setState(() { _items = res.data ?? []; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Downloads', style: AppTextStyles.headingSM),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(child: Text('No downloads yet.', style: TextStyle(color: AppColors.textSecondary)))
                    : ListView.separated(
                        controller: ctrl,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (_, i) {
                          final d = _items[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.play_circle_outline_rounded, color: AppColors.primary),
                            title: Text(d['title']?.toString() ?? 'Lesson', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(d['course_name']?.toString() ?? '', style: AppTextStyles.bodySM),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Shared small widgets ────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySM),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.backgroundGrey, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Text(subtitle, style: AppTextStyles.bodySM),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
