import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';
import '../services/sync_service.dart';

class SyncIndicator extends StatelessWidget {
  final SyncStatus status;
  final VoidCallback? onTap;

  const SyncIndicator({super.key, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            SizedBox(width: 8.w),
            Text(
              _getText(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: _getTextColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (status.isSyncing) {
      return SizedBox(
        width: 14.w,
        height: 14.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    return Icon(_getIcon(), size: 16.w, color: _getTextColor());
  }

  IconData _getIcon() {
    switch (status.state) {
      case SyncState.idle:
        return Iconsax.cloud;
      case SyncState.syncing:
        return Iconsax.refresh;
      case SyncState.success:
        return Iconsax.tick_circle;
      case SyncState.error:
        return Iconsax.warning_2;
    }
  }

  String _getText() {
    switch (status.state) {
      case SyncState.idle:
        if (status.pendingItems > 0) {
          return '${status.pendingItems} pending';
        }
        return 'Synced';
      case SyncState.syncing:
        if (status.totalItems > 0) {
          return 'Syncing ${status.syncedItems}/${status.totalItems}';
        }
        return 'Syncing...';
      case SyncState.success:
        return 'Sync complete';
      case SyncState.error:
        return 'Sync failed';
    }
  }

  Color _getBackgroundColor() {
    switch (status.state) {
      case SyncState.idle:
        return status.pendingItems > 0
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1);
      case SyncState.syncing:
        return AppColors.info.withOpacity(0.1);
      case SyncState.success:
        return AppColors.success.withOpacity(0.1);
      case SyncState.error:
        return AppColors.error.withOpacity(0.1);
    }
  }

  Color _getTextColor() {
    switch (status.state) {
      case SyncState.idle:
        return status.pendingItems > 0 ? AppColors.warning : AppColors.success;
      case SyncState.syncing:
        return AppColors.info;
      case SyncState.success:
        return AppColors.success;
      case SyncState.error:
        return AppColors.error;
    }
  }
}

// Sync Progress Bar
class SyncProgressBar extends StatelessWidget {
  final SyncStatus status;

  const SyncProgressBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (!status.isSyncing) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.info,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Syncing data...',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.infoDark,
                ),
              ),
              const Spacer(),
              Text(
                '${status.syncedItems}/${status.totalItems}',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: status.progress,
              backgroundColor: AppColors.info.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.info),
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }
}

// Floating Sync Button
class FloatingSyncButton extends StatelessWidget {
  final int pendingCount;
  final bool isSyncing;
  final VoidCallback? onTap;

  const FloatingSyncButton({
    super.key,
    required this.pendingCount,
    this.isSyncing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0 && !isSyncing) return const SizedBox.shrink();

    return Positioned(
      bottom: 100.h,
      right: 16.w,
      child: GestureDetector(
        onTap: isSyncing ? null : onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSyncing ? AppColors.info : AppColors.warning,
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: (isSyncing ? AppColors.info : AppColors.warning)
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSyncing)
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              else
                Icon(Iconsax.cloud_add, size: 18.w, color: AppColors.white),
              SizedBox(width: 8.w),
              Text(
                isSyncing ? 'Syncing...' : '$pendingCount pending',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
