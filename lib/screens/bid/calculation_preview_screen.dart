import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/bid_model.dart';
import '../../widgets/error_widget.dart';

class CalculationPreviewScreen extends StatelessWidget {
  const CalculationPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract BidModel from arguments
    final bid = ModalRoute.of(context)?.settings.arguments as BidModel?;

    if (bid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Calculations')),
        body: CustomErrorWidget.general(message: 'No bid data provided'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calculation Details'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Grand Total Card
            _buildGrandTotalCard(bid),

            SizedBox(height: 24.h),

            // Breakdown
            _buildBreakdownCard(bid),

            SizedBox(height: 24.h),

            // Stats
            _buildStatsRow(bid),
          ],
        ),
      ),
    );
  }

  Widget _buildGrandTotalCard(BidModel bid) {
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
                  Helpers.formatCurrency(bid.grandTotal),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Iconsax.calculator, size: 30.w, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(BidModel bid) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal', bid.subtotal, Iconsax.receipt_1),
          SizedBox(height: 16.h),
          _buildRow(
            'Total Discount',
            -bid.totalDiscount,
            Iconsax.discount_shape,
            isNegative: true,
          ),
          SizedBox(height: 16.h),
          _buildRow(
            'Total Tax',
            bid.totalTax,
            Iconsax.percentage_square,
            valueColor: AppColors.warning,
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(color: AppColors.border),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Total',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                Helpers.formatCurrency(bid.grandTotal),
                style: TextStyle(
                  fontSize: 20.sp,
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

  Widget _buildRow(
    String label,
    double value,
    IconData icon, {
    bool isNegative = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.w, color: AppColors.textSecondary),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          '${isNegative ? '-' : ''}${Helpers.formatCurrency(value.abs())}',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color:
                valueColor ??
                (isNegative ? AppColors.success : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BidModel bid) {
    return Row(
      children: [
        _buildStatItem('Items', '${bid.items.length}', AppColors.info),
        SizedBox(width: 12.w),
        _buildStatItem('Qty', '${bid.totalQuantity}', AppColors.secondary),
        SizedBox(width: 12.w),
        _buildStatItem(
          'Avg Tax',
          '${bid.averageTaxPercent.toStringAsFixed(1)}%',
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
