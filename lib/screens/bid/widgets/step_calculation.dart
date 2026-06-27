import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../create_bid_cubit.dart';
import '../create_bid_state.dart';

class StepCalculation extends StatelessWidget {
  const StepCalculation({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateBidCubit, CreateBidState>(
      builder: (context, state) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),

              SizedBox(height: 24.h),

              // Items Breakdown
              _buildItemsBreakdown(state),

              SizedBox(height: 24.h),

              // Calculation Summary
              _buildCalculationSummary(state),

              SizedBox(height: 24.h),

              // Grand Total Card
              _buildGrandTotalCard(state),

              SizedBox(height: 24.h),

              // Stats Row
              _buildStatsRow(state),

              SizedBox(height: 100.h), // Space for bottom button
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(Iconsax.calculator, size: 24.w, color: AppColors.success),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calculation Preview',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Review auto-calculated totals',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsBreakdown(CreateBidState state) {
    return Container(
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
              Icon(Iconsax.box, size: 18.w, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                'Items Breakdown',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '${state.items.length} items',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Items list
          ...state.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                border: index < state.items.length - 1
                    ? Border(bottom: BorderSide(color: AppColors.border))
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${item.quantity} × ${Helpers.formatCurrency(item.unitPrice)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Helpers.formatCurrency(item.total),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCalculationSummary(CreateBidState state) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildCalcRow(
            label: 'Subtotal',
            value: state.subtotal,
            icon: Iconsax.receipt_1,
          ),
          SizedBox(height: 12.h),
          _buildCalcRow(
            label: 'Total Discount',
            value: -state.totalDiscount,
            icon: Iconsax.discount_shape,
            isNegative: state.totalDiscount > 0,
            valueColor: state.totalDiscount > 0 ? AppColors.success : null,
          ),
          SizedBox(height: 12.h),
          _buildCalcRow(
            label: 'Total Tax',
            value: state.totalTax,
            icon: Iconsax.percentage_square,
            valueColor: AppColors.warning,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(color: AppColors.border),
          ),
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Iconsax.money_recive,
                  size: 18.w,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Net Total',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                Helpers.formatCurrency(state.grandTotal),
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalcRow({
    required String label,
    required double value,
    required IconData icon,
    bool isNegative = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: AppColors.grey100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.w, color: AppColors.grey600),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ),
        Text(
          '${isNegative ? '-' : ''}${Helpers.formatCurrency(value.abs())}',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildGrandTotalCard(CreateBidState state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grand Total',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  Helpers.formatCurrency(state.grandTotal),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Iconsax.tick_circle,
                      size: 14.w,
                      color: AppColors.white.withOpacity(0.7),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Auto-calculated',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Icon(Iconsax.calculator, size: 40.w, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(CreateBidState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Iconsax.box,
            label: 'Items',
            value: '${state.items.length}',
            color: AppColors.info,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            icon: Iconsax.shopping_cart,
            label: 'Quantity',
            value: '${state.totalQuantity}',
            color: AppColors.secondary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            icon: Iconsax.discount_shape,
            label: 'Discount',
            value: '${state.averageDiscountPercent.toStringAsFixed(1)}%',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.w, color: color),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
