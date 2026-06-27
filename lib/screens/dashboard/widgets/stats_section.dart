import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../dashboard_state.dart';

class StatsSection extends StatelessWidget {
  final DashboardStats stats;
  final bool isLoading;
  final VoidCallback? onTotalTap;
  final VoidCallback? onPendingTap;
  final VoidCallback? onApprovedTap;
  final VoidCallback? onDraftTap;

  const StatsSection({
    super.key,
    required this.stats,
    this.isLoading = false,
    this.onTotalTap,
    this.onPendingTap,
    this.onApprovedTap,
    this.onDraftTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.trend_up,
                      size: 14.w,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${stats.successRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Stats Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Total Bids',
                  value: stats.totalBids.toString(),
                  icon: Iconsax.document_text,
                  color: AppColors.primary,
                  onTap: onTotalTap,
                  delay: 0,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  title: 'Pending',
                  value: stats.pendingBids.toString(),
                  icon: Iconsax.clock,
                  color: AppColors.warning,
                  onTap: onPendingTap,
                  delay: 100,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Approved',
                  value: stats.approvedBids.toString(),
                  icon: Iconsax.tick_circle,
                  color: AppColors.success,
                  onTap: onApprovedTap,
                  delay: 200,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  title: 'Drafts',
                  value: stats.draftBids.toString(),
                  icon: Iconsax.edit,
                  color: AppColors.grey600,
                  onTap: onDraftTap,
                  delay: 300,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Total Value Card
          _buildTotalValueCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    int delay = 0,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(icon, size: 20.w, color: color),
                    ),
                    Icon(
                      Iconsax.arrow_right_3,
                      size: 16.w,
                      color: AppColors.grey400,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  isLoading ? '...' : value,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
        )
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildTotalValueCard() {
    return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Bid Value',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isLoading
                          ? '...'
                          : Helpers.formatCurrency(stats.totalAmount),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.tick_circle,
                                size: 12.w,
                                color: AppColors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                Helpers.formatCurrency(stats.approvedAmount),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Approved',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(
                  Iconsax.money_recive,
                  size: 36.w,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }
}
