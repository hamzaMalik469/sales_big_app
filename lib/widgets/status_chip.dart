import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool showIcon;
  final bool isSmall;

  const StatusChip({
    super.key,
    required this.status,
    this.showIcon = true,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8.w : 12.w,
        vertical: isSmall ? 4.h : 6.h,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(isSmall ? 6.r : 8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getIcon(),
              size: isSmall ? 12.w : 14.w,
              color: _getTextColor(),
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            _getDisplayText(),
            style: TextStyle(
              fontSize: isSmall ? 10.sp : 12.sp,
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText() {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.statusDraftBg;
      case 'pending':
        return AppColors.statusPendingBg;
      case 'approved':
        return AppColors.statusApprovedBg;
      case 'rejected':
        return AppColors.statusRejectedBg;
      default:
        return AppColors.grey100;
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.statusDraft;
      case 'pending':
        return AppColors.statusPending;
      case 'approved':
        return AppColors.statusApproved;
      case 'rejected':
        return AppColors.statusRejected;
      default:
        return AppColors.grey600;
    }
  }

  IconData _getIcon() {
    switch (status.toLowerCase()) {
      case 'draft':
        return Iconsax.edit;
      case 'pending':
        return Iconsax.clock;
      case 'approved':
        return Iconsax.tick_circle;
      case 'rejected':
        return Iconsax.close_circle;
      default:
        return Iconsax.information;
    }
  }
}

// Sync Status Chip
class SyncStatusChip extends StatelessWidget {
  final bool isSynced;
  final bool isSmall;

  const SyncStatusChip({
    super.key,
    required this.isSynced,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6.w : 10.w,
        vertical: isSmall ? 3.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: isSynced
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmall ? 4.r : 6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSynced ? Iconsax.tick_circle : Iconsax.cloud_cross,
            size: isSmall ? 10.w : 12.w,
            color: isSynced ? AppColors.success : AppColors.warning,
          ),
          SizedBox(width: 4.w),
          Text(
            isSynced ? 'Synced' : 'Pending',
            style: TextStyle(
              fontSize: isSmall ? 9.sp : 11.sp,
              fontWeight: FontWeight.w500,
              color: isSynced ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Tag Chip
class TagChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool isSelected;

  const TagChip({
    super.key,
    required this.label,
    this.color,
    this.onTap,
    this.onRemove,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: chipColor.withOpacity(isSelected ? 1 : 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.white : chipColor,
              ),
            ),
            if (onRemove != null) ...[
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Iconsax.close_circle5,
                  size: 16.w,
                  color: isSelected ? AppColors.white : chipColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Filter Chip Group
class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  final bool allowDeselect;

  const FilterChipGroup({
    super.key,
    required this.options,
    this.selected,
    required this.onSelected,
    this.allowDeselect = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selected;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () {
                if (allowDeselect && isSelected) {
                  onSelected(null);
                } else {
                  onSelected(option);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
