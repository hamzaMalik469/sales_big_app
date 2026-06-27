import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../create_bid_state.dart';

class StepIndicator extends StatelessWidget {
  final CreateBidStep currentStep;
  final Function(CreateBidStep)? onStepTap;
  final bool canTapPreviousSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.onStepTap,
    this.canTapPreviousSteps = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: CreateBidStep.values.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isActive = step == currentStep;
          final isCompleted = step.index < currentStep.index;
          final isLast = index == CreateBidStep.values.length - 1;

          return Expanded(
            child: Row(
              children: [
                // Step Circle & Label
                Expanded(
                  child: GestureDetector(
                    onTap:
                        (canTapPreviousSteps &&
                            isCompleted &&
                            onStepTap != null)
                        ? () => onStepTap!(step)
                        : null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : isCompleted
                                ? AppColors.success
                                : AppColors.grey200,
                            shape: BoxShape.circle,
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(
                                    Icons.check,
                                    size: 16.w,
                                    color: AppColors.white,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? AppColors.white
                                          : AppColors.grey500,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Label
                        Text(
                          _getStepLabel(step),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isActive
                                ? AppColors.primary
                                : isCompleted
                                ? AppColors.success
                                : AppColors.grey500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),

                // Connector Line
                if (!isLast)
                  Container(
                    width: 20.w,
                    height: 2.h,
                    margin: EdgeInsets.only(bottom: 18.h),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.grey200,
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getStepLabel(CreateBidStep step) {
    switch (step) {
      case CreateBidStep.basicInfo:
        return 'Info';
      case CreateBidStep.addItems:
        return 'Items';
      case CreateBidStep.calculation:
        return 'Calculate';
      case CreateBidStep.review:
        return 'Review';
    }
  }
}
