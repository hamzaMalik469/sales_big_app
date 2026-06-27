import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';
import '../core/utils/helpers.dart';
import '../models/bid_model.dart';
import 'status_chip.dart';

class BidCard extends StatelessWidget {
  final BidModel bid;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showSyncStatus;

  const BidCard({
    super.key,
    required this.bid,
    this.onTap,
    this.onLongPress,
    this.showSyncStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Avatar
                    Container(
                      width: 48.w,
                      height: 48.w,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          Helpers.getInitials(bid.projectName),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Title & Client
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bid.projectName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Iconsax.building,
                                size: 14.w,
                                color: AppColors.textTertiary,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  bid.clientName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // Status Chip
                    StatusChip(status: bid.status),
                  ],
                ),

                SizedBox(height: 16.h),

                // Divider
                Divider(height: 1, color: AppColors.border),

                SizedBox(height: 16.h),

                // Footer Row
                Row(
                  children: [
                    // Items Count
                    _buildInfoItem(
                      icon: Iconsax.box,
                      label: '${bid.totalItemsCount} items',
                    ),

                    SizedBox(width: 16.w),

                    // Date
                    _buildInfoItem(
                      icon: Iconsax.calendar,
                      label: Helpers.formatDate(bid.createdAt),
                    ),

                    const Spacer(),

                    // Total Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Helpers.formatCurrency(bid.grandTotal),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        if (showSyncStatus && !bid.isSynced) ...[
                          SizedBox(height: 4.h),
                          SyncStatusChip(isSynced: bid.isSynced, isSmall: true),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.w, color: AppColors.textTertiary),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// Compact Bid Card (for recent bids on dashboard)
class CompactBidCard extends StatelessWidget {
  final BidModel bid;
  final VoidCallback? onTap;

  const CompactBidCard({super.key, required this.bid, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Helpers.getStatusBgColor(bid.status),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Icon(
                      Helpers.getStatusIcon(bid.status),
                      size: 18.w,
                      color: Helpers.getStatusColor(bid.status),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid.projectName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        bid.clientName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Helpers.formatCurrency(bid.grandTotal),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      Helpers.getRelativeTime(bid.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 8.w),

                Icon(
                  Iconsax.arrow_right_3,
                  size: 18.w,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

