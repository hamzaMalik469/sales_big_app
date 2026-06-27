import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';

class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final String? message;
  final VoidCallback? onRetry;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isOffline ? null : 0,
      child: isOffline
          ? Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.warning,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Icon(
                      Iconsax.wifi_square,
                      size: 20.w,
                      color: AppColors.white,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        message ??
                            'You\'re offline. Data will sync when connected.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (onRetry != null) ...[
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: onRetry,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

// Offline Mode Indicator (smaller, for app bar)
class OfflineModeIndicator extends StatelessWidget {
  final bool isOffline;

  const OfflineModeIndicator({super.key, required this.isOffline});

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.wifi_square, size: 14.w, color: AppColors.warning),
          SizedBox(width: 4.w),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

// Connection Status Widget
class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final String? connectionType;
  final VoidCallback? onCheckConnection;

  const ConnectionStatusWidget({
    super.key,
    required this.isConnected,
    this.connectionType,
    this.onCheckConnection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isConnected ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isConnected
              ? AppColors.success.withOpacity(0.3)
              : AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isConnected
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConnected ? Iconsax.wifi : Iconsax.wifi_square,
              size: 22.w,
              color: isConnected ? AppColors.success : AppColors.warning,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Connected' : 'Offline Mode',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isConnected
                        ? AppColors.successDark
                        : AppColors.warningDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isConnected
                      ? connectionType ?? 'Internet connection available'
                      : 'Working with cached data',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isConnected ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          if (onCheckConnection != null)
            GestureDetector(
              onTap: onCheckConnection,
              child: Icon(
                Iconsax.refresh,
                size: 22.w,
                color: isConnected ? AppColors.success : AppColors.warning,
              ),
            ),
        ],
      ),
    );
  }
}
