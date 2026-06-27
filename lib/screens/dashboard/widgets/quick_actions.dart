import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../../../config/routes.dart';

class QuickActions extends StatelessWidget {
  final int unsyncedCount;
  final VoidCallback? onSyncTap;

  const QuickActions({super.key, this.unsyncedCount = 0, this.onSyncTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Iconsax.add_circle,
                  label: 'New Bid',
                  color: AppColors.primary,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.createBid),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _QuickActionCard(
                  icon: Iconsax.document_text,
                  label: 'All Bids',
                  color: AppColors.secondary,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.bidList),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _QuickActionCard(
                  icon: Iconsax.cloud,
                  label: 'Sync',
                  color: unsyncedCount > 0
                      ? AppColors.warning
                      : AppColors.success,
                  badge: unsyncedCount > 0 ? unsyncedCount.toString() : null,
                  onTap:
                      onSyncTap ??
                      () => Navigator.pushNamed(context, AppRoutes.syncStatus),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, size: 24.w, color: color),
                ),
                if (badge != null)
                  Positioned(
                    top: -6.h,
                    right: -6.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
