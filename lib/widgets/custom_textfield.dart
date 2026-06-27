import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../config/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final bool showClearButton;
  final bool isPassword;
  final TextCapitalization textCapitalization;
  final String? initialValue;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.contentPadding,
    this.borderRadius,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.showClearButton = false,
    this.isPassword = false,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword || widget.obscureText;
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

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
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textTertiary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: true,
            fillColor: widget.enabled
                ? (widget.fillColor ?? AppColors.grey50)
                : AppColors.grey100,
            contentPadding:
                widget.contentPadding ??
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 22.w, color: AppColors.grey500)
                : widget.prefix,
            suffixIcon: _buildSuffixIcon(),
            border: _buildBorder(AppColors.border),
            enabledBorder: _buildBorder(widget.borderColor ?? AppColors.border),
            focusedBorder: _buildBorder(
              widget.focusedBorderColor ?? AppColors.primary,
              width: 2,
            ),
            errorBorder: _buildBorder(AppColors.error),
            focusedErrorBorder: _buildBorder(AppColors.error, width: 2),
            disabledBorder: _buildBorder(AppColors.grey200),
            hintStyle: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
            helperStyle: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
            errorStyle: TextStyle(fontSize: 12.sp, color: AppColors.error),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    final icons = <Widget>[];

    // Clear button
    if (widget.showClearButton && _hasText && widget.enabled) {
      icons.add(
        GestureDetector(
          onTap: _clearText,
          child: Icon(
            Iconsax.close_circle5,
            size: 20.w,
            color: AppColors.grey400,
          ),
        ),
      );
    }

    // Password toggle
    if (widget.isPassword) {
      icons.add(
        GestureDetector(
          onTap: _togglePasswordVisibility,
          child: Icon(
            _obscureText ? Iconsax.eye_slash : Iconsax.eye,
            size: 22.w,
            color: AppColors.grey500,
          ),
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      icons.add(
        GestureDetector(
          onTap: widget.onSuffixTap,
          child: Icon(widget.suffixIcon, size: 22.w, color: AppColors.grey500),
        ),
      );
    }

    // Custom suffix widget
    if (widget.suffix != null) {
      icons.add(widget.suffix!);
    }

    if (icons.isEmpty) return null;

    if (icons.length == 1) {
      return Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: icons.first,
      );
    }

    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: icons.map((icon) {
          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: icon,
          );
        }).toList(),
      ),
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 16.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

// Search Text Field
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;

  const SearchTextField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      focusNode: focusNode,
      hint: hint ?? 'Search...',
      prefixIcon: Iconsax.search_normal,
      showClearButton: true,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      borderRadius: 12.r,
      fillColor: AppColors.grey100,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    );
  }
}

// OTP Text Field
class OTPTextField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  const OTPTextField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<OTPTextField> createState() => _OTPTextFieldState();
}

class _OTPTextFieldState extends State<OTPTextField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    widget.onChanged?.call(_otp);

    if (_otp.length == widget.length) {
      widget.onCompleted?.call(_otp);
    }
  }

  void _onKeyDown(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 50.w,
          height: 56.h,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => _onKeyDown(index, event),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.grey50,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _onChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}
