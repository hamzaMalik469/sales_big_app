import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../config/app_colors.dart';

// Simple Loading Indicator
class LoadingWidget extends StatelessWidget {
  final double? size;
  final Color? color;
  final double strokeWidth;

  const LoadingWidget({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 40.w,
        height: size ?? 40.w,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// Full Screen Loading Overlay
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.4),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LoadingWidget(),
                    if (message != null) ...[
                      SizedBox(height: 16.h),
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
            ),
          ),
      ],
    );
  }
}

// Shimmer Loading Effect
class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder? shape;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape,
  });

  // Circle shimmer
  const ShimmerWidget.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 0,
        shape = const CircleBorder();

  // Rectangle shimmer
  const ShimmerWidget.rectangle({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  }) : shape = null;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: AppColors.grey200,
          shape: shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
        ),
      ),
    );
  }
}

// Shimmer List Item
class ShimmerListItem extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int lines;

  const ShimmerListItem({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.lines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          if (hasLeading) ...[
            ShimmerWidget.circle(size: 48.w),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(lines, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index < lines - 1 ? 8.h : 0),
                  child: ShimmerWidget.rectangle(
                    width: index == 0 ? double.infinity : 150.w,
                    height: 14.h,
                    borderRadius: 4,
                  ),
                );
              }),
            ),
          ),
          if (hasTrailing) ...[
            SizedBox(width: 12.w),
            ShimmerWidget.rectangle(
              width: 60.w,
              height: 28.h,
              borderRadius: 6,
            ),
          ],
        ],
      ),
    );
  }
}

// Shimmer Card
class ShimmerCard extends StatelessWidget {
  final double? height;

  const ShimmerCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerWidget.circle(size: 40.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerWidget.rectangle(width: 150.w, height: 14.h),
                    SizedBox(height: 6.h),
                    ShimmerWidget.rectangle(width: 100.w, height: 12.h),
                  ],
                ),
              ),
              ShimmerWidget.rectangle(width: 60.w, height: 24.h, borderRadius: 12),
            ],
          ),
          SizedBox(height: 16.h),
          ShimmerWidget.rectangle(width: double.infinity, height: 12.h),
          SizedBox(height: 8.h),
          ShimmerWidget.rectangle(width: 200.w, height: 12.h),
          if (height != null) ...[
            SizedBox(height: 16.h),
            ShimmerWidget.rectangle(
              width: double.infinity,
              height: height! - 120.h,
              borderRadius: 12,
            ),
          ],
        ],
      ),
    );
  }
}

// Shimmer Bid Card
class ShimmerBidCard extends StatelessWidget {
  const ShimmerBidCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget.rectangle(width: 160.w, height: 16.h),
              ShimmerWidget.rectangle(width: 70.w, height: 24.h, borderRadius: 12),
            ],
          ),
          SizedBox(height: 12.h),
          ShimmerWidget.rectangle(width: 120.w, height: 14.h),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget.rectangle(width: 80.w, height: 12.h),
                  SizedBox(height: 4.h),
                  ShimmerWidget.rectangle(width: 100.w, height: 20.h),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShimmerWidget.rectangle(width: 60.w, height: 12.h),
                  SizedBox(height: 4.h),
                  ShimmerWidget.rectangle(width: 80.w, height: 14.h),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Loading List
class LoadingList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int)? itemBuilder;

  const LoadingList({
    super.key,
    this.itemCount = 5,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: itemBuilder ?? (context, index) => const ShimmerListItem(),
    );
  }
}