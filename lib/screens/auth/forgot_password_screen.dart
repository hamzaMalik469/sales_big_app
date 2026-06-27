import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/error_widget.dart';
import 'forgot_password_cubit.dart';
import 'forgot_password_state.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ForgotPasswordCubit>(),
      child: const ForgotPasswordView(),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.isSuccess) {
          _showSuccessDialog(context, state.successMessage ?? '');
        } else if (state.isFailure && state.errorMessage != null) {
          showErrorSnackBar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Iconsax.arrow_left,
                  size: 20.w,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),

                    // Header
                    _buildHeader(),

                    SizedBox(height: 48.h),

                    // Illustration
                    _buildIllustration(),

                    SizedBox(height: 48.h),

                    // Form
                    _buildForm(context, state),

                    SizedBox(height: 32.h),

                    // Submit Button
                    _buildSubmitButton(context, state),

                    SizedBox(height: 24.h),

                    // Back to Login
                    _buildBackToLogin(context),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Forgot Password? 🔐',
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, curve: Curves.easeOut),

        SizedBox(height: 12.h),

        Text(
              "Don't worry! It happens. Please enter the email address associated with your account.",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            )
            .animate()
            .fadeIn(delay: 100.ms, duration: 500.ms)
            .slideX(begin: -0.2, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildIllustration() {
    return Center(
      child:
          Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.secondary.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Inner ring
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),

                    // Icon
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.sms,
                        size: 32.w,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOut),
    );
  }

  Widget _buildForm(BuildContext context, ForgotPasswordState state) {
    return CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'Enter your email',
          prefixIcon: Iconsax.sms,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: state.emailError,
          onChanged: context.read<ForgotPasswordCubit>().emailChanged,
          onSubmitted: (_) {
            if (state.canSubmit) {
              context.read<ForgotPasswordCubit>().submit();
            }
          },
        )
        .animate()
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildSubmitButton(BuildContext context, ForgotPasswordState state) {
    return CustomButton(
          text: 'Send Reset Link',
          onPressed: state.canSubmit
              ? () => context.read<ForgotPasswordCubit>().submit()
              : null,
          isLoading: state.isLoading,
          icon: Iconsax.send_2,
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildBackToLogin(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Iconsax.arrow_left, size: 18.w, color: AppColors.primary),
        label: Text(
          'Back to Login',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 500.ms);
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SuccessDialog(
        message: message,
        onPressed: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Go back to login
        },
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final String message;
  final VoidCallback onPressed;

  const _SuccessDialog({required this.message, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: AppColors.successGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Iconsax.tick_circle,
                size: 40.w,
                color: AppColors.white,
              ),
            ).animate().scale(
              begin: const Offset(0, 0),
              curve: Curves.elasticOut,
              duration: 600.ms,
            ),

            SizedBox(height: 24.h),

            // Title
            Text(
              'Email Sent!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            SizedBox(height: 12.h),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

            SizedBox(height: 32.h),

            // Button
            CustomButton(
                  text: 'Back to Login',
                  onPressed: onPressed,
                  icon: Iconsax.login,
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
