import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/models/portal_store.dart';
import '../../../internship/presentation/screens/internship_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  String _currency(double value) => '\u20B9${value.toInt()}';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PortalState>(
      valueListenable: PortalStore.instance.state,
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text(AppStrings.wishlist)),
          body: state.wishlist.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.favorite_outline_rounded,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No wishlisted items yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Browse internships and courses\nto add them to your wishlist',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  itemCount: state.wishlist.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.wishlist[index];
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
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(item.description, style: AppTextStyles.bodySM),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(item.durationLabel, style: AppTextStyles.bodySM),
                              const SizedBox(width: 12),
                              Text(item.level, style: AppTextStyles.bodySM),
                              const Spacer(),
                              Text(
                                _currency(item.price),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => InternshipDetailScreen(
                                        internshipId: item.id,
                                      ),
                                    ),
                                  ),
                                  child: const Text('View Details'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => PortalStore.instance
                                      .removeFromWishlist(item.id),
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
        );
      },
    );
  }
}
