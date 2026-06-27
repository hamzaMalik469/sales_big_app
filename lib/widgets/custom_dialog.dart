import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';
import 'custom_button.dart';

class CustomDialog {
  // Confirmation Dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDanger = false,
    IconData? icon,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDanger: isDanger,
        icon: icon,
      ),
    );
  }

  // Delete Confirmation
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    String? itemName,
  }) async {
    return showConfirmation(
      context: context,
      title: 'Delete ${itemName ?? 'Item'}?',
      message:
          'This action cannot be undone. Are you sure you want to delete ${itemName != null ? '"$itemName"' : 'this item'}?',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDanger: true,
      icon: Iconsax.trash,
    );
  }

  // Logout Confirmation
  static Future<bool?> showLogoutConfirmation(BuildContext context) async {
    return showConfirmation(
      context: context,
      title: 'Logout?',
      message:
          'Are you sure you want to logout? Any unsaved changes will be lost.',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      isDanger: true,
      icon: Iconsax.logout,
    );
  }

  // Success Dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        type: _AlertType.success,
        onPressed: () {
          Navigator.pop(context);
          onPressed?.call();
        },
      ),
    );
  }

  // Error Dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        type: _AlertType.error,
        onPressed: () {
          Navigator.pop(context);
          onPressed?.call();
        },
      ),
    );
  }

  // Info Dialog
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _AlertDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        type: _AlertType.info,
        onPressed: () {
          Navigator.pop(context);
          onPressed?.call();
        },
      ),
    );
  }

  // Loading Dialog
  static void showLoading(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LoadingDialog(message: message),
    );
  }

  // Hide Loading
  static void hideLoading(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

// Confirmation Dialog Widget
class _ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDanger;
  final IconData? icon;

  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.isDanger = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: (isDanger ? AppColors.error : AppColors.primary)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ??
                    (isDanger ? Iconsax.warning_2 : Iconsax.message_question),
                size: 32.w,
                color: isDanger ? AppColors.error : AppColors.primary,
              ),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12.h),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 28.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: cancelText,
                    onPressed: () => Navigator.pop(context, false),
                    type: ButtonType.outlined,
                    size: ButtonSize.medium,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: CustomButton(
                    text: confirmText,
                    onPressed: () => Navigator.pop(context, true),
                    type: isDanger ? ButtonType.danger : ButtonType.primary,
                    size: ButtonSize.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Alert Type
enum _AlertType { success, error, info }

// Alert Dialog Widget
class _AlertDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String buttonText;
  final _AlertType type;
  final VoidCallback onPressed;

  const _AlertDialog({
    required this.title,
    this.message,
    required this.buttonText,
    required this.type,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: _getColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(), size: 36.w, color: _getColor()),
            ),

            SizedBox(height: 20.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
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
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            SizedBox(height: 28.h),

            // Button
            CustomButton(
              text: buttonText,
              onPressed: onPressed,
              type: ButtonType.primary,
              size: ButtonSize.medium,
              backgroundColor: _getColor(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case _AlertType.success:
        return AppColors.success;
      case _AlertType.error:
        return AppColors.error;
      case _AlertType.info:
        return AppColors.info;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case _AlertType.success:
        return Iconsax.tick_circle;
      case _AlertType.error:
        return Iconsax.close_circle;
      case _AlertType.info:
        return Iconsax.info_circle;
    }
  }
}

// Loading Dialog Widget
class _LoadingDialog extends StatelessWidget {
  final String? message;

  const _LoadingDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48.w,
              height: 48.w,
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            if (message != null) ...[
              SizedBox(height: 20.h),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
