import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../../../config/routes.dart';
import '../../../models/bid_model.dart';
import '../../../widgets/bid_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/loading_widget.dart';

class RecentBidsSection extends StatelessWidget {
  final List<BidModel> bids;
  final bool isLoading;
  final VoidCallback? onViewAllTap;
  final Function(BidModel)? onBidTap;

  const RecentBidsSection({
    super.key,
    required this.bids,
    this.isLoading = false,
    this.onViewAllTap,
    this.onBidTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Bids',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed:
                    onViewAllTap ??
                    () {
                      Navigator.pushNamed(context, AppRoutes.bidList);
                    },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Iconsax.arrow_right_3,
                      size: 16.w,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Content
        _buildContent(context),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return Column(
        children: List.generate(3, (index) => const ShimmerBidCard()),
      );
    }

    if (bids.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: CompactEmptyState(
          icon: Iconsax.document_text,
          message: 'No bids yet. Create your first bid!',
          actionText: 'Create Bid',
          onAction: () => Navigator.pushNamed(context, AppRoutes.createBid),
        ),
      );
    }

    return Column(
      children: bids.asMap().entries.map((entry) {
        final index = entry.key;
        final bid = entry.value;

        return CompactBidCard(
              bid: bid,
              onTap: () {
                if (onBidTap != null) {
                  onBidTap!(bid);
                } else {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.bidDetails,
                    arguments: {'bidId': bid.id},
                  );
                }
              },
            )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 700 + (index * 100)),
              duration: 300.ms,
            )
            .slideX(begin: 0.1, curve: Curves.easeOut);
      }).toList(),
    );
  }
}
