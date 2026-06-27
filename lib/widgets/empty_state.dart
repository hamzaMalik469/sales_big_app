import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';
import 'custom_button.dart';

class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onAction;
  final bool showButton;
  final Color? iconColor;
  final Widget? customIcon;
  final double? iconSize;

  const EmptyState({
    super.key,
    this.icon,
    this.title,
    this.message,
    this.buttonText,
    this.onAction,
    this.showButton = true,
    this.iconColor,
    this.customIcon,
    this.iconSize,
  });

  // Empty Bids
  factory EmptyState.bids({
    VoidCallback? onCreateBid,
  }) {
    return EmptyState(
      icon: Iconsax.document_text,
      title: 'No Bids Yet',
      message: 'Start by creating your first bid to manage your sales.',
      buttonText: 'Create New Bid',
      onAction: onCreateBid,
    );
  }

  // Empty Search Results
  factory EmptyState.search({
    String? searchTerm,
    VoidCallback? onClear,
  }) {
    return EmptyState(
      icon: Iconsax.search_normal,
      title: 'No Results Found',
      message: searchTerm != null
          ? 'No results found for "$searchTerm". Try a different search term.'
          : 'No results found. Try a different search term.',
      buttonText: 'Clear Search',
      onAction: onClear,
    );
  }

  // Empty Offline
  factory EmptyState.offline({
    VoidCallback? onRefresh,
  }) {
    return EmptyState(
      icon: Iconsax.cloud_cross,
      title: 'No Offline Data',
      message: 'All your data is synced! There are no pending offline entries.',
      showButton: false,
      iconColor: AppColors.success,
    );
  }

  // Empty Notifications
  factory EmptyState.notifications() {
    return const EmptyState(
      icon: Iconsax.notification,
      title: 'No Notifications',
      message: 'You\'re all caught up! No new notifications.',
      showButton: false,
    );
  }

  // Custom Empty
  factory EmptyState.custom({
    required IconData icon,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onAction,
    Color? iconColor,
  }) {
    return EmptyState(
      icon: icon,
      title: title,
      message: message,
      buttonText: buttonText,
      onAction: onAction,
      showButton: onAction != null,
      iconColor: iconColor,
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
            // Icon or Custom Widget
            if (customIcon != null)
              customIcon!
            else
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Iconsax.document,
                  size: iconSize ?? 56.w,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
            
            SizedBox(height: 28.h),
            
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
            
            // Message
            if (message != null) ...[
              SizedBox(height: 12.h),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Action Button
            if (showButton && onAction != null && buttonText != null) ...[
              SizedBox(height: 32.h),
              CustomButton(
                text: buttonText!,
                onPressed: onAction,
                type: ButtonType.primary,
                size: ButtonSize.medium,
                expanded: false,
                icon: _getButtonIcon(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData? _getButtonIcon() {
    if (buttonText?.toLowerCase().contains('create') ?? false) {
      return Iconsax.add;
    }
    if (buttonText?.toLowerCase().contains('search') ?? false) {
      return Iconsax.search_normal;
    }
    if (buttonText?.toLowerCase().contains('clear') ?? false) {
      return Iconsax.close_circle;
    }
    if (buttonText?.toLowerCase().contains('refresh') ?? false) {
      return Iconsax.refresh;
    }
    return null;
  }
}

// Compact Empty State (for inline use)
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onAction;
  final String? actionText;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48.w,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionText != null) ...[
            SizedBox(height: 16.h),
            TextButton(
              onPressed: onAction,
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}