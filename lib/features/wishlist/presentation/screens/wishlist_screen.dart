import 'package:bio_xplora_portal/core/network/course_service.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/api_models.dart';
import '../../../internship/presentation/screens/internship_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _courseService = CourseService();
  List<CourseModel> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final res = await _courseService.getWishlist();
    if (!mounted) return;
    if (res.success) {
      setState(() { _items = res.data ?? []; _loading = false; });
    } else {
      setState(() { _error = res.message ?? 'Failed to load wishlist'; _loading = false; });
    }
  }

  Future<void> _remove(String courseId) async {
    await _courseService.removeFromWishlist(int.tryParse(courseId) ?? 0);
    _load();
  }

  String _currency(double value) => '\u20B9${value.toInt()}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.wishlist),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
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
              : _items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_outline_rounded, size: 64, color: AppColors.textHint),
                          SizedBox(height: 16),
                          Text('No wishlisted items yet',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          SizedBox(height: 8),
                          Text('Browse internships and courses\nto add them to your wishlist',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.paddingMD),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final price = item.priceOptions.isNotEmpty
                              ? item.priceOptions.first.price
                              : 0.0;
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                const SizedBox(height: 6),
                                Text(item.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySM),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(item.duration, style: AppTextStyles.bodySM),
                                    const SizedBox(width: 12),
                                    Text(item.level, style: AppTextStyles.bodySM),
                                    const Spacer(),
                                    Text(_currency(price),
                                        style: const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => InternshipDetailScreen(internshipId: item.id),
                                          ),
                                        ),
                                        child: const Text('View Details'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _remove(item.id),
                                        child: const Text('Remove'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
