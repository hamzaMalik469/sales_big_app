import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/app_colors.dart';
import '../core/utils/helpers.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.subtitle,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and Title Row
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 20.w, color: cardColor),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.w,
                    color: AppColors.grey400,
                  ),
              ],
            ),

            SizedBox(height: 16.h),

            // Value
            if (isLoading)
              Container(
                width: 60.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              )
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

            SizedBox(height: 4.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),

            // Subtitle
            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: cardColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Dashboard Stats Grid
class DashboardStatsGrid extends StatelessWidget {
  final int totalBids;
  final int pendingBids;
  final int approvedBids;
  final double totalAmount;
  final bool isLoading;
  final VoidCallback? onTotalTap;
  final VoidCallback? onPendingTap;
  final VoidCallback? onApprovedTap;
  final VoidCallback? onAmountTap;

  const DashboardStatsGrid({
    super.key,
    required this.totalBids,
    required this.pendingBids,
    required this.approvedBids,
    required this.totalAmount,
    this.isLoading = false,
    this.onTotalTap,
    this.onPendingTap,
    this.onApprovedTap,
    this.onAmountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total Bids',
                  value: totalBids.toString(),
                  icon: Icons.description_outlined,
                  color: AppColors.primary,
                  onTap: onTotalTap,
                  isLoading: isLoading,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: StatCard(
                  title: 'Pending',
                  value: pendingBids.toString(),
                  icon: Icons.hourglass_empty,
                  color: AppColors.warning,
                  onTap: onPendingTap,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Approved',
                  value: approvedBids.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  onTap: onApprovedTap,
                  isLoading: isLoading,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: StatCard(
                  title: 'Total Value',
                  value: Helpers.formatCurrency(totalAmount),
                  icon: Icons.attach_money,
                  color: AppColors.secondary,
                  onTap: onAmountTap,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Summary Card (for bid details)
class SummaryCard extends StatelessWidget {
  final String title;
  final List<SummaryItem> items;
  final Widget? footer;

  const SummaryCard({
    super.key,
    required this.title,
    required this.items,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),

          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: item.isBold
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: item.color ?? AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (footer != null) ...[
            Divider(height: 24.h, color: AppColors.border),
            footer!,
          ],
        ],
      ),
    );
  }
}

class SummaryItem {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const SummaryItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });
}
