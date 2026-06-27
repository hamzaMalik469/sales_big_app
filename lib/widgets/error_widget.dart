import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showButton;
  final Color? iconColor;
  final double? iconSize;

  const CustomErrorWidget({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.buttonText,
    this.onRetry,
    this.showButton = true,
    this.iconColor,
    this.iconSize,
  });

  // Network Error
  factory CustomErrorWidget.network({VoidCallback? onRetry}) {
    return CustomErrorWidget(
      icon: Iconsax.wifi_square,
      title: 'No Internet Connection',
      message: 'Please check your network connection and try again.',
      buttonText: 'Try Again',
      onRetry: onRetry,
    );
  }

  // Server Error
  factory CustomErrorWidget.server({VoidCallback? onRetry}) {
    return CustomErrorWidget(
      icon: Iconsax.cloud_cross,
      title: 'Server Error',
      message: 'Something went wrong on our end. Please try again later.',
      buttonText: 'Retry',
      onRetry: onRetry,
    );
  }

  // General Error
  factory CustomErrorWidget.general({String? message, VoidCallback? onRetry}) {
    return CustomErrorWidget(
      icon: Iconsax.warning_2,
      title: 'Oops! Something Went Wrong',
      message: message ?? 'An unexpected error occurred. Please try again.',
      buttonText: 'Try Again',
      onRetry: onRetry,
    );
  }

  // Not Found Error
  factory CustomErrorWidget.notFound({
    String? message,
    VoidCallback? onAction,
    String? buttonText,
  }) {
    return CustomErrorWidget(
      icon: Iconsax.document_1,
      title: 'Not Found',
      message: message ?? 'The requested item could not be found.',
      buttonText: buttonText ?? 'Go Back',
      onRetry: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.error).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Iconsax.warning_2,
                size: iconSize ?? 48.w,
                color: iconColor ?? AppColors.error,
              ),
            ),

            SizedBox(height: 24.h),

            // Title
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

            if (message != null) ...[
              SizedBox(height: 12.h),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (showButton && onRetry != null) ...[
              SizedBox(height: 32.h),
              CustomButton(
                text: buttonText ?? 'Retry',
                onPressed: onRetry,
                type: ButtonType.primary,
                size: ButtonSize.medium,
                icon: Iconsax.refresh,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Inline Error Widget (smaller)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.warning_2, size: 22.w, color: AppColors.error),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: AppColors.errorDark),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Iconsax.refresh,
                  size: 18.w,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Snackbar Error
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Iconsax.warning_2, color: AppColors.white, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(16.w),
      duration: const Duration(seconds: 4),
    ),
  );
}

// Snackbar Success
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Iconsax.tick_circle, color: AppColors.white, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(16.w),
      duration: const Duration(seconds: 3),
    ),
  );
}

// Snackbar Info
void showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Iconsax.info_circle, color: AppColors.white, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
      backgroundColor: AppColors.info,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(16.w),
      duration: const Duration(seconds: 3),
    ),
  );
}
