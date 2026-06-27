import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';

enum ButtonType { primary, secondary, outlined, text, danger }

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final IconData? suffixIcon;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final bool expanded;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.suffixIcon,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? (width ?? double.infinity) : width,
      height: height ?? _getHeight(),
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    final isEnabled = !isDisabled && !isLoading && onPressed != null;

    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(isEnabled);
      case ButtonType.secondary:
        return _buildSecondaryButton(isEnabled);
      case ButtonType.outlined:
        return _buildOutlinedButton(isEnabled);
      case ButtonType.text:
        return _buildTextButton(isEnabled);
      case ButtonType.danger:
        return _buildDangerButton(isEnabled);
    }
  }

  Widget _buildElevatedButton(bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? AppColors.white,
        disabledBackgroundColor: AppColors.grey300,
        disabledForegroundColor: AppColors.grey500,
        elevation: 0,
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        ),
      ),
      child: _buildButtonContent(textColor ?? AppColors.white),
    );
  }

  Widget _buildSecondaryButton(bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primarySurface,
        foregroundColor: textColor ?? AppColors.primary,
        disabledBackgroundColor: AppColors.grey100,
        disabledForegroundColor: AppColors.grey400,
        elevation: 0,
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        ),
      ),
      child: _buildButtonContent(textColor ?? AppColors.primary),
    );
  }

  Widget _buildOutlinedButton(bool isEnabled) {
    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        disabledForegroundColor: AppColors.grey400,
        padding: padding ?? _getPadding(),
        side: BorderSide(
          color: isEnabled
              ? (borderColor ?? AppColors.primary)
              : AppColors.grey300,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        ),
      ),
      child: _buildButtonContent(
        isEnabled ? (textColor ?? AppColors.primary) : AppColors.grey400,
      ),
    );
  }

  Widget _buildTextButton(bool isEnabled) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        disabledForegroundColor: AppColors.grey400,
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        ),
      ),
      child: _buildButtonContent(
        isEnabled ? (textColor ?? AppColors.primary) : AppColors.grey400,
      ),
    );
  }

  Widget _buildDangerButton(bool isEnabled) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.error,
        foregroundColor: textColor ?? AppColors.white,
        disabledBackgroundColor: AppColors.grey300,
        disabledForegroundColor: AppColors.grey500,
        elevation: 0,
        padding: padding ?? _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        ),
      ),
      child: _buildButtonContent(textColor ?? AppColors.white),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 24.w,
        height: 24.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: _getIconSize(), color: color),
          SizedBox(width: 8.w),
        ],
        Text(
          text,
          style:
              textStyle ??
              TextStyle(
                fontSize: _getFontSize(),
                fontWeight: FontWeight.w600,
                color: color,
              ),
        ),
        if (suffixIcon != null) ...[
          SizedBox(width: 8.w),
          Icon(suffixIcon, size: _getIconSize(), color: color),
        ],
      ],
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40.h;
      case ButtonSize.medium:
        return 52.h;
      case ButtonSize.large:
        return 60.h;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
      case ButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h);
      case ButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 32.w, vertical: 18.h);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 13.sp;
      case ButtonSize.medium:
        return 15.sp;
      case ButtonSize.large:
        return 17.sp;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.w;
      case ButtonSize.medium:
        return 20.w;
      case ButtonSize.large:
        return 24.w;
    }
  }
}

// Icon Button Widget
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final double? iconSize;
  final double? borderRadius;
  final bool isLoading;
  final String? tooltip;
  final bool hasBorder;
  final Color? borderColor;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.iconSize,
    this.borderRadius,
    this.isLoading = false,
    this.tooltip,
    this.hasBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size ?? 48.w,
      height: size ?? 48.w,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.grey100,
        borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        border: hasBorder
            ? Border.all(color: borderColor ?? AppColors.border, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: (iconSize ?? 22.w) - 2,
                    height: (iconSize ?? 22.w) - 2,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        iconColor ?? AppColors.textSecondary,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    size: iconSize ?? 22.w,
                    color: iconColor ?? AppColors.textSecondary,
                  ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}

// Floating Action Button
class CustomFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;
  final bool isExtended;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;

  const CustomFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.label,
    this.isExtended = false,
    this.isLoading = false,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: isLoading ? null : onPressed,
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: iconColor ?? AppColors.white,
        elevation: 4,
        icon: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    iconColor ?? AppColors.white,
                  ),
                ),
              )
            : Icon(icon, size: 22.w),
        label: Text(
          label!,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: iconColor ?? AppColors.white,
      elevation: 4,
      child: isLoading
          ? SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  iconColor ?? AppColors.white,
                ),
              ),
            )
          : Icon(icon, size: 26.w),
    );
  }
}
