import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';

class DropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const DropdownItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });
}

class CustomDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final IconData? prefixIcon;
  final double? borderRadius;
  final Color? fillColor;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
    this.prefixIcon,
    this.borderRadius,
    this.fillColor,
    this.validator,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        FormField<T>(
          validator: widget.validator,
          initialValue: widget.value,
          builder: (FormFieldState<T> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: widget.enabled
                      ? () => _showBottomSheet(context, field)
                      : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      color: widget.enabled
                          ? (widget.fillColor ?? AppColors.grey50)
                          : AppColors.grey100,
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? 16.r,
                      ),
                      border: Border.all(
                        color: field.hasError
                            ? AppColors.error
                            : _isOpen
                            ? AppColors.primary
                            : AppColors.border,
                        width: _isOpen || field.hasError ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (widget.prefixIcon != null) ...[
                          Icon(
                            widget.prefixIcon,
                            size: 22.w,
                            color: AppColors.grey500,
                          ),
                          SizedBox(width: 12.w),
                        ],
                        Expanded(
                          child: Text(
                            _getSelectedLabel(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: widget.value != null
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Icon(
                          _isOpen ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                          size: 20.w,
                          color: AppColors.grey500,
                        ),
                      ],
                    ),
                  ),
                ),
                if (field.hasError || widget.errorText != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    widget.errorText ?? field.errorText ?? '',
                    style: TextStyle(fontSize: 12.sp, color: AppColors.error),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  String _getSelectedLabel() {
    if (widget.value == null) return widget.hint ?? 'Select an option';

    final selected = widget.items.firstWhere(
      (item) => item.value == widget.value,
      orElse: () =>
          DropdownItem<T>(value: widget.value as T, label: widget.hint ?? ''),
    );

    return selected.label;
  }

  void _showBottomSheet(BuildContext context, FormFieldState<T> field) {
    setState(() => _isOpen = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DropdownBottomSheet<T>(
        items: widget.items,
        selectedValue: widget.value,
        onSelected: (value) {
          widget.onChanged?.call(value);
          field.didChange(value);
          Navigator.pop(context);
        },
        title: widget.label ?? 'Select',
      ),
    ).whenComplete(() {
      setState(() => _isOpen = false);
    });
  }
}

class _DropdownBottomSheet<T> extends StatelessWidget {
  final List<DropdownItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T?> onSelected;
  final String title;

  const _DropdownBottomSheet({
    required this.items,
    this.selectedValue,
    required this.onSelected,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.close_circle,
                      size: 20.w,
                      color: AppColors.grey600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.border),

          // Items
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.value == selectedValue;

                return ListTile(
                  onTap: () => onSelected(item.value),
                  leading: item.icon != null
                      ? Icon(
                          item.icon,
                          size: 22.w,
                          color: item.iconColor ?? AppColors.grey600,
                        )
                      : null,
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Iconsax.tick_circle5,
                          size: 22.w,
                          color: AppColors.primary,
                        )
                      : null,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 4.h,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }
}

// Simple Inline Dropdown (Material Style)
class SimpleDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const SimpleDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: enabled ? AppColors.grey50 : AppColors.grey100,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              isExpanded: true,
              value: value,
              hint: Text(
                hint ?? 'Select',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textTertiary,
                ),
              ),
              icon: Icon(
                Iconsax.arrow_down_1,
                size: 20.w,
                color: AppColors.grey500,
              ),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              dropdownColor: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item.value,
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        Icon(item.icon, size: 20.w, color: item.iconColor),
                        SizedBox(width: 12.w),
                      ],
                      Text(item.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }
}
