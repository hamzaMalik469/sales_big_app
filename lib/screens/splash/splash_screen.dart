import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/app_colors.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../core/di/service_locator.dart';
import 'splash_cubit.dart';
import 'splash_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>()..initialize(),
      child: const SplashView(),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else if (state.isUnauthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
                Color(0xFF1E3A5F),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo Section
                _buildLogoSection(),

                const Spacer(flex: 2),

                // Loading Section
                _buildLoadingSection(),

                SizedBox(height: 48.h),

                // Version Info
                _buildVersionInfo(),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Container
        Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(32.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.description_outlined,
                  size: 56.w,
                  color: AppColors.primary,
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .scale(
              begin: const Offset(0.5, 0.5),
              curve: Curves.elasticOut,
              duration: 800.ms,
            ),

        SizedBox(height: 32.h),

        // App Name
        Text(
              'Bid Management',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: 0.5,
              ),
            )
            .animate()
            .fadeIn(delay: 300.ms, duration: 600.ms)
            .slideY(begin: 0.3, curve: Curves.easeOut),

        SizedBox(height: 8.h),

        // Tagline
        Text(
              'Streamline Your Sales Process',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.white.withOpacity(0.8),
              ),
            )
            .animate()
            .fadeIn(delay: 500.ms, duration: 600.ms)
            .slideY(begin: 0.3, curve: Curves.easeOut),
      ],
    );
  }

  Widget _buildLoadingSection() {
    return BlocBuilder<SplashCubit, SplashState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Indicator
            SizedBox(
              width: 200.w,
              child: Column(
                children: [
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: LinearProgressIndicator(
                      value: state.loadingProgress,
                      backgroundColor: AppColors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                      minHeight: 6.h,
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                  SizedBox(height: 16.h),

                  // Loading Text
                  Text(
                    _getLoadingText(state.loadingProgress),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withOpacity(0.7),
                    ),
                  ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getLoadingText(double progress) {
    if (progress < 0.3) return 'Initializing...';
    if (progress < 0.6) return 'Checking authentication...';
    if (progress < 0.9) return 'Loading your data...';
    return 'Almost ready...';
  }

  Widget _buildVersionInfo() {
    return Column(
      children: [
        Text(
          'Version ${AppConstants.appVersion}',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.white.withOpacity(0.5),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '© 2025 Bid Management',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.white.withOpacity(0.4),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1000.ms, duration: 600.ms);
  }
}
