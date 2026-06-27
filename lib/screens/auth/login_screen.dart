import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../core/di/service_locator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/error_widget.dart';
import 'login_cubit.dart';
import 'login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else if (state.isFailure && state.errorMessage != null) {
          showErrorSnackBar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),

                    // Header Section
                    _buildHeader(),

                    SizedBox(height: 48.h),

                    // Form Section
                    _buildForm(context, state),

                    SizedBox(height: 24.h),

                    // Remember Me & Forgot Password
                    _buildRememberForgot(context, state),

                    SizedBox(height: 32.h),

                    // Login Button
                    _buildLoginButton(context, state),

                    SizedBox(height: 32.h),

                    // Divider
                    _buildDivider(),

                    SizedBox(height: 32.h),

                    // Social Login
                    _buildSocialLogin(),

                    SizedBox(height: 32.h),

                    // Sign Up Link
                    _buildSignUpLink(),

                    SizedBox(height: 24.h),
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
        // Logo
        Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.description_outlined,
                size: 32.w,
                color: AppColors.white,
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, curve: Curves.easeOut),

        SizedBox(height: 32.h),

        // Welcome Text
        Text(
              'Welcome Back! 👋',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideX(begin: -0.2, curve: Curves.easeOut),

        SizedBox(height: 8.h),

        Text(
              'Sign in to continue managing your bids',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            )
            .animate()
            .fadeIn(delay: 300.ms, duration: 500.ms)
            .slideX(begin: -0.2, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildForm(BuildContext context, LoginState state) {
    final cubit = context.read<LoginCubit>();

    return Column(
      children: [
        // Email Field
        CustomTextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              label: 'Email Address',
              hint: 'Enter your email',
              prefixIcon: Iconsax.sms,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: state.emailError,
              onChanged: cubit.emailChanged,
              onSubmitted: (_) => _passwordFocusNode.requestFocus(),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 500.ms)
            .slideY(begin: 0.2, curve: Curves.easeOut),

        SizedBox(height: 20.h),

        // Password Field
        CustomTextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              label: 'Password',
              hint: 'Enter your password',
              prefixIcon: Iconsax.lock,
              isPassword: true,
              textInputAction: TextInputAction.done,
              errorText: state.passwordError,
              onChanged: cubit.passwordChanged,
              onSubmitted: (_) => cubit.login(),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 500.ms)
            .slideY(begin: 0.2, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildRememberForgot(BuildContext context, LoginState state) {
    final cubit = context.read<LoginCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember Me
        GestureDetector(
          onTap: cubit.toggleRememberMe,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: state.rememberMe
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: state.rememberMe
                        ? AppColors.primary
                        : AppColors.grey400,
                    width: 2,
                  ),
                ),
                child: state.rememberMe
                    ? Icon(Icons.check, size: 14.w, color: AppColors.white)
                    : null,
              ),
              SizedBox(width: 10.w),
              Text(
                'Remember me',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Forgot Password
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.forgotPassword);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 500.ms);
  }

  Widget _buildLoginButton(BuildContext context, LoginState state) {
    return CustomButton(
          text: 'Sign In',
          onPressed: state.canSubmit
              ? () => context.read<LoginCubit>().login()
              : null,
          isLoading: state.isLoading,
          icon: Iconsax.login,
        )
        .animate()
        .fadeIn(delay: 700.ms, duration: 500.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.grey300, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'Or continue with',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.grey300, thickness: 1)),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms);
  }

  Widget _buildSocialLogin() {
    return Row(
          children: [
            // Google
            Expanded(
              child: _SocialButton(
                icon: 'G',
                label: 'Google',
                onTap: () {
                  // TODO: Implement Google Sign In
                  showInfoSnackBar(context, 'Google Sign In coming soon!');
                },
              ),
            ),
            SizedBox(width: 16.w),
            // Apple (Optional)
            Expanded(
              child: _SocialButton(
                icon: '',
                iconWidget: Icon(
                  Icons.apple,
                  size: 24.w,
                  color: AppColors.textPrimary,
                ),
                label: 'Apple',
                onTap: () {
                  // TODO: Implement Apple Sign In
                  showInfoSnackBar(context, 'Apple Sign In coming soon!');
                },
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 900.ms, duration: 500.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }

  Widget _buildSignUpLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // TODO: Navigate to Sign Up
                  showInfoSnackBar(context, 'Sign Up coming soon!');
                },
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms, duration: 500.ms);
  }
}

// Social Button Widget
class _SocialButton extends StatelessWidget {
  final String icon;
  final Widget? iconWidget;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    this.iconWidget,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconWidget != null)
              iconWidget!
            else
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
